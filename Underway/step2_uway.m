%function tmp = step2_uway();
   % Compute bio-physical quantities from optical data

   clear all
   PLOT = 1;

   % Load paths and common variables
   run('../input_parameters.m')
   global din = [OUT_PROC UWAY_DIR 'Step1/'];
   global proc_dir = [din '../Step2/'];
   global gps_dir = PATH_GPS;
   global ts_dir = PATH_TS;
   % Create path for saving figures
   global fig_dir = [OUT_FIGS,UWAY_DIR];
   % Create directories if they do not exists
   if ~exist(fig_dir,'dir')
      mkdir(fig_dir);
   endif
   if ~exist(proc_dir,'dir')
      mkdir(proc_dir);
   endif


   % Create date range
   [numdates, strdates, vecdates, jday_in] = get_date_range(inidate,enddate);

   fn_saved = glob([din '*mat']);

   global YYYY = vecdates(1,1); % Assumes all AMT days are within same year!!

   % Change first day to process more than just last sampled day 
   first_day = find_index_strdate_in_glob(fn_saved,sprintf('%d',jday_in(1)));
   last_day = find_index_strdate_in_glob(fn_saved,sprintf('%d',jday_in(end)));

   % Need to overwrite array of jdays with dates from saved files
   for ifile = 1:length(fn_saved)
       jdays(ifile) = str2num(strsplit(fn_saved{ifile},'.'){1}(end-2:end));
   endfor

   dailyfiles = dir(  [din '*mat']  );

   first_day = 1;   
   for iday = first_day:last_day

        % First process Ship ctd data
        % (needed by bb3 processing)
        disp('processing SHIP UNDERWAY data...');  
        step2h_underway_amt27_make_processed(jdays(iday), PATH_TS, ship_uway_fname, CRUISE)  ;%  siccome hai la tua CTD, qui potresti usare la tua T and S.
        disp('...done\n\n'); 

        disp(dailyfiles(iday).name)
        fflush(stdout);

        jday_str = dailyfiles(iday).name(end-6:end-4);
        % Load WAPvars
        load([din dailyfiles(iday).name]);

        % Idea is that flow is always there
        % (also needed by ac9 processing)
        disp('processing Flow data...');  
        flow = step2f_flow_make_processed(WAPvars.flow,dailyfiles(iday));
        disp('...done\n\n'); 

        % Cycle trhough the variables within WAPvars
        instruments = fieldnames(WAPvars);
        for iWAP = 1:length(instruments)
           disp(['Processing ',instruments{iWAP},' data...']);
           switch instruments{iWAP}
               case 'flow'
                   disp('Flow already processed')

               case 'acs'
                   step2a_acs_amt27_make_processed(WAPvars.acs, dailyfiles(iday), iday, acs_lim, force=0, 'acs');
       
#               case 'acs2'
#                   step2a_acs_amt27_make_processed(WAPvars.acs2, dailyfiles(iday), iday, acs_lim, force=0, 'acs2');
#       
#               case 'ac9'
#                   keyboard
#                   step2a_ac9_amt_make_processed(WAPvars.ac9, dailyfiles(iday), ac9_lim, force=0, flow);
#
#               case 'bb3'
#                   %------------------------------------------
#                   % load underway ship's data
#                   load(ls([proc_dir '*' jday_str '*']));
#                   undwy = out.uway;
#                   %------------------------------------------
#
#                   step2b_bb3_amt27_make_processed(WAPvars.bb3, undwy, dailyfiles(iday), iday, bb_opt_lim,CRUISE);
#
#               case 'cstar'
#                   % This requires acs, so check if it is there
#                   if ~isempty(intersect('acs',instruments))
#                       step2d_cstar_make_processed(WAPvars.cstar, WAPvars.acs, dailyfiles(iday), cstar_lim);
#                   else
#                       disp('No acs on found! Cstar cannot be processed')
#                   endif
#
               case 'ctd'
                   step2f_ctd_make_processed(WAPvars.ctd,dailyfiles(iday));

#               case 'clam'
#                   disp('Nothing to do with the CLAM')
#
#               case 'flow_v'
#                   disp('Nothing to do with flow_v')
#
#               otherwise
#                   disp('Instrument to be implemented')
#                   keyboard
           endswitch
           disp('...done\n\n'); 
       endfor
   endfor
  
 if PLOT == 1
   % Plot spectra from acs
   for iday = first_day:last_day
      %plot_spectra2 (strsplit(fn_saved{ij}, '_.'){end-1})
      disp(num2str(jdays(iday)));
      fflush(stdout);
      plot_spectra2(sprintf('%d',jdays(iday)),spectra_alim, spectra_clim, chl_lim);
   endfor
 endif

   %% save chl for Bob
   %    secchi_chl
%endfunction
