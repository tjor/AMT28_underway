function NoWL = get_acs_NoWL(D_CAL_FILES, ACS_CAL_FILE_NAME)
    % Read number of wavelengths of the given acs from the calibration file
    fid = fopen([D_CAL_FILES, ACS_CAL_FILE_NAME], "r");
    for i = 1:8
        d = fgetl(fid);
    endfor
    NoWL = str2num(d(1:2));

endfunction
