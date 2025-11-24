elems(1) = Simulink.BusElement;
elems(1).Name = 'Activate_AIN_Pressed';
elems(1).DataType = 'boolean';

elems(2) = Simulink.BusElement;
elems(2).Name = 'Cancel_AIN_Pressed';
elems(2).DataType = 'boolean';

AINStatusBus = Simulink.Bus;
AINStatusBus.Elements = elems;

assignin('base', 'AINStatusBus', AINStatusBus);