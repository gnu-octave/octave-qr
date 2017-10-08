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
## @deftypefn {} {} plot_qr_code (@var{code})
##
## Defines some test cases for QR-Codes.
##
## The returned struct contains the following fields:
##
## @table @asis
## @item @qcode{"str"}
## The originally encoded string.
##
## @item @qcode{"mode"}
## This will alway be @qcode{"BYTE"}.
##
## @item @qcode{"ec_level"}
## The used error correction level 'L', 'M', 'Q', or 'H'.
##
## @item @qcode{"version"}
## The QR-Code version used (1-40).
##
## @item @qcode{"mask_pattern"}
## The mask_pattern used (0-7).
##
## @item @qcode{"matrix"}
## The QR-Code matrix.
## @end table
##
## An example call:
##
## @example
## test_case = qr_test (1);
## @end example
##
## @seealso{qr_code}
## @end deftypefn

function test_case = qr_test (num)
  switch (num)
    case 1
      test_case.str = "Hallo";
      test_case.mode = "BYTE";
      test_case.ec_level = 'L';
      test_case.version = 1;
      test_case.mask_pattern = 7;
      test_case.matrix = [ ...
        1 1 1 1 1 1 1 0 0 1 0 1 1 0 1 1 1 1 1 1 1;
        1 0 0 0 0 0 1 0 1 1 0 1 0 0 1 0 0 0 0 0 1;
        1 0 1 1 1 0 1 0 1 1 0 0 1 0 1 0 1 1 1 0 1;
        1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1;
        1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 0 1;
        1 0 0 0 0 0 1 0 1 0 0 1 1 0 1 0 0 0 0 0 1;
        1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1;
        0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0;
        1 1 0 1 0 0 1 1 0 1 1 0 0 0 1 1 1 0 1 1 0;
        0 1 1 0 1 0 0 0 0 0 1 0 0 0 1 0 0 1 0 1 1;
        0 1 0 1 1 1 1 1 0 0 1 0 1 1 0 0 0 1 1 0 1;
        1 1 0 1 1 1 0 0 1 1 1 1 0 0 0 0 0 1 0 1 1;
        0 1 1 1 0 0 1 1 0 0 1 0 1 0 1 0 1 0 0 0 0;
        0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 1 1 0 1 0 0;
        1 1 1 1 1 1 1 0 1 0 0 0 0 1 0 1 0 1 1 1 0;
        1 0 0 0 0 0 1 0 0 1 0 1 1 1 0 1 1 0 0 0 0;
        1 0 1 1 1 0 1 0 0 1 1 1 0 0 1 1 1 0 0 0 1;
        1 0 1 1 1 0 1 0 1 1 0 1 0 0 0 1 0 1 1 1 1;
        1 0 1 1 1 0 1 0 0 1 1 0 1 0 0 0 1 0 1 0 1;
        1 0 0 0 0 0 1 0 1 1 1 0 0 1 1 0 0 0 0 0 0;
        1 1 1 1 1 1 1 0 1 1 0 1 1 0 0 1 0 1 0 1 0];
    case 2
      test_case.str = "Hi, this is a pretty long string to be encoded";
      test_case.mode = "BYTE";
      test_case.ec_level = 'L';
      test_case.version = 3;
      test_case.mask_pattern = 2;
      test_case.matrix = [ ...
        1 1 1 1 1 1 1 0 0 0 1 0 1 0 0 0 1 1 1 1 1 0 1 1 1 1 1 1 1;
        1 0 0 0 0 0 1 0 1 0 1 0 0 1 0 1 0 1 0 0 0 0 1 0 0 0 0 0 1;
        1 0 1 1 1 0 1 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 1 0 1 1 1 0 1;
        1 0 1 1 1 0 1 0 1 1 1 0 1 1 1 1 0 1 0 1 0 0 1 0 1 1 1 0 1;
        1 0 1 1 1 0 1 0 0 1 0 0 0 0 0 0 0 1 1 1 1 0 1 0 1 1 1 0 1;
        1 0 0 0 0 0 1 0 1 1 0 1 1 0 1 1 1 1 0 0 0 0 1 0 0 0 0 0 1;
        1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1;
        0 0 0 0 0 0 0 0 0 1 1 1 0 0 1 0 1 0 1 0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 0 1 1 1 1 0 1 0 1 0 0 0 1 0 0 0 1 0 1 0 1 0 1 0;
        1 1 1 0 0 1 0 1 0 0 1 0 1 0 0 0 1 0 1 1 0 1 1 1 1 0 0 1 1;
        1 1 0 1 0 0 1 0 1 0 1 0 0 0 0 1 0 1 0 0 1 1 0 0 1 0 0 1 0;
        0 1 1 0 1 0 0 1 1 0 0 0 1 0 0 1 1 0 0 0 0 0 0 0 1 1 0 1 0;
        1 0 0 0 0 1 1 1 0 1 1 0 1 1 1 1 1 1 1 1 1 1 0 0 0 1 1 0 1;
        0 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 1 1 1 1 1 0 1 1 0 1 1;
        1 1 0 0 0 0 1 0 1 0 0 1 1 0 1 1 0 0 1 0 0 1 0 1 0 0 0 1 0;
        1 0 0 0 1 0 0 0 0 1 1 1 0 0 1 1 0 0 1 0 1 1 0 0 1 1 0 0 0;
        0 0 0 1 1 1 1 0 1 0 1 1 1 1 1 1 0 1 0 0 1 0 0 1 0 0 1 1 1;
        1 0 0 1 1 1 0 1 0 0 0 0 1 1 0 0 0 0 0 1 1 0 1 1 1 0 1 1 1;
        1 0 1 1 0 0 1 0 1 1 0 0 1 1 1 1 1 1 1 0 0 1 0 1 1 0 0 0 0;
        1 0 0 1 0 1 0 1 1 0 1 0 0 0 0 0 1 0 0 0 1 1 0 0 0 1 0 1 0;
        1 0 0 0 0 1 1 0 0 1 0 0 1 1 1 1 0 1 0 0 1 1 1 1 1 0 1 1 1;
        0 0 0 0 0 0 0 0 1 1 0 1 0 0 0 0 1 0 0 1 1 0 0 0 1 0 1 1 0;
        1 1 1 1 1 1 1 0 1 1 0 0 0 1 0 1 0 0 0 1 1 0 1 0 1 1 0 0 0;
        1 0 0 0 0 0 1 0 0 1 1 0 0 0 1 0 1 0 1 1 1 0 0 0 1 1 0 1 1;
        1 0 1 1 1 0 1 0 1 0 0 0 1 1 1 0 0 1 0 0 1 1 1 1 1 1 1 0 1;
        1 0 1 1 1 0 1 0 1 0 0 1 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 1 1;
        1 0 1 1 1 0 1 0 1 1 1 0 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0;
        1 0 0 0 0 0 1 0 1 0 1 0 0 0 1 1 0 0 1 0 1 1 0 0 1 0 0 1 0;
        1 1 1 1 1 1 1 0 1 0 0 0 1 1 1 0 0 1 0 1 0 1 1 0 1 0 1 0 0];
    otherwise
      error ("qr_test: Invalid test number");
  endswitch
endfunction
