function [msec_bb3 time_bb3 dat_bb3 wl_bb3] = rd_ecobb3(fname)

    fid = fopen(fname, "r");

        %fmt = "%f %f/%f/%f	%f:%f:%f %*f %f %*f 	%f %*f 	%f %*f\n";
        % tmp = fscanf(fid, fmt, [10, Inf])';
        fmt = "%f %f/%f/%f	%f:%f:%f %f %f %f	%f %f	%f %*f\n";
        tmp = fscanf(fid, fmt, [13, Inf])';

    fclose(fid);

    if ~isempty(tmp)
       dat_bb3 = [tmp(:,9), tmp(:,11), tmp(:,13)];
       msec_bb3 = tmp(:,1);
       time_bb3 = datenum([2000+tmp(:,4) tmp(:,2) tmp(:,3) tmp(:,5) tmp(:,6) tmp(:,7)]);
       wl_bb3 = [tmp(1,8), tmp(1,10), tmp(1,12)];
    else
       dat_bb3 = [];
       msec_bb3 = [];
       time_bb3 = [];
       wl_bb3 = [];
    endif

endfunction



