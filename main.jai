#import "Basic";
#import,file "app_loader.jai";

VERBOSE :: true;

main :: () {
    memory: *void;
    app := app_library_load(context.allocator, VERBOSE);
    assert(app.is_valid, "App not loaded correctly, abort!");

    quit: bool;
    while quit == false {
        if app.update {
            quit = app.update();
        }

        if app_library_changed(*app) {
            if app.is_valid {
                memory = app.unload();
                app_library_unload(*app, VERBOSE);
            }
            new_app := app_library_load(context.allocator);
            // Replace the app only if it's valid of we'll crash (app_library_load can fail for a lot of reasons since we do file I/O).
            // Another approach would be to default to a stub instead, it's up to you.
            if new_app.is_valid {
                app = new_app;
                app.reload(memory);
            }
        }
    }
}

// For release builds, you'll probably want to disable all that dynamic loading
// and have something simpler like the example below:

/*
#load "app.jai";

main :: () {
    quit: bool;
    while quit == false {
        quit = update();
    }
}
*/