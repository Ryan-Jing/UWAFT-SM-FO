classdef System_Supervisor_Tests < matlab.unittest.TestCase
    properties
        modelName = 'parent' %
        inputVarName = 'EventsBus_Input';
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            % Load the model
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end
            
            % Configure Logging
            set_param(testCase.modelName, 'SignalLogging', 'on');
            set_param(testCase.modelName, 'SignalLoggingName', 'logsout');
            set_param(testCase.modelName, 'SaveOutput', 'on');
            
            % IMPORTANT: Tell Simulink to look for our Struct in the Workspace
            set_param(testCase.modelName, 'LoadExternalInput', 'on');
            set_param(testCase.modelName, 'ExternalInput', testCase.inputVarName);
        end
    end
    
    methods(TestClassTeardown)
        function closeModel(testCase)
            close_system(testCase.modelName, 0);
        end
    end
    
    methods(Test)
        
        % =================================================================
        % TEST 1: Default State (Everything Off)
        % =================================================================
        function test_DefaultState(testCase)
            time = [0; 1]; 
            in = testCase.createZeroBusInputs(time);
            
            simOut = testCase.runSim(in, 1);
            mode = testCase.getOutputMode(simOut);
            
            % Expect Mode 0 (Deactivated)
            testCase.verifyEqual(mode(end), 0, 'System should start in Mode 0 (Deactivated).');
        end
        
        % =================================================================
        % TEST 2: ACC Lifecycle (Mode 1)
        % Logic: Enable && V2X && Longitudinal -> Standby
        % =================================================================
        function test_ACC_Lifecycle(testCase)
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroBusInputs(time);
            
            % 1. Activate ACC Conditions (t=1)
            in.ACCStatusBus.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            in.ACCStatusBus.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            in.ACCStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            % 2. Press Set/Resume to go Active (t=2)
            in.ACCStatusBus.Set_Resume.Data             = logical([0; 0; 1; 1; 1]);
            
            % 3. Press Cancel (t=3)
            in.ACCStatusBus.Cancel_Pressed.Data         = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 4);
            mode = testCase.getOutputMode(simOut);
            
            % Check t=1.5 (Should be Standby/ACC selected -> Mode 1)
            testCase.verifyEqual(testCase.sampleAt(mode, time, 1.5), 1, 'Should be in ACC Mode (1) after Enable conditions met.');
            
            % Check t=3.5 (Should be Deactivated -> Mode 0 or 1 depending on logic)
            % *Note: If Cancel goes to Standby, it stays 1. If Cancel goes to Deactivated, it becomes 0.
            % Based on your chart, Cancel -> Deactivated if Global_Standby handles it.
            % But check your logic: Cancel usually goes Active->Standby.
            
            testCase.verifyEqual(mode(end), 0, 'Should return to Mode 0 (Deactivated) after Cancel.'); 
        end

        % =================================================================
        % TEST 3: AP Lifecycle (Mode 5) - Complex Logic
        % Logic: Long && Lat && Brakes && Stationary -> Standby
        % =================================================================
        function test_AP_Lifecycle(testCase)
            time = [0; 1; 2];
            in = testCase.createZeroBusInputs(time);
            
            % 1. Set Partial Conditions (Should NOT activate)
            in.APStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1; 1]);
            in.APStatusBus.Lateral_Switch_ON.Data      = logical([0; 1; 1]);
            in.APStatusBus.Driver_Brakes.Data          = logical([0; 1; 1]);
            % Missing 'Is_Stationary' at t=1
            
            % 2. Set All Conditions (t=2)
            in.APStatusBus.Is_Stationary.Data          = logical([0; 0; 1]);
            
            simOut = testCase.runSim(in, 2);
            mode = testCase.getOutputMode(simOut);
            
            % At t=1, should still be 0 (Condition not met)
            testCase.verifyEqual(testCase.sampleAt(mode, time, 1.0), 0, 'AP should NOT activate if Stationary is missing.');
            
            % At t=2, should be 5 (AP Selected)
            testCase.verifyEqual(mode(end), 5, 'AP should activate (Mode 5) when all flags are true.');
        end

        % =================================================================
        % TEST 4: LCC Lifecycle (Mode 3)
        % Logic: Centered && CACC && Speed>35 && LatSwitch -> Standby
        % =================================================================
        function test_LCC_Lifecycle(testCase)
            time = [0; 1];
            in = testCase.createZeroBusInputs(time);
            
            in.LCCStatusBus.Lane_Change_Centred.Data = logical([0; 1]);
            in.LCCStatusBus.CACC_Active.Data         = logical([0; 1]);
            in.LCCStatusBus.Speed_GT_35_MPH.Data     = logical([0; 1]);
            in.LCCStatusBus.Lateral_Switch_ON.Data   = logical([0; 1]);
            
            simOut = testCase.runSim(in, 1);
            mode = testCase.getOutputMode(simOut);
            
            testCase.verifyEqual(mode(end), 3, 'LCC (Mode 3) should be active.');
        end
        
        % =================================================================
        % TEST 5: Arbitration (AP Priority over ACC?)
        % Check what happens if BOTH are valid.
        % =================================================================
        function test_Arbitration(testCase)
            time = [0; 1];
            in = testCase.createZeroBusInputs(time);
            
            % Enable ACC
            in.ACCStatusBus.ACC_Enable_Pressed.Data     = logical([0; 1]);
            in.ACCStatusBus.V2X_Switch_ON.Data          = logical([0; 1]);
            in.ACCStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1]);
            
            % Enable AP (Simultaneously)
            in.APStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1]);
            in.APStatusBus.Lateral_Switch_ON.Data      = logical([0; 1]);
            in.APStatusBus.Driver_Brakes.Data          = logical([0; 1]);
            in.APStatusBus.Is_Stationary.Data          = logical([0; 1]);
            
            simOut = testCase.runSim(in, 1);
            mode = testCase.getOutputMode(simOut);
            
            % Look at your Stateflow Transitions numbers. 
            % If ACC transition is '1' and AP is '3' or '4', ACC wins.
            % Adjust this expectation based on your specific transition priority.
            currentVal = mode(end);
            disp(['Arbitration Result: ' num2str(currentVal)]);
            
            % Assuming ACC has priority 1:
            testCase.verifyEqual(currentVal, 1, 'ACC should take priority if transition 1 is ACC.');
        end
        
    end
    
    methods(Access = private)
        
        function simOut = runSim(testCase, inputStruct, stopTime)
            % Assign the Struct-of-Timeseries to the Workspace
            assignin('base', testCase.inputVarName, inputStruct);
            
            % Run Simulation
            set_param(testCase.modelName, 'StopTime', num2str(stopTime));
            simOut = sim(testCase.modelName);
        end
        
        function val = sampleAt(~, signalData, timeVec, sampleTime)
            % Helper to find value at specific time
            % Assumes signalData and timeVec are same length
            [~, idx] = min(abs(timeVec - sampleTime));
            val = signalData(idx);
        end
        
        function modeData = getOutputMode(~, simOut)
            % Standard extraction of "System_Mode"
            % Tries logsout first, then yout
            rawObj = [];
            if isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
                try rawObj = simOut.logsout.get('System_Mode'); catch, end
            end
            if isempty(rawObj) && isprop(simOut, 'yout') && ~isempty(simOut.yout)
                 try rawObj = simOut.yout.get('System_Mode'); catch, end
            end
            
            if isempty(rawObj), error('Could not find "System_Mode" in output.'); end
            
            while isa(rawObj, 'Simulink.SimulationData.Dataset')
                rawObj = rawObj.get(1); 
            end
            modeData = double(rawObj.Values.Data);
        end
        
        function in = createZeroBusInputs(~, timeVector)
            % ============================================================
            % AUTO-GENERATING THE BUS INPUT STRUCTURE
            % ============================================================
            % This mimics your actual Bus definitions using TimeSeries
            
            zeroTS = timeseries(false(size(timeVector)), timeVector);
            zeroTS = setinterpmethod(zeroTS, 'zoh');
            
            % --- ACC Inputs ---
            in.ACCStatusBus.ACC_Enable_Pressed     = zeroTS;
            in.ACCStatusBus.V2X_Switch_ON          = zeroTS;
            in.ACCStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.ACCStatusBus.Set_Resume             = zeroTS;
            in.ACCStatusBus.Cancel_Pressed         = zeroTS;
            in.ACCStatusBus.Driver_Brakes          = zeroTS;
            in.ACCStatusBus.Timeout_Event          = zeroTS;
            in.ACCStatusBus.In_CACC_Speed_Range    = zeroTS;

            % --- CACC Inputs ---
            in.CACCStatusBus.ACC_Enable_Pressed     = zeroTS;
            in.CACCStatusBus.V2X_Switch_ON          = zeroTS;
            in.CACCStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.CACCStatusBus.Set_Resume             = zeroTS;
            in.CACCStatusBus.Cancel_Pressed         = zeroTS;
            in.CACCStatusBus.Driver_Brakes          = zeroTS;
            in.CACCStatusBus.Timeout_Event          = zeroTS;
            in.CACCStatusBus.In_CACC_Speed_Range    = zeroTS;

            % --- AP Inputs ---
            in.APStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.APStatusBus.Lateral_Switch_ON      = zeroTS;
            in.APStatusBus.Driver_Brakes          = zeroTS;
            in.APStatusBus.Is_Stationary          = zeroTS;
            in.APStatusBus.Activate_AP_Pressed    = zeroTS;
            in.APStatusBus.Parking_In_Range       = zeroTS;
            in.APStatusBus.Finish_Pressed         = zeroTS;
            in.APStatusBus.Cancel_AP_Pressed      = zeroTS;

            % --- LCC Inputs ---
            in.LCCStatusBus.Lane_Change_Centred      = zeroTS;
            in.LCCStatusBus.CACC_Active              = zeroTS;
            in.LCCStatusBus.Speed_GT_35_MPH          = zeroTS;
            in.LCCStatusBus.Lateral_Switch_ON        = zeroTS;
            in.LCCStatusBus.Activate_LCC_Pressed     = zeroTS;
            in.LCCStatusBus.Cancel_LCC_Pressed       = zeroTS;
            in.LCCStatusBus.Driver_Inactivity_Detected = zeroTS;
            
            % --- AIN Inputs ---
            in.AINStatusBus.Activate_AIN_Pressed = zeroTS;
            in.AINStatusBus.Cancel_AIN_Pressed   = zeroTS;
        end
    end
end