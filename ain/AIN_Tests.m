classdef AIN_Tests < matlab.unittest.TestCase
    % AIN_Tests
    % Unit tests for the AIN Stateflow chart.
    % Flow: Standby (1) -> Active (2) -> Deactivated (0)
    % Run with: results = runtests('AIN_Tests')

    properties
        modelName = 'ain' 
        
        inputOrder = {'Activate_AIN_Pressed', ...
                      'Cancel_AIN_Pressed'};
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end
            
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
        % TEST 1: Default State (Should be 1 - Standby)
        % =================================================================
        function test_DefaultState(testCase)
            time = [0; 1]; 
            in = testCase.createZeroInputs(time);
            
            simOut = testCase.runSim(in, 0);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 1, 'Default state should be Standby (1).');
        end
        
        % =================================================================
        % TEST 2: Standby -> Active (State 1 -> 2)
        % =================================================================
        function test_StandbyToActive(testCase)
            % Scenario: Press Activate at T=1
            time = [0; 1; 2];
            in = testCase.createZeroInputs(time);
            
            in.Activate_AIN_Pressed.Data = logical([0; 1; 1]);
            
            simOut = testCase.runSim(in, 2);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 2, 'State should transition to Active (2).');
        end
        
        % =================================================================
        % TEST 3: Active -> Deactivated (State 2 -> 0)
        % =================================================================
        function test_ActiveToDeactivated(testCase)
            % Scenario: Standby -> Activate -> Release -> Cancel
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroInputs(time);
            
           in.Activate_AIN_Pressed.Data = logical([0; 1; 0; 0; 0]);
            
            in.Cancel_AIN_Pressed.Data   = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 4);
            
            currentState = testCase.getOutputState(simOut);
            testCase.verifyEqual(currentState(end), 0, 'State should drop to Deactivated (0) after Cancel.');
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