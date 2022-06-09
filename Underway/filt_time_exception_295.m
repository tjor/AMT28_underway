#### this is needed to take care of a wrong timing for the filter on day 295
function [var_filt tm_fl tm_uf] = filt_time_exception_295(var, flow_v)



    tm_fl = find(flow_v.mean==-1);
    tm_uf = find(flow_v.mean== 0);

    var_filt = interp1(var.time(tm_fl), medfilt1(var.med(tm_fl,:),11), var.time, 'extrap');


 
    
    
    
    
endfunction



