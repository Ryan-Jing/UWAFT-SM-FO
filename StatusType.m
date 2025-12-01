classdef StatusType < Simulink.IntEnumType
    enumeration
        Deactivated(0)
        Standby(1)
        Active(2)
    end

    methods (Static)
        function retVal = getDefaultValue()
            retVal = ACCStatusType.Deactivated;
        end

        function retVal = getDescription()
            retVal = 'Enumeration for Adaptive Cruise Control Status';
        end
        
        function retVal = addClassNameToEnumNames()
            retVal = true; 
        end
    end
end