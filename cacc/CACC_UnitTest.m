classdef CACC_UnitTest < matlab.unittest.TestCase
    % CACC_UnitTest Unit tests for the cacc.slx Stateflow chart.
    %
    % To run these tests:
    % 3. In the MATLAB Command Window, type:
    %    results = runtests('CACC_UnitTest')
    
    properties
        modelName = 'cacc' % .slx file
    end
    
    methods(TestClassSetup)
        % This runs once before all tests
        function loadModel(testCase)
            % Load the Simulink model
            disp(['Loading model: ' testCase.modelName]);
            load_system(testCase.modelName);
        end
    end
    
    methods(TestClassTeardown)
        % This runs once after all tests
        function closeModel(testCase)
            % Close the Simulink model without saving
            disp(['Closing model: ' testCase.modelName]);
            close_system(testCase.modelName, 0);
        end
    end
    
    methods(Test)
        % Test 1: Verify the default state is CACC_Deactivated
        function test_DefaultState(testCase)
            time = [0]; % Test at t=0
            in = testCase.createDefaultInputs(time);
            simOut = testCase.runSim(in, 0);
            
            % --- FIX: Must use testCase to call private methods ---
            [white_light, green_light] = testCase.getOutputs(simOut);
            
            % Verify
            testCase.verifyEqual(white_light.Data(end), false, 'Default state: White light should be FALSE.');
            testCase.verifyEqual(green_light.Data(end), false, 'Default state: Green light should be FALSE.');
        end
        
        % Test 2: Deactivated -> Standby
        function test_DeactivatedToStandby(testCase)
            time = [0; 1; 2]; % t=0: Init, t=1: Trigger, t=2: Hold
            in = testCase.createDefaultInputs(time);
            
            in.ACC_Enable_Pressed.Data   = [false; true; true];
            in.V2X_Switch_ON.Data      = [false; true; true];
            in.Longitudinal_Switch_ON.Data = [false; true; true];
            
            simOut = testCase.runSim(in, 2);
            % --- FIX: Must use testCase to call private methods ---
            [white_light, green_light] = testCase.getOutputs(simOut);
            
            % Verify
            testCase.verifyEqual(white_light.Data(end), true, 'State should be Standby: White light should be TRUE.');
            testCase.verifyEqual(green_light.Data(end), false, 'State should be Standby: Green light should be FALSE.');
        end
        
        % Test 3: Standby -> Active
        function test_StandbyToActive(testCase)
            time = [0; 1; 2; 3]; % t=0: Init, t=1: Go to Standby, t=2: Press SET, t=3: Hold
            in = testCase.createDefaultInputs(time);
            
            in.ACC_Enable_Pressed.Data   = [false; true; true; true];
            in.V2X_Switch_ON.Data      = [false; true; true; true];
            in.Longitudinal_Switch_ON.Data = [false; true; true; true];
            in.SET_Pressed.Data          = [false; false; true; true];
            
            simOut = testCase.runSim(in, 3);
            % --- FIX: Must use testCase to call private methods ---
            [white_light, green_light] = testCase.getOutputs(simOut);
            
            % Verify transition to Active
            testCase.verifyEqual(white_light.Data(end), false, 'State should be Active: White light should be FALSE.');
            testCase.verifyEqual(green_light.Data(end), true, 'State should be Active: Green light should be TRUE.');
        end
        
        % Test 4: Active -> Standby (via Cancel_Pressed)
        function test_ActiveToStandby_Cancel(testCase)
            time = [0; 1; 2; 3; 4]; % t=1: Standby, t=2: Active, t=3: Press Cancel, t=4: Hold
            in = testCase.createDefaultInputs(time);
            
            in.ACC_Enable_Pressed.Data   = [false; true; true; true; true];
            in.V2X_Switch_ON.Data      = [false; true; true; true; true];
            in.Longitudinal_Switch_ON.Data = [false; true; true; true; true];
            in.SET_Pressed.Data          = [false; false; true; true; true];
            in.Cancel_Pressed.Data       = [false; false; false; true; true];
            
            simOut = testCase.runSim(in, 4);
            % --- FIX: Must use testCase to call private methods ---
            [white_light, green_light] = testCase.getOutputs(simOut);
            
            % Verify transition back to Standby
            testCase.verifyEqual(white_light.Data(end), true, 'State should be Standby: White light should be TRUE.');
            testCase.verifyEqual(green_light.Data(end), false, 'State should be Standby: Green light should be FALSE.');
        end
        
        % Test 5: Active -> Standby (via Driver_Brakes)
        function test_ActiveToStandby_Brake(testCase)
            time = [0; 1; 2; 3; 4]; % t=1: Standby, t=2: Active, t=3: Press Brakes, t=4: Hold
            in = testCase.createDefaultInputs(time);
            
            in.ACC_Enable_Pressed.Data   = [false; true; true; true; true];
            in.V2X_Switch_ON.Data      = [false; true; true; true; true];
            in.Longitudinal_Switch_ON.Data = [false; true; true; true; true];
            in.SET_Pressed.Data          = [false; false; true; true; true];
            in.Driver_Brakes.Data        = [false; false; false; true; true];
            
            simOut = testCase.runSim(in, 4);
            % --- FIX: Must use testCase to call private methods ---
            [white_light, green_light] = testCase.getOutputs(simOut);
            
            % Verify transition back to Standby
            testCase.verifyEqual(white_light.Data(end), true, 'State should be Standby: White light should be TRUE.');
            testCase.verifyEqual(green_light.Data(end), false, 'State should be Standby: Green light should be FALSE.');
        end
        
        % Test 6: Active -> Deactivated (via Timeout)
        function test_ActiveToDeactivated_Timeout(testCase)
            time = [0; 1; 2; 3; 4]; % t=1: Standby, t=2: Active, t=3: Timeout, t=4: Hold
            in = testCase.createDefaultInputs(time);
            
            in.ACC_Enable_Pressed.Data   = [false; true; true; true; true];
            in.V2X_Switch_ON.Data      = [false; true; true; true; true];
            in.Longitudinal_Switch_ON.Data = [false; true; true; true; true];
            in.SET_Pressed.Data          = [false; false; true; true; true];
            in.Timeout_Event.Data        = [false; false; false; true; true];
            
            simOut = testCase.runSim(in, 4);
            % --- FIX: Must use testCase to call private methods ---
            [white_light, green_light] = testCase.getOutputs(simOut);
            
            % Verify transition to Deactivated
            testCase.verifyEqual(white_light.Data(end), false, 'State should be Deactivated: White light should be FALSE.');
            testCase.verifyEqual(green_light.Data(end), false, 'State should be Deactivated: Green light should be FALSE.');
        end
        
        % Test 7: Standby -> Deactivated (via Timeout)
        function test_StandbyToDeactivated_Timeout(testCase)
            time = [0; 1; 2; 3]; % t=1: Standby, t=2: Timeout, t=3: Hold
            in = testCase.createDefaultInputs(time);
            
            in.ACC_Enable_Pressed.Data   = [false; true; true; true];
            in.V2X_Switch_ON.Data      = [false; true; true; true];
            in.Longitudinal_Switch_ON.Data = [false; true; true; true];
            in.Timeout_Event.Data        = [false; false; true; true];
            
            simOut = testCase.runSim(in, 3);
            % --- FIX: Must use testCase to call private methods ---
            [white_light, green_light] = testCase.getOutputs(simOut);
            
            % Verify transition to Deactivated
            testCase.verifyEqual(white_light.Data(end), false, 'State should be Deactivated: White light should be FALSE.');
            testCase.verifyEqual(green_light.Data(end), false, 'State should be Deactivated: Green light should be FALSE.');
        end
    end

    methods(Access = private)
        % Helper function to create a default set of inputs (all false)
        function in = createDefaultInputs(testCase, timeVector)
            % This version creates a STRUCT.
            % The runSim function will convert this to a cell array.
            in.ACC_Enable_Pressed    = timeseries(false(size(timeVector)), timeVector);
            in.V2X_Switch_ON         = timeseries(false(size(timeVector)), timeVector);
            in.Longitudinal_Switch_ON = timeseries(false(size(timeVector)), timeVector);
            in.SET_Pressed           = timeseries(false(size(timeVector)), timeVector);
            in.Cancel_Pressed        = timeseries(false(size(timeVector)), timeVector);
            in.Driver_Brakes         = timeseries(false(size(timeVector)), timeVector);
            in.Timeout_Event         = timeseries(false(size(timeVector)), timeVector);
        end
        
        % Helper function to run the simulation (using the "Blog Post" method)
        function simOut = runSim(testCase, in_struct, stopTime)
            
            mdl = testCase.modelName;

            % --- This is the "Blog Post" method ---
            
            % 1. Turn ON 'LoadExternalInput'
            set_param(mdl, 'LoadExternalInput', 'on');

            % 2. Create the 'inports' cell array dataset.
            try
                inports = createInputDataset(mdl);
            catch ME
                if strcmp(ME.identifier, 'sl_sta:editor:modelNotOpen')
                    load_system(mdl); 
                    inports = createInputDataset(mdl);
                else
                    rethrow(ME);
                end
            end
            
            % 3. Populate the 'inports' cell array from your 'in_struct'.
            for i = 1:numel(inports)
                portName = inports{i}.Name; % Get name, e.g., 'SET_Pressed'
                
                if isfield(in_struct, portName)
                    
                    % Get our complete timeseries object from the test
                    ts = in_struct.(portName); 
                    
                    % Assign the correct name from the model's Inport block
                    ts.Name = portName;
                    
                    % Replace the entire empty object
                    inports{i} = ts; 

                else
                    error('Model Inport "%s" does not have a matching field in the test input struct.', portName);
                end
            end
            
            % 4. Create the SimulationInput object
            simIn = Simulink.SimulationInput(mdl);
            
            % 5. Set the ExternalInput using the populated cell array
            simIn = simIn.setExternalInput(inports);
            
            % 6. Set the stop time
            simIn = simIn.setModelParameter('StopTime', num2str(stopTime));
            
            % 7. Run the simulation
            simOut = sim(simIn);
        end
        
        % Helper function to get outputs from the sim result
        function [white_light, green_light] = getOutputs(testCase, simOut)
            % Assumes your Outports are named 'Out_Light_White' and 'Out_Light_Green'
            % and are set to "Log signal data" in the model.
            try
                % --- THIS IS THE FIX ---
                % Your settings save Outport data to a field named 'yout'
                % inside the main 'simOut' object.
                white_light = simOut.yout.get('Out_Light_White');
                green_light = simOut.yout.get('Out_Light_Green');
                
            catch ME
                % Check if the error is that 'yout' doesn't exist
                if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                    error('Could not find "yout" in the simulation output. Please check "Output: yout" in Model Settings > Data Import/Export.');
                else
                    % This will catch the "Unrecognized field name" error if
                    % the signal name is wrong.
                    error('Could not find signals "Out_Light_White" or "Out_Light_Green" inside "simOut.yout". Make sure they are set to "Log signal data". Error: %s', ME.message);
                end
            end
        end
    end
end