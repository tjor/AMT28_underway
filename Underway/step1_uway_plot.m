%function step1_uway_plot
   % Plot time series for date range defined in ../input_parameters.m

   clear all

   % Load paths and common variables
   run('../input_parameters.m')
   proc_dir = [OUT_PROC UWAY_DIR 'Step1/' UWAY_WAP_SUBDIR];
   % Create path for saving figures
   fig_dir = [OUT_FIGS UWAY_DIR UWAY_WAP_SUBDIR];
   % Create directory if it does not exists
   if ~exist(fig_dir,'dir')
      mkdir(fig_dir)
   endif

   % Create date range
   [numdates, strdates, vecdates, jdays] = get_date_range(inidate,enddate);

   % Cycle through all jdays
   for i = 1:length(jdays)
      strdate = strdates(i,:);
      doy = sprintf('%d',jdays(i));
      % Processed file to load
      fname = [proc_dir, fproc_name , doy, '.mat'];
      if exist(fname,'file')
         disp(['Plotting day ' strdate])
         load(fname)

         % String date
         t0 = y0(str2num(strdate(1:4))); 

         disp('%-------------------------')
         % Plot flow (assumption is that flow is always there)
         flow = WAPvars.flow;
         disp('Plot flow')
         figure(1, 'visible', 'off')
         hold on
         plot(flow.time-t0+1, flow.mean(:,1),'r-')
         xlim([flow.time(1) flow.time(end)]-t0+1)
         ylabel('flow.mean(:,1)')
         set(gca, 'ylim', flow_lim);
         fnout = [fig_dir,'flow_', doy, '.png'];
         print('-dpng', fnout)
         close all
         disp(' Saved!')

         % Cycle through all instruments
         for idh8 = 1:length(dh8_instruments)
             disp(['Plot ' dh8_instruments{idh8}])
             switch dh8_instruments{idh8}

                 case 'acs'
                     acs = WAPvars.acs;
                     figure(1, 'visible', 'off')
                     hold on
                     plot(acs.raw.time-t0+1, acs.raw.mean(:,30),'-')
                     ylabel('acs.raw.mean(:,30)')
                     %set(gca, 'ylim', [0 0.4]);
                     xlim([acs.raw.time(1) acs.raw.time(end)]-t0+1)
                     %%%%%%%%%%%%%%%%%%%%%%
                     % Change limits in input_params
                     % outputpath from input_params
                     ylim(acs_raw_lim)
                     fnout = [fig_dir,'raw_acs_', doy, '.png'];
                     print('-dpng', fnout)
                     close all

                 case 'acs2'
                     acs2 = WAPvars.acs2;
                     figure(1, 'visible', 'off')
                     hold on
                     plot(acs2.raw.time-t0+1, acs2.raw.mean(:,30),'-')
                     ylabel('acs2.raw.mean(:,30)')
                     %set(gca, 'ylim', [0 0.4]);
                     xlim([acs2.raw.time(1) acs2.raw.time(end)]-t0+1)
                     %%%%%%%%%%%%%%%%%%%%%%
                     % Change limits in input_params
                     % outputpath from input_params
                     ylim(acs_raw_lim)
                     fnout = [fig_dir,'raw_acs2_', doy, '.png'];
                     print('-dpng', fnout)
                     close all

                case 'ac9' 
                    ac9 = WAPvars.ac9;
                    figure(1, 'visible', 'off')
                    hold on
                    plot(ac9.raw.time-t0+1, ac9.raw.mean(:,2),'-')
                    ylabel('ac9.raw.mean(:,2)')
                    %set(gca, 'ylim', [0 0.4]);
                    xlim([ac9.raw.time(1) ac9.raw.time(end)]-t0+1)
                    %%%%%%%%%%%%%%%%%%%%%%
                    % Change limits in input_params
                    % outputpath from input_params
                    ylim(acs_raw_lim)
                    fnout = [fig_dir,'raw_ac9_', doy, '.png'];
                    print('-dpng', fnout)
                    close all

                case 'bb3'
                    bb3 = WAPvars.bb3;
                    figure(1, 'visible', 'off')
                    hold on
                    plot(bb3.counts.time-t0+1, bb3.counts.mean(:,2),'-')
                    ylabel('BB3-1173 (532 nm)');
                    xlim([bb3.counts.time(1) bb3.counts.time(end)]-t0+1)
                    set(gca, 'ylim', bb3_lim);
                    fnout = [fig_dir,'raw_bb532_', doy, '.png'];
                    print('-dpng', fnout)
                    close all

                case 'ctd'
                    ctd = WAPvars.ctd;
                    figure(4, 'visible', 'off')
                    subplot(211)
                    hold on
                    plot(ctd.time-t0+1, ctd.mean(:,1),'-')
                    ylabel('T (degC)');
                    xlim([ctd.time(1) ctd.time(end)]-t0+1)
                    set(gca, 'ylim', SST_lim);

                    subplot(212)
                    hold on
                    plot(ctd.time-t0+1, ctd.mean(:,3),'-')
                    ylabel('S (psu)');
                    xlim([ctd.time(1) ctd.time(end)]-t0+1)
                    set(gca, 'ylim', SSS_lim);

                    fnout = [fig_dir,'raw_ctd_TS_', doy, '.png'];
                    print('-dpng', fnout)
                    close all
                case 'cstar'
                    disp('Cstar not plotted here!!')
                case 'clam'
                    disp('CLAM not plotted here!!')
                 otherwise
                    disp('Instrument not implemented yet!!!')
            endswitch
         disp(' Saved!')
         endfor
         disp('%-------------------------')
         disp(' ')
      endif
   endfor
   disp('Done!')
   
   
