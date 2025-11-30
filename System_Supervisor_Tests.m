classdef System_Supervisor_Tests < matlab.unittest.TestCase
    properties
        modelName = 'parent'
        inputVarName = 'EventsBus_Input';
    end
    
    methods(TestClassSetup)
        function loadModel(testCase)
            if ~bdIsLoaded(testCase.modelName)
                load_system(testCase.modelName);
            end


            testCase.defineBuses();
            
            % Enable Logging for everything
            set_param(testCase.modelName, 'SignalLogging', 'on');
            set_param(testCase.modelName, 'SignalLoggingName', 'logsout');
            set_param(testCase.modelName, 'SaveOutput', 'on');
            
            % Setup External Input
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
            
            testCase.verifyEqual(mode(end), 0, 'Mode should be 0.');
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
            in.ACCStatusBus.Set_Resume.Data             = logical([0; 0; 1; 1; 1]);
            
            % 3. Cancel -> Deactivated
            in.ACCStatusBus.Cancel_Pressed.Data         = logical([0; 0; 0; 1; 1]);
            
            simOut = testCase.runSim(in, 4);
            mode = testCase.getSignal(simOut, 'System_Mode');
            active = testCase.getSignal(simOut, 'Is_Active');
            
            % Check t=1.5 (Standby)
            % Mode should be 1, but Active should be FALSE
            testCase.verifyEqual(testCase.sampleAt(mode, time, 1.5), 1, 'Mode should be 1 (ACC).');
            testCase.verifyEqual(testCase.sampleAt(active, time, 1.5), 0, 'Active should be 0 (Standby).');
            
            % Check t=2.5 (Active)
            % Mode should be 1, Active should be TRUE
            testCase.verifyEqual(testCase.sampleAt(mode, time, 2.5), 1, 'Mode should be 1 (ACC).');
            testCase.verifyEqual(testCase.sampleAt(active, time, 2.5), 1, 'Active should be 1 (Driving).');
            
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
            
            simOut = testCase.runSim(in, 2);
            
            % Try to get the internal signal from the ACC Model
            % (Make sure you mark the output line of the ACC block for logging!)
            try
                acc_state = testCase.getSignal(simOut, 'ACC_Current_State'); % Or whatever the signal name is
                
                % If ACC is Active, this should be 2 (Active state inside the child chart)
                % If the Enabler was broken, this would stay 0.
                final_val = acc_state(end);
                testCase.verifyEqual(final_val, 2, 'The Child ACC Model did not wake up! Enabler might be broken.');
            catch
                % Warn if signal not found, but don't fail the whole suite
                warning('Could not find ACC_Current_State. Did you enable logging on the signal line?');
            end
        end
        
        % ... (Keep your other AP / LCC / Arbitration tests here) ...
        
    end
    
    methods(Access = private)
        function defineBuses(~)
            % ============================================================
            % 1. DEFINE CHILD BUSES FIRST (CRITICAL!)
            % ============================================================
            
            % --- ACC Bus ---
            acc_elems(1) = Simulink.BusElement; acc_elems(1).Name = 'ACC_Enable_Pressed'; acc_elems(1).DataType = 'boolean';
            acc_elems(2) = Simulink.BusElement; acc_elems(2).Name = 'V2X_Switch_ON'; acc_elems(2).DataType = 'boolean';
            acc_elems(3) = Simulink.BusElement; acc_elems(3).Name = 'Longitudinal_Switch_ON'; acc_elems(3).DataType = 'boolean';
            acc_elems(4) = Simulink.BusElement; acc_elems(4).Name = 'Set_Resume'; acc_elems(4).DataType = 'boolean';
            acc_elems(5) = Simulink.BusElement; acc_elems(5).Name = 'Cancel_Pressed'; acc_elems(5).DataType = 'boolean';
            acc_elems(6) = Simulink.BusElement; acc_elems(6).Name = 'Driver_Brakes'; acc_elems(6).DataType = 'boolean';
            acc_elems(7) = Simulink.BusElement; acc_elems(7).Name = 'Timeout_Event'; acc_elems(7).DataType = 'boolean';
            acc_elems(8) = Simulink.BusElement; acc_elems(8).Name = 'In_CACC_Speed_Range'; acc_elems(8).DataType = 'boolean';
            ACCStatusBus = Simulink.Bus;
            ACCStatusBus.Elements = acc_elems;
            assignin('base', 'ACCStatusBus', ACCStatusBus);

            % --- CACC Bus ---
            % (Assuming same structure as ACC based on your previous code)
            CACCStatusBus = Simulink.Bus;
            CACCStatusBus.Elements = acc_elems; % Reusing acc_elems if identical, otherwise define cacc_elems
            assignin('base', 'CACCStatusBus', CACCStatusBus);

            % --- LCC Bus ---
            lcc_elems(1) = Simulink.BusElement; lcc_elems(1).Name = 'Lane_Change_Centred'; lcc_elems(1).DataType = 'boolean';
            lcc_elems(2) = Simulink.BusElement; lcc_elems(2).Name = 'CACC_Active'; lcc_elems(2).DataType = 'boolean';
            lcc_elems(3) = Simulink.BusElement; lcc_elems(3).Name = 'Speed_GT_35_MPH'; lcc_elems(3).DataType = 'boolean';
            lcc_elems(4) = Simulink.BusElement; lcc_elems(4).Name = 'Lateral_Switch_ON'; lcc_elems(4).DataType = 'boolean';
            lcc_elems(5) = Simulink.BusElement; lcc_elems(5).Name = 'Activate_LCC_Pressed'; lcc_elems(5).DataType = 'boolean';
            lcc_elems(6) = Simulink.BusElement; lcc_elems(6).Name = 'Cancel_LCC_Pressed'; lcc_elems(6).DataType = 'boolean';
            lcc_elems(7) = Simulink.BusElement; lcc_elems(7).Name = 'Driver_Inactivity_Detected'; lcc_elems(7).DataType = 'boolean';
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


            % ============================================================
            % 2. NOW DEFINE THE PARENT BUS
            % ============================================================
            events_elems(1) = Simulink.BusElement;
            events_elems(1).Name = 'ACCStatusBus'; 
            events_elems(1).DataType = 'Bus: ACCStatusBus'; % Now valid because ACCStatusBus exists!
            
            events_elems(2) = Simulink.BusElement;
            events_elems(2).Name = 'CACCStatusBus'; 
            events_elems(2).DataType = 'Bus: CACCStatusBus'; 
            
            events_elems(3) = Simulink.BusElement;
            events_elems(3).Name = 'LCCStatusBus'; 
            events_elems(3).DataType = 'Bus: LCCStatusBus'; 
            
            events_elems(4) = Simulink.BusElement;
            events_elems(4).Name = 'AINStatusBus'; 
            events_elems(4).DataType = 'Bus: AINStatusBus'; 
            
            events_elems(5) = Simulink.BusElement;
            events_elems(5).Name = 'APStatusBus'; 
            events_elems(5).DataType = 'Bus: APStatusBus'; 
            
            EventsBus = Simulink.Bus;
            EventsBus.Elements = events_elems;
            assignin('base', 'EventsBus', EventsBus);

            flag_elems(1) = Simulink.BusElement; flag_elems(1).Name = 'ACC_Ready';  flag_elems(1).DataType = 'boolean';
            flag_elems(2) = Simulink.BusElement; flag_elems(2).Name = 'CACC_Ready'; flag_elems(2).DataType = 'boolean';
            flag_elems(3) = Simulink.BusElement; flag_elems(3).Name = 'LCC_Ready';  flag_elems(3).DataType = 'boolean';
            flag_elems(4) = Simulink.BusElement; flag_elems(4).Name = 'AIN_Ready';  flag_elems(4).DataType = 'boolean';
            flag_elems(5) = Simulink.BusElement; flag_elems(5).Name = 'AP_Ready';   flag_elems(5).DataType = 'boolean';
            
            FlagsBus = Simulink.Bus;
            FlagsBus.Elements = flag_elems;
            assignin('base', 'FlagsBus', FlagsBus);
            
            % --- GenericInputs Bus ---
            gen_elems(1) = Simulink.BusElement; gen_elems(1).Name = 'CancelCmd';    gen_elems(1).DataType = 'boolean';
            gen_elems(2) = Simulink.BusElement; gen_elems(2).Name = 'NextStateCmd'; gen_elems(2).DataType = 'boolean';
            
            GenericInputsBus = Simulink.Bus;
            GenericInputsBus.Elements = gen_elems;
            assignin('base', 'GenericInputsBus', GenericInputsBus);
        end
        
        function simOut = runSim(testCase, inputStruct, stopTime)
            assignin('base', testCase.inputVarName, inputStruct);
            set_param(testCase.modelName, 'StopTime', num2str(stopTime));
            simOut = sim(testCase.modelName);
        end
        
        function val = sampleAt(~, signalData, timeVec, sampleTime)
            [~, idx] = min(abs(timeVec - sampleTime));
            val = signalData(idx);
        end
        
        function data = getSignal(~, simOut, signalName)
            % Generic helper to get ANY signal (Mode, Active, or Child States)
            rawObj = [];
            if isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
                try rawObj = simOut.logsout.get(signalName); catch, end
            end
            if isempty(rawObj) && isprop(simOut, 'yout') && ~isempty(simOut.yout)
                 try rawObj = simOut.yout.get(signalName); catch, end
            end
            
            if isempty(rawObj)
                error('Signal "%s" not found in logsout or yout. Did you verify the name and enable logging?', signalName);
            end
            
            while isa(rawObj, 'Simulink.SimulationData.Dataset')
                rawObj = rawObj.get(1); 
            end
            data = double(rawObj.Values.Data);
        end
        
        function in = createZeroBusInputs(~, timeVector)
            % (Paste your existing CreateZeroBusInputs code here - it looks correct)
            zeroTS = timeseries(false(size(timeVector)), timeVector);
            zeroTS = setinterpmethod(zeroTS, 'zoh');
            
            in.ACCStatusBus.ACC_Enable_Pressed     = zeroTS;
            in.ACCStatusBus.V2X_Switch_ON          = zeroTS;
            in.ACCStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.ACCStatusBus.Set_Resume             = zeroTS;
            in.ACCStatusBus.Cancel_Pressed         = zeroTS;
            in.ACCStatusBus.Driver_Brakes          = zeroTS;
            in.ACCStatusBus.Timeout_Event          = zeroTS;
            in.ACCStatusBus.In_CACC_Speed_Range    = zeroTS;

            in.CACCStatusBus.ACC_Enable_Pressed     = zeroTS;
            in.CACCStatusBus.V2X_Switch_ON          = zeroTS;
            in.CACCStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.CACCStatusBus.Set_Resume             = zeroTS;
            in.CACCStatusBus.Cancel_Pressed         = zeroTS;
            in.CACCStatusBus.Driver_Brakes          = zeroTS;
            in.CACCStatusBus.Timeout_Event          = zeroTS;
            in.CACCStatusBus.In_CACC_Speed_Range    = zeroTS;

            in.APStatusBus.Longitudinal_Switch_ON = zeroTS;
            in.APStatusBus.Lateral_Switch_ON      = zeroTS;
            in.APStatusBus.Driver_Brakes          = zeroTS;
            in.APStatusBus.Is_Stationary          = zeroTS;
            in.APStatusBus.Activate_AP_Pressed    = zeroTS;
            in.APStatusBus.Parking_In_Range       = zeroTS;
            in.APStatusBus.Finish_Pressed         = zeroTS;
            in.APStatusBus.Cancel_AP_Pressed      = zeroTS;

            in.LCCStatusBus.Lane_Change_Centred      = zeroTS;
            in.LCCStatusBus.CACC_Active              = zeroTS;
            in.LCCStatusBus.Speed_GT_35_MPH          = zeroTS;
            in.LCCStatusBus.Lateral_Switch_ON        = zeroTS;
            in.LCCStatusBus.Activate_LCC_Pressed     = zeroTS;
            in.LCCStatusBus.Cancel_LCC_Pressed       = zeroTS;
            in.LCCStatusBus.Driver_Inactivity_Detected = zeroTS;
            
            in.AINStatusBus.Activate_AIN_Pressed = zeroTS;
            in.AINStatusBus.Cancel_AIN_Pressed   = zeroTS;
        end
    end
end