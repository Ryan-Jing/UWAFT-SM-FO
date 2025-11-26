ain_elems(1) = Simulink.BusElement;
ain_elems(1).Name = 'Activate_AIN_Pressed';
ain_elems(1).DataType = 'boolean';

ain_elems(2) = Simulink.BusElement;
ain_elems(2).Name = 'Cancel_AIN_Pressed';
ain_elems(2).DataType = 'boolean';

AINStatusBus = Simulink.Bus;
AINStatusBus.Elements = ain_elems;

assignin('base', 'AINStatusBus', AINStatusBus);