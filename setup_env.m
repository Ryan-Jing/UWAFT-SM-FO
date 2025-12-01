% Define the list of subsystems
subsystems = {'acc', 'ain', 'ap', 'cacc', 'lcc'};

for i = 1:length(subsystems)
    currentSub = subsystems{i};

    cd(currentSub);
    addpath(pwd);

    commandName = [upper(currentSub), '_Struct'];

    disp(['Running: ' commandName]);

    eval(commandName);

    cd('..');
end

disp('Running: Event_Struct')
Event_Struct
disp('Running: Current_State_Struct')
Current_State_Struct
disp('Variables setup. Ready to run tests!')
