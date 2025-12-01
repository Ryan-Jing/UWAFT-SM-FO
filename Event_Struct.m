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
