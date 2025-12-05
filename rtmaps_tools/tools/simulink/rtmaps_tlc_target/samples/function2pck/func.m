function [h] = func(a, b)  %#codegen
% The directive %#codegen indicates that the function is intended for code generation

% this allows the generation of C code from the p-coded version of this function
coder.allowpcode('plain');

% matlab's hypot()
h = sqrt(a^2 + b^2);
