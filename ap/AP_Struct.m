ap_elems(1) = Simulink.BusElement;
ap_elems(1).Name = 'Longitudinal_Switch_ON';
ap_elems(1).DataType = 'boolean';

ap_elems(2) = Simulink.BusElement;
ap_elems(2).Name = 'Lateral_Switch_ON';
ap_elems(2).DataType = 'boolean';

ap_elems(3) = Simulink.BusElement;
ap_elems(3).Name = 'Driver_Brakes';
ap_elems(3).DataType = 'boolean';

ap_elems(4) = Simulink.BusElement;
ap_elems(4).Name = 'Is_Stationary';
ap_elems(4).DataType = 'boolean';

ap_elems(5) = Simulink.BusElement;
ap_elems(5).Name = 'Activate_AP_Pressed';
ap_elems(5).DataType = 'boolean';

ap_elems(6) = Simulink.BusElement;
ap_elems(6).Name = 'Parking_In_Range';
ap_elems(6).DataType = 'boolean';

ap_elems(7) = Simulink.BusElement;
ap_elems(7).Name = 'Finish_Pressed';
ap_elems(7).DataType = 'boolean';

ap_elems(8) = Simulink.BusElement;
ap_elems(8).Name = 'Cancel_AP_Pressed';
ap_elems(8).DataType = 'boolean';

APStatusBus = Simulink.Bus;
APStatusBus.Elements = ap_elems;

assignin('base', 'APStatusBus', APStatusBus);