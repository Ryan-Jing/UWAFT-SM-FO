%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RTMaps TLC Target for Simulink v2.7.1
%% Copyright 2013-2023 Intempora S.A.S.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% rtmaps_function2pck(func)
% rtmaps_function2pck(func, 'Param1Name', param1Val, 'Param2Name', param2Val, ...)
%
% Builds an RTMaps package from a function using the RTMaps TLC Target for Simulink
%
% This function does the following:
%   1. Create a temporary Simulink model from "func" using "rtmaps_function2model"
%   2. Builds an RTMaps package from the created model using "rtmaps_model2pck"
%
% The generated RTMaps package is named '<function_name>_<function_type>.pck', such that:
%   * <function_name> is the name of the function
%   * <function_type> is 'm' for .m file functions, 'p' for p-coded .p file functions and 'b' for
%                     built-in functions. This suffix is useful for both identifying the type
%                     of the original function and avoiding any issues related to name shadowing
%                     when creating and using the temporary model
%
% INPUT
%   func                       function name or function handle
%   'ParamName', paramValue... List of parameter, value pairs to configure in the genrated temporary model
%
% Please see "rtmaps_function2model" and "rtmaps_model2pck" for details
% on the supported function types and model structure
%
% For p-coded functions, please note that "coder.allowpcode('plain');" must be used
% in the original .m version of the .p file before p-coding it
