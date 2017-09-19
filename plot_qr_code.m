function plot_qr_code (data)

data = flipud (data); # Because we later draw from 0 upwards.

## Compute pixel offsets
[X, Y] = meshgrid (1:length (data));
X = repmat ((X(data == 1) - 1)', 4, 1);
Y = repmat ((Y(data == 1) - 1)', 4, 1);

## Compute patch coordinates using the offsets
x = [0; 0; 1; 1];
y = [0; 1; 1; 0];
x = repmat (x, 1, length(X)) + X;
y = repmat (y, 1, length(Y)) + Y;
patch(x,y,'black')
axis ("off");

endfunction

## Should encode a QR Code "Hallo"
%!test
%! data = [
%! 1 1 1 1 1 1 1 0 0 1 0 1 1 0 1 1 1 1 1 1 1;
%! 1 0 0 0 0 0 1 0 1 1 0 1 0 0 1 0 0 0 0 0 1;
%! 1 0 1 1 1 0 1 0 1 1 0 0 1 0 1 0 1 1 1 0 1;
%! 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1;
%! 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 0 1;
%! 1 0 0 0 0 0 1 0 1 0 0 1 1 0 1 0 0 0 0 0 1;
%! 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1;
%! 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0;
%! 1 1 0 1 0 0 1 1 0 1 1 0 0 0 1 1 1 0 1 1 0;
%! 0 1 1 0 1 0 0 0 0 0 1 0 0 0 1 0 0 1 0 1 1;
%! 0 1 0 1 1 1 1 1 0 0 1 0 1 1 0 0 0 1 1 0 1;
%! 1 1 0 1 1 1 0 0 1 1 1 1 0 0 0 0 0 1 0 1 1;
%! 0 1 1 1 0 0 1 1 0 0 1 0 1 0 1 0 1 0 0 0 0;
%! 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 1 1 0 1 0 0;
%! 1 1 1 1 1 1 1 0 1 0 0 0 0 1 0 1 0 1 1 1 0;
%! 1 0 0 0 0 0 1 0 0 1 0 1 1 1 0 1 1 0 0 0 0;
%! 1 0 1 1 1 0 1 0 0 1 1 1 0 0 1 1 1 0 0 0 1;
%! 1 0 1 1 1 0 1 0 1 1 0 1 0 0 0 1 0 1 1 1 1;
%! 1 0 1 1 1 0 1 0 0 1 1 0 1 0 0 0 1 0 1 0 1;
%! 1 0 0 0 0 0 1 0 1 1 1 0 0 1 1 0 0 0 0 0 0;
%! 1 1 1 1 1 1 1 0 1 1 0 1 1 0 0 1 0 1 0 1 0];
%! plot_qr_code (data)