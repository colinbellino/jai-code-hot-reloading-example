// This hasn't been testing on Linux yet, might have to have a different implementation for OS == .LINUX

load :: (path: string, verbose := false) -> (ptr: *void, ok: bool) {
    #if OS == .WINDOWS {
        #import "Basic";
        #import "Windows";
        #import "Windows_Utf8";
        ptr := LoadLibraryW(utf8_to_wide_new(path,, allocator = temp));
        if ptr == null && verbose {
            log_error("Couldn't load library at path: %. Error: %.", path, GetLastError());
        }
        return ptr, ptr != null;
    } else {
        #import "Basic";
        #import "POSIX";
        ptr := dlopen(to_c_string(path,, allocator = temp), RTLD_NOW);
        if ptr == null && verbose {
            log_error("Couldn't load library at path: %. %.", path, to_string(dlerror()));
        }
        return ptr, ptr != null;
    }
}

unload :: (ptr: *void, verbose := false) -> (ok: bool) {
    assert(ptr != null);

    #if OS == .WINDOWS {
        #import "Basic";
        #import "Windows";

        result := FreeLibrary(ptr);
        if result == 0 && verbose {
            log_error("Couldn't unload library.\n%.", GetLastError());
        }
        return cast(bool) result != 0;
    } else {
        #import "Basic";
        #import "POSIX";
        result := dlclose(ptr);
        if result != 0 && verbose {
            log_error("Couldn't unload library.\n%.", to_string(dlerror()));
        }
        return result == 0;
    }
}

symbol_address :: (library: *void, symbol_name: string, verbose := false) -> (ptr: *void, ok: bool) {
    #if OS == .WINDOWS {
        #import "Basic";
        #import "Windows";
        ptr := GetProcAddress(library, to_c_string(symbol_name,, allocator = temp));
        if ptr == null && verbose {
            log_error("Couldn't load library symbol: %.\n%.", symbol_name, GetLastError());
        }
        return ptr, ptr != null;
    } else {
        #import "Basic";
        #import "POSIX";
        ptr := dlsym(library, to_c_string(symbol_name,, allocator = temp));
        if ptr == null && verbose {
            log_error("Couldn't load library symbol: get_memory.\n%.", to_string(dlerror()));
        }
        return ptr, ptr != null;
    }
}
