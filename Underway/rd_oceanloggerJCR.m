function tmp = rd_oceanloggerJCR(fn)

%2015,265.000579,265,0.00057870, 2015  265  00:00:46,17.800000,66.180000,-0.200000,-400.200000,17.800000,65.400000,1.200000,-400.300000,1025.110000,1025.070000,18.874300,4.774590,35.813500,1519.230000,0.556000,18.800000,0.523669,18.471400,0.829633,18.471200

    fmt = "%f,%f,%f,%f, %f  %f  %f:%f:%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n";

    fid = fopen(fn, "r");

        d = fscanf(fid, fmt, [29, Inf])'; 
   
    fclose(fid);   


    tmp.time = y0(d(1))-1+d(:,2);

    tmp.air_temp1 = d(:,10); % [degC]
    tmp.humidity1 = d(:,11); % [%]
    tmp.par = d(:,12); % [umol/m2]]
    tmp.tir1 = d(:,13); % [W/m2]
    tmp.air_temp2 = d(:,14); % [degC]
    tmp.humidity2 = d(:,15); % [%]
    tmp.par2 = d(:,16); % [umol/m2]]
    tmp.tir2 = d(:,17); % [W/m2]
    tmp.baro1 = d(:,18); % [hPa]
    tmp.baro2 = d(:,19); % [hPa]
    tmp.thermosalinograph_temp = d(:,20); % [degC]
    tmp.conductivity = d(:,21); % [S/m]
    tmp.sal = d(:,22); % [psu]
    tmp.velocity = d(:,23); % [m/s]
    tmp.chl = d(:,24); % [ug/l]
    tmp.sample_temp = d(:,25); % [degC]
    tmp.flowrate = d(:,26); % [l/min]
    tmp.sst = d(:,27); % [degC]

    tmp.field28th = d(:,28);
    tmp.field29th = d(:,29);



endfunction
