function [MM,DD,YY,hh,mm,ss, msec] = rd_19(fn)

fid = fopen (fn, "r");

    fmt = "%f %f/%f/%f	%f:%f:%f\n";
    tmp = fscanf(fid, fmt, [7, Inf])';
    
    msec = tmp(:,1);
    MM = tmp(:,2);
    DD = tmp(:,3);
    YY = tmp(:,4);
    hh = tmp(:,5);
    mm = tmp(:,6);
    ss = tmp(:,7);


fclose(fid);





endfunction
