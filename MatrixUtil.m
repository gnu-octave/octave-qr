##
## Copyright 2008 ZXing authors
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

## Author satorux@google.com (Satoru Takabayashi) - creator
## Author dswitkin@google.com (Daniel Switkin) - ported from C++

## Build 2D matrix of QR Code from "dataBits" with "ecLevelBits", "version" and
## "getMaskPattern".  On success, store the result in "matrix" and return true.
function matrix = MatrixUtil (dataBits, ecLevelBits, version, maskPattern, dimension)
  matrix = -ones (dimension);
  matrix = embedBasicPatterns (version, matrix);
  ## Type information appear with any version.
  matrix = embedTypeInfo (ecLevelBits, maskPattern, matrix);
  ## Version info appear if version >= 7.
  matrix = maybeEmbedVersionInfo (version, matrix);
  ## Data should be embedded at end.
  matrix = embedDataBits (dataBits, maskPattern, matrix);
endfunction


## Embed basic patterns. On success, modify the matrix and return true.
## The basic patterns are:
## - Position detection patterns
## - Timing patterns
## - Dark dot at the left bottom corner
## - Position adjustment patterns, if need be
function matrix = embedBasicPatterns (ver, matrix)
  ## Embed position detection patterns (the three big squares at corners) and
  ## surrounding vertical/horizontal separators.
  POSITION_DETECTION_PATTERN = [...
    1, 1, 1, 1, 1, 1, 1;
    1, 0, 0, 0, 0, 0, 1;
    1, 0, 1, 1, 1, 0, 1;
    1, 0, 1, 1, 1, 0, 1;
    1, 0, 1, 1, 1, 0, 1;
    1, 0, 0, 0, 0, 0, 1;
    1, 1, 1, 1, 1, 1, 1];
  ## Left top corner.
  matrix(1:8, 1:8) = zeros (8, 8);
  matrix(1:7, 1:7) = POSITION_DETECTION_PATTERN;
  ## Right top corner.
  matrix(1:8, end-7:end) = zeros (8, 8);
  matrix(1:7, end-6:end) = POSITION_DETECTION_PATTERN;
  ## Left bottom corner.
  matrix(end-7:end, 1:8) = zeros (8, 8);
  matrix(end-6:end, 1:7) = POSITION_DETECTION_PATTERN;

  ## Embed the lonely dark dot at left bottom corner.  JISX0510:2004 (p.46)
  matrix(end - 7, 9) = 1;

  ## Position adjustment patterns appear if version >= 2.
  matrix = maybeEmbedPositionAdjustmentPatterns (ver, matrix);
  ## Timing patterns should be embedded after position adj. patterns.
  TIMING_PATTERN = mod (1:length(matrix) - 16, 2);
  matrix(7,9:end-8) = TIMING_PATTERN;
  matrix(9:end-8,7) = TIMING_PATTERN;
endfunction


## Embed type information. On success, modify the matrix.
function matrix = embedTypeInfo(ecLevelBits, maskPattern, matrix)
  typeInfoBits = makeTypeInfoBits (ecLevelBits, maskPattern);
  ## Left top corner.
  matrix(9,[1:6,8]) = typeInfoBits(1:7);
  matrix([1:6,8:9],9) = typeInfoBits(end:-1:end-7);
  
  ## Left bottom corner.
  matrix(end-6:end,9) = typeInfoBits(7:-1:1);
  ## Right top corner.
  matrix(9,end-7:end) = typeInfoBits(end-7:end);
endfunction


## Embed version information if need be. On success, modify the matrix and
## return true.  See 8.10 of JISX0510:2004 (p.47) for how to embed version
## information.
function matrix = maybeEmbedVersionInfo(ver, matrix)
  if (ver < 7)  ## Version info is necessary if version >= 7.
    return;
  endif
  versionInfoBits = makeVersionInfoBits (ver);

  bitIndex = 6 * 3;  # It will decrease from 18 to 1.
  for i = 1:6
    for j = 0:2
      ## Place bits in LSB (least significant bit) to MSB order.
      bit = versionInfoBits.get(bitIndex);
      bitIndex--;
      ## Left bottom corner.
      matrix(i, end - 11 + j) = bit;
      ## Right bottom corner.
      matrix(end - 11 + j, i) = bit;
    endfor
  endfor
endfunction


## Return the mask bit for "getMaskPattern" at "x" and "y".  See 8.8 of
## JISX0510:2004 for mask pattern conditions.
function bool = getDataMaskBit (maskPattern, x, y)
  x = uint32 (x - 1);
  y = uint32 (y - 1);
  switch (maskPattern)
    case 0
      intermediate = bitand ((y + x), 0x1);
    case 1
      intermediate = bitand (y, 0x1);
    case 2
      intermediate = mod (x, 3);
    case 3
      intermediate = mod ((y + x), 3);
    case 4
      intermediate = bitand (((y / 2) + (x / 3)), 0x1);
    case 5
      temp = y * x;
      intermediate = bitand (temp, 0x1) + mod (temp, 3);
    case 6
      temp = y * x;
      intermediate = bitand ((bitand (temp, 0x1) + mod (temp, 3)), 0x1);
    case 7
      temp = y * x;
      intermediate = bitand ((mod (temp, 3) + bitand ((y + x), 0x1)), 0x1);
    otherwise
      error ("Invalid mask pattern: %d.", maskPattern);
  endswitch
  bool = (intermediate == 0);
endfunction

## Embed "dataBits" using "getMaskPattern".  On success, modify the matrix and
## return true.  For debugging purposes, it skips masking process if
## "getMaskPattern" is -1..  See 8.7 of JISX0510:2004 (p.38) for how to embed
## data bits.
function matrix = embedDataBits(dataBits, maskPattern, matrix)
  bitIndex = 1;
  direction = -1;
  ## Start from the right bottom cell.
  [y, x] = size (matrix);
  while (x > 1)
    ## Skip the vertical timing pattern.
    if (x == 7)
      x -= 1;
    endif
    while (y >= 1 && y <= size (matrix, 2))
      for i = 0:1
        xx = x - i;
        ## Skip the cell if it's not empty.
        if (matrix(y, xx) != -1)
          continue;
        endif
        ## Padding bit. If there is no bit left, we'll fill the left cells
        ## with 0, as described in 8.4.9 of JISX0510:2004 (p. 24).
        bit = false;
        if (bitIndex <= dataBits.getSize())
          bit = dataBits.get(bitIndex);
          bitIndex++;
        endif

        ## Skip masking if mask_pattern is -1.
        if (maskPattern != -1 && getDataMaskBit (maskPattern, xx, y))
          bit = !bit;
        endif
        matrix(y, xx) = bit;
      endfor
      y += direction;
    endwhile
    direction = -direction; ## Reverse the direction.
    y += direction;
    x -= 2; ## Move to the left.
  endwhile
  ## All bits should be consumed.
  if (bitIndex - 1 != dataBits.getSize())
    error ("MatrixUtil: Not all bits consumed: %d/%d", bitIndex, ...
      dataBits.getSize());
  endif
endfunction


## Return the position of the most significant bit set (to one) in the "value".
## The most significant bit is position 32. If there is no bit set, return 0.
## Examples:
## - findMSBSet(0) => 0
## - findMSBSet(1) => 1
## - findMSBSet(255) => 8
function val = findMSBSet (value)
  val = length (dec2bin (uint32 (value)));
  if (uint32 (value) == 0)
    val = 0;
  endif
endfunction


## Calculate BCH (Bose-Chaudhuri-Hocquenghem) code for "value" using polynomial
## "poly".  The BCH code is used for encoding type information and version
## information.
## Example: Calculation of version information of 7.
## f(x) is created from 7.
## - 7 = 000111 in 6 bits
## - f(x) = x^2 + x^1 + x^0
## g(x) is given by the standard (p. 67)
## - g(x) = x^12 + x^11 + x^10 + x^9 + x^8 + x^5 + x^2 + 1
## Multiply f(x) by x^(18 - 6)
## - f'(x) = f(x) * x^(18 - 6)
## - f'(x) = x^14 + x^13 + x^12
## Calculate the remainder of f'(x) / g(x)
## x^2
## __________________________________________________
## g(x) )x^14 + x^13 + x^12
## x^14 + x^13 + x^12 + x^11 + x^10 + x^7 + x^4 + x^2
## --------------------------------------------------
## x^11 + x^10 + x^7 + x^4 + x^2
##
## The remainder is x^11 + x^10 + x^7 + x^4 + x^2
## Encode it in binary: 110010010100
## The return value is 0xc94 (1100 1001 0100)
##
## Since all coefficients in the polynomials are 1 or 0, we can do the
## calculation by bit operations. We don't care if coefficients are positive
## or negative.
function value = calculateBCHCode (value, poly)
  if (poly == 0)
    error ("MatrixUtil: 0 polynomial");
  endif
  ## If poly is "1 1111 0010 0101" (version info poly), msbSetInPoly is 13.
  ## We'll subtract 1 from 13 to make it 12.
  msbSetInPoly = findMSBSet (poly);
  value = uint32 (value);
  value *= 2^(msbSetInPoly - 1);
  ## Do the division business using exclusive-or operations.
  while (findMSBSet (value) >= msbSetInPoly)
    value = bitxor (value, poly * 2^(findMSBSet (value) - msbSetInPoly));
  endwhile
  ## Now the "value" is the remainder (i.e. the BCH code)
endfunction


## Make bit vector of type information. On success, store the result in "bits"
## and return true.  Encode error correction level and mask pattern.  See 8.9
## of JISX0510:2004 (p.45) for details.
function bits = makeTypeInfoBits (ecLevelBits, maskPattern)
  bits = BitArray();
  typeInfo = bitor (uint32 (ecLevelBits * 2^3), maskPattern);
  bits.appendBits (typeInfo, 5);

  ## From Appendix C in JISX0510:2004 (p.65).
  TYPE_INFO_POLY = 0x537;
  bchCode = calculateBCHCode (typeInfo, TYPE_INFO_POLY);
  bits.appendBits (bchCode, 10);

  ## From Appendix C in JISX0510:2004 (p.65).
  TYPE_INFO_MASK_PATTERN = 0x5412;
  maskBits = BitArray();
  maskBits.appendBits (TYPE_INFO_MASK_PATTERN, 15);
  bits.xor (maskBits);

  if (bits.getSize() != 15) # Just in case.
    error ("MatrixUtil: should not happen but we got: %d", bits.getSize());
  endif
  bits = bits.bits;
endfunction


## Make bit vector of version information. On success, store the result in
## "bits" and return true.  See 8.10 of JISX0510:2004 (p.45) for details.
function bits = makeVersionInfoBits (ver)
  ## From Appendix D in JISX0510:2004 (p. 67)
  VERSION_INFO_POLY = 0x1f25;  # 1 1111 0010 0101
  bits = BitArray ();
  bits.appendBits(ver, 6);
  bchCode = calculateBCHCode(ver, VERSION_INFO_POLY);
  bits.appendBits(bchCode, 12);

  if (bits.getSize() != 18) # Just in case.
    error ("MatrixUtil: should not happen but we got: %d", bits.getSize());
  endif
endfunction


## Embed position adjustment patterns if need be.
function matrix = maybeEmbedPositionAdjustmentPatterns(ver, matrix)
  if (ver < 2)  # The patterns appear if version >= 2
    return;
  endif
  ## From Appendix E. Table 1, JIS0510X:2004 (p 71).  The table was double-
  ## checked by komatsu.
  POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE = [ ...
    -1, -1, -1, -1,  -1,  -1,  -1; ... # Version 1
     6, 18, -1, -1,  -1,  -1,  -1; ... # Version 2
     6, 22, -1, -1,  -1,  -1,  -1; ... # Version 3
     6, 26, -1, -1,  -1,  -1,  -1; ... # Version 4
     6, 30, -1, -1,  -1,  -1,  -1; ... # Version 5
     6, 34, -1, -1,  -1,  -1,  -1; ... # Version 6
     6, 22, 38, -1,  -1,  -1,  -1; ... # Version 7
     6, 24, 42, -1,  -1,  -1,  -1; ... # Version 8
     6, 26, 46, -1,  -1,  -1,  -1; ... # Version 9
     6, 28, 50, -1,  -1,  -1,  -1; ... # Version 10
     6, 30, 54, -1,  -1,  -1,  -1; ... # Version 11
     6, 32, 58, -1,  -1,  -1,  -1; ... # Version 12
     6, 34, 62, -1,  -1,  -1,  -1; ... # Version 13
     6, 26, 46, 66,  -1,  -1,  -1; ... # Version 14
     6, 26, 48, 70,  -1,  -1,  -1; ... # Version 15
     6, 26, 50, 74,  -1,  -1,  -1; ... # Version 16
     6, 30, 54, 78,  -1,  -1,  -1; ... # Version 17
     6, 30, 56, 82,  -1,  -1,  -1; ... # Version 18
     6, 30, 58, 86,  -1,  -1,  -1; ... # Version 19
     6, 34, 62, 90,  -1,  -1,  -1; ... # Version 20
     6, 28, 50, 72,  94,  -1,  -1; ... # Version 21
     6, 26, 50, 74,  98,  -1,  -1; ... # Version 22
     6, 30, 54, 78, 102,  -1,  -1; ... # Version 23
     6, 28, 54, 80, 106,  -1,  -1; ... # Version 24
     6, 32, 58, 84, 110,  -1,  -1; ... # Version 25
     6, 30, 58, 86, 114,  -1,  -1; ... # Version 26
     6, 34, 62, 90, 118,  -1,  -1; ... # Version 27
     6, 26, 50, 74,  98, 122,  -1; ... # Version 28
     6, 30, 54, 78, 102, 126,  -1; ... # Version 29
     6, 26, 52, 78, 104, 130,  -1; ... # Version 30
     6, 30, 56, 82, 108, 134,  -1; ... # Version 31
     6, 34, 60, 86, 112, 138,  -1; ... # Version 32
     6, 30, 58, 86, 114, 142,  -1; ... # Version 33
     6, 34, 62, 90, 118, 146,  -1; ... # Version 34
     6, 30, 54, 78, 102, 126, 150; ... # Version 35
     6, 24, 50, 76, 102, 128, 154; ... # Version 36
     6, 28, 54, 80, 106, 132, 158; ... # Version 37
     6, 32, 58, 84, 110, 136, 162; ... # Version 38
     6, 26, 54, 82, 110, 138, 166; ... # Version 39
     6, 30, 58, 86, 114, 142, 170];    # Version 40
  coordinates = POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE(ver,:);
  for y = coordinates
    if (y >= 1)
      for x = coordinates
        if ((x >= 1) && (matrix(y + 1, x + 1) == -1))
          ## If the cell is unset, we embed the position adjustment pattern
          ## here.  -2 is necessary since the x/y coordinates point to the
          ## center of the pattern, not the left top corner.
          matrix(y - 1:y + 3, x - 1:x + 3) = [ ...
            1, 1, 1, 1, 1;
            1, 0, 0, 0, 1;
            1, 0, 1, 0, 1;
            1, 0, 0, 0, 1;
            1, 1, 1, 1, 1];
        endif
      endfor
    endif
  endfor
endfunction
