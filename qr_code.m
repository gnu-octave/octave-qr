## Copyright (C) 2008 ZXing authors
## Copyright (C) 2017 Kai T. Ohlhus <k.ohlhus@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {@var{code} =} qr_code (@var{content})
## @deftypefnx {} {@var{code} =} qr_code (@var{content}, @var{ec_level})
## @deftypefnx {} {[@var{code}, @var{info}] =} qr_code (@dots{})
##
## Generates a QR-Code matrix @var{code} from a string @var{content}.
##
## The optional input parameter @var{ec_level} determines the level of error
## correction:
##
## @table @asis
## @item @qcode{"L"}
## ~7% correction.
##
## @item @qcode{"M"}
## ~15 correction.
##
## @item @qcode{"Q"}
## ~25% correction.
##
## @item @qcode{"H"}
## ~30% correction.
## @end table
##
## The optional return value @var{info} contains a struct with some
## information about the generated QR-Code @var{code}.
##
## An example for generating a QR-Code containg the string
## @qcode{"Hello World!!!"} with ~7% error correction:
##
## @example
## [code, info] = qr_code ("Hello World!!!", "L");
## @end example
##
## @seealso{plot_qr_code}
## @end deftypefn

## Author: Satoru Takabayashi <satorux@google.com>
## Ported from C++       by Daniel Switkin <dswitkin@google.com>
## Ported from Java 2017 by Kai T. Ohlhus <k.ohlhus@gmail.com>

function [code, info] = qr_code (content, varargin)
  javaaddpath ([pwd(), filesep(), "qrcode.jar"]);

  switch (nargin)
    case 1
      info.ec_level = 'L';
    case 2
      info.ec_level = validatestring (varargin{1}, {'L', 'M', 'Q', 'H'});
    otherwise
      print_usage ();
  endswitch

  ## Byte encoding.  See ISO 18004:2006, 6.4.1, Tables 2 and 3.
  info.mode = "BYTE";
  mode_indicator = 0x04;

  ## This will store the header information, like mode and length, as well as
  ## "header" segments like an ECI segment.
  headerBits = BitArray ();

  ## (With ECI in place,) Write the mode indicator.
  headerBits.appendBits (mode_indicator, 4);

  ## Collect data within the main segment, separately, to count its size if
  ## needed.  Don't add it to main payload yet.
  dataBits = BitArray ();
  content_bytes = uint8 (content);
  for i = 1:length(content_bytes)
    dataBits.appendBits (content_bytes(i), 8);
  endfor

  ## Decides the smallest version of QR code that will contain all of the
  ## provided data.

  ## Hard part: need to know version to know how many bits length takes.  But
  ## need to know how many bits it takes to know version.  First we take a
  ## guess at version by assuming version will be the minimum, 1:
  info.version = 1;
  bits_per_char = 8;
  bits_needed =  headerBits.getSize () + dataBits.getSize ();

  version_ecb_array = get_version_ecb_array ();
  numBytes = 0;
  numBlocks = 0;
  numDataBytes = 0;

  for v = 1:40
    info.version = v;
    if (v > 9)
      bits_per_char = 16;
    endif

    ## In the following comments, we use as example numbers of "version = 7"
    ## and "info.ec_level = H".

    ecBlocks_struct = getfield ({version_ecb_array(info.version)}{1}, 'L');
    ## numBytes = 196, Version.getTotalCodewords()
    numBytes = ecBlocks_struct.ecBlocks;
    numBytes(:, 2) += ecBlocks_struct.ecCodewordsPerBlock;
    numBytes = prod (numBytes, 2);

    ## numEcBytes = 130
    ecBlocks_struct = getfield ({version_ecb_array(info.version)}{1}, ...
      info.ec_level);
    numBlocks = sum (ecBlocks_struct.ecBlocks(:,1));
    numEcBytes = numBlocks * ecBlocks_struct.ecCodewordsPerBlock;
    ## numDataBytes = 196 - 130 = 66
    numDataBytes = numBytes - numEcBytes;
    totalInputBytes = floor ((bits_needed + bits_per_char + 7) / 8);

    if ((v == 40) && (numDataBytes < totalInputBytes))
      error ("qr_code: version choice failed.");
    elseif (numDataBytes >= totalInputBytes)
      break;
    endif
  endfor

  headerAndDataBits = BitArray ();
  headerAndDataBits.appendBitArray(headerBits);

  ## Append length info.
  num_chars = dataBits.getSizeInBytes();
  if (num_chars >= 2^bits_per_char)
    error ("qr_code: Appending length info %d >= %d.", num_chars, ...
      2^bits_per_char);
  endif
  headerAndDataBits.appendBits(num_chars, bits_per_char);

  ## Put data together into the overall payload
  headerAndDataBits.appendBitArray (dataBits);

  ## Terminate bits as described in 8.4.8 and 8.4.9 of JISX0510:2004 (p.24).
  capacity = numDataBytes * 8;
  if (headerAndDataBits.getSize() > capacity)
    error ("qr_code: data bits cannot fit in the QR Code %d > %d.",
      headerAndDataBits.getSize(), capacity);
  endif

  for i = 1:4
    if (headerAndDataBits.getSize() < capacity)
      headerAndDataBits.appendBit(false);
    endif
  endfor

  ## Append termination bits.  See 8.4.8 of JISX0510:2004 (p.24) for details.
  ## If the last byte isn't 8-bit aligned, we'll add padding bits.
  numBitsInLastByte = bitand (uint32 (headerAndDataBits.getSize()), 0x07);
  if (numBitsInLastByte > 0)
    for i = numBitsInLastByte:7
      headerAndDataBits.appendBit(false);
    endfor
  endif

  ## If we have more space, we'll fill the space with padding patterns defined
  ## in 8.4.9 (p.24).
  numPaddingBytes = numDataBytes - headerAndDataBits.getSizeInBytes();
  for i = 1:numPaddingBytes
    val = 0x11;
    if (mod (i, 2) == 1)
      val = 0xEC;
    endif
    headerAndDataBits.appendBits(val, 8);
  endfor
  if (headerAndDataBits.getSize() != capacity)
    error ("qr_code: Bits size != capacity.");
  endif

  ## Interleave data bits with error correction code.
  finalBits = interleaveWithECBytes (headerAndDataBits, numBytes, numDataBytes,
                                     numBlocks);

  ## Bits for ec_level
  ##   L(0x01)   ~7% correction
  ##   M(0x00)  ~15% correction
  ##   Q(0x03)  ~25% correction
  ##   H(0x02)  ~30% correction
  switch (info.ec_level)
    case 'L'
      ec_level_bits = 0x01;
    case 'M'
      ec_level_bits = 0x00;
    case 'Q'
      ec_level_bits = 0x03;
    case 'H'
      ec_level_bits = 0x02;
    otherwise
      error ("qr_code: Invalid ec_level, one of 'L', 'M', 'Q', or 'H'");
  end

  ## Choose the mask pattern and set to "code".
  qr_code_dimension = 17 + 4 * info.version;
  min_penalty = intmax ("int32");  # Lower penalty is better.

  ## We try all mask patterns to choose the best one.
  for mask_pattern = 0:7
    matrix = MatrixUtil (finalBits, ec_level_bits, info.version, ...
                         mask_pattern, qr_code_dimension);
    ## The mask penalty calculation is complicated.  See Table 21 of
    ## JISX0510:2004 (p.45) for details.  Basically it applies four rules and
    ## summate all penalties.
    penalty = calculateMaskPenalty (matrix);
    if (penalty < min_penalty)
      min_penalty = penalty;
      info.mask_pattern = mask_pattern;
      code = matrix;
    endif
  endfor
endfunction


## Returns the code point of the table used in alphanumeric mode
function acode = getAlphanumericCode (code)
  ## The original table is defined in the table 5 of JISX0510:2004 (p.19).
  persistent ALPHANUMERIC_TABLE = [ ...
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  # 0x00-0x0f
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  # 0x10-0x1f
  36, -1, -1, -1, 37, 38, -1, -1, -1, -1, 39, 40, -1, 41, 42, 43,  # 0x20-0x2f
   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 44, -1, -1, -1, -1, -1,  # 0x30-0x3f
  -1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,  # 0x40-0x4f
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, -1, -1, -1, -1, -1]; # 0x50-0x5f

  acode = ALPHANUMERIC_TABLE(code);
endfunction


## Get number of data bytes and number of error correction bytes for block id
## "blockID". Store the result in "numDataBytesInBlock", and
## "numECBytesInBlock". See table 12 in 8.5.1 of JISX0510:2004 (p.30)
function [numDataBytesInBlock, numECBytesInBlock] = ...
  getNumDataBytesAndNumECBytesForBlockID (numTotalBytes, numDataBytes, ...
                                          numRSBlocks, blockID)
  if (blockID > numRSBlocks)
    error ("qr_code: Block ID too large");
  endif
  ## numRsBlocksInGroup2 = 196 % 5 = 1
  numRsBlocksInGroup2 = mod (numTotalBytes, numRSBlocks);
  ## numRsBlocksInGroup1 = 5 - 1 = 4
  numRsBlocksInGroup1 = numRSBlocks - numRsBlocksInGroup2;
  ## numTotalBytesInGroup1 = 196 / 5 = 39
  numTotalBytesInGroup1 = floor (numTotalBytes / numRSBlocks);
  ## numTotalBytesInGroup2 = 39 + 1 = 40
  numTotalBytesInGroup2 = numTotalBytesInGroup1 + 1;
  ## numDataBytesInGroup1 = 66 / 5 = 13
  numDataBytesInGroup1 = floor (numDataBytes / numRSBlocks);
  ## numDataBytesInGroup2 = 13 + 1 = 14
  numDataBytesInGroup2 = numDataBytesInGroup1 + 1;
  ## numEcBytesInGroup1 = 39 - 13 = 26
  numEcBytesInGroup1 = numTotalBytesInGroup1 - numDataBytesInGroup1;
  ## numEcBytesInGroup2 = 40 - 14 = 26
  numEcBytesInGroup2 = numTotalBytesInGroup2 - numDataBytesInGroup2;
  ## Sanity checks.
  ## 26 = 26
  if (numEcBytesInGroup1 != numEcBytesInGroup2)
    error ("qr_code: EC bytes mismatch");
  endif
  ## 5 = 4 + 1.
  if (numRSBlocks != numRsBlocksInGroup1 + numRsBlocksInGroup2)
    error ("qr_code: RS blocks mismatch");
  endif
  ## 196 = (13 + 26) * 4 + (14 + 26) * 1
  compare_total_bytes = ...
      ((numDataBytesInGroup1 + numEcBytesInGroup1) * numRsBlocksInGroup1) ...
    + ((numDataBytesInGroup2 + numEcBytesInGroup2) * numRsBlocksInGroup2);
  if (numTotalBytes != compare_total_bytes)
    error ("qr_code: Total bytes mismatch");
  endif

  if (blockID - 1 < numRsBlocksInGroup1)
    numDataBytesInBlock = numDataBytesInGroup1;
    numECBytesInBlock = numEcBytesInGroup1;
    return;
  endif
  numDataBytesInBlock = numDataBytesInGroup2;
  numECBytesInBlock = numEcBytesInGroup2;
endfunction


## Interleave "bits" with corresponding error correction bytes.  On success,
## store the result in "result". The interleave rule is complicated. See 8.6
## of JISX0510:2004 (p.37) for details.
function result = interleaveWithECBytes(bits, numTotalBytes, numDataBytes, numRSBlocks)
  ## "bits" must have "getNumDataBytes" bytes of data.
  if (bits.getSizeInBytes() != numDataBytes)
    error ("qr_code: Number of bits and data bytes does not match");
  endif

  ## Step 1. Divide data bytes into blocks and generate error correction bytes
  ## for them.  We'll store the divided data bytes blocks and error correction
  ## bytes blocks into "blocks".
  dataBytesOffset = 0;
  maxNumDataBytes = 0;
  maxNumEcBytes = 0;

  ## Since, we know the number of reedsolmon blocks, we can initialize the
  ## vector with the number.
  blocks = cell (numRSBlocks, 2);

  for i = 1:numRSBlocks
    [numDataBytesInBlock, numEcBytesInBlock] = ...
      getNumDataBytesAndNumECBytesForBlockID (numTotalBytes, numDataBytes, ...
                                              numRSBlocks, i);

    dataBytes = bits.toBytes(8 * dataBytesOffset + 1, 0, numDataBytesInBlock);
    to_encode = bitand (uint32 ([dataBytes(:); zeros(numEcBytesInBlock, 1)]), 0xFF);
    rse = javaObject ("qrcode.ReedSolomonEncoder");
    to_encode = javaMethod ("encode", rse, to_encode, numEcBytesInBlock);
    ecBytes = to_encode(end-numEcBytesInBlock+1:end);

    blocks(i,:) = {dataBytes, ecBytes};

    maxNumDataBytes = max (maxNumDataBytes, numDataBytesInBlock);
    maxNumEcBytes = max (maxNumEcBytes, numEcBytesInBlock);
    dataBytesOffset += numDataBytesInBlock;
  endfor
  if (numDataBytes != dataBytesOffset)
    error ("qr_code: Data bytes does not match offset");
  endif

  result = BitArray();

  ## First, place data blocks.
  for i = 1:maxNumDataBytes
    for j = 1:numRSBlocks
      dataBytes = blocks{j,1};
      if (i <= length (dataBytes))
        result.appendBits(dataBytes(i), 8);
      endif
    endfor
  endfor
  ## Then, place error correction blocks.
  for i = 1:maxNumEcBytes
    for j = 1:numRSBlocks
      ecBytes = blocks{j,2};
      if (i <= length (ecBytes))
        result.appendBits(ecBytes(i), 8);
      endif
    endfor
  endfor
  if (numTotalBytes != result.getSizeInBytes())
    error ("qr_code: Interleaving error: %d and %d differ.", numTotalBytes, ...
      result.getSizeInBytes());
  endif
endfunction

%!test
%! test_case = qr_test(1);
%! [code, info] = qr_code (test_case.str, test_case.ec_level);
%! assert (info.ec_level,     test_case.ec_level);
%! assert (info.mode,         test_case.mode);
%! assert (info.version,      test_case.version);
%! assert (info.mask_pattern, test_case.mask_pattern);
%! assert (code,              test_case.matrix);

%!test
%! test_case = qr_test(2);
%! [code, info] = qr_code (test_case.str, test_case.ec_level);
%! assert (info.ec_level,     test_case.ec_level);
%! assert (info.mode,         test_case.mode);
%! assert (info.version,      test_case.version);
%! assert (info.mask_pattern, test_case.mask_pattern);
%! assert (code,              test_case.matrix);