function NoWL = get_acs_NoWL(din,serial_num)
    % Read number of wavelengths of the given acs from the calibration file
    % Cal file is in din/Calibration directory
    cla_dir = [din,'Calibration_files/']; 
    fname = sprintf('acs%3d.dev',serial_num);
[cla_dir,fname]
    fid = fopen([cla_dir,fname],"r");
    for i = 1:8
        d = fgetl(fid);
    endfor
    NoWL = str2num(d(1:2));

endfunction
