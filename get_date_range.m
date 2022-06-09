function [numdates, strdates, vecdates, jdays] = get_date_range(inidate,enddate)
   % Return arrays with range of dates between inidate and enddate
   % Arrays are day numbers, day vectors, and day strings
   % Also return julian days
   numdates = datenum(inidate,'yyyymmdd'):1:datenum(enddate,'yyyymmdd');
   strdates = datestr(numdates,'yyyymmdd');
   vecdates = datevec(numdates);
   jdays = jday(numdates);

endfunction
