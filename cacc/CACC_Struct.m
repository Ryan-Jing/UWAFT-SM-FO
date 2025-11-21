elems(1) = Simulink.BusElement;
elems(1).Name = 'ACC_Enable_Pressed';
elems(1).DataType = 'boolean';

elems(2) = Simulink.BusElement;
elems(2).Name = 'V2X_Switch_ON';
elems(2).DataType = 'boolean';

elems(3) = Simulink.BusElement;
elems(3).Name = 'Longitudinal_Switch_ON';
elems(3).DataType = 'boolean';

elems(4) = Simulink.BusElement;
elems(4).Name = 'SET_Pressed';
elems(4).DataType = 'boolean';

elems(5) = Simulink.BusElement;
elems(5).Name = 'Cancel_Pressed';
elems(5).DataType = 'boolean';

elems(6) = Simulink.BusElement;
elems(6).Name = 'Driver_Brakes';
elems(6).DataType = 'boolean';

elems(7) = Simulink.BusElement;
elems(7).Name = 'Timeout_Event';
elems(7).DataType = 'boolean';

CANStatusBus = Simulink.Bus;
CANStatusBus.Elements = elems;

assignin('base', 'CANStatusBus', CANStatusBus);