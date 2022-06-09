function [msec_cstar dat_cstar] = rd_cstar(fname)


#1750	CST-1426DR	10976	13838	14930	00.179	539
#2510	CST-1426DR	10976	13839	14931	00.179	538
#3260	CST-1426DR	10976	13842	14934	00.178	539



    fid = fopen(fname, "r");

        fmt = "%f CST-1426DR %f %f %*f %*f %*f\n";  ##  %f/%f/%f	%f:%f:%f %*f %f %*f 	%f %*f 	%f %*f\n";

        tmp = fscanf(fid, fmt, [3, Inf])';

    fclose(fid);

    if ~isempty(tmp)
       dat_cstar = tmp(:,2)./tmp(:,3);
       msec_cstar = tmp(:,1);
    else
       dat_cstar = [];
       msec_cstar = [];
    endif

endfunction

