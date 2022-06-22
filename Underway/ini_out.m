# initialize empty (nan) acs and ac9 structure in files to make sure we have a complete time-stamp dimension for the whole cruise
function ini_out(day2ini, doy)

global FN_ROOT_STEP2


     # define acs time vector (from file name)
     onemin = datenum([0 0 0 0 1 0 ]); # this is the time interval between bins (i.e., 1 minute)     
     yymmddHHMMDD = zeros(1440,6); # initialize empty matrix
     yymmddHHMMDD(:,3) = onemin*[0:1:1440-1]'; # assign to day-column the minute intervals

     tmp_time = datenum( ones(1440,1)*[0 0 0 0 0 0] + yymmddHHMMDD) + doy  -1   ; # compute julian day for current date (jdays(iday))
datevec(tmp_time(1))
     acs.time = tmp_time; # assign time vector to acs structure of this day

     # fill the rest of the acs structure with NaNs
     acs.ap = nan(1440,176);
     acs.cp = nan(1440,176);
     acs.ap_u = nan(1440,176);
     acs.cp_u = nan(1440,176);
     acs.N = nan(1440,1);
     acs.bp = nan(1440,176);
     acs.bp_u = nan(1440,176);
     acs.nn = nan(1440,1);
     acs.wl = nan(1,176);
     acs.wv = nan(1,176);

     ac9.time = acs.time;
     ac9.ap = nan(1440,9);
     ac9.ap_u = nan(1440,9);
     ac9.bp = nan(1440,9);
     ac9.bp_u = nan(1440,9);
     ac9.cp = nan(1440,9);
     ac9.cp_u = nan(1440,9);
     ac9.N = nan(1440,1);
     ac9.wv = nan(1,9);

     bb3.bbp = nan(1440,3);
     bb3.bbp_err = nan(1440,3);
     bb3.bb02 = nan(1440,3);
     bb3.bb02_err = nan(1440,3);
     bb3.bbp_corr = nan(1440,3);
     bb3.bdgt.X = nan(1440,3);
     bb3.bdgt.SF = nan(1440,3);
     bb3.bdgt.C = nan(1440,3);
     bb3.bdgt.Bw = nan(1440,3);
     bb3.bdgt.DC = nan(1440,3);
     bb3.bdgt.WE = nan(1440,3);


     # add acs structure to out structure to be written in step2 file
     out.acs = acs;
     out.ac9 = ac9;
     out.bb3 = bb3;

     # write empty step2 file 
     savefile = [FN_ROOT_STEP2 strsplit(day2ini, "_"){end}];
     save('-v6', savefile , 'out' )


endfunction        

