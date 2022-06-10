function t0 = y0(yyyy);
%
% function t0 = y0(yyyy)
%
% Returns datenum([yyyy-1 12 31 23 59 59.99999999999999])
%
% Dec. 27 2012, gdo

    sy = size(yyyy);
    t0 = datenum([yyyy-ones(sy) ones(sy)*[12 31 23 59 59.99999999999999]]);
    
endfunction




