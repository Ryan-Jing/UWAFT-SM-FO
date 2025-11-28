acc_elems(1) = Simulink.BusElement;
acc_elems(1).Name = 'ACC_Enable_Pressed';
acc_elems(1).DataType = 'boolean';

acc_elems(2) = Simulink.BusElement;
acc_elems(2).Name = 'V2X_Switch_ON';
acc_elems(2).DataType = 'boolean';

acc_elems(3) = Simulink.BusElement;
acc_elems(3).Name = 'Longitudinal_Switch_ON';
acc_elems(3).DataType = 'boolean';

acc_elems(4) = Simulink.BusElement;
acc_elems(4).Name = 'Set_Resume';
acc_elems(4).DataType = 'boolean';

acc_elems(5) = Simulink.BusElement;
acc_elems(5).Name = 'Cancel_Pressed';
acc_elems(5).DataType = 'boolean';

acc_elems(6) = Simulink.BusElement;
acc_elems(6).Name = 'Driver_Brakes';
acc_elems(6).DataType = 'boolean';

acc_elems(7) = Simulink.BusElement;
acc_elems(7).Name = 'Timeout_Event';
acc_elems(7).DataType = 'boolean';

acc_elems(8) = Simulink.BusElement;
acc_elems(8).Name = 'In_CACC_Speed_Range';
acc_elems(8).DataType = 'boolean';

ACCStatusBus = Simulink.Bus;
ACCStatusBus.Elements = acc_elems;

assignin('base', 'ACCStatusBus', ACCStatusBus);