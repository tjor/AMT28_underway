function parcellfunERRFUNC(S)

    disp("\n\n\n-------------error in parcellfun------------------");
    disp(S.message);
    
    disp(S.stack.name)
    disp(S.stack.line)
    
    disp("\nexiting octave: bye!");
    disp("--------------------------------------------------");
    
    keyboard
    
    fflush(stdout);
    
    


endfunction
