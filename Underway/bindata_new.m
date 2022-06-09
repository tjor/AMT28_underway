%create a structure where the data will be stored
function [bindata] = bindata_new(bintime,ncol)


    if ischar(bintime)
        yymmdd = datevec(bintime,'yyyymmdd');
        [bin_hh,bin_mm] = meshgrid(0:23,0:59);
        bin_hh = bin_hh(:);    
        bin_mm = bin_mm(:);    
        bintime = datenum(yymmdd(1), yymmdd(2), yymmdd(3), bin_hh, bin_mm, 0);

    end
    
    
    bindata.time = bintime;
    bindata.deltat = datenum(0,0,0,0,1,0);			%set delta_t=1 minute
    
    bindata.ns = nan(length(bintime),1);
    bindata.qcflag = zeros(length(bintime),1);
    
    bindata.mean = nan(length(bintime),ncol);
    bindata.med = nan(length(bintime),ncol);
    bindata.std = nan(length(bintime),ncol);
    bindata.prc = nan(length(bintime),ncol);
    bindata.N = nan(length(bintime),ncol);
    
    bindata.comments = {['Created ' datestr(now,0)]};

    
    
    
