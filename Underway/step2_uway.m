%function tmp = step2_uway();
   % Compute bio-physical quantities from optical data
 
   clear all
   PLOT = 1;

   % Load paths and common variables
   run("../input_parameters.m")
   global OUT_PROC # this is for plot_spectra2.m
   global UWAY_DIR

   % Create date range
   [numdates, strdates, vecdates, jday_in] = get_date_range(inidate,enddate);

   fn_saved = glob([DIR_STEP1 "*mat"]);

   global YYYY = vecdates(1, 1); % Assumes all AMT days are within same year!! % used as processing Id

   % Change first day to process more than just last sampled day 
   first_day = find_index_strdate_in_glob(fn_saved, sprintf("%d", jday_in(1))); % follows from ini and end dates
   last_day = find_index_strdate_in_glob(fn_saved, sprintf("%d", jday_in(end)));

   % Need to overwrite array of jdays with dates from saved files
   for ifile = 1:length(fn_saved)
       jdays(ifile) = str2num(strsplit(fn_saved{ifile}, "."){1}(end-2:end)); % creates jday array-define
   endfor

   dailyfiles = dir(  [DIR_STEP1 "*mat"]  ); % redundancy with line 27? just different format




   # initialize empty (nan) acs and ac9 structure in files to make sure we have a complete time-stamp dimension for the whole cruise
   for iday = 1:length(jdays)

     # define acs time vector (from file name)
     onemin = datenum([0 0 0 0 1 0 ]); # this is the time interval between bins (i.e., 1 minute)     
     yymmddHHMMDD = zeros(1440,6); # initialize empty matrix
     yymmddHHMMDD(:,3) = onemin*[0:1:1440-1]'; # assign to day-column the minute intervals

     tmp_time = datenum( ones(1440,1)*[0 0 0 0 0 0] + yymmddHHMMDD) + jdays(iday)    ; # compute julia day for current date (jdays(iday))

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

     # write empty step2 file 
     savefile = [FN_ROOT_STEP2 strsplit(dailyfiles(iday).name, "_"){end}];
     save('-v6', savefile , 'out' )


   endfor


   %first_day = 1;   
   for iday = first_day:last_day
        
        disp(["\n---------" dailyfiles(iday).name "--------\n"] )
        fflush(stdout);

        % First process Ship ctd data
        % (needed by bb3 processing)
        disp("\nprocessing SHIPs UNDERWAY data...");  
        uway = step2h_ships_underway_amt_make_processed(jdays(iday), \
                DIR_GPS, GLOB_GPS, FN_GPS, FNC_GPS, \
                DIR_METDATA, GLOB_METDATA, FN_METDATA, FNC_METDATA)  ;%
        disp("...done"); 
        

        jday_str = dailyfiles(iday).name(end-6:end-4);

        % Load WAPvars from step1 output file
        load([DIR_STEP1 dailyfiles(iday).name]);

        % Idea is that flow is always there
        % (also needed by ac9 processing)
        disp("processing Flow data...");  
        flow = step2f_flow_make_processed(WAPvars.flow, dailyfiles(iday));
        disp("...done"); 


        % Cycle through the variables within WAPvars
        instruments = fieldnames(WAPvars);
        for iWAP = 1:length(instruments)

           disp(["Processing ", instruments{iWAP}, " data..."]);

           switch instruments{iWAP}
               case "flow"
                   disp("Flow already processed")

               case "acs"
                   step2a_acs_amt_make_processed(WAPvars.acs, dailyfiles(iday), iday, acs_lim, FORCE=0, "acs");
       
               case "acs2"
                   step2a_acs_amt_make_processed(WAPvars.acs2, dailyfiles(iday), iday, acs_lim, FORCE=0, "acs2");
       
               case "ac9"
                   step2a_ac9_amt_make_processed(WAPvars.ac9, dailyfiles(iday), ac9_lim, FORCE=0, flow);


## uncomment this when you want to process BB3 data
#               case "bb3"
#                   step2b_bb3_amt_make_processed(WAPvars.bb3, uway, dailyfiles(iday), iday, bb_opt_lim, CRUISE);

               case "cstar"
                   step2d_cstar_make_processed(WAPvars.cstar, dailyfiles(iday), cstar_lim);

               case "ctd"
                   step2f_ctd_make_processed(WAPvars.ctd, dailyfiles(iday));

#               otherwise
#                   disp("Instrument to be implemented")
#                   keyboard

           endswitch



           disp("...done");
       endfor
       disp("\n");
       toc
   endfor
  
 if PLOT == 1
   % Plot spectra from acs
   disp("\nplotting spectra...");
   for iday = first_day:last_day
#      disp(num2str(jdays(iday)));
#      fflush(stdout);
      plot_spectra2(sprintf("%d",jdays(iday)),spectra_alim, spectra_clim, chl_lim);
   endfor
 endif

   %% save chl for Bob
   %    secchi_chl
%endfunction
