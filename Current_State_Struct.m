status_elems(1) = Simulink.BusElement;
status_elems(1).Name = 'ACCStatus'; 
status_elems(1).DataType = 'Enum: StatusType';

status_elems(2) = Simulink.BusElement;
status_elems(2).Name = 'CACCStatus'; 
status_elems(2).DataType = 'Enum: StatusType';

status_elems(3) = Simulink.BusElement;
status_elems(3).Name = 'LCCStatus'; 
status_elems(3).DataType = 'Enum: StatusType';

status_elems(4) = Simulink.BusElement;
status_elems(4).Name = 'AINStatus'; 
status_elems(4).DataType = 'Enum: StatusType';

status_elems(5) = Simulink.BusElement;
status_elems(5).Name = 'APStatus'; 
status_elems(5).DataType = 'Enum: StatusType';


CurrentStateBus = Simulink.Bus;
CurrentStateBus.Elements = status_elems;
assignin('base', 'CurrentStateBus', CurrentStateBus);






