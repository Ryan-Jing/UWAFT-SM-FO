function test_function2pck()

curr_dir = cd;

try

    %% mfile %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    mkdir('mfile_test');
    cd('mfile_test');

    copyfile(fullfile(curr_dir, 'func.m'));
    rtmaps_function2pck('func');

    movefile('func_m.pck', curr_dir);
    cd(curr_dir);

    %% pfile %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    mkdir('pfile_test');
    cd('pfile_test');

    pcode(fullfile(curr_dir, 'func.m'));
    rtmaps_function2pck('func');

    movefile('func_p.pck', curr_dir);
    cd(curr_dir);

    %% built-in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    mkdir('builtin_test');
    cd('builtin_test');

    rtmaps_function2pck(@hypot);

    movefile('hypot_b.pck', curr_dir);
    cd(curr_dir);

catch ME
    cd(curr_dir);
    rethrow(ME);
end
