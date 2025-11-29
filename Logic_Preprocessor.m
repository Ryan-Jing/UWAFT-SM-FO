function [Flags, GenericInputs] = Logic_Preprocessor(Bus)
% This function runs CONTINUOUSLY outside the Stateflow Chart.
% It normalizes all the specific logic into generic "Ready" flags.

%% 1. Initialize Outputs
% "Flags" will tell Stateflow WHICH mode is allowed to go to Standby
Flags.ACC_Ready  = false;
Flags.CACC_Ready = false;
Flags.LCC_Ready  = false;
Flags.AIN_Ready  = false;
Flags.AP_Ready   = false;

% "GenericInputs" maps specific buttons to generic commands
GenericInputs.EnableCmd = false;
GenericInputs.CancelCmd = false;
GenericInputs.NextStateCmd = false; % e.g., Set/Resume or Finish

%% 2. Calculate Availability Logic (The "Different" Logic)

% --- ACC Logic ---
% Condition: Enable && V2X && Longitudinal Switch
Flags.ACC_Ready = Bus.ACCStatusBus.ACC_Enable_Pressed && ...
                  Bus.ACCStatusBus.V2X_Switch_ON && ...
                  Bus.ACCStatusBus.Longitudinal_Switch_ON;

% --- CACC Logic (Inferred) ---
% Condition: Enable && In Speed Range (Example)
Flags.CACC_Ready = Bus.CACCStatusBus.ACC_Enable_Pressed && ...
                   Bus.CACCStatusBus.In_CACC_Speed_Range;

% --- LCC Logic ---
% Condition: Centered && CACC Active && Speed > 35 && Lat Switch
Flags.LCC_Ready = Bus.LCCStatusBus.Lane_Change_Centred && ...
                  Bus.LCCStatusBus.CACC_Active && ...
                  Bus.LCCStatusBus.Speed_GT_35_MPH && ...
                  Bus.LCCStatusBus.Lateral_Switch_ON;

% --- AIN Logic (Dummy) ---
% Condition: Just check if button pressed
Flags.AIN_Ready = Bus.AINStatusBus.Activate_AIN_Pressed;

% --- AP Logic ---
% Condition: Long && Lat && Brakes && Stationary
Flags.AP_Ready = Bus.APStatusBus.Longitudinal_Switch_ON && ...
                 Bus.APStatusBus.Lateral_Switch_ON && ...
                 Bus.APStatusBus.Driver_Brakes && ...
                 Bus.APStatusBus.Is_Stationary;

%% 3. Map Buttons to Generic Commands (For the Lifecycle)
% This allows the generic state machine to know "User wants to Cancel"
% without knowing WHICH cancel button was pressed.

% Consolidate ALL Cancel buttons (OR logic)
GenericInputs.CancelCmd = Bus.ACCStatusBus.Cancel_Pressed || ...
                          Bus.CACCStatusBus.Cancel_Pressed || ...
                          Bus.LCCStatusBus.Cancel_LCC_Pressed || ...
                          Bus.AINStatusBus.Cancel_AIN_Pressed || ...
                          Bus.APStatusBus.Cancel_AP_Pressed;

% Consolidate ALL "Go To Active" buttons (Set/Resume/Finish)
GenericInputs.NextStateCmd = Bus.ACCStatusBus.Set_Resume || ...
                             Bus.CACCStatusBus.Set_Resume || ...
                             Bus.APStatusBus.Finish_Pressed;
                             % Note: LCC might auto-activate or use a button, add here if needed.

end