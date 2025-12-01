classdef LCC_Tests < matlab.unittest.TestCase
    properties
        modelName = 'lcc'
        
        % The diagram implies two main bus inputs
        rootInputNames = {'LCC_Inputs', 'Current_State_Bus'};
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end
            
            % Define the Buses so the model inputs match the diagram types
            testCase.defineBuses();
            
            set_param(testCase.modelName, 'SignalLogging', 'on');
            set_param(testCase.modelName, 'SignalLoggingName', 'logsout');
            set_param(testCase.modelName, 'SaveOutput', 'on');
            
            % Ensure interpolation is off for boolean logic to work cleanly
            try
                set_param([testCase.modelName '/LCC_Inputs'], 'Interpolate', 'off');
                set_param([testCase.modelName '/Current_State_Bus'], 'Interpolate', 'off');
            catch
                % Ignore if blocks don't exist yet, but good practice
            end
        end
    end
    
    methods(TestClassTeardown)
        function closeModel(testCase)
            close_system(testCase.modelName, 0);
        end
    end
    
    methods(Test)
        
        % =================================================================
        % TEST 1: Default State
        % =================================================================
        function test_DefaultState(testCase)
            time = [0; 1]; 
            inputs = testCase.createInputs(time);
            
            simOut = testCase.runSim(inputs, 0);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should start at Deactivated (0).');
        end
        
        % =================================================================
        % TEST 2: Deactivated -> Standby
        % =================================================================
        % Diagram Logic: 
        % Lane_Change_Centred && Speed > 35 && Lateral_Switch_ON 
        % && APStatus == 0 && ACCStatus == 2
        function test_DeactivatedToStandby(testCase)
            time = [0; 1; 2];
            inputs = testCase.createInputs(time);
            
            % 1. Set LCC Inputs (Booleans)
            inputs.LCC_Inputs.Lane_Change_Centred.Data = logical([0; 1; 1]);
            inputs.LCC_Inputs.Speed_GT_35_MPH.Data     = logical([0; 1; 1]);
            inputs.LCC_Inputs.Lateral_Switch_ON.Data   = logical([0; 1; 1]);
            
            % 2. Set Current_State_Bus (Enums/Integers)
            % The diagram specifically checks for ACCStatus == 2 (Active)
            % and APStatus == 0 (Deactivated)
            inputs.Current_State_Bus.ACCStatus.Data(1:3) = StatusType.Active;      % 2
            inputs.Current_State_Bus.APStatus.Data(1:3)  = StatusType.Deactivated; % 0
            
            simOut = testCase.runSim(inputs, 2);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should be Standby (1) when conditions are met.');
        end
        
        % =================================================================
        % TEST 3: Standby -> Active
        % =================================================================
        % Diagram Logic: Activate_LCC_Pressed
        function test_StandbyToActive(testCase)
            time = [0; 1; 2; 3];
            inputs = testCase.createInputs(time);
            
            % Establish Standby conditions first
            inputs.LCC_Inputs.Lane_Change_Centred.Data = logical([0; 1; 1; 1]);
            inputs.LCC_Inputs.Speed_GT_35_MPH.Data     = logical([0; 1; 1; 1]);
            inputs.LCC_Inputs.Lateral_Switch_ON.Data   = logical([0; 1; 1; 1]);
            
            inputs.Current_State_Bus.ACCStatus.Data(1:4) = StatusType.Active;
            inputs.Current_State_Bus.APStatus.Data(1:4)  = StatusType.Deactivated;
            
            % Press Activate at T=2
            inputs.LCC_Inputs.Activate_LCC_Pressed.Data = logical([0; 0; 1; 1]);
            
            simOut = testCase.runSim(inputs, 3);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 2, 'State should be Active (2) after Activate is pressed.');
        end
        
        % =================================================================
        % TEST 4: Active -> Deactivated (via Cancel)
        % =================================================================
        % Diagram Logic: [LCC_Inputs.Cancel_LCC_Pressed] -> returns to Deactivated
        function test_ActiveToDeactivated_Cancel(testCase)
            time = [0; 1; 2; 3; 4];
            inputs = testCase.createInputs(time);
            
            % 1. Setup Active Conditions
            inputs.LCC_Inputs.Lane_Change_Centred.Data = logical([0; 1; 1; 1; 1]);
            inputs.LCC_Inputs.Speed_GT_35_MPH.Data     = logical([0; 1; 1; 1; 1]);
            inputs.LCC_Inputs.Lateral_Switch_ON.Data   = logical([0; 1; 1; 1; 1]);
            inputs.Current_State_Bus.ACCStatus.Data    = repmat(StatusType.Active, size(time));
            inputs.Current_State_Bus.APStatus.Data     = repmat(StatusType.Deactivated, size(time));
            inputs.LCC_Inputs.Activate_LCC_Pressed.Data = logical([0; 0; 1; 0; 0]);
            
            % 2. Press Cancel at T=3
            inputs.LCC_Inputs.Cancel_LCC_Pressed.Data   = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(inputs, 4);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should return to Deactivated (0) when Cancel is pressed.');
        end

        % =================================================================
        % TEST 5: Standby Logic Fail (ACC Not Active)
        % =================================================================
        % Verify we DO NOT go to Standby if ACC is not Active (ACCStatus != 2)
        function test_FailToStandby_ACCNotReady(testCase)
            time = [0; 1; 2];
            inputs = testCase.createInputs(time);
            
            % Valid inputs otherwise...
            inputs.LCC_Inputs.Lane_Change_Centred.Data = logical([0; 1; 1]);
            inputs.LCC_Inputs.Speed_GT_35_MPH.Data     = logical([0; 1; 1]);
            inputs.LCC_Inputs.Lateral_Switch_ON.Data   = logical([0; 1; 1]);
            
            % BUT ACC is only Standby (1), not Active (2)
            inputs.Current_State_Bus.ACCStatus.Data    = repmat(StatusType.Standby, size(time));
            
            simOut = testCase.runSim(inputs, 2);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'Should NOT enter Standby if ACC is not Active.');
        end
    end
    
    methods(Access = private)
        
        function simOut = runSim(testCase, inputs, stopTime)
            mdl = testCase.modelName;
            
            % Assign structs to base workspace
            assignin('base', 'LCC_Inputs', inputs.LCC_Inputs);
            assignin('base', 'Current_State_Bus', inputs.Current_State_Bus);
            
            set_param(mdl, 'LoadExternalInput', 'on');
            % Order must match the bus inputs expected by the model root
            set_param(mdl, 'ExternalInput', 'LCC_Inputs, Current_State_Bus');
            set_param(mdl, 'StopTime', num2str(stopTime));
            
            simOut = sim(mdl);
        end
        
        function inputs = createInputs(~, timeVector)
            % 1. Create LCC_Inputs Structure (Booleans)
            lccStruct = struct();
            lccFields = {'Lane_Change_Centred', 'Speed_GT_35_MPH', 'Lateral_Switch_ON', ...
                         'Activate_LCC_Pressed', 'Cancel_LCC_Pressed'};
            
            for i = 1:numel(lccFields)
                ts = timeseries(false(size(timeVector)), timeVector);
                ts.Name = lccFields{i};
                ts = setinterpmethod(ts, 'zoh'); 
                lccStruct.(lccFields{i}) = ts;
            end
            
            % 2. Create Current_State_Bus Structure (Enums)
            stateStruct = struct();
            stateFields = {'ACCStatus', 'APStatus'}; % Add others if needed (CACC, etc)
            
            defaultEnumVal = StatusType.Deactivated;
            enumArray = repmat(defaultEnumVal, size(timeVector));
            
            for i = 1:numel(stateFields)
                ts = timeseries(enumArray, timeVector);
                ts.Name = stateFields{i};
                ts = setinterpmethod(ts, 'zoh'); 
                stateStruct.(stateFields{i}) = ts;
            end
            
            inputs.LCC_Inputs = lccStruct;
            inputs.Current_State_Bus = stateStruct;
        end
        
        function stateData = getOutputState(~, simOut)
            rawObj = [];
            if isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
                rawObj = simOut.logsout.get('CurrentState');
            end
            if isempty(rawObj)
                 error('Could not find signal "CurrentState" in logsout.');
            end
            if isa(rawObj, 'Simulink.SimulationData.Dataset')
                rawObj = rawObj.get(1); 
            end
            stateData = double(rawObj.Values.Data);
        end
        
        function defineBuses(~)
            % Define LCC_Inputs Bus
            clear lcc_elems;
            lcc_elems(1) = Simulink.BusElement; lcc_elems(1).Name = 'Lane_Change_Centred'; lcc_elems(1).DataType = 'boolean';
            lcc_elems(2) = Simulink.BusElement; lcc_elems(2).Name = 'Speed_GT_35_MPH';     lcc_elems(2).DataType = 'boolean';
            lcc_elems(3) = Simulink.BusElement; lcc_elems(3).Name = 'Lateral_Switch_ON';   lcc_elems(3).DataType = 'boolean';
            lcc_elems(4) = Simulink.BusElement; lcc_elems(4).Name = 'Activate_LCC_Pressed';lcc_elems(4).DataType = 'boolean';
            lcc_elems(5) = Simulink.BusElement; lcc_elems(5).Name = 'Cancel_LCC_Pressed';  lcc_elems(5).DataType = 'boolean';
            LCCInputBus = Simulink.Bus; LCCInputBus.Elements = lcc_elems;
            assignin('base', 'LCCInputBus', LCCInputBus);
            
            % Define Current_State_Bus (Reusing specific fields from your ACC example)
            clear status_elems;
            status_elems(1) = Simulink.BusElement; status_elems(1).Name = 'ACCStatus'; status_elems(1).DataType = 'Enum: StatusType';
            status_elems(2) = Simulink.BusElement; status_elems(2).Name = 'APStatus';  status_elems(2).DataType = 'Enum: StatusType';
            % Add padding elements if your bus expects 5 elements like the ACC one did
            status_elems(3) = Simulink.BusElement; status_elems(3).Name = 'CACCStatus'; status_elems(3).DataType = 'Enum: StatusType';
            status_elems(4) = Simulink.BusElement; status_elems(4).Name = 'LCCStatus';  status_elems(4).DataType = 'Enum: StatusType';
            status_elems(5) = Simulink.BusElement; status_elems(5).Name = 'AINStatus';  status_elems(5).DataType = 'Enum: StatusType';
            
            CurrentStateBus = Simulink.Bus; CurrentStateBus.Elements = status_elems;
            assignin('base', 'CurrentStateBus', CurrentStateBus);
        end
    end
end