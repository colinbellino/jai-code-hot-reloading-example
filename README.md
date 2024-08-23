# Code hot reloading example

The project is split in two main entry points:
- `main.jai` The main program that will load the app code, watch for changes and unload/reload the app when it was changed.
- `app.jai` The actual app code, need to expose `update`, `unload` and `reload` procedures since those will be loaded by the main program.

## How to use
- Build the main program: `jai build_main.jai`
- Build the app: `jai build_app.jai`
- Run the main program, should be `dist/main.exe` (or `./dist/main` on macos/linux)
You can run everything in this order if you just want to build and open: `jai build_main.jai && jai build_app.jai && ./dist/main`

## Taking this further
I tried to keep this example simple, but a lot more can be done with this, here are some ideas:
- Detect if the app memory layout/size changed between reloads, because right now this would break in unintended ways since we don't assert that in this example. Ideally, you'll want to close and reopen the app in that case, or display an error in that case.
- Run the `build_app.jai` from within the app itself (ie: "Recompile app" button or shortcut)
- Merge the build files into one and use build parameters to choose between build main/app/both or even open the app in a debugger.
- Build the main program only the first time you compile the app, after that only build the `app.jai`.
- Everything is built in debug/x64 mode right now, obviously you'll want to have a release build in your full project that disables code loading (see bottom of `main.jai`).