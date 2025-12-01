clear lcc_elems

lcc_elems(1) = Simulink.BusElement;
lcc_elems(1).Name = 'Lane_Change_Centred';
lcc_elems(1).DataType = 'boolean';

lcc_elems(2) = Simulink.BusElement;
lcc_elems(2).Name = 'Speed_GT_35_MPH';
lcc_elems(2).DataType = 'boolean';

lcc_elems(3) = Simulink.BusElement;
lcc_elems(3).Name = 'Lateral_Switch_ON';
lcc_elems(3).DataType = 'boolean';

lcc_elems(4) = Simulink.BusElement;
lcc_elems(4).Name = 'Activate_LCC_Pressed';
lcc_elems(4).DataType = 'boolean';

lcc_elems(5) = Simulink.BusElement;
lcc_elems(5).Name = 'Cancel_LCC_Pressed';
lcc_elems(5).DataType = 'boolean';

lcc_elems(6) = Simulink.BusElement;
lcc_elems(6).Name = 'Driver_Inactivity_Detected';
lcc_elems(6).DataType = 'boolean';

LCCStatusBus = Simulink.Bus;
LCCStatusBus.Elements = lcc_elems;

assignin('base', 'LCCStatusBus', LCCStatusBus);