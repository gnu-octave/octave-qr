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
## Plots a graphical representation of a QR-Code matrix @var{code}.
##
## An example call:
##
## @example
## plot_qr_code (qr_code ("Hello World!!!"));
## @end example
##
## @seealso{qr_code}
## @end deftypefn

function plot_qr_code (code)

code = flipud (code); # Because we later draw from 0 upwards.

## Compute pixel offsets
[X, Y] = meshgrid (1:length (code));
X = repmat ((X(code == 1) - 1)', 4, 1);
Y = repmat ((Y(code == 1) - 1)', 4, 1);

## Compute patch coordinates using the offsets
x = [0; 0; 1; 1];
y = [0; 1; 1; 0];
x = repmat (x, 1, length(X)) + X;
y = repmat (y, 1, length(Y)) + Y;
patch(x,y,'black')
axis equal
axis ("off");

endfunction
