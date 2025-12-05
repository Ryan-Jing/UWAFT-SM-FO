%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RTMaps TLC Target for Simulink v2.7.1
%% Copyright 2013-2023 Intempora S.A.S.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% model_handle = rtmaps_function2model(func)
% model_handle = rtmaps_function2model(func, show_gui)
%
% Creates a Simulink model from a function
%
% This function does the following:
%   1. Generates a Simulink model that has a "MATLAB Function" block
%   2. Sets func as the block's function
%      1. If the function's source code is available, it used as the block's source code
%      2. If the function's source code is not available (i.e. p-coded file or built-in function)
%         then the function call is wrapped and set as the block's source code
%   3. Adds the proper amount of INports and OUTports to the model and connects them
%      to the "MATLAB Function" block
%
% The following function types for "func" are supported:
%   * .m file functions
%   * p-coded, .p file functions.
%   * Built-in functions
%
% All the above function types must have:
%   * At least 1 input argument
%   * At least 1 output variable
%   * No "varargin"
%   * No "varargout"
%
% INPUT
%   func     function name or function handle
%   show_gui If true, shows the Simulink main window (default=false)
%
% OUTPUT
%   model_handle handle to the created model
