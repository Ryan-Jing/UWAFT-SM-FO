%% HappyPath.m
% A "Happy Path" simulation for the CACC State Machine
% Logic: Deactivated -> Standby -> Active -> Deactivated

clear; clc;

% =========================================================================
% 1. CONFIGURATION
% =========================================================================
modelName = 'cacc'; 

% Check if model is loaded to prevent "File changed on disk" warnings
if ~bdIsLoaded(modelName)
    load_system(modelName);
end

% Simulation time settings
endTime = 10;
stepSize = 0.1;
t = 0:stepSize:endTime;

% =========================================================================
% 2. GENERATE INPUT SIGNALS
% =========================================================================

% Initialize all signals. We use zeros() initially for easy math/indexing
numSteps = length(t);
acc_enable = zeros(numSteps, 1);
v2x_on     = zeros(numSteps, 1);
long_on    = zeros(numSteps, 1);
set_btn    = zeros(numSteps, 1);
cancel_btn = zeros(numSteps, 1);
brake      = zeros(numSteps, 1);
timeout    = zeros(numSteps, 1);

% --- DEFINE THE SCENARIO ---

% EVENT 1: T=2s -> Enable System
start_idx = find(t >= 2, 1);
acc_enable(start_idx:end) = 1;
v2x_on(start_idx:end)     = 1;
long_on(start_idx:end)    = 1;

% EVENT 2: T=5s -> Driver Presses SET
set_idx_start = find(t >= 5, 1);
set_idx_end   = find(t >= 6, 1);
set_btn(set_idx_start:set_idx_end) = 1;

% EVENT 3: T=8s -> Driver Cancels
cancel_idx_start = find(t >= 8, 1);
cancel_idx_end   = find(t >= 9, 1);
cancel_btn(cancel_idx_start:cancel_idx_end) = 1;

% =========================================================================
% 3. CREATE TIMESERIES (WITH LOGICAL CASTING)
% =========================================================================
% CRITICAL FIX: We wrap the data in logical(...) to convert double -> boolean

ACC_Enable_Pressed     = timeseries(logical(acc_enable), t);
V2X_Switch_ON          = timeseries(logical(v2x_on), t);
Longitudinal_Switch_ON = timeseries(logical(long_on), t);
SET_Pressed            = timeseries(logical(set_btn), t);
Cancel_Pressed         = timeseries(logical(cancel_btn), t);
Driver_Brakes          = timeseries(logical(brake), t);
Timeout_Event          = timeseries(logical(timeout), t);

% =========================================================================
% 4. PUSH TO BASE WORKSPACE & CONFIGURE MODEL
% =========================================================================

% Push variables to Base Workspace so Simulink can "see" them
assignin('base', 'ACC_Enable_Pressed', ACC_Enable_Pressed);
assignin('base', 'V2X_Switch_ON', V2X_Switch_ON);
assignin('base', 'Longitudinal_Switch_ON', Longitudinal_Switch_ON);
assignin('base', 'SET_Pressed', SET_Pressed);
assignin('base', 'Cancel_Pressed', Cancel_Pressed);
assignin('base', 'Driver_Brakes', Driver_Brakes);
assignin('base', 'Timeout_Event', Timeout_Event);

% Configure Model to read external inputs
set_param(modelName, 'LoadExternalInput', 'on');
inputMap = 'ACC_Enable_Pressed, V2X_Switch_ON, Longitudinal_Switch_ON, SET_Pressed, Cancel_Pressed, Driver_Brakes, Timeout_Event';
set_param(modelName, 'ExternalInput', inputMap);

% Open the Scope explicitly
try
    open_system([modelName '/Scope1']); 
catch
    % Scope might have a different name, ignore if not found
end

% =========================================================================
% 5. RUN SIMULATION
% =========================================================================
fprintf('Running simulation with LOGICAL inputs...\n');
out = sim(modelName);


try
    data = out.logsout.get('CurrentState').Values;
    
    figure;
    plot(data.Time, data.Data, 'LineWidth', 3);
    title('Debug Plot: CurrentState');
    grid on;
    ylabel('State (0=Deactivated, 1=Standby, 2=Active)');
    ylim([-0.5 2.5]);
    yticks([0 1 2]);
    fprintf('Plot generated. Check the new figure window.\n');
    
catch
    fprintf('ERROR: Could not find "CurrentState" in logs.\n');
    fprintf('Make sure the signal line going to Scope1 has "Log Selected Signals" turned on.\n');
end
fprintf('Done! Check your Scope window.\n');


