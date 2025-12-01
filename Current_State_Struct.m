status_elems(1) = Simulink.BusElement;
status_elems(1).Name = 'ACCStatus'; 
status_elems(1).DataType = 'Enum: StatusType';

status_elems(2) = Simulink.BusElement;
status_elems(2).Name = 'CACCStatus'; 
status_elems(2).DataType = 'Enum: StatusType';

status_elems(3) = Simulink.BusElement;
status_elems(3).Name = 'LCCStatus'; 
status_elems(3).DataType = 'Enum: LCCStatusType';

status_elems(4) = Simulink.BusElement;
status_elems(4).Name = 'AINStatus'; 
status_elems(4).DataType = 'Enum: AINStatusType';

status_elems(5) = Simulink.BusElement;
status_elems(5).Name = 'APStatus'; 
status_elems(5).DataType = 'Enum: APStatusType';


CurrentState = Simulink.Bus;
CurrentState.Elements = status_elems;
assignin('base', 'CurrentState', EventsBus);







