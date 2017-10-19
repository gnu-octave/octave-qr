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

## Represents a polynomial whose coefficients are elements of a GF.
## Much credit is due to William Rucklidge since portions of this code are an
## indirect port of his C++ Reed-Solomon implementation.
classdef GenericGFPoly < handle

  properties
    field;
    coefficients;
  endproperties

  methods
    ## field - The GenericGF instance representing the field to use to
    ##         perform computations.
    ## coefficients - Coefficients as ints representing elements of GF(size),
    ##                arranged from most significant (highest-power term)
    ##                coefficient to least significant.
    function obj = GenericGFPoly (field, coefficients)
      if (nargin != 2)
        print_usage ();
      endif
      if (isempty (coefficients))
        error ("GenericGFPoly: coefficients may not be empty.");
      endif
      ## Strip leading zeros
      while (length (coefficients) > 1 && coefficients(1) == 0)
        coefficients = coefficients(2:end);
      endwhile
      obj.field = field;
      obj.coefficients = coefficients;
    endfunction


    function ret = getCoefficients (obj)
      ret = obj.coefficients;
    endfunction


    ## Return degree of this polynomial.
    function ret = getDegree (obj)
      ret = length (obj.coefficients) - 1;
    endfunction


    ## Return true iff this polynomial is the monomial "0".
    function bool = isZero (obj)
      bool = (obj.coefficients(1) == 0);
    endfunction


    ## Return coefficient of x^degree term in this polynomial.
    function ret = getCoefficient (obj, degree)
      ret = obj.coefficients(end - degree);
    endfunction


    ## Return evaluation of this polynomial at a given point.
    function ret = evaluateAt(obj, a)
      if (a == 0)
        ## Just return the x^0 coefficient
        ret = obj.coefficients(end);
      elseif (a == 1)
        ## Just the sum of the coefficients
        ret = 0;
        for i = 1:length(obj.coefficients)
          ret = bitxor (ret, obj.coefficients(i));
        endfor
      else
        ret = coefficients(1);
        for i = 1:length(obj.coefficients)
          ret = bitxor (obj.field.multiply(a, ret), obj.coefficients(i));
        endfor
      endif
    endfunction


    function ret = addOrSubtract (obj, other)
      if (obj.isZero ())
        ret = other;
        return;
      endif
      if (other.isZero ())
        ret = obj;
        return;
      endif

      a = obj.coefficients;
      b = other.coefficients;
      max_len = max (length (a), length (b));
      ## Make both coefficient vectors same size.
      a = [zeros(1, max_len - length (a)), a];
      b = [zeros(1, max_len - length (b)), b];

      ret = GenericGFPoly (obj.field, bitxor (a, b));
    endfunction


    function ret = multiply (obj, other)
      if (obj.isZero() || other.isZero())
        ret = obj.field.getZero();
        return;
      endif
      a = obj.coefficients;
      b = other.coefficients;
      product = uint32 (zeros (1, length (a) + length (b) - 1));
      for i = 1:length (a)
        for j = 1:length (b)
          product(i - 1 + j) = bitxor (product(i - 1 + j),
                                       obj.field.multiply (a(i), b(j)));
        endfor
      endfor
      ret = GenericGFPoly (obj.field, product);
    endfunction


    function ret = multiplyByMonomial (obj, degree, coefficient)
      if (degree < 0)
        error ("GenericGFPoly: degree may not be negative.");
      endif
      if (coefficient == 0)
        ret = obj.field.getZero ();
        return;
      endif
      product = uint32 (zeros (1, length (obj.coefficients) + degree));
      for i = 1:length (obj.coefficients)
        product(i) = obj.field.multiply (obj.coefficients(i), coefficient);
      endfor
      ret = GenericGFPoly (obj.field, product);
    endfunction


    function [quotient, remainder] = divide (obj, other)
      if (other.isZero())
        error ("GenericGFPoly: Divide by 0.");
      endif

      quotient = obj.field.getZero ();
      remainder = obj;

      denominatorLeadingTerm = other.coefficients(1);
      inverseDenominatorLeadingTerm = obj.field.inverse(denominatorLeadingTerm);

      while ((remainder.getDegree () >= other.getDegree ()) ...
             && ! remainder.isZero ())
        degreeDifference = remainder.getDegree() - other.getDegree();
        scale = obj.field.multiply (remainder.getCoefficient(remainder.getDegree()), inverseDenominatorLeadingTerm);
        term = other.multiplyByMonomial (degreeDifference, scale);
        iterationQuotient = obj.field.buildMonomial(degreeDifference, scale);
        quotient = quotient.addOrSubtract (iterationQuotient);
        remainder = remainder.addOrSubtract (term);
      endwhile
    endfunction

    function disp(obj)
      for i = length (obj.coefficients):-1:1
        coefficient = obj.coefficients(i);
        if (coefficient != 0)
          if (coefficient < 0)
            fprintf (" - ");
            coefficient = -coefficient;
          else
            if (i != length (obj.coefficients))
              fprintf (" + ");
            endif
          endif
          if (i == 1 || coefficient != 1)
            alphaPower = obj.field.log(coefficient);
            if (alphaPower == 0)
              fprintf ('1');
            elseif (alphaPower == 1)
              fprintf ('a');
            else
              fprintf ("a^%d", alphaPower);
            endif
          endif
          if (i != 1)
            if (i == 2)
              fprintf ("x");
            else
              fprintf ("x^%d", i);
            endif
          endif
        endif
      endfor
    endfunction

  endmethods

endclassdef
