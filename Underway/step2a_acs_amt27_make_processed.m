%load acs data and process them using calibration independent technique (filter/NOfilter)
% and a NIR-base correction for residual temperature dependence

function acsout = step2a_acs_make_processed(acs, dailyfile, idays, acs_lim, force, acstype)

   global dac2dTS
   global Yt Ysa
   global a b refNIR NIR 
   global fval
   global errO
   % Global variables from step2
   global din
   global proc_dir
   global fig_dir
   global YYYY

   close all

   tic

   if ~exist(proc_dir)
      mkdir(proc_dir);
   endif

   acsoutap = [];
   acsoutcp = [];
   acsoutap3 = [];
   acsoutcp3 = [];

   newT0 = y0(YYYY);  %reference time for plotting

   % % ----GRG------
   %correction for residual T-dependence
   %% read Excel spreadsheet with temperature and salinity dependence for acs interpolated every 2 nm
   %fnTS = 'C:\Giorgio\Data\From_literature\Water_absorption\Sullivan_etal_2006_instrumentspecific.xls';     %<<<====== CHANGE HERE
   %dac2dTS = xlsread(fnTS);
   fnTS = 'acs_TSdep.txt';
   dac2dTS = load([fnTS]);

   Ts = [];
   Ts_u = [];
   Ts_d = [];
   diffe = [];%this is the matrix where we store the step-difference in cp
   acdom = [];



   % this is to skip ACs processng or when there are no ACs data
   if (force!=1 & (~exist('acs')) |  all(isnan(acs.raw.med(:,1))))
      keyboard
      return     
   endif


   % Apply ac-s QC
   % acs.raw.med(acs.raw.qcflag~=0,:) = nan;
   % acs.raw.med(acs.raw.qcflag~=0,:) = nan;
   % acs.raw.std(acs.raw.qcflag~=0,:) = nan;

   time = acs.raw.time - newT0;

   giorno = str2num(dailyfile.name(end-6:end-4));     %+(tmp_time(:,5)+tmp_time(:,6)/60)/24;

   n_wv = length(acs.awl);

   
   
   % Determine times for filtered and unfiltered measurements to be used in
   % calculating calibration independent particle properties
   % Select only times that we have data logged for
   tmp_time = datevec(time);
   tmp_sched = time;
   tmp_time_min = round(tmp_time(:,5)+tmp_time(:,6)/60);

   tm_fl = (ismember(tmp_time_min, [2:9]) & tmp_sched) ;  %filtered times                                      %<<<====== CHANGE HERE
   tm_uf = (ismember(tmp_time_min, [11:58]) & tmp_sched);  %unfiltered times                                   %<<<====== CHANGE HERE

   tm_fl_med=(ismember(tmp_time_min, [5]) & tmp_sched) ;  %filtered times to be used for correction            %<<<====== CHANGE HERE

   
   

   %take median value of the xTF filtered times without using any loop   
   xTF = 8;  % how many 0.2um filtered points we have
   n_wv = length(acs.awl);

   tmp_fi_a = acs.raw.med(tm_fl,1:n_wv)';
   tmp_fi_a = reshape(tmp_fi_a,n_wv,xTF,size(acs.raw.med(tm_fl,1:n_wv),1)/xTF);
   med_fi_a = median(tmp_fi_a,2);
   med_fi_a = reshape(med_fi_a, n_wv,size(acs.raw.med(tm_fl,1:n_wv),1)/xTF)';

   tmp_fi_c = acs.raw.med(tm_fl,n_wv+1:end)';
   tmp_fi_c = reshape(tmp_fi_c,n_wv,xTF,size(acs.raw.med(tm_fl,n_wv+1:end),1)/xTF);
   med_fi_c = median(tmp_fi_c,2);
   med_fi_c = reshape(med_fi_c, n_wv,size(acs.raw.med(tm_fl,n_wv+1:end),1)/xTF)';


   % take median also of the within-bin variability of a and c
   tmp_fi_a_u = acs.raw.prc(tm_fl, 1:n_wv)';
   tmp_fi_a_u = reshape(tmp_fi_a_u, n_wv, xTF, size(acs.raw.prc(tm_fl,1:n_wv),1)/xTF);
   med_fi_a_u = median(tmp_fi_a_u, 2);
   med_fi_a_u = reshape(med_fi_a_u, n_wv, size(acs.raw.prc(tm_fl,1:n_wv),1)/xTF)';

   tmp_fi_c_u = acs.raw.prc(tm_fl, n_wv+1:end)';
   tmp_fi_c_u = reshape(tmp_fi_c_u, n_wv, xTF, size(acs.raw.prc(tm_fl,n_wv+1:end),1)/xTF);
   med_fi_c_u = median(tmp_fi_c_u, 2);
   med_fi_c_u = reshape(med_fi_c_u, n_wv,size(acs.raw.prc(tm_fl,n_wv+1:end),1)/xTF)';


   %store filtered data
   acs.cdom.a = med_fi_a;
   acs.cdom.time = time(tm_fl_med);

   % Linear interpolation between filtered measurements and their uncertainties
   acs.afilt_i = interp1(time(tm_fl_med), med_fi_a, time, 'extrap');
   acs.cfilt_i = interp1(time(tm_fl_med), med_fi_c, time, 'extrap');
  
   acs.afilt_u_i = interp1(time(tm_fl_med), med_fi_a_u, time, 'extrap');
   acs.cfilt_u_i = interp1(time(tm_fl_med), med_fi_c_u, time, 'extrap');
   
   % Define and fill [a,c]tot variables and their uncertainties
   acs.atot = nan(size(acs.raw.med(:,1:n_wv)));
   acs.ctot = nan(size(acs.raw.med(:,n_wv+1:end)));
   acs.atot(tm_uf,:) = acs.raw.med(tm_uf,1:n_wv);
   acs.ctot(tm_uf,:) = acs.raw.med(tm_uf,n_wv+1:end);
   
   acs.atot_u = nan(size(acs.raw.prc(:,1:n_wv)));
   acs.ctot_u = nan(size(acs.raw.prc(:,n_wv+1:end)));
   acs.atot_u(tm_uf,:) = acs.raw.prc(tm_uf,1:n_wv) ./ sqrt(acs.raw.N(tm_uf,1:n_wv)) ; % note that I am dividing the uncertainty by sqrt(N)
   acs.ctot_u(tm_uf,:) = acs.raw.prc(tm_uf,n_wv+1:end) ./ sqrt(acs.raw.N(tm_uf,n_wv+1:end)); % note that I am dividing the uncertainty by sqrt(N)
   

   % compute approximate coefficient of variation within the binning time 
   if ~isfield(acs, 'a_cv')
      acs.a_cv = [acs.raw.std(:,1:n_wv)./acs.raw.mean(:,1:n_wv)];
      acs.c_cv = [acs.raw.std(:,n_wv+1:end)./acs.raw.mean(:,n_wv+1:end)];
   else  
      acs.a_cv = [acs.a_cv; acs.raw.std(:,1:n_wv)./acs.raw.mean(:,1:n_wv)];
      acs.c_cv = [acs.c_cv; acs.raw.std(:,n_wv+1:end)./acs.raw.mean(:,n_wv+1:end)];
   endif

   % Calibration-independent particle optical properties
   acs.ap = acs.atot - acs.afilt_i;
   acs.cp = acs.ctot - acs.cfilt_i;

   % propagate uncertainties
   acs.ap_u = sqrt(acs.atot_u.^2 + acs.afilt_u_i.^2);
   acs.cp_u = sqrt(acs.ctot_u.^2 + acs.cfilt_u_i.^2);
   
   % store number of points biined in each bin
   acs.N = acs.raw.N(:,1);


   iwv0 = 30;  %(540 in the raw wvlenghts)

   figure(1, 'visible', 'off')
   clf
   hold on
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0), '.', 'MarkerSize', 6, 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0)+acs.raw.prc(:,iwv0), '.', 'MarkerSize', 1, 'linewidth', 0.1)
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0)-acs.raw.prc(:,iwv0), '.', 'MarkerSize', 1, 'linewidth', 0.1)
      
      plot(acs.raw.time(tm_fl)-newT0+1, acs.raw.mean(tm_fl,iwv0), 'ro', 'linewidth', 0.5)
      plot(acs.raw.time(tm_fl)-newT0+1, acs.raw.mean(tm_fl,iwv0)+acs.raw.prc(tm_fl,iwv0), 'r.', 'linewidth', 0.1)
      plot(acs.raw.time(tm_fl)-newT0+1, acs.raw.mean(tm_fl,iwv0)-acs.raw.prc(tm_fl,iwv0), 'r.', 'linewidth', 0.1)
      
      plot(acs.raw.time-newT0+1, acs.afilt_i(:,iwv0), 'k', 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.afilt_u_i(:,iwv0), 'k', 'linewidth', 0.1)
      plot(acs.raw.time-newT0+1, acs.afilt_u_i(:,iwv0), 'k', 'linewidth', 0.1)
      
      plot(acs.raw.time-newT0+1, acs.ap(:,iwv0)+.2, 'mo', 'MarkerSize', 2, 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.ap(:,iwv0)+acs.ap_u(:,iwv0)+.2, 'm.', 'MarkerSize', 1, 'linewidth', 0.1)
      plot(acs.raw.time-newT0+1, acs.ap(:,iwv0)-acs.ap_u(:,iwv0)+.2, 'm.', 'MarkerSize', 1, 'linewidth', 0.1)
   %axis([188 189 0 .25])
   set(gca, 'ylim', acs_lim);
   title('raw a_p')
   hold off

   if acstype == 'acs'
       fnout = [fig_dir 'raw_ap_' dailyfile.name(end-6:end-4)  '.png'];
   elseif acstype == 'acs2'
       fnout = [fig_dir 'raw_ap_acs2_' dailyfile.name(end-6:end-4)  '.png'];
   endif
   print('-dpng', fnout)


   figure(2, 'visible', 'off')
   clf
   hold on
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0+n_wv), '.', 'MarkerSize', 6, 'linewidth', 0.5)
      plot(acs.raw.time(tm_fl)-newT0+1, acs.raw.mean(tm_fl,iwv0+n_wv), 'ro', 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.cfilt_i(:,iwv0), 'k', 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.cp(:,iwv0)+.2, 'mo', 'MarkerSize', 2, 'linewidth', 0.5)
   %axis([188 189 0 .25])
   set(gca, 'ylim', acs_lim);
   title('raw c_p')
   hold off    

   if acstype == 'acs'
       fnout = [fig_dir 'raw_cp_' dailyfile.name(end-6:end-4)  '.png'];
   elseif acstype == 'acs2'
       fnout = [fig_dir 'raw_cp_acs2_' dailyfile.name(end-6:end-4)  '.png'];
   endif
   print('-dpng', fnout)
   %pause

   % ---GRG---                                     %<<<====== CAREFUL HERE
   % ARBITRARILY correct for step at ~550nm
   % HP: the longer portion of the spectrum (LPS) is the correct one
   % use the first two lambdas of the LPS to linearly predict to the last value of the shorter portion
   % of the spectrum (SPS)
   %    
   % <===========================================>>> NEED TO FIX THIS LATER ON <<<===========================================
   %    
   %for beam-c the first wl of the LPS is at position 36 (565.2 nm)
   % keyboard
   %      wv1 = 36;
   %      wv2 = 37;
   %
   %     acs.step.cp.v = acs.cp(:,wv1:wv2);  %these are the values of wl that we use to predict the last point of the SPS
   %     acs.step.cp.coeff(:,1) = (acs.step.cp.v(:,2)-acs.step.cp.v(:,1))/(acs.cwl(wv2)-acs.cwl(wv1));  %slope
   %     acs.step.cp.coeff(:,2) = acs.step.cp.v(:,1)-acs.cwl(:,wv1)*acs.step.cp.coeff(:,1);           %intercept
   %     acs.step.cp.pred = acs.step.cp.coeff(:,1)*acs.cwl(wv1-1) + acs.step.cp.coeff(:,2);   %predicted last wl of SPS
   %     acs.step.cp.diff = acs.step.cp.pred-acs.cp(:,wv1-1);   %difference (predicted - observed)
   %     
   %     acs.cp_nostep = acs.cp;
   %     acs.cp_nostep(:,1:wv1-1) = acs.cp_nostep(:,1:wv1-1)+acs.step.cp.diff*ones(1,wv1-1);
   %     
   %     acs.step.ap.v = acs.ap(:,wv1:wv2);  %these are the values of wl that we use to predict the last point of the SPS
   %     acs.step.ap.coeff(:,1) = (acs.step.ap.v(:,2)-acs.step.ap.v(:,1))/(acs.awl(wv2)-acs.awl(wv1));  %slope
   %     acs.step.ap.coeff(:,2) = acs.step.ap.v(:,1)-acs.awl(:,wv1)*acs.step.ap.coeff(:,1);           %intercept
   %     acs.step.ap.pred = acs.step.ap.coeff(:,1)*acs.awl(wv1-1) + acs.step.ap.coeff(:,2);   %predicted last wl of SPS
   %     acs.step.ap.diff = acs.step.ap.pred-acs.ap(:,wv1-1);   %difference (predicted - observed)
   %     
   %     acs.ap_nostep = acs.ap;
   %     acs.ap_nostep(:,1:wv1-1) = acs.ap_nostep(:,1:wv1-1)+acs.step.ap.diff*ones(1,wv1-1);

   acs.cp_nostep = acs.cp;
   acs.cp_nostep_u = acs.cp_u;
   acs.ap_nostep = acs.ap;
   acs.ap_nostep_u = acs.ap_u;

   % ---GRG---
   % select only non-NaN points
   nn = ~isnan(acs.cp(:,1));
   
   % ---GRG---
   % interpolate awl and cwl to match the band centers of a and c
   acs.wl = [400:2:750];

   %interpolate cp
   acs.int.cp = acs.int.cp_u = nan(size(acs.cp,1), length(acs.wl));
   acs.int.cp(nn,:) = interp1(acs.cwl, acs.cp_nostep(nn,:)', acs.wl, 'extrap')';
   acs.int.cp_u(nn,:) = interp1(acs.cwl, acs.cp_nostep_u(nn,:)', acs.wl, 'extrap')';
   
   %interpolate ap
   acs.int.ap = acs.int.ap_u = nan(size(acs.ap,1), length(acs.wl));
   acs.int.ap(nn,:) = interp1(acs.awl, acs.ap_nostep(nn,:)', acs.wl, 'extrap')';    %NOTE that the first lambda od acs.awl and acs.cwl are > 400nm  => the first interpolated wv is =NaN
   acs.int.ap_u(nn,:) = interp1(acs.awl, acs.ap_nostep_u(nn,:)', acs.wl, 'extrap')';    %NOTE that the first lambda od acs.awl and acs.cwl are > 400nm  => the first interpolated wv is =NaN

   % % ----GRG------
   %correction of for residual T-dependence
   %find( abs(acs.int.ap(:,171)-acs.int.ap(:,152))>0 );
   nn = find(~isnan(acs.int.ap(:,171)));
   
   acs.Tsb_corr.ap = nan(size(acs.int.ap));
   acs.Tsb_corr.cp = nan(size(acs.int.cp));
   acs.Tsb_corr.ap_u = nan(size(acs.int.ap));
   acs.Tsb_corr.cp_u = nan(size(acs.int.cp));

   % store N of binned data points
   acs.Tsb_corr.N = acs.N;

   if idays>0
      %compute initial guess for the scattering coefficient b   (WE ASSUME no SALINITY CHANGES, FOR THE MOMENT)
      acs.int.bp = acs.int.cp - acs.int.ap;

      DTs = zeros(length(nn),1);
      s_DTs_up = zeros(length(nn),2);
      s_DTs_dw = zeros(length(nn),2);

      %   for iap=362:length(nn)  %use these spectra for example
      for iap = 1:length(nn)

         [DTs(iap,:), aTbcorr, ap_err, cp_err] = T_sal_corr_0(acs, idays, nn, iap);
         iout = [idays, iap DTs(iap)];

         acs.Tsb_corr.ap(nn(iap),:) = aTbcorr;
         acs.Tsb_corr.ap_u(nn(iap),:) = ap_err;

         if acstype == 'acs'
             save iap.txt iout -ascii
         elseif acstype == 'acs2'
             save iap_acs2.txt iout -ascii
         endif

         %compute T-corrected beam-c (i.e. subtract from cp the DELTAap due to residual temperature difference)
         acs.Tsb_corr.cp(nn(iap),:) = acs.int.cp(nn(iap),:)     -dac2dTS(:,2)'*DTs(iap,1)  ;
         acs.Tsb_corr.cp_u(nn(iap),:) = cp_err;

      endfor

      Ts = [Ts; DTs];
   else
	   
      acs.Tsb_corr.ap = acs.int.ap;
      acs.Tsb_corr.cp = nan(size(acs.int.ap));

   endif
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %-----------------------------------    

   %compute Tb-corrected scattering coefficient
   acs.Tsb_corr.bp = acs.Tsb_corr.cp - acs.Tsb_corr.ap;
   acs.Tsb_corr.bp_u = sqrt(acs.Tsb_corr.ap_u.^2 + acs.Tsb_corr.cp_u.^2);


   acs.Tsb_corr.nn = nn;
   acs.Tsb_corr.time = time;
   acs.Tsb_corr.wl = acs.wl;

   savefile = [proc_dir,'proc_',dailyfile.name];
   if (exist(savefile))
      load(savefile);
   endif

   if acstype == 'acs'
       out.acs = acs.Tsb_corr;
       out.acs.wv = acs.wl;
   elseif acstype == 'acs2'
       out.acs2 = acs.Tsb_corr;
       out.acs2.wv = acs.wl;
   endif

   save('-v6', savefile , 'out' )

   % diffe = [diffe;acs.step.ap.diff];

   acsoutap = [acsoutap;[acs.raw.time-newT0 acs.Tsb_corr.ap]];
   acsoutcp = [acsoutcp;[acs.raw.time-newT0 acs.Tsb_corr.cp]];

   if ~isempty(acsoutap)
        acsout.time = acsoutap(:,1);
        acsout.ap = acsoutap(:,2:end);
        acsout.cp = acsoutcp(:,2:end);
   endif

   toc
end





