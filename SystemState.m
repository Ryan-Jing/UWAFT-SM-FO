classdef SystemState < Simulink.IntEnumType
    % Defines the combined state for consumers
    enumeration
        Deactivated(0)
        
        ACC_Standby(10)
        ACC_Active(11)
        
        CACC_Standby(20)
        CACC_Active(21)
        
        LCC_Standby(30)
        LCC_Active(31)
        
        AIN_Standby(40)
        AIN_Active(41)
        
        AP_Standby(50)
        AP_Active(51)
    end
    
    methods (Static)
        function ret = getDefaultValue()
            ret = SystemState.Deactivated;
        end
    end
end