#import "Basic";
#import "File";
#import "File_Utilities"; // for visit_files
#import "Compiler";

OUTPUT_PATH           :: "dist/";
OUPUT_EXECUTABLE_NAME :: "app";

#run {
    set_build_options_dc(.{ do_output = false });
    make_directory_if_it_does_not_exist(OUTPUT_PATH, recursive = true);

    // Since the build can generate a lot debug and temporary files if you use it a lot,
    // we do some clean up to not keep too much garbage.
    visit_files(OUTPUT_PATH, recursive = false, null, delete_app_files_visitor, visit_files = true, visit_directories = true);

    log("Compiling app. | OS: % | CPU: %", OS, CPU);
    workspace := compiler_create_workspace("Build app");

    options := get_build_options(workspace);
    copy_commonly_propagated_fields(get_build_options(), *options);
    options.output_path = OUTPUT_PATH;
    options.output_executable_name = OUPUT_EXECUTABLE_NAME;
    options.output_type = .DYNAMIC_LIBRARY; // Important!
    options.os_target   = OS;
    options.cpu_target  = CPU;
    options.backend     = .X64;
    set_optimization(*options, .DEBUG);
    set_build_options(options, workspace);

    compiler_begin_intercept(workspace);

    add_build_file("app.jai", workspace);

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

delete_app_files_visitor :: (info: *File_Visit_Info, user_data: *void) {
    #import "String";
    if starts_with(info.short_name, "app.") {
        if info.is_directory {
            delete_directory(info.full_name);
        } else {
            file_delete(info.full_name);
        }
    }
}