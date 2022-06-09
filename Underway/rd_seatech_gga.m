function tmp = rd_seatech_gga(fn)

%2015,265.000000,265,0.00000000,000000.27,42.65628,-18.28315,2,08,1.1,3.04,2.0,0120
%2016,268.000000,268,0.00000000,235959.86,48.82730,-7.86832,2,07,1.1,-1.26,3.0,0120




#     fmt = '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n';
# 
#     fid = fopen(fn, "r");
# 
#         d = fscanf(fid, fmt, [13, Inf])'; 
#    
#     fclose(fid);   

    
    d = dlmread(fn);

    tmp.time = y0(d(1))-1+d(:,2);

    tmp.lat = d(:,6); % [degN]
    tmp.lon = d(:,7); % [degE]



%    % this is to deal with change in format through the cruise
%    if length(tmp.time==1)
%
%        fmt = "%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,,\n";
%
%        fid = fopen(fn, "r");
%
%            d = fscanf(fid, fmt, [11, Inf])'; 
%       
%        fclose(fid);   
%
%
%        tmp.time = y0(d(1))-1+d(:,2);
%
%        tmp.lat = d(:,6); % [degN]
%        tmp.lon = d(:,7); % [degE]
%            
%
%
%    endif




endfunction
