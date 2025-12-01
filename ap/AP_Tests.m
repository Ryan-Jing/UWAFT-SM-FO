classdef AP_Tests < matlab.unittest.TestCase
    % AP_Tests
    % Unit tests for the Automated Parking (AP) Stateflow chart.
    
    properties
        modelName = 'ap' 
        
        inputOrder = {'Longitudinal_Switch_ON', ... % 1
                      'Lateral_Switch_ON', ...      % 2
                      'Driver_Brakes', ...          % 3
                      'Is_Stationary', ...          % 4
                      'Activate_AP_Pressed', ...    % 5
                      'Parking_In_Range', ...       % 6 
                      'Finish_Pressed', ...         % 7
                      'Cancel_AP_Pressed'};         % 8
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end
            
            % Ensure Model is configured to log data correctly
            set_param(testCase.modelName, 'SignalLogging', 'on');
            set_param(testCase.modelName, 'SignalLoggingName', 'logsout');
            set_param(testCase.modelName, 'SaveOutput', 'on');
        end
    end
    
    methods(TestClassTeardown)
        function closeModel(testCase)
            close_system(testCase.modelName, 0);
        end
    end
    
    methods(Test)
        
        % =================================================================
        % TEST 1: Default State (Should be 0 - Deactivated)
        % =================================================================
        function test_DefaultState(testCase)
            time = [0; 1]; 
            in = testCase.createZeroInputs(time);
            
            simOut = testCase.runSim(in, 0);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'Default state should be Deactivated (0).');
        end
        
        % =================================================================
        % TEST 2: Deactivated -> Standby (State 0 -> 1)
        % =================================================================
        function test_DeactivatedToStandby(testCase)
            time = [0; 1; 2];
            in = testCase.createZeroInputs(time);
            
            in.Longitudinal_Switch_ON.Data = logical([0; 1; 1]);
            in.Lateral_Switch_ON.Data      = logical([0; 1; 1]);
            in.Driver_Brakes.Data          = logical([0; 1; 1]);
            in.Is_Stationary.Data          = logical([0; 1; 1]);
            in.Parking_In_Range.Data       = logical([0; 0; 0]);

            simOut = testCase.runSim(in, 2);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'State should transition to Standby (1).');
        end
        
        % =================================================================
        % TEST 3: Standby -> Active (State 1 -> 2)
        % =================================================================
        function test_StandbyToActive(testCase)
            time = [0; 1; 2; 3];
            in = testCase.createZeroInputs(time);
            
            % T=1: Establish Standby
            in.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1]);
            in.Lateral_Switch_ON.Data      = logical([0; 1; 1; 1]);
            in.Driver_Brakes.Data          = logical([0; 1; 1; 1]);
            in.Is_Stationary.Data          = logical([0; 1; 1; 1]);
            
            in.Parking_In_Range.Data       = logical([0; 1; 1; 1]);
            
            % T=2: Press Activate
            in.Activate_AP_Pressed.Data    = logical([0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 3);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 2, 'State should transition to Active (2).');
        end

        % =================================================================
        % TEST 4: Active -> Deactivated via CANCEL (State 2 -> 0)
        % =================================================================
        function test_ActiveToDeactivated_Cancel(testCase)
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroInputs(time);
            
            % Setup Standby -> Active flow
            in.Longitudinal_Switch_ON.Data = logical([1; 1; 1; 0; 0]);
            in.Lateral_Switch_ON.Data      = logical([1; 1; 1; 0; 0]);
            in.Driver_Brakes.Data          = logical([1; 1; 1; 0; 0]);
            in.Is_Stationary.Data          = logical([1; 1; 1; 0; 0]);
            in.Parking_In_Range.Data       = logical([1; 1; 1; 0; 0]);
            
            % T=1: Activate
            in.Activate_AP_Pressed.Data    = logical([0; 1; 1; 0; 0;]);
            
            % T=3: Press Cancel
            in.Cancel_AP_Pressed.Data      = logical([0; 0; 0; 1; 1;]);
            
            simOut = testCase.runSim(in, 4);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should return to Deactivated (0) after Cancel.');
        end

        % =================================================================
        % TEST 5: Active -> Deactivated via FINISH (State 2 -> 0)
        % =================================================================
        function test_ActiveToDeactivated_Finish(testCase)
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroInputs(time);
            
            % Setup Standby -> Active flow
            in.Longitudinal_Switch_ON.Data = logical([1; 1; 1; 0; 0]);
            in.Lateral_Switch_ON.Data      = logical([1; 1; 1; 0; 0]);
            in.Driver_Brakes.Data          = logical([1; 1; 1; 0; 0]);
            in.Is_Stationary.Data          = logical([1; 1; 1; 0; 0]);
            
            in.Parking_In_Range.Data       = logical([1; 1; 1; 1; 1]);
            
            % T=1: Activate
            in.Activate_AP_Pressed.Data    = logical([0; 1; 0; 0; 0]);
            
            % T=3: Press Finish
            in.Finish_Pressed.Data         = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 4);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should return to Deactivated (0) after Finish.');
        end
        
    end
    
    methods(Access = private)
        % =================================================================
        % HELPER: SIMULATION RUNNER
        % =================================================================
        function simOut = runSim(testCase, inputStruct, stopTime)
            mdl = testCase.modelName;
            
            % 1. Push variables to BASE workspace
            for i = 1:numel(testCase.inputOrder)
                varName = testCase.inputOrder{i};
                if isfield(inputStruct, varName)
                    assignin('base', varName, inputStruct.(varName));
                else
                    error('Missing input variable in test structure: %s', varName);
                end
            end
            
            % 2. Configure Model Parameters
            set_param(mdl, 'LoadExternalInput', 'on');
            inputMapStr = strjoin(testCase.inputOrder, ',');
            set_param(mdl, 'ExternalInput', inputMapStr);
            set_param(mdl, 'StopTime', num2str(stopTime));
            
            % 3. Run Simulation
            simOut = sim(mdl);
        end
        
        % =================================================================
        % HELPER: OUTPUT EXTRACTION
        % =================================================================
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
            
            stateData = double(stateData);
        end
        
        % =================================================================
        % HELPER: INPUT CREATION
        % =================================================================
        function in = createZeroInputs(testCase, timeVector)
            for i = 1:numel(testCase.inputOrder)
                varName = testCase.inputOrder{i};
                % Note: We use false/logical here because your model ports
                % are now set to boolean.
                ts = timeseries(false(size(timeVector)), timeVector);
                ts.Name = varName;
                ts = setinterpmethod(ts, 'zoh'); 
                in.(varName) = ts;
            end
        end
    end
    clear;
end