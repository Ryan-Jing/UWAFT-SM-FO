function cleanup_simple_test()

model_name = 'simple_test';

% clean up the working directory
try rmdir('slprj', 's'), catch, end
try rmdir([model_name '_rtmaps_build'], 's'), catch, end
if exist([model_name '.pck']), delete([model_name '.pck']), end
