%load cstar data and process them using calibration independent technique (filter/NOfilter)

function step2d_cstar_make_processed(cstar, dailyfile, cstar_lim)

   close all

   % Global var from step2
   global FN_ROOT_STEP2 
   global DIR_FIGS 
   global YYYY


      jday_str = dailyfile.name(end-6:end-4);

#      % Apply ac-s QC
#      cstar.raw.mean(acs.raw.qcflag~=0,:) = nan;
#      cstar.raw.med(acs.raw.qcflag~=0,:)  = nan;
#      cstar.raw.std(acs.raw.qcflag~=0,:)  = nan;

      time = cstar.raw.time - y0(YYYY);


      % Determine times for filtered and unfiltered measurements to be used in
      % calculating calibration independent particle properties
      % Select only times that we have data logged for
      tmp_time = datevec(time);
      tmp_sched = time;
      tmp_time_min = round(tmp_time(:,5)+tmp_time(:,6)/60);

      i_tm_fl = (ismember(tmp_time_min, [2:9]) & tmp_sched) ;  %filtered times       
      i_tm_uf = (ismember(tmp_time_min, [11:58]) & tmp_sched);  %unfiltered times

      i_tm_fl_med = (ismember(tmp_time_min, [5]) & tmp_sched) ;  %filtered times to be used for correction
      %
      %compute uncalibrated cp    
      cstar.cp_tmp = cstar.raw.med;




      %take median value of the 8 filtered times without using any loop
      noFilTimes = 8;
      tmp_fi_c = cstar.cp_tmp(i_tm_fl,:)';
      tmp_fi_c = reshape(tmp_fi_c,1,noFilTimes,size(cstar.cp_tmp(i_tm_fl,:),1)/noFilTimes);
      med_fi_c = median(tmp_fi_c,2);  
      med_fi_c = reshape(med_fi_c, 1,size(cstar.cp_tmp(i_tm_fl,:),1)/noFilTimes)';



      % Linear interpolation between filtered measurements
      cstar.cfilt_i = interp1(time(i_tm_fl_med), med_fi_c, time, 'extrap'); 


   ############## HARCODED: 2 BE REMOVED ##################### 
   # if strcmp(dailyfile.name, 'optics_amt28_295.mat')
   #     [var_filt i_tm_fl i_tm_uf] = filt_time_exception_295(cstar.raw, flow_v);
   #     cstar.cfilt_i = var_filt;
   # endif
   ###########################################



      % Calibration-independent particle optical properties

      Nmed = 1;  % nanmedian(cstar.volts.N(:,1));
      
      % initialize output variables
      cstar.cp = nan(size(cstar.cp_tmp));
      cstar.cp_err = nan(size(cstar.cp_tmp));
      
      
      % fill output variables
      cstar.cp(i_tm_uf,:) = cstar.cp_tmp(i_tm_uf,:) - cstar.cfilt_i(i_tm_uf,:);
      cstar.cp_err(i_tm_uf,1) = sqrt( 1/0.25^2.*( (cstar.raw.prc(i_tm_uf,1)./sqrt(cstar.raw.N(i_tm_uf,1))./cstar.raw.med(i_tm_uf,1)).^2 + ...
                                              (0.5e-3./sqrt(Nmed)./cstar.cfilt_i(i_tm_uf,1)).^2)    )  ;

      %     


      % ---GRG---
      % select only non-NaN points
      cstar.nn = ~isnan(cstar.cp(:,1));


      cstar.time = time;%(i_tm_uf);


      c1 = rmfield(cstar, ['cp_tmp']);
      c1 = rmfield(c1, ['cfilt_i']);




      savefile = [FN_ROOT_STEP2 strsplit(dailyfile.name, "_"){end}];
      if exist(savefile, 'file')
         load(savefile)
      end

      out.cstar = cstar;
      save('-v6', savefile , 'out' )






      
      figure(1, 'visible', 'off')  ;
      clf
      hold on
      plot(time, cstar.cp_tmp(:,1), 'o-', 'markersize',4, 'linewidth', 0.5)
      plot(time(i_tm_fl), cstar.cp_tmp(i_tm_fl,1), 'r*', 'markersize',4, 'linewidth', 0.5)
      hold off
      set(gca, 'ylim', cstar_lim)

      fnout = [DIR_FIGS 'cstar' jday_str '.png'];
      print ('-dpng', fnout)

      
      


   endfunction



















