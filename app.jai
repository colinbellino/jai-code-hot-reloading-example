#import "Basic";

Game_State :: struct {
    number_of_reloads: int;
}

game: *Game_State;

#program_export
update :: () -> (quit: bool) {
    if game == null {
        game = New(Game_State);
        log("Game initialized.");
    }

    // This is where your game loop would go

    return false; // Return true to tell the main program to quit.
}

#program_export
unload :: () -> *Game_State {
    // This is were you'll probably do some clean up in a real project
    // so you don't leak memory, file handles, etc (not that it's super important in debug builds, but you know)
    log("Game unloaded.");
    return game;
}

#program_export
reload :: (memory: *Game_State) {
    // We get a pointer to the game memory before the code reload so we need
    // to assign it to what the game is using.
    assert(memory != null);
    game = memory; 
    game.number_of_reloads += 1; // Just for the example, to show we are keeping the game state on reload
    log("Game reloaded (number_of_reloads: %).", game.number_of_reloads);
}
