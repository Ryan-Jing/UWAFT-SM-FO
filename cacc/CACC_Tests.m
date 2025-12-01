classdef CACC_Tests < matlab.unittest.TestCase
    properties
        modelName = 'cacc'
        % Order matters here
        inputOrder = {'ACC_Enable_Pressed', ...
                      'V2X_Switch_ON', ...
                      'Longitudinal_Switch_ON', ...
                      'Set_Resume', ...
                      'Cancel_Pressed', ...
                      'Driver_Brakes', ...
                      'Timeout_Event', ...
                      'In_CACC_Speed_Range'
                      };
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            % Load the model once before tests start
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end
            
            % Config logging data to read from script
            set_param(testCase.modelName, 'SignalLogging', 'on');
            set_param(testCase.modelName, 'SignalLoggingName', 'logsout');
            set_param(testCase.modelName, 'SaveOutput', 'on');
        end
    end
    
    methods(TestClassTeardown)
        function closeModel(testCase)
            % Cleanup after all tests are done
            close_system(testCase.modelName, 0);
        end
    end
    
    methods(Test)
        
        % =================================================================
        % TEST 1: Default State (Should be 0)
        % =================================================================
        function test_DefaultState(testCase)
            time = [0; 1]; 
            in = testCase.createZeroInputs(time);
            
            simOut = testCase.runSim(in, 0);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should start at Deactivated (0).');
        end
        
        % =================================================================
        % TEST 2: Deactivated -> Standby (State 0 -> 1)
        % =================================================================
        function test_DeactivatedToStandby(testCase)
            time = [0; 1; 2];
            in = testCase.createZeroInputs(time);
            
            in.ACC_Enable_Pressed.Data     = logical([0; 1; 1]);
            in.V2X_Switch_ON.Data          = logical([0; 1; 1]);
            in.Longitudinal_Switch_ON.Data = logical([0; 1; 1]);
            
            simOut = testCase.runSim(in, 2);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should be Standby (1) after enabling.');
        end
        
        % =================================================================
        % TEST 3: Standby -> Active (State 1 -> 2)
        % =================================================================
        function test_StandbyToActive(testCase)
            time = [0; 1; 2; 3];
            in = testCase.createZeroInputs(time);
            
            in.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1]);
            in.V2X_Switch_ON.Data          = logical([0; 1; 1; 1]);
            in.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1]);
            
            % Press SET
            in.Set_Resume.Data            = logical([0; 0; 1; 1]);
            in.In_CACC_Speed_Range.Data    = logical([0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 3);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 2, 'State should be Active (2) after pressing SET.');
        end
        
        % =================================================================
        % TEST 4: Active -> Standby (via Cancel) (State 2 -> 1)
        % =================================================================
        function test_ActiveToStandby_Cancel(testCase)
            % Scenario: Enable -> SET -> Release SET -> Cancel
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroInputs(time);
            
            in.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            in.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            in.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            in.Set_Resume.Data            = logical([0; 0; 1; 0; 0]);
            in.In_CACC_Speed_Range.Data   = logical([0; 0; 1; 0; 0]);
            
            in.Cancel_Pressed.Data         = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 4);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should drop to Standby (1) after Cancel.');
        end
        
        % =================================================================
        % TEST 5: Active -> Standby (via Brakes) (State 2 -> 1)
        % =================================================================
        function test_ActiveToStandby_Brake(testCase)
             % Scenario: Enable -> SET -> Release SET -> Brakes
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroInputs(time);
            
            in.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            in.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            in.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            in.Set_Resume.Data            = logical([0; 0; 1; 0; 0]);
            
            in.Driver_Brakes.Data          = logical([0; 0; 0; 1; 1]); 
            
            simOut = testCase.runSim(in, 4);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should drop to Standby (1) after Brakes.');
        end
        
        % =================================================================
        % TEST 6: Active -> Deactivated (via Timeout) (State 2 -> 0)
        % =================================================================
        function test_ActiveToDeactivated_Timeout(testCase)
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroInputs(time);
            
            in.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            in.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            in.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            in.Set_Resume.Data             = logical([0; 0; 1; 1; 1]);
            in.In_CACC_Speed_Range.Data    = logical([0; 0; 1; 1; 1]);
            
            in.Timeout_Event.Data          = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 4);
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should Crash to Deactivated (0) on Timeout.');
        end

    end
    
    methods(Access = private)
        function simOut = runSim(testCase, inputStruct, stopTime)
            mdl = testCase.modelName;
            
            for i = 1:numel(testCase.inputOrder)
                varName = testCase.inputOrder{i};
                if isfield(inputStruct, varName)
                    assignin('base', varName, inputStruct.(varName));
                else
                    error('Missing input variable in test structure: %s', varName);
                end
            end
            
            set_param(mdl, 'LoadExternalInput', 'on');
            inputMapStr = strjoin(testCase.inputOrder, ',');
            set_param(mdl, 'ExternalInput', inputMapStr);
            set_param(mdl, 'StopTime', num2str(stopTime));
            
            simOut = sim(mdl);
        end
        
        function stateData = getOutputState(~, simOut)
            rawObj = [];
            
            if isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
                rawObj = simOut.logsout.get('CurrentState');
            end
            
            if isempty(rawObj) && isprop(simOut, 'yout') && ~isempty(simOut.yout)
                 try
                    rawObj = simOut.yout.get('CurrentState');
                 catch
                 end
            end
            
            if isempty(rawObj)
                error('Could not find signal "CurrentState" in simulation output.');
            end
            
            while isa(rawObj, 'Simulink.SimulationData.Dataset')
                if rawObj.numElements > 0
                    rawObj = rawObj.get(1); 
                else
                    error('Found a Dataset named "CurrentState", but it is empty.');
                end
            end
            
            if isa(rawObj, 'Simulink.SimulationData.Signal')
                stateData = rawObj.Values.Data;
            elseif isa(rawObj, 'timeseries')
                stateData = rawObj.Data;
            else
                error('Found "CurrentState", but object type is unexpected: %s', class(rawObj));
            end
            
            % Easier to compare as double
            stateData = double(stateData);
        end
        
        function in = createZeroInputs(testCase, timeVector)
            for i = 1:numel(testCase.inputOrder)
                varName = testCase.inputOrder{i};
                ts = timeseries(false(size(timeVector)), timeVector);
                ts.Name = varName;
                ts = setinterpmethod(ts, 'zoh'); 
                in.(varName) = ts;
            end
        end
    end
end