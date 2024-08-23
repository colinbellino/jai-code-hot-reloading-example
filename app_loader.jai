#import "Basic";
#import "System";
#import "String";
#import "File_Utilities";
library :: #import,file "library.jai";

#if OS == .WINDOWS {
    LIBRARY_FILENAME :: "app.dll";
} else #if OS == .MACOS {
    LIBRARY_FILENAME :: "app.dylib";
} else {
    LIBRARY_FILENAME :: "app.lib";
}

App :: struct {
    handle:             *void;
    update:             () -> (quit: bool);
    unload:             () -> *void;
    reload:             (memory: *void);
    last_modification:  Apollo_Time;
    is_valid:           bool;
}

app_library_load :: (allocator: Allocator, verbose := false) -> (app: App) {
    context.allocator = allocator;
    cwd := get_path_of_running_executable_directory();
    logger := ifx(verbose) then context.logger else noop_logger;

    source_path_full := tprint("%/%", cwd, LIBRARY_FILENAME);
    temp_path_full := tprint("%.temp.%", source_path_full, _counter);
    copy_ok := copy_file(source_path_full, temp_path_full,, logger = logger);
    if copy_ok == false && verbose {
        log_error("Couldn't copy to temp file.");
    }

    app: App;
    app.handle = library.load(temp_path_full, verbose);
    app.update = library.symbol_address(app.handle, "update", verbose);
    app.unload = library.symbol_address(app.handle, "unload", verbose);
    app.reload = library.symbol_address(app.handle, "reload", verbose);
    app.is_valid = app.handle != null && app.update != null && app.unload != null && app.reload != null;
    if app.is_valid {
        _counter += 1;
        app.last_modification = file_modtime_and_size(source_path_full);
    }
    return app;
}

app_library_unload :: (app: *App, verbose := false) -> (ok: bool) {
    result := library.unload(app.handle, verbose);
    app.handle = null;
    app.update = null;
    app.unload = null;
    app.reload = null;
    app.is_valid = false;
    return result;
}

app_library_changed :: (app: *App) -> bool {
    cwd := get_path_of_running_executable_directory(,, allocator = temp);
    full_name := tprint("%/%", cwd, LIBRARY_FILENAME);
    modtime, size := file_modtime_and_size(full_name);
    diff := compare_apollo_times(modtime, app.last_modification);
    return diff == 1;
}

#scope_file

_counter := 0; // We use this to generate incrementing filenames

get_path_of_running_executable_directory :: () -> string {
    path := get_path_of_running_executable();
    words := split(path, "/");
    return join(..array_view(words, 0, words.count - 1), "/");
}

noop_logger :: (message: string, data: *void, info: Log_Info) {}