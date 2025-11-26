lcc_elems(1) = Simulink.BusElement;
lcc_elems(1).Name = 'Lane_Change_Centred';
lcc_elems(1).DataType = 'boolean';

lcc_elems(2) = Simulink.BusElement;
lcc_elems(2).Name = 'CACC_Active';
lcc_elems(2).DataType = 'boolean';

lcc_elems(3) = Simulink.BusElement;
lcc_elems(3).Name = 'Speed_GT_35_MPH';
lcc_elems(3).DataType = 'boolean';

lcc_elems(4) = Simulink.BusElement;
lcc_elems(4).Name = 'Lateral_Switch_ON';
lcc_elems(4).DataType = 'boolean';

lcc_elems(5) = Simulink.BusElement;
lcc_elems(5).Name = 'Activate_LCC_Pressed';
lcc_elems(5).DataType = 'boolean';

lcc_elems(6) = Simulink.BusElement;
lcc_elems(6).Name = 'Cancel_LCC_Pressed';
lcc_elems(6).DataType = 'boolean';

lcc_elems(7) = Simulink.BusElement;
lcc_elems(7).Name = 'Driver_Inactivity_Detected';
lcc_elems(7).DataType = 'boolean';

LCCStatusBus = Simulink.Bus;
LCCStatusBus.Elements = lcc_elems;

assignin('base', 'LCCStatusBus', LCCStatusBus);