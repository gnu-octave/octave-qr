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

classdef BitArray < handle

  properties
    bits;
  endproperties

  methods
    function obj = BitArray()
      obj.bits = logical ([]);
    endfunction

    function obj = disp (obj)
      disp (obj.bits);
    endfunction

    function s = getSize (obj)
      s = length (obj.bits);
    endfunction

    function s = getSizeInBytes (obj)
      s = floor ((obj.getSize () + 7) / 8);
    endfunction

    function s = get (obj, i)
      s = logical (obj.bits(i));
    endfunction

    function set (obj, i)
      obj.bits(i) = true;
    endfunction

    function flip (obj, i)
      obj.bits(i) = ! obj.bits(i);
    endfunction

    ## @param from first bit to check
    ## @return index of first bit that is set, starting from the given index,
    ## or size if none are set at or beyond this given index
    ## @see #getNextUnset(int)
    function from = getNextSet (obj, from)
      while ((from < obj.size ()) && (obj.bits(from) == false))
        from++;
      endwhile
    endfunction

    ## @param from index to start looking for unset bit
    ## @return index of next unset bit, or {@code size} if none are unset until
    ## the end
    ## @see #getNextSet(int)
    function from = getNextUnset(obj, from)
      while ((from < obj.size ()) && (obj.bits(from) == true))
        from++;
      endwhile
    endfunction

    function appendBit(obj, bit)
      obj.bits = [obj.bits(:); logical(bit)];
    endfunction

    ## Appends the least-significant bits, from value, in order from most-
    ## significant to least-significant.  For example, appending 6 bits from
    ## 0x000001E will append the bits 0, 1, 1, 1, 1, 0 in that order.
    ##
    ## @param value {@code int} containing bits to append
    ## @param numBits bits from value to append
    function appendBits(obj, value, numBits)
      if (numBits < 0 || numBits > 32)
        error ("BitArray: Num bits must be between 0 and 32");
      endif
      for i = numBits-1:-1:0
        obj.appendBit (bitand (uint32 (value), 2^i) != 0);
      endfor
    endfunction

    function appendBitArray(obj, other)
      obj.bits = [obj.bits(:); logical(other.bits(:))];
    endfunction

    function xor(obj, other)
      obj.bits = xor (obj.bits, logical (other));
    endfunction

    ## @param bitOffset first bit to start writing
    ## @param offset position in array to start writing
    ## @param numBytes how many bytes to write
    ## @return Array of bits as byte array.  The bytes are written most-
    ##   significant byte first.
    function arr = toBytes (obj, bitOffset, offset, numBytes)
      arr = uint8 (zeros (numBytes, 1));
      for i = 1:numBytes
        theByte = uint8 (0);
        for j = 7:-1:0
          if (obj.get (bitOffset))
            theByte = bitor (theByte, 2^j);
          endif
          bitOffset++;
        endfor
        arr(offset + i) = uint8 (theByte);
      endfor
    endfunction

  endmethods

endclassdef
