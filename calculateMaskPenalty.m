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

## Author Satoru Takabayashi
## Author Daniel Switkin
## Author Sean Owen

function penalty = calculateMaskPenalty (matrix)
  ## Penalty weights from section 6.8.2.1
  N2 = 3;
  N3 = 40;
  N4 = 10;
  penalty = applyMaskPenaltyRule1 (matrix) ...
     + N2 * applyMaskPenaltyRule2 (matrix) ...
     + N3 * applyMaskPenaltyRule3 (matrix) ...
     + N4 * applyMaskPenaltyRule4 (matrix);
endfunction


## Apply mask penalty rule 1 and return the penalty.  Find repetitive cells
## with the same color and give penalty to them.  Example: 00000 or 11111.
function penalty = applyMaskPenaltyRule1 (matrix)
  ## We need this for doing this calculation in both vertical and horizontal
  ## orders respectively.
  penalty = applyMaskPenaltyRule1Internal(matrix) ...
          + applyMaskPenaltyRule1Internal(matrix');
endfunction


## Helper function for applyMaskPenaltyRule1.
function penalty = applyMaskPenaltyRule1Internal (matrix)
  N1 = 3;  # Penalty weights from section 6.8.2.1
  penalty = 0;
  [height, width] = size (matrix);
  for i = 1:height
    numSameBitCells = 0;
    prevBit = -1;
    for j = 1:width
      bit = matrix(i,j);
      if (bit == prevBit)
        numSameBitCells++;
      else
        if (numSameBitCells >= 5)
          penalty += N1 + (numSameBitCells - 5);
        endif
        numSameBitCells = 1;  # Include the cell itself.
        prevBit = bit;
      endif
    endfor
    if (numSameBitCells >= 5)
      penalty += N1 + (numSameBitCells - 5);
    endif
  endfor
endfunction


## Apply mask penalty rule 2 and return the penalty.  Find 2x2 blocks with the
## same color and give penalty to them.  This is actually equivalent to the
## spec's rule, which is to find MxN blocks and give a penalty proportional to
## (M-1)x(N-1), because this is the number of 2x2 blocks inside such a block.
function penalty = applyMaskPenaltyRule2 (matrix)
  penalty = 0;
  [height, width] = size (matrix);
  for y = 1:(height - 1)
    for x = 1:(width - 1)
      if (all (all (matrix(y:(y+1),x:(x+1)) == matrix(y,x))))
        penalty++;
      endif
    endfor
  endfor
endfunction


## Apply mask penalty rule 3 and return the penalty.  Find consecutive runs of
## 1:1:3:1:1:4 starting with black, or 4:1:1:3:1:1 starting with white, and
## give penalty to them.  If we find patterns like 000010111010000, we give
## penalty once.
function numPenalties = applyMaskPenaltyRule3 (matrix)
  numPenalties = 0;
  [height, width] = size (matrix);
  for y = 1:height
    for x = 1:width
      if (((x + 6) <= width)
          && all (matrix(y, x:(x + 6)) == [1 0 1 1 1 0 1])
          && (all (matrix(y, max(1,x-4):x) == 0)
              || all (matrix(y, (x + 7):min(width, x + 11)) == 0)))
        numPenalties++;
      endif
      if (((y + 6) <= height)
          && (matrix(y:(y + 6), x) == [1 0 1 1 1 0 1])
          && (all (matrix(max(1,y-4):y, x) == 0)
              || all (matrix((y + 7):min(width, y + 11), x) == 0)))
        numPenalties++;
      endif
    endfor
  endfor
endfunction


## Apply mask penalty rule 4 and return the penalty.  Calculate the ratio of
## dark cells and give penalty if the ratio is far from 50%.  It gives 10
## penalty for 5% distance.
function fivePercentVariances = applyMaskPenaltyRule4 (matrix)
  numDarkCells = sum (sum (matrix));
  [height, width] = size (matrix);
  numTotalCells = height * width;
  fivePercentVariances = ...
    abs(numDarkCells * 2 - numTotalCells) * 10 / numTotalCells;
endfunction
