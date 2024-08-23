# Code hot reloading example in Jai

The goal of this project is to be a simple example of a program reloading it's code when you recompile it. Feel free to reuse some of the code in there and make it your own.

## Structure
The project is split in two main entry points:
- `main.jai` The main program that will load the app code, watch for changes and unload/reload the app when it was changed.
- `app.jai` The actual app code, need to export `update`, `unload` and `reload` procedures since those will be loaded by the main program.

## How to use
- Build the main program: `jai build_main.jai`
- Build the app: `jai build_app.jai`
- Run the main program, should be `dist/main.exe` (or `./dist/main` on macos/linux)
Or all in one: `jai build_main.jai && jai build_app.jai && ./dist/main`.

## Taking this further
I tried to keep this example simple, but a lot more can be done with this, here are some ideas:
- Everything is built in debug/x64 mode right now, obviously you'll want to have a release build in your full project that disables code loading (see bottom of `main.jai`).
- Detect if the app memory layout/size changed between reloads, because right now this would break in unintended ways since we don't assert that in this example. Ideally, you'll want to close and reopen the app in that case, or display an error in that case.
- Rebuild the app from within the app itself (ie: "Recompile app" button or shortcut), or display progress in your UI if your builds take some time :)
- The build files are split in to mainly for the purpose of the example, you can merge that into a single file and use build parameters to choose what to rebuild (main/app/both). I generally add a param to open the programm in a debugger in there too.
- Build the main program only the first time you compile the app?