clear cacc_elems

cacc_elems(1) = Simulink.BusElement;
cacc_elems(1).Name = 'CACC_Enable_Pressed';
cacc_elems(1).DataType = 'boolean';

cacc_elems(2) = Simulink.BusElement;
cacc_elems(2).Name = 'V2X_Switch_ON';
cacc_elems(2).DataType = 'boolean';

cacc_elems(3) = Simulink.BusElement;
cacc_elems(3).Name = 'Longitudinal_Switch_ON';
cacc_elems(3).DataType = 'boolean';

cacc_elems(4) = Simulink.BusElement;
cacc_elems(4).Name = 'Set_Resume';
cacc_elems(4).DataType = 'boolean';

cacc_elems(5) = Simulink.BusElement;
cacc_elems(5).Name = 'Cancel_Pressed';
cacc_elems(5).DataType = 'boolean';

cacc_elems(6) = Simulink.BusElement;
cacc_elems(6).Name = 'Driver_Brakes';
cacc_elems(6).DataType = 'boolean';

cacc_elems(7) = Simulink.BusElement;
cacc_elems(7).Name = 'Timeout_Event';
cacc_elems(7).DataType = 'boolean';

cacc_elems(8) = Simulink.BusElement;
cacc_elems(8).Name = 'In_CACC_Speed_Range';
cacc_elems(8).DataType = 'boolean';

cacc_elems(9) = Simulink.BusElement;
cacc_elems(9).Name = 'Speed_GT_55_MPH';
cacc_elems(9).DataType = 'boolean';

CACCStatusBus = Simulink.Bus;
CACCStatusBus.Elements = cacc_elems;

assignin('base', 'CACCStatusBus', CACCStatusBus);