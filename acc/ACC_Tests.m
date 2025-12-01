classdef ACC_Tests < matlab.unittest.TestCase
    properties
        modelName = 'acc'
        
        rootInputNames = {'ACC_Inputs', 'Current_State_Bus'};
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end
            
            testCase.defineBuses();
            
            set_param(testCase.modelName, 'SignalLogging', 'on');
            set_param(testCase.modelName, 'SignalLoggingName', 'logsout');
            set_param(testCase.modelName, 'SaveOutput', 'on');

            
            set_param([testCase.modelName '/Current_State_Bus'], 'Interpolate', 'off');
            set_param([testCase.modelName '/ACC_Inputs'], 'Interpolate', 'off');
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
        function test_DeactivatedToStandby(testCase)
            time = [0; 1; 2];
            inputs = testCase.createInputs(time);
            
            % Modify ACC_Inputs
            inputs.ACC_Inputs.ACC_Enable_Pressed.Data     = logical([0; 1; 1]);
            inputs.ACC_Inputs.V2X_Switch_ON.Data          = logical([0; 1; 1]);
            inputs.ACC_Inputs.Longitudinal_Switch_ON.Data = logical([0; 1; 1]);
            
            % Modify Current_State_Bus (Must be Enum type)
            inputs.Current_State_Bus.APStatus.Data(1:3)   = StatusType.Deactivated;
            
            simOut = testCase.runSim(inputs, 2);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should be Standby (1).');
        end
        
        % =================================================================
        % TEST 3: Standby -> Active
        % =================================================================
        function test_StandbyToActive(testCase)
            time = [0; 1; 2; 3];
            inputs = testCase.createInputs(time);
            
            inputs.ACC_Inputs.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1]);
            inputs.ACC_Inputs.V2X_Switch_ON.Data          = logical([0; 1; 1; 1]);
            inputs.ACC_Inputs.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1]);
            
            inputs.Current_State_Bus.APStatus.Data(1:4)   = StatusType.Deactivated;
            
            inputs.ACC_Inputs.Set_Resume.Data             = logical([0; 0; 1; 1]);
            inputs.ACC_Inputs.In_CACC_Speed_Range.Data    = logical([0; 0; 1; 1]);
            
            simOut = testCase.runSim(inputs, 3);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 2, 'State should be Active (2).');
        end
        
        % =================================================================
        % TEST 4: Active -> Standby (via Cancel)
        % =================================================================
        function test_ActiveToStandby_Cancel(testCase)
            time = [0; 1; 2; 3; 4];
            inputs = testCase.createInputs(time);
            
            inputs.ACC_Inputs.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            inputs.ACC_Inputs.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            inputs.ACC_Inputs.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            inputs.Current_State_Bus.APStatus.Data(1:5)   = StatusType.Deactivated;
            
            inputs.ACC_Inputs.Set_Resume.Data             = logical([0; 0; 1; 0; 0]);
            inputs.ACC_Inputs.In_CACC_Speed_Range.Data    = logical([0; 0; 1; 0; 0]);
            inputs.ACC_Inputs.Cancel_Pressed.Data         = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(inputs, 4);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should drop to Standby (1).');
        end
        
        % =================================================================
        % TEST 5: Active -> Standby (via Brakes)
        % =================================================================
        function test_ActiveToStandby_Brake(testCase)
            time = [0; 1; 2; 3; 4];
            inputs = testCase.createInputs(time);
            
            inputs.ACC_Inputs.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            inputs.ACC_Inputs.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            inputs.ACC_Inputs.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            inputs.Current_State_Bus.APStatus.Data(1:5)   = StatusType.Deactivated;
            
            inputs.ACC_Inputs.Set_Resume.Data             = logical([0; 0; 1; 0; 0]);
            inputs.ACC_Inputs.In_CACC_Speed_Range.Data    = logical([0; 0; 1; 0; 0]);
            inputs.ACC_Inputs.Driver_Brakes.Data          = logical([0; 0; 0; 1; 1]); 
            
            simOut = testCase.runSim(inputs, 4);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should drop to Standby (1).');
        end
        
        % =================================================================
        % TEST 6: Active -> Deactivated (via Timeout)
        % =================================================================
        function test_ActiveToDeactivated_Timeout(testCase)
            time = [0; 1; 2; 3; 4];
            inputs = testCase.createInputs(time);
            
            inputs.ACC_Inputs.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            inputs.ACC_Inputs.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            inputs.ACC_Inputs.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            inputs.Current_State_Bus.APStatus.Data(1:5)   = StatusType.Deactivated;
            
            inputs.ACC_Inputs.Set_Resume.Data             = logical([0; 0; 1; 1; 1]);
            inputs.ACC_Inputs.In_CACC_Speed_Range.Data    = logical([0; 0; 1; 1; 1]);
            inputs.ACC_Inputs.Timeout_Event.Data          = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(inputs, 4);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should Crash to Deactivated (0).');
        end
    end
    
    methods(Access = private)
        
        function simOut = runSim(testCase, inputs, stopTime)
            mdl = testCase.modelName;
            
            % Assign structs to base workspace
            assignin('base', 'ACC_Inputs', inputs.ACC_Inputs);
            assignin('base', 'Current_State_Bus', inputs.Current_State_Bus);
            
            set_param(mdl, 'LoadExternalInput', 'on');
            % Order must match comma separated list
            set_param(mdl, 'ExternalInput', 'ACC_Inputs, Current_State_Bus');
            set_param(mdl, 'StopTime', num2str(stopTime));
            
            simOut = sim(mdl);
        end
        
        function inputs = createInputs(~, timeVector)
            accStruct = struct();
            accFields = {'ACC_Enable_Pressed', 'V2X_Switch_ON', 'Longitudinal_Switch_ON', ...
                         'Set_Resume', 'Cancel_Pressed', 'Driver_Brakes', 'Timeout_Event', 'In_CACC_Speed_Range'};
            
            for i = 1:numel(accFields)
                ts = timeseries(false(size(timeVector)), timeVector);
                ts.Name = accFields{i};
                ts = setinterpmethod(ts, 'zoh'); 
                accStruct.(accFields{i}) = ts;
            end
            
            stateStruct = struct();
            stateFields = {'ACCStatus', 'CACCStatus', 'LCCStatus', 'AINStatus', 'APStatus'};
            
            defaultEnumVal = StatusType.Deactivated;
            enumArray = repmat(defaultEnumVal, size(timeVector));
            
            for i = 1:numel(stateFields)
                ts = timeseries(enumArray, timeVector);
                ts.Name = stateFields{i};
                ts = setinterpmethod(ts, 'zoh'); 
                stateStruct.(stateFields{i}) = ts;
            end
            
            inputs.ACC_Inputs = accStruct;
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
            clear acc_elems;
            acc_elems(1) = Simulink.BusElement; acc_elems(1).Name = 'ACC_Enable_Pressed'; acc_elems(1).DataType = 'boolean';
            acc_elems(2) = Simulink.BusElement; acc_elems(2).Name = 'V2X_Switch_ON'; acc_elems(2).DataType = 'boolean';
            acc_elems(3) = Simulink.BusElement; acc_elems(3).Name = 'Longitudinal_Switch_ON'; acc_elems(3).DataType = 'boolean';
            acc_elems(4) = Simulink.BusElement; acc_elems(4).Name = 'Set_Resume'; acc_elems(4).DataType = 'boolean';
            acc_elems(5) = Simulink.BusElement; acc_elems(5).Name = 'Cancel_Pressed'; acc_elems(5).DataType = 'boolean';
            acc_elems(6) = Simulink.BusElement; acc_elems(6).Name = 'Driver_Brakes'; acc_elems(6).DataType = 'boolean';
            acc_elems(7) = Simulink.BusElement; acc_elems(7).Name = 'Timeout_Event'; acc_elems(7).DataType = 'boolean';
            acc_elems(8) = Simulink.BusElement; acc_elems(8).Name = 'In_CACC_Speed_Range'; acc_elems(8).DataType = 'boolean';
            ACCStatusBus = Simulink.Bus; ACCStatusBus.Elements = acc_elems;
            assignin('base', 'ACCStatusBus', ACCStatusBus);

            clear status_elems;
            status_elems(1) = Simulink.BusElement; status_elems(1).Name = 'ACCStatus'; status_elems(1).DataType = 'Enum: StatusType';
            status_elems(2) = Simulink.BusElement; status_elems(2).Name = 'CACCStatus'; status_elems(2).DataType = 'Enum: StatusType';
            status_elems(3) = Simulink.BusElement; status_elems(3).Name = 'LCCStatus'; status_elems(3).DataType = 'Enum: StatusType';
            status_elems(4) = Simulink.BusElement; status_elems(4).Name = 'AINStatus'; status_elems(4).DataType = 'Enum: StatusType';
            status_elems(5) = Simulink.BusElement; status_elems(5).Name = 'APStatus'; status_elems(5).DataType = 'Enum: StatusType';
            CurrentStateBus = Simulink.Bus; CurrentStateBus.Elements = status_elems;
            assignin('base', 'CurrentStateBus', CurrentStateBus);
        end
    end
end