function [msec wl690 wl675 wl690_mon wl675_mon a690 a675 Tsample Tmonitor Tboard] = rd_clam(fn)

%13250	 23.0512,  5.24493,  36.0844
%250 2   52441780    73512960    90060040    122320568   5.822980e-01    6.009861e-01    2.163092e+00    2.036734e+00    1.263578e-01    18.81   18.28   32.17   -128

    fmt = repmat("%f\t",1,14);
    fmt =[fmt,"%f\n"];
    %f\t%f\t%f  %f  %f  %f  %f  %f  %f  %f  %f  %f  %f  %f\n";

    fid = fopen(fn, "r");

        d = fscanf(fid, fmt, [15, Inf])'; 
   
    fclose(fid);   

    % It can happen that file exists bu it is empty
    % Need to check for that to avoid error
    if ~isempty(d)

        msec = d(:,1);

        wl690 = d(:,3); # [counts]
        wl675 = d(:,4); # [counts]
        wl690_mon = d(:,5); # [counts]
        wl675_mon = d(:,6); # [counts]
        Tsample = d(:,12); # [degC]
        Tmonitor = d(:,13); # [degC]
        Tboard = d(:,14); # [degC]

        a675 = -1/0.25 * log(wl675./wl675_mon);
        a690 = -1/0.25 * log(wl690./wl690_mon);
    else
        msec = [];

        wl690 = []; # [counts]
        wl675 = []; # [counts]
        wl690_mon = []; # [counts]
        wl675_mon = []; # [counts]
        Tsample = []; # [degC]
        Tmonitor = []; # [degC]
        Tboard = []; # [degC]

        a675 = [];
        a690 = [];
    endif


endfunction
