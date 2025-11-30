events_elems(1) = Simulink.BusElement;
events_elems(1).Name = 'ACCStatusBus'; 
events_elems(1).DataType = 'Bus: ACCStatusBus'; 

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

