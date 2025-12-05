%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RTMaps TLC Target for Simulink v2.7.1
%% Copyright 2013-2023 Intempora S.A.S.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% rtmaps_model2pck(model)
% rtmaps_model2pck(model, 'Param1Name', param1Val, 'Param2Name', param2Val, ...)
%
% Builds an RTMaps package from a model using the RTMaps TLC Target for Simulink
%
% This function does the following:
%   1. Loads the model
%   2. Sets 'rtmaps.tlc' as the the System Target File
%   3. If the list of ParamName, ParamValue pairs is not empty,
%      it sets the specified parameters using the corresponding values
%   4. Generates and builds the code for the RTMaps package
%   5. Closes the model WITHOUT SAVING the changes
%
% INPUT
%   model                    Name or handle of the model to build
%   'ParamName', paramVal... List of parameter, value pairs to configure
