#import "Basic";
#import "File";
#import "Compiler";

OUTPUT_PATH           :: "dist/";
OUPUT_EXECUTABLE_NAME :: "main";

#run {
    set_build_options_dc(.{ do_output = false });
    make_directory_if_it_does_not_exist(OUTPUT_PATH, recursive = true);

    log("Compiling main. | OS: % | CPU: %", OS, CPU);
    workspace := compiler_create_workspace("Build main");

    options := get_build_options(workspace);
    copy_commonly_propagated_fields(get_build_options(), *options);
    options.output_path = OUTPUT_PATH;
    options.output_executable_name = OUPUT_EXECUTABLE_NAME;
    options.output_type = .EXECUTABLE;
    options.os_target   = OS;
    options.cpu_target  = CPU;
    options.backend     = .X64;
    set_optimization(*options, .DEBUG);
    set_build_options(options, workspace);

    compiler_begin_intercept(workspace);

    add_build_file("main.jai", workspace);

    while true {
        message := compiler_wait_for_message();
        if message.kind == {
            case .COMPLETE; {
                message_complete := (cast(*Message_Complete) message);
                if message_complete.error_code != .NONE {
                    exit(1);
                }
                break;
            }
        }
    }
    compiler_end_intercept(workspace);
};