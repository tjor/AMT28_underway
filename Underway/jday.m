function doy = jday(indate)
#
# function doy = jday(indate)
# compute day of the year from date
# idate is an Octave date e.g., today()
#
    pkg load financial
    indate = indate(:);
    doy = floor(indate-y0(year(indate))+1);
endfunction
