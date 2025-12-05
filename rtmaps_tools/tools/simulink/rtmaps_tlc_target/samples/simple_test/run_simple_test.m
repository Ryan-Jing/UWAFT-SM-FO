
function run_simple_test()

model_name = 'simple_test';

close_system(model_name, 0);

% clean up the working directory
try rmdir('slprj', 's'), catch, end
try rmdir([model_name '_rtmaps_build'], 's'), catch, end
if exist([model_name '.pck']), delete([model_name '.pck']), end

% create a simple model: Output = 2 * Input
% InPort --> Gain (gain=2) --> OutPort

try
    % https://www.mathworks.com/matlabcentral/answers/100126-why-can-t-i-add-a-block-to-my-model-using-add_block#answer_109474
    load_system('simulink');

    new_system(model_name);
    %open_system(model_name);
    load_system(model_name);

    add_block('simulink/Commonly Used Blocks/In1' , [model_name '/iPort']);
    add_block('simulink/Commonly Used Blocks/Out1', [model_name '/oPort']);
    add_block('simulink/Commonly Used Blocks/Gain', [model_name '/gain']);

    add_line(model_name, 'iPort/1', 'gain/1');
    add_line(model_name, 'gain/1' , 'oPort/1');

    set_param([model_name '/gain'], 'Gain', '2');

    %openDialog(getActiveConfigSet(model_name));
    set_param(model_name, 'SystemTargetFile', 'rtmaps.tlc');
    set_param(model_name, 'FixedStep', '0.2');

    % build the model
    slbuild(model_name);

    close_system(model_name, 0);

catch ME
    close_system(model_name, 0);
    rethrow(ME)
end


