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

## author Sean Owen
## author William Rucklidge

## Implements Reed-Solomon encoding, as the name implies.
function toEncode = ReedSolomonEncoder (toEncode, ecBytes)
  persistent field = GenericGF ();
  persistent cachedGenerators = {GenericGFPoly(field, 1)};
  if (ecBytes == 0)
    error ("ReedSolomonEncoder: No error correction bytes.");
  endif
  dataBytes = length (toEncode) - ecBytes;
  if (dataBytes <= 0)
    error ("ReedSolomonEncoder: No data bytes provided.");
  endif
  if (ecBytes >= length (cachedGenerators))
    lastGenerator = cachedGenerators{end};
    for d = (length (cachedGenerators):ecBytes) + 1
      nextGenerator = lastGenerator.multiply (GenericGFPoly(field, [1, field.exp(d - 1)]));
      cachedGenerators{end + 1} = nextGenerator;
      lastGenerator = nextGenerator;
    endfor
  endif
  generator = cachedGenerators{ecBytes};
  infoCoefficients = toEncode(1:dataBytes);
  info = GenericGFPoly (field, infoCoefficients);
  info = info.multiplyByMonomial (ecBytes, 1);
  [~, remainder] = info.divide (generator);
  remainder.coefficients;
  numZeroCoefficients = ecBytes - length (remainder.coefficients);
  toEncode = [toEncode, zeros(1, numZeroCoefficients), remainder.coefficients];
endfunction

%!test
%!
%! data = [ 64,  84, 134, 22, 198, 198, 240, 236, 17, 236, 17, 236, 17,  ...
%!         236,  17, 236, 17, 236,  17];
%! ec_bytes = [232, 35, 19, 217, 253, 159, 23];
%! data_and_ec_bytes = ReedSolomonEncoder ([data, zeros(1, length (ec_bytes))], length (ec_bytes));
%! assert (data, data_and_ec_bytes(1:length (data)));
%! assert (ec_bytes, data_and_ec_bytes((length (data) + 1):end));

%!test
%! cachedGenerators = [
%!   1,
%!   x + 1,
%!   x^2 + a^25x + a,
%!   x^3 + a^198x^2 + a^199x + a^3,
%!   x^4 + a^75x^3 + a^249x^2 + a^78x + a^6,
%!   x^5 + a^113x^4 + a^164x^3 + a^166x^2 + a^119x + a^10,
%!   x^6 + a^166x^5 + x^4 + a^134x^3 + a^5x^2 + a^176x + a^15,
%!   x^7 + a^87x^6 + a^229x^5 + a^146x^4 + a^149x^3 + a^238x^2 + a^102x + a^21,
%!   x^8 + a^175x^7 + a^238x^6 + a^208x^5 + a^249x^4 + a^215x^3 + a^252x^2 + a^196x + a^28,
%!   x^9 + a^95x^8 + a^246x^7 + a^137x^6 + a^231x^5 + a^235x^4 + a^149x^3 + a^11x^2 + a^123x + a^36,
%!   x^10 + a^251x^9 + a^67x^8 + a^46x^7 + a^61x^6 + a^118x^5 + a^70x^4 + a^64x^3 + a^94x^2 + a^32x + a^45,
%!   x^11 + a^220x^10 + a^192x^9 + a^91x^8 + a^194x^7 + a^172x^6 + a^177x^5 + a^209x^4 + a^116x^3 + a^227x^2 + a^10x + a^55,
%!   x^12 + a^102x^11 + a^43x^10 + a^98x^9 + a^121x^8 + a^187x^7 + a^113x^6 + a^198x^5 + a^143x^4 + a^131x^3 + a^87x^2 + a^157x + a^66,
%!   x^13 + a^74x^12 + a^152x^11 + a^176x^10 + a^100x^9 + a^86x^8 + a^100x^7 + a^106x^6 + a^104x^5 + a^130x^4 + a^218x^3 + a^206x^2 + a^140x + a^78,
%!   x^14 + a^199x^13 + a^249x^12 + a^155x^11 + a^48x^10 + a^190x^9 + a^124x^8 + a^218x^7 + a^137x^6 + a^216x^5 + a^87x^4 + a^207x^3 + a^59x^2 + a^22x + a^91,
%!   x^15 + a^8x^14 + a^183x^13 + a^61x^12 + a^91x^11 + a^202x^10 + a^37x^9 + a^51x^8 + a^58x^7 + a^58x^6 + a^237x^5 + a^140x^4 + a^124x^3 + a^5x^2 + a^99x + a^105]
