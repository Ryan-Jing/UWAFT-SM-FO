classdef StatusType < Simulink.IntEnumType
    enumeration
        Deactivated(0)
        Standby(1)
        Active(2)
    end

    methods (Static)
        function retVal = generateEnumClass()
            retVal = false;
        end

        function retVal = getDefaultValue()
            retVal = StatusType.Deactivated;
        end

        function retVal = getDescription()
            retVal = 'Enumeration for Adaptive Cruise Control Status';
        end

        function retVal = addClassNameToEnumNames()
            retVal = true;
        end

        % function retVal = getHeaderFile()
        %     retVal = 'StatusType.h';
        % end

        function retVal = getDataScope()
            retVal = 'Imported';
        end
    end
end