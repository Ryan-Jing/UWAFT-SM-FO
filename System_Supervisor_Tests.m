classdef System_Supervisor_Tests < matlab.unittest.TestCase
    properties
        modelName = 'parent'
        inputVarName = 'EventsBus_Input';
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            testCase.defineBuses();
            
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end
            
            set_param(testCase.modelName, 'SignalLogging', 'on');
            set_param(testCase.modelName, 'SignalLoggingName', 'logsout');
            set_param(testCase.modelName, 'SaveOutput', 'on');
            
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
        % TEST 1: Default State
        % =================================================================
        function test_DefaultState(testCase)
            time = [0; 1]; 
            in = testCase.createZeroBusInputs(time);
            
            simOut = testCase.runSim(in, 1);
            mode = testCase.getSignal(simOut, 'System_Mode');
            active = testCase.getSignal(simOut, 'Is_Active');
            
            testCase.verifyEqual(mode(end), 0, 'Mode should be 0 (Deactivated).');
            testCase.verifyEqual(active(end), 0, 'Is_Active should be false.');
        end
        
        % =================================================================
        % TEST 2: ACC Lifecycle (Standby vs Active)
        % =================================================================
        function test_ACC_Lifecycle(testCase)
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroBusInputs(time);
            
            % 1. Enable -> Standby
            in.ACCStatusBus.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            in.ACCStatusBus.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]);
            in.ACCStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            % 2. Set -> Active
            in.ACCStatusBus.Set_Resume.Data             = logical([0; 0; 1; 0; 0]);
            
            % 3. Cancel -> Deactivated
            in.ACCStatusBus.Cancel_Pressed.Data         = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 4);
            [mode, modeTime] = testCase.getSignal(simOut, 'System_Mode'); 
            [active, activeTime] = testCase.getSignal(simOut, 'Is_Active');
            
            % Check t=1.5 (Standby)
            testCase.verifyEqual(testCase.sampleAt(mode, modeTime, 1.2), 1, 'Mode should be 1 (ACC).');
            testCase.verifyEqual(testCase.sampleAt(active, activeTime, 1.2), 0, 'Active should be 0 (Standby).');
            
            % Check t=2.5 (Active)
            testCase.verifyEqual(testCase.sampleAt(mode, modeTime, 2.5), 1, 'Mode should be 1 (ACC).');
            testCase.verifyEqual(testCase.sampleAt(active, activeTime, 2.5), 1, 'Active should be 1 (Active).');
            
            % Check t=3.5 (Deactivated)
            testCase.verifyEqual(mode(end), 0, 'Mode should return to 0.');
        end

        % =================================================================
        % TEST 3: Subsystem Wake-Up Check (Integration Logic)
        % *Requires you to log the output signal of ACC subsystem*
        % =================================================================
        function test_ACC_Subsystem_WakeUp(testCase)
            time = [0; 1; 2];
            in = testCase.createZeroBusInputs(time);
            
            % Go to Active ACC
            in.ACCStatusBus.ACC_Enable_Pressed.Data     = logical([0; 1; 1]);
            in.ACCStatusBus.V2X_Switch_ON.Data          = logical([0; 1; 1]);
            in.ACCStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1; 1]);
            in.ACCStatusBus.Set_Resume.Data             = logical([0; 1; 1]);
            in.ACCStatusBus.In_CACC_Speed_Range.Data    = logical([0; 1; 1]);
            
            simOut = testCase.runSim(in, 2);
            
            acc_state = testCase.getSignal(simOut, 'ACC_Current_State'); 
            final_val = acc_state(end);
            % Assuming internal logic outputs 2 for Active state
            testCase.verifyEqual(final_val, 2, 'The Child ACC Model did not wake up! Enabler might be broken.');
        end

        % =================================================================
        % TEST 4: AIN Transition Logic 
        % Logic: If ACC conditions are met, BUT Speed > 55, go to AIN (Mode 4)
        % =================================================================
        function test_AIN_Transition(testCase)
            time = [0; 1; 2; 3];
            in = testCase.createZeroBusInputs(time);
            
            in.ACCStatusBus.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1]);
            in.ACCStatusBus.V2X_Switch_ON.Data          = logical([0; 1; 1; 1]);
            in.ACCStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1]);
            in.ACCStatusBus.Speed_GT_55_MPH.Data        = logical([0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 3);
            [mode, modeTime] = testCase.getSignal(simOut, 'System_Mode'); % Get Data & Time
            
            % CHECK 1: ACC Stable Zone (e.g., t=1.2)
            % At 1.2s, Enable is high (since t=0.5), but Speed is still low (switches at t=1.5)
            testCase.verifyEqual(testCase.sampleAt(mode, modeTime, 1.2), 1, 'Should start in ACC (Mode 1).');
            
            % CHECK 2: AIN Stable Zone (e.g., t=2.5)
            % At 2.5s, Speed is definitely high.
            testCase.verifyEqual(testCase.sampleAt(mode, modeTime, 2.5), 4, 'Should switch to AIN (Mode 4).');
        end
        
        % =================================================================
        % TEST 5: LCC Fallback Logic (NEW)
        % Logic: LCC Active -> LCC Lost (but ACC valid) -> Fallback to ACC Active
        % =================================================================
        function test_LCC_Fallback(testCase)
            time = [0; 1; 2; 3; 4];
            in = testCase.createZeroBusInputs(time);
            
            % 1. Enable Everything for LCC (t=1)
            % LCC requires ACC prerequisites + Lane Centering
            in.ACCStatusBus.ACC_Enable_Pressed.Data     = logical([0; 1; 1; 1; 1]);
            in.ACCStatusBus.V2X_Switch_ON.Data          = logical([0; 1; 1; 1; 1]); 
            in.ACCStatusBus.Longitudinal_Switch_ON.Data = logical([0; 1; 1; 1; 1]);
            
            in.LCCStatusBus.Lane_Change_Centred.Data    = logical([0; 1; 1; 0; 0]); % LOST at t=3
            in.LCCStatusBus.Speed_GT_35_MPH.Data        = logical([0; 1; 1; 1; 1]);
            in.LCCStatusBus.Lateral_Switch_ON.Data      = logical([0; 1; 1; 1; 1]);
            
            % 2. Go Active (t=2)
            % Use generic Set/Resume to trigger active state
            in.LCCStatusBus.Activate_LCC_Pressed.Data   = logical([0; 0; 1; 1; 1]); 
            in.ACCStatusBus.Set_Resume.Data             = logical([0; 0; 1; 1; 1]); 
            
            simOut = testCase.runSim(in, 4);
            [mode, modeTime] = testCase.getSignal(simOut, 'System_Mode');
            [active, activeTime] = testCase.getSignal(simOut, 'Is_Active');
            
            % t=2.5: Should be LCC Active (Mode 3)
            testCase.verifyEqual(testCase.sampleAt(mode, modeTime, 2.5), 3, 'Should be in LCC (Mode 3).');
            testCase.verifyEqual(testCase.sampleAt(active, activeTime, 2.5), 1, 'Should be Active.');
            
            % t=3.5: Lane Lost -> Should degrade to ACC (Mode 1), NOT Deactivated (0)
            currentMode = testCase.sampleAt(mode, modeTime, 3.5);
            testCase.verifyEqual(currentMode, 1, 'Should downgrade to ACC (Mode 1) when lane is lost.');
            
            % Verify we are STILL ACTIVE
            currentActive = testCase.sampleAt(active, activeTime, 3.5);
            testCase.verifyEqual(currentActive, 1, 'System should remain ACTIVE during downgrade.');
        end

    end
    
    methods(Access = private)
        
        function defineBuses(~)
            clear acc_elems; clear cacc_elems; clear ap_elems; clear ain_elems; clear lcc_elems; clear gen_elems; clear flag_elems;
            
            % --- ACC Bus ---
            acc_elems(1) = Simulink.BusElement; acc_elems(1).Name = 'ACC_Enable_Pressed'; acc_elems(1).DataType = 'boolean';
            acc_elems(2) = Simulink.BusElement; acc_elems(2).Name = 'V2X_Switch_ON'; acc_elems(2).DataType = 'boolean';
            acc_elems(3) = Simulink.BusElement; acc_elems(3).Name = 'Longitudinal_Switch_ON'; acc_elems(3).DataType = 'boolean';
            acc_elems(4) = Simulink.BusElement; acc_elems(4).Name = 'Set_Resume'; acc_elems(4).DataType = 'boolean';
            acc_elems(5) = Simulink.BusElement; acc_elems(5).Name = 'Cancel_Pressed'; acc_elems(5).DataType = 'boolean';
            acc_elems(6) = Simulink.BusElement; acc_elems(6).Name = 'Driver_Brakes'; acc_elems(6).DataType = 'boolean';
            acc_elems(7) = Simulink.BusElement; acc_elems(7).Name = 'Timeout_Event'; acc_elems(7).DataType = 'boolean';
            acc_elems(8) = Simulink.BusElement; acc_elems(8).Name = 'In_CACC_Speed_Range'; acc_elems(8).DataType = 'boolean';
            acc_elems(9) = Simulink.BusElement; acc_elems(9).Name = 'Speed_GT_55_MPH'; acc_elems(9).DataType = 'boolean'; 
            ACCStatusBus = Simulink.Bus;
            ACCStatusBus.Elements = acc_elems;
            assignin('base', 'ACCStatusBus', ACCStatusBus);

            cacc_elems(1) = Simulink.BusElement; cacc_elems(1).Name = 'CACC_Enable_Pressed'; cacc_elems(1).DataType = 'boolean';
            cacc_elems(2) = Simulink.BusElement; cacc_elems(2).Name = 'V2X_Switch_ON'; cacc_elems(2).DataType = 'boolean';
            cacc_elems(3) = Simulink.BusElement; cacc_elems(3).Name = 'Longitudinal_Switch_ON'; cacc_elems(3).DataType = 'boolean';
            cacc_elems(4) = Simulink.BusElement; cacc_elems(4).Name = 'Set_Resume'; cacc_elems(4).DataType = 'boolean';
            cacc_elems(5) = Simulink.BusElement; cacc_elems(5).Name = 'Cancel_Pressed'; cacc_elems(5).DataType = 'boolean';
            cacc_elems(6) = Simulink.BusElement; cacc_elems(6).Name = 'Driver_Brakes'; cacc_elems(6).DataType = 'boolean';
            cacc_elems(7) = Simulink.BusElement; cacc_elems(7).Name = 'Timeout_Event'; cacc_elems(7).DataType = 'boolean';
            cacc_elems(8) = Simulink.BusElement; cacc_elems(8).Name = 'In_CACC_Speed_Range'; cacc_elems(8).DataType = 'boolean';
            cacc_elems(9) = Simulink.BusElement; cacc_elems(9).Name = 'Speed_GT_55_MPH'; cacc_elems(9).DataType = 'boolean';

            % --- CACC Bus ---
            CACCStatusBus = Simulink.Bus;
            CACCStatusBus.Elements = cacc_elems; 
            assignin('base', 'CACCStatusBus', CACCStatusBus);

            % --- LCC Bus ---
            lcc_elems(1) = Simulink.BusElement; lcc_elems(1).Name = 'Lane_Change_Centred'; lcc_elems(1).DataType = 'boolean';
            lcc_elems(2) = Simulink.BusElement; lcc_elems(2).Name = 'Speed_GT_35_MPH'; lcc_elems(2).DataType = 'boolean';
            lcc_elems(3) = Simulink.BusElement; lcc_elems(3).Name = 'Lateral_Switch_ON'; lcc_elems(3).DataType = 'boolean';
            lcc_elems(4) = Simulink.BusElement; lcc_elems(4).Name = 'Activate_LCC_Pressed'; lcc_elems(4).DataType = 'boolean';
            lcc_elems(5) = Simulink.BusElement; lcc_elems(5).Name = 'Cancel_LCC_Pressed'; lcc_elems(5).DataType = 'boolean';
            lcc_elems(6) = Simulink.BusElement; lcc_elems(6).Name = 'Driver_Inactivity_Detected'; lcc_elems(6).DataType = 'boolean';
            LCCStatusBus = Simulink.Bus;
            LCCStatusBus.Elements = lcc_elems;
            assignin('base', 'LCCStatusBus', LCCStatusBus);

            % --- AIN Bus ---
            ain_elems(1) = Simulink.BusElement; ain_elems(1).Name = 'Activate_AIN_Pressed'; ain_elems(1).DataType = 'boolean';
            ain_elems(2) = Simulink.BusElement; ain_elems(2).Name = 'Cancel_AIN_Pressed'; ain_elems(2).DataType = 'boolean';
            AINStatusBus = Simulink.Bus;
            AINStatusBus.Elements = ain_elems;
            assignin('base', 'AINStatusBus', AINStatusBus);

            % --- AP Bus ---
            ap_elems(1) = Simulink.BusElement; ap_elems(1).Name = 'Longitudinal_Switch_ON'; ap_elems(1).DataType = 'boolean';
            ap_elems(2) = Simulink.BusElement; ap_elems(2).Name = 'Lateral_Switch_ON'; ap_elems(2).DataType = 'boolean';
            ap_elems(3) = Simulink.BusElement; ap_elems(3).Name = 'Driver_Brakes'; ap_elems(3).DataType = 'boolean';
            ap_elems(4) = Simulink.BusElement; ap_elems(4).Name = 'Is_Stationary'; ap_elems(4).DataType = 'boolean';
            ap_elems(5) = Simulink.BusElement; ap_elems(5).Name = 'Activate_AP_Pressed'; ap_elems(5).DataType = 'boolean';
            ap_elems(6) = Simulink.BusElement; ap_elems(6).Name = 'Parking_In_Range'; ap_elems(6).DataType = 'boolean';
            ap_elems(7) = Simulink.BusElement; ap_elems(7).Name = 'Finish_Pressed'; ap_elems(7).DataType = 'boolean';
            ap_elems(8) = Simulink.BusElement; ap_elems(8).Name = 'Cancel_AP_Pressed'; ap_elems(8).DataType = 'boolean';
            APStatusBus = Simulink.Bus;
            APStatusBus.Elements = ap_elems;
            assignin('base', 'APStatusBus', APStatusBus);
            
            % --- PARENT Bus ---
            events_elems(1) = Simulink.BusElement; events_elems(1).Name = 'ACCStatusBus';  events_elems(1).DataType = 'Bus: ACCStatusBus';
            events_elems(2) = Simulink.BusElement; events_elems(2).Name = 'CACCStatusBus'; events_elems(2).DataType = 'Bus: CACCStatusBus';
            events_elems(3) = Simulink.BusElement; events_elems(3).Name = 'LCCStatusBus';  events_elems(3).DataType = 'Bus: LCCStatusBus';
            events_elems(4) = Simulink.BusElement; events_elems(4).Name = 'AINStatusBus';  events_elems(4).DataType = 'Bus: AINStatusBus';
            events_elems(5) = Simulink.BusElement; events_elems(5).Name = 'APStatusBus';   events_elems(5).DataType = 'Bus: APStatusBus';
            
            EventsBus = Simulink.Bus;
            EventsBus.Elements = events_elems;
            assignin('base', 'EventsBus', EventsBus);

            flag_elems(1) = Simulink.BusElement; flag_elems(1).Name = 'ACC_Ready';  flag_elems(1).DataType = 'boolean';
            flag_elems(2) = Simulink.BusElement; flag_elems(2).Name = 'CACC_Ready'; flag_elems(2).DataType = 'boolean';
            flag_elems(3) = Simulink.BusElement; flag_elems(3).Name = 'LCC_Ready';  flag_elems(3).DataType = 'boolean';
            flag_elems(4) = Simulink.BusElement; flag_elems(4).Name = 'AIN_Ready';  flag_elems(4).DataType = 'boolean';
            flag_elems(5) = Simulink.BusElement; flag_elems(5).Name = 'AP_Ready';   flag_elems(5).DataType = 'boolean';
            % Triggers
            flag_elems(6) = Simulink.BusElement; flag_elems(6).Name = 'ACC_Enable_Cmd';  flag_elems(6).DataType = 'boolean';
            flag_elems(7) = Simulink.BusElement; flag_elems(7).Name = 'CACC_Enable_Cmd'; flag_elems(7).DataType = 'boolean';
            flag_elems(8) = Simulink.BusElement; flag_elems(8).Name = 'LCC_Enable_Cmd';  flag_elems(8).DataType = 'boolean';
            flag_elems(9) = Simulink.BusElement; flag_elems(9).Name = 'AP_Enable_Cmd';   flag_elems(9).DataType = 'boolean';
            
            FlagsBus = Simulink.Bus;
            FlagsBus.Elements = flag_elems;
            assignin('base', 'FlagsBus', FlagsBus);
            
            gen_elems(1) = Simulink.BusElement; gen_elems(1).Name = 'CancelCmd';    gen_elems(1).DataType = 'boolean';
            gen_elems(2) = Simulink.BusElement; gen_elems(2).Name = 'NextStateCmd'; gen_elems(2).DataType = 'boolean';
            
            GenericInputsBus = Simulink.Bus;
            GenericInputsBus.Elements = gen_elems;
            assignin('base', 'GenericInputsBus', GenericInputsBus);
        end
        
        function simOut = runSim(testCase, inputStruct, stopTime)
            ds = Simulink.SimulationData.Dataset();
            ds = ds.addElement(inputStruct, 'EventsBus'); 
            assignin('base', testCase.inputVarName, ds);
            set_param(testCase.modelName, 'StopTime', num2str(stopTime));
            simOut = sim(testCase.modelName);
        end

        
        function [data, timeObj] = getSignal(~, simOut, signalName)
            % Returns both Data and Time vector
            rawObj = [];
            if isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
                if ~isempty(simOut.logsout.find('Name', signalName))
                    rawObj = simOut.logsout.get(signalName); 
                end
            end
            if isempty(rawObj) && isprop(simOut, 'yout') && ~isempty(simOut.yout)
                 try rawObj = simOut.yout.get(signalName); catch, end
            end
            
            if isempty(rawObj)
                error('Signal "%s" not found.', signalName);
            end
            
            while isa(rawObj, 'Simulink.SimulationData.Dataset')
                rawObj = rawObj.get(1); 
            end
            
            data = double(rawObj.Values.Data);
            timeObj = rawObj.Values.Time; % CAPTURE TIME
        end
        
        function val = sampleAt(~, signalData, signalTime, targetTime)
            % Finds the value of the signal at the specific targetTime
            % using "Zero-Order Hold" logic (value just before or at time).
            
            % Find the last index where time <= targetTime
            idx = find(signalTime <= targetTime, 1, 'last');
            
            if isempty(idx)
                val = 0; % Default if simulation hasn't started
            else
                val = signalData(idx);
            end
        end
        
        function in = createZeroBusInputs(~, timeVector)
            % Helper to create zero timeseries for all fields
            % CRITICAL: Fields are defined in the EXACT order of the Bus Objects
            
            zeroTS = timeseries(false(size(timeVector)), timeVector);
            zeroTS = setinterpmethod(zeroTS, 'zoh');
            
            % 1. ACCStatusBus (9 Elements)
            in.ACCStatusBus.ACC_Enable_Pressed     = zeroTS;
            in.ACCStatusBus.V2X_Switch_ON          = zeroTS;
            in.ACCStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.ACCStatusBus.Set_Resume             = zeroTS;
            in.ACCStatusBus.Cancel_Pressed         = zeroTS;
            in.ACCStatusBus.Driver_Brakes          = zeroTS;
            in.ACCStatusBus.Timeout_Event          = zeroTS;
            in.ACCStatusBus.In_CACC_Speed_Range    = zeroTS;
            in.ACCStatusBus.Speed_GT_55_MPH        = zeroTS; % Element 9

            % 2. CACCStatusBus (9 Elements)
            in.CACCStatusBus.CACC_Enable_Pressed     = zeroTS;
            in.CACCStatusBus.V2X_Switch_ON          = zeroTS;
            in.CACCStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.CACCStatusBus.Set_Resume             = zeroTS;
            in.CACCStatusBus.Cancel_Pressed         = zeroTS;
            in.CACCStatusBus.Driver_Brakes          = zeroTS;
            in.CACCStatusBus.Timeout_Event          = zeroTS;
            in.CACCStatusBus.In_CACC_Speed_Range    = zeroTS;
            in.CACCStatusBus.Speed_GT_55_MPH        = zeroTS; % Element 9

            % 3. LCCStatusBus (7 Elements)
            in.LCCStatusBus.Lane_Change_Centred      = zeroTS;
            in.LCCStatusBus.Speed_GT_35_MPH          = zeroTS;
            in.LCCStatusBus.Lateral_Switch_ON        = zeroTS;
            in.LCCStatusBus.Activate_LCC_Pressed     = zeroTS;
            in.LCCStatusBus.Cancel_LCC_Pressed       = zeroTS;
            in.LCCStatusBus.Driver_Inactivity_Detected = zeroTS;

            % 4. AINStatusBus (3 Elements)
            in.AINStatusBus.Activate_AIN_Pressed = zeroTS;
            in.AINStatusBus.Cancel_AIN_Pressed   = zeroTS;

            % 5. APStatusBus (8 Elements)
            in.APStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.APStatusBus.Lateral_Switch_ON      = zeroTS;
            in.APStatusBus.Driver_Brakes          = zeroTS;
            in.APStatusBus.Is_Stationary          = zeroTS;
            in.APStatusBus.Activate_AP_Pressed    = zeroTS;
            in.APStatusBus.Parking_In_Range       = zeroTS;
            in.APStatusBus.Finish_Pressed         = zeroTS;
            in.APStatusBus.Cancel_AP_Pressed      = zeroTS;
        end
    end
end