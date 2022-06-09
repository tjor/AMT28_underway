%load cstar data and process them using calibration independent technique (filter/NOfilter)

function [cp_3] = step2d_cstar_make_processed(cstar, acs, dailyfile, cstar_lim)

   close all

   tic

   % Global var from step2
   global din
   global proc_dir
   global fig_dir
   global YYYY

   % % ----GRG------

   cp_3 = [];

   Ts = [];
   Ts_u = [];
   Ts_d = [];
   diffe = [];%this is the matrix where we store the step-difference in cp



      jday_str = dailyfile.name(end-6:end-4);

      % Apply ac-s QC
      cstar.raw.mean(acs.raw.qcflag~=0,:) = nan;
      cstar.raw.med(acs.raw.qcflag~=0,:)  = nan;
      cstar.raw.std(acs.raw.qcflag~=0,:)  = nan;

      time = cstar.raw.time-(y0(YYYY)-1);

      %this if is to account for a shift in the position of the filtered times.  It seems to be due to the DH4 or to a problem with the time syncronizations among computers
      giorno = str2num(dailyfile.name(end-6:end-4));%+(tmp_time(:,5)+tmp_time(:,6)/60)/24;

      % Determine times for filtered and unfiltered measurements to be used in
      % calculating calibration independent particle properties
      % Select only times that we have data logged for
      tmp_time = datevec(time);
      tmp_sched = time;
      tmp_time_min = round(tmp_time(:,5)+tmp_time(:,6)/60);

      tm_fl = (ismember(tmp_time_min, [2:9]) & tmp_sched) ;  %filtered times       
      tm_uf     = (ismember(tmp_time_min, [11:58]) & tmp_sched);  %unfiltered times

      tm_fl_med = (ismember(tmp_time_min, [5]) & tmp_sched) ;  %filtered times to be used for correction
      %
      %compute uncalibrated cp    
      cstar.cp_tmp = cstar.raw.med;




      %take median value of the 8 filtered times without using any loop

      noFilTimes = 8;
      tmp_fi_c = cstar.cp_tmp(tm_fl,:)';
      tmp_fi_c = reshape(tmp_fi_c,1,noFilTimes,size(cstar.cp_tmp(tm_fl,:),1)/noFilTimes);
      med_fi_c = median(tmp_fi_c,2);  
      med_fi_c = reshape(med_fi_c, 1,size(cstar.cp_tmp(tm_fl,:),1)/noFilTimes)';



      % Linear interpolation between filtered measurements
      cstar.cfilt_i = interp1(time(tm_fl_med), med_fi_c, time); 


    
    if strcmp(dailyfile.name, 'optics_amt28_295.mat')
    
        [var_filt tm_fl tm_uf] = filt_time_exception_295(cstar.raw, flow_v);
        
        cstar.cfilt_i = var_filt;
        
    
    endif
      



      % Calibration-independent particle optical properties

      Nmed = 1;  % nanmedian(cstar.volts.N(:,1));
      
      % initialize output variables
      cstar.cp = nan(size(cstar.cp_tmp));
      cstar.cp_err = nan(size(cstar.cp_tmp));
      % fill output variables
      cstar.cp(tm_uf,:) = cstar.cp_tmp(tm_uf,:) - cstar.cfilt_i(tm_uf,:);
      cstar.cp_err(tm_uf,1) = sqrt( 1/0.25^2.*( (cstar.raw.prc(tm_uf,1)./sqrt(cstar.raw.N(tm_uf,1))./cstar.raw.med(tm_uf,1)).^2 + (0.5e-3./sqrt(Nmed)./cstar.cfilt_i(tm_uf,1)).^2)    )  ;

      %     


      % ---GRG---
      % select only non-NaN points
      cstar.nn = ~isnan(cstar.cp(:,1));
      % ---GRG---


      cstar.time = time;%(tm_uf);


      c1 = rmfield(cstar, ['cp_tmp']);
      c1 = rmfield(c1, ['cfilt_i']);




      savefile = [proc_dir,'proc_',dailyfile.name];
      if (exist(savefile))
         load(savefile)
      end
      out.cstar = cstar;
      save('-v6', savefile , 'out' )






      
      figure(1, 'visible', 'off')  ;
      clf
      hold on
      plot(time, cstar.cp_tmp(:,1), 'o-', 'markersize',4, 'linewidth', 0.5)
      plot(time(tm_fl), cstar.cp_tmp(tm_fl,1), 'r*', 'markersize',4, 'linewidth', 0.5)
      hold off
      set(gca, 'ylim', cstar_lim)

      fnout = [fig_dir,'cstar' jday_str '.png'];
      print ('-dpng', fnout)

      
      
      
      % hold off
      % figure(1)
      % subplot(2,1,1)
      % title(num2str(idays))
      % hold on
      %   plot(time, cstar.cp_tmp(:,1), 'go')
      %   plot(time(tm_fl), cstar.cp_tmp(tm_fl,1), 'k.')
      %   plot(time(tm_fl), cstar.cp_tmp(tm_fl,1), 'k.')
      %   plot(time(tm_fl_med), med_fi_c(:,1), 'm*', 'Markersize', 4)
      %   plot(time, cstar.cfilt_i(:,1), 'k')
      % hold off
      % axis([286 288 1.46 1.56])
      % 
      % subplot(2,1,2)
      % hold on
      %   plot(time, cstar.cp_tmp(:,2), 'ro')
      %   plot(time(tm_fl), cstar.cp_tmp(tm_fl,2), 'k.')
      %   plot(time(tm_fl_med), med_fi_c(:,2), 'm*', 'Markersize', 4)
      %   plot(time, cstar.cfilt_i(:,2), 'k')
      % hold off
      % axis([187 190 1.66 1.76])

      % subplot(2,1,1)
      % title(num2str(idays))
      % hold on
      %   plot(time, cstar.volts.prc(:,1), 'go')
      %   plot(time(tm_fl), cstar.volts.prc(tm_fl,1), 'k*')
      % %     plot(time(tm_fl), cstar.cp_tmp(tm_fl,1), 'k.')
      % %     plot(time(tm_fl_med), med_fi_c(:,1), 'm*', 'Markersize', 4)
      % %     plot(time, cstar.cfilt_i(:,1), 'k')
      % hold off
      % subplot(2,1,2)
      % hold on
      %   plot(time, cstar.volts.prc(:,2), 'ro')
      %   plot(time(tm_fl), cstar.volts.prc(tm_fl,2), 'k*')
      % %     plot(time(tm_fl), cstar.cp_tmp(tm_fl,1), 'k.')
      % %     plot(time(tm_fl_med), med_fi_c(:,1), 'm*', 'Markersize', 4)
      % %     plot(time, cstar.cfilt_i(:,1), 'k')
      % hold off



   %toc



   % cp_3 = [cp_3; [cstar.time, cstar.cp(:,:)]];
   %save('-v6', '../output/cp_cstar.mat', 'cp_3')

   % figure
   % plot(cp_3(:,1), cp_3(:,2), 'go', 'MarkerSize', 2); hold on
   % plot(cp_3(:,1), cp_3(:,3), 'ro', 'MarkerSize', 2)
   % axis([285 round(max(time))+1 0 .3])
   % ylabel('c-star c_p (m^{-1})');
   % xlabel('decimal days from Jan 1, 2009');





   endfunction



















