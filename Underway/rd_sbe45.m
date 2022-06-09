function [msec T C S] = rd_sbe45(fn)

#13250	 23.0512,  5.24493,  36.0844

    fmt = "%f %f,%f,%f\n";

    fid = fopen(fn, "r");

        d = fscanf(fid, fmt, [4, Inf])'; 
   
    fclose(fid);   


    msec = d(:,1);

    T = d(:,2); # [degC]
    C = d(:,3); # [volts]
    S = d(:,4); # [sal]






endfunction
