function acsout = step2a_acs_amt_make_processed(acs, dailyfile, idays, acs_lim, FORCE, acstype)

   % tjor: the ACS function laods acs data and processes using calibration independent technique (filter/NOfilter)
   % and a NIR-base correction for residual temperature dependence using subfunction T_sal_corr_0.m. Uncertainty proagation is
   % currently done assuming that each source of uncertainty is independent.

   % Processed outputs (saved in Step 2 matfile) are:

   % ap: particulate absorption
   % cp: particulate beam-attenuation
   % bp: particulate backscattering
   % ap_u: particulate absorption uncertainty
   % cp_u: particulate beam-attenuation uncertainty
   % bp_u: particulate backscattering uncertainty
   % N: number of data points in each hourly bin (typically 240 for AMT 28)
   % nn: number of data points that are not a NaN
   % time: 
   % wv or wl: wavelengths (posisble redudancy?)


   global dac2dTS
   global Yt Ysa
   global a b refNIR NIR 
   global fval
   global errO

   % Global variables from step2
   global FN_ROOT_STEP2 
   global DIR_FIGS 
   global YYYY

   close all

   tic


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
   fnTS = 'acs_TSdep.txt'; # Temperature-dependence coefficients
   dac2dTS = load([fnTS]);

   Ts = [];
   Ts_u = [];
   Ts_d = [];
   diffe = [];%this is the matrix where we store the step-difference in cp
   acdom = [];



   % this is to skip ACs processng or when there are no ACs data
   if (FORCE != 1 & (~exist('acs')) |  all(isnan(acs.raw.med(:,1))))
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

   i_fl = (ismember(tmp_time_min, [2:9]) & tmp_sched) ;  % assign index to filtered times                                      %<<<====== CHANGE HERE
   i_uf = (ismember(tmp_time_min, [11:58]) & tmp_sched);  % assign index to unfiltered times                                   %<<<====== CHANGE HERE

   i_fl_med = (ismember(tmp_time_min, [5]) & tmp_sched) ;  % assign index to filtered times to be used for correction            %<<<====== CHANGE HERE

   
   

   %take median value of the xTF filtered times without using any loop   
   xTF = 8;  % how many 0.2um filtered points we have
   n_wv = length(acs.awl);

   tmp_fi_a = acs.raw.med(i_fl,1:n_wv)'; # this is for the absorption
   tmp_fi_a = reshape(tmp_fi_a,n_wv,xTF,size(acs.raw.med(i_fl,1:n_wv),1)/xTF);
   med_fi_a = median(tmp_fi_a,2);
   med_fi_a = reshape(med_fi_a, n_wv,size(acs.raw.med(i_fl,1:n_wv),1)/xTF)'; # hourly absorption medians of the first 10 minutes of every hour

   tmp_fi_c = acs.raw.med(i_fl,n_wv+1:end)'; # and this is for the attenuation
   tmp_fi_c = reshape(tmp_fi_c,n_wv,xTF,size(acs.raw.med(i_fl,n_wv+1:end),1)/xTF);
   med_fi_c = median(tmp_fi_c,2);
   med_fi_c = reshape(med_fi_c, n_wv,size(acs.raw.med(i_fl,n_wv+1:end),1)/xTF)';


   % take median also of the within-bin variability of a and c
   tmp_fi_a_u = acs.raw.prc(i_fl, 1:n_wv)';
   tmp_fi_a_u = reshape(tmp_fi_a_u, n_wv, xTF, size(acs.raw.prc(i_fl,1:n_wv),1)/xTF);
   med_fi_a_u = median(tmp_fi_a_u, 2);
   med_fi_a_u = reshape(med_fi_a_u, n_wv, size(acs.raw.prc(i_fl,1:n_wv),1)/xTF)'; # hourly absorption robust-std medians of the fist 10 minutes of every hour

   tmp_fi_c_u = acs.raw.prc(i_fl, n_wv+1:end)';
   tmp_fi_c_u = reshape(tmp_fi_c_u, n_wv, xTF, size(acs.raw.prc(i_fl,n_wv+1:end),1)/xTF);
   med_fi_c_u = median(tmp_fi_c_u, 2);
   med_fi_c_u = reshape(med_fi_c_u, n_wv,size(acs.raw.prc(i_fl,n_wv+1:end),1)/xTF)';


   %store filtered data (DO NOT CONFUSE with read ay measurements: these are just the filtered signals)
   acs.cdom.a = med_fi_a;
   acs.cdom.time = time(i_fl_med);

   % Linear interpolation over the course of the day between filtered measurements and their uncertainties
   acs.afilt_i = interp1(time(i_fl_med), med_fi_a, time, 'extrap'); # extrap is just to fill in the last hour of the day
   acs.cfilt_i = interp1(time(i_fl_med), med_fi_c, time, 'extrap');
  
   acs.afilt_u_i = interp1(time(i_fl_med), med_fi_a_u, time, 'extrap');
   acs.cfilt_u_i = interp1(time(i_fl_med), med_fi_c_u, time, 'extrap');
   
   % Define and fill [a,c]tot variables and their uncertainties
   acs.atot = nan(size(acs.raw.med(:,1:n_wv))); # these are the total absorption coeffiients (i.e.,  not the particulate absorption coeeffs)
   acs.ctot = nan(size(acs.raw.med(:,n_wv+1:end)));
   acs.atot(i_uf,:) = acs.raw.med(i_uf,1:n_wv);
   acs.ctot(i_uf,:) = acs.raw.med(i_uf,n_wv+1:end);
   
   acs.atot_u = nan(size(acs.raw.prc(:,1:n_wv)));
   acs.ctot_u = nan(size(acs.raw.prc(:,n_wv+1:end)));
   acs.atot_u(i_uf,:) = acs.raw.prc(i_uf,1:n_wv) ./ sqrt(acs.raw.N(i_uf,1:n_wv)) ; % note that I am dividing the uncertainty by sqrt(N)
   acs.ctot_u(i_uf,:) = acs.raw.prc(i_uf,n_wv+1:end) ./ sqrt(acs.raw.N(i_uf,n_wv+1:end)); % note that I am dividing the uncertainty by sqrt(N)
   

   % compute approximate coefficient of variation within the binning time 
   if ~isfield(acs, 'a_cv')
      acs.a_cv = [acs.raw.std(:,1:n_wv)./acs.raw.mean(:,1:n_wv)];
      acs.c_cv = [acs.raw.std(:,n_wv+1:end)./acs.raw.mean(:,n_wv+1:end)];
   else  
      acs.a_cv = [acs.a_cv; acs.raw.std(:,1:n_wv)./acs.raw.mean(:,1:n_wv)];
      acs.c_cv = [acs.c_cv; acs.raw.std(:,n_wv+1:end)./acs.raw.mean(:,n_wv+1:end)];
   endif

   % Calibration-independent particle optical properties
   acs.ap = acs.atot - acs.afilt_i; # this is what is plotted in Fig 3a of Slade et al., 2010 (ap is particulate absorption)
   acs.cp = acs.ctot - acs.cfilt_i;

   % propagate uncertainties
   acs.ap_u = sqrt(acs.atot_u.^2 + acs.afilt_u_i.^2);
   acs.cp_u = sqrt(acs.ctot_u.^2 + acs.cfilt_u_i.^2);
   
   % store number of points binned in each bin
   acs.N = acs.raw.N(:,1);


   iwv0 = 30;  %(~540nm in the raw wavlenghts)

   figure(1, 'visible', 'off')
   clf
   hold on
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0), '.', 'MarkerSize', 6, 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0)+acs.raw.prc(:,iwv0), '.', 'MarkerSize', 1, 'linewidth', 0.1)
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0)-acs.raw.prc(:,iwv0), '.', 'MarkerSize', 1, 'linewidth', 0.1)
      
      plot(acs.raw.time(i_fl)-newT0+1, acs.raw.mean(i_fl,iwv0), 'ro', 'linewidth', 0.5)
      plot(acs.raw.time(i_fl)-newT0+1, acs.raw.mean(i_fl,iwv0)+acs.raw.prc(i_fl,iwv0), 'r.', 'linewidth', 0.1)
      plot(acs.raw.time(i_fl)-newT0+1, acs.raw.mean(i_fl,iwv0)-acs.raw.prc(i_fl,iwv0), 'r.', 'linewidth', 0.1)
      
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
       fnout = [DIR_FIGS 'raw_ap_' dailyfile.name(end-6:end-4)  '.png'];
   elseif acstype == 'acs2'
       fnout = [DIR_FIGS 'raw_ap_acs2_' dailyfile.name(end-6:end-4)  '.png'];
   endif
   print('-dpng', fnout)


   figure(2, 'visible', 'off')
   clf
   hold on
      plot(acs.raw.time-newT0+1, acs.raw.mean(:,iwv0+n_wv), '.', 'MarkerSize', 6, 'linewidth', 0.5)
      plot(acs.raw.time(i_fl)-newT0+1, acs.raw.mean(i_fl,iwv0+n_wv), 'ro', 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.cfilt_i(:,iwv0), 'k', 'linewidth', 0.5)
      plot(acs.raw.time-newT0+1, acs.cp(:,iwv0)+.2, 'mo', 'MarkerSize', 2, 'linewidth', 0.5)
   %axis([188 189 0 .25])
   set(gca, 'ylim', acs_lim);
   title('raw c_p')
   hold off    

   if acstype == 'acs'
       fnout = [DIR_FIGS 'raw_cp_' dailyfile.name(end-6:end-4)  '.png'];
   elseif acstype == 'acs2'
       fnout = [DIR_FIGS 'raw_cp_acs2_' dailyfile.name(end-6:end-4)  '.png'];
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

   acs.cp_nostep = acs.cp; # previously there was an extra step to correct for spectral discontinuity (see commented part above), this is if due to the linear filter of the ACs which is divided into two parts (see ACs manual or documentation)
   acs.cp_nostep_u = acs.cp_u;
   acs.ap_nostep = acs.ap;
   acs.ap_nostep_u = acs.ap_u;

   % ---GRG---
   % select only non-NaN points
   i_nn = ~isnan(acs.cp(:,1));
   
   % ---GRG---
   % interpolate awl and cwl to match the band centers of a and c onto a common wavelength array (acs.wl)
   acs.wl = [400:2:750];

   %interpolate cp
   acs.int.cp = acs.int.cp_u = nan(size(acs.cp,1), length(acs.wl));
   acs.int.cp(i_nn,:) = interp1(acs.cwl, acs.cp_nostep(i_nn,:)', acs.wl, 'extrap')';
   acs.int.cp_u(i_nn,:) = interp1(acs.cwl, acs.cp_nostep_u(i_nn,:)', acs.wl, 'extrap')';
   
   %interpolate ap
   acs.int.ap = acs.int.ap_u = nan(size(acs.ap,1), length(acs.wl));
   acs.int.ap(i_nn,:) = interp1(acs.awl, acs.ap_nostep(i_nn,:)', acs.wl, 'extrap')';    %NOTE that the first lambda od acs.awl and acs.cwl are > 400nm  => the first interpolated wv is =NaN
   acs.int.ap_u(i_nn,:) = interp1(acs.awl, acs.ap_nostep_u(i_nn,:)', acs.wl, 'extrap')';    %NOTE that the first lambda od acs.awl and acs.cwl are > 400nm  => the first interpolated wv is =NaN

   % % ----GRG------
   %correction of for residual T-dependence (this is the correction described in the Slade et al 2010 paper)
   %find( abs(acs.int.ap(:,171)-acs.int.ap(:,152))>0 );
   i_nn = find(~isnan(acs.int.ap(:,1))); # "1" is arbitrary and "nn" is just used to initialize arrays below 
   
   acs.Tsb_corr.ap = nan(size(acs.int.ap)); # in "Tsb", "T" is for temperature, "s" for salinity and "b" is for scattering
   acs.Tsb_corr.cp = nan(size(acs.int.cp));
   acs.Tsb_corr.ap_u = nan(size(acs.int.ap));
   acs.Tsb_corr.cp_u = nan(size(acs.int.cp));

   % store N of binned data points
   acs.Tsb_corr.N = acs.N;

   if idays>0
      %compute initial guess for the scattering coefficient b   (WE ASSUME no SALINITY CHANGES, FOR THE MOMENT)
      acs.int.bp = acs.int.cp - acs.int.ap; # eq 2 in Slade et al., 2010

      DTs = zeros(length(i_nn),1);
      s_DTs_up = zeros(length(i_nn),2);
      s_DTs_dw = zeros(length(i_nn),2);

      %   for iap=362:length(nn)  %use these spectra for example
      for iap = 1:length(i_nn) 

         [DTs(iap,:), aTbcorr, ap_err, cp_err] = T_sal_corr_0(acs, idays, i_nn, iap);
         iout = [idays, iap DTs(iap)];

         acs.Tsb_corr.ap(i_nn(iap),:) = aTbcorr;
         acs.Tsb_corr.ap_u(i_nn(iap),:) = ap_err;

         if acstype == 'acs'
             save iap.txt iout -ascii
         elseif acstype == 'acs2'
             save iap_acs2.txt iout -ascii
         endif

         %compute T-corrected beam-c (i.e. subtract from cp the DELTAap due to residual temperature difference)
         acs.Tsb_corr.cp(i_nn(iap),:) = acs.int.cp(i_nn(iap),:)     -dac2dTS(:,2)'*DTs(iap,1)  ; # first non-numbered equation on pg 1739 of Slade et al., 2010
         acs.Tsb_corr.cp_u(i_nn(iap),:) = cp_err;

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


   acs.Tsb_corr.nn = i_nn;
   acs.Tsb_corr.time = time;
   acs.Tsb_corr.wl = acs.wl;
datevec(time(1))
   savefile = [FN_ROOT_STEP2 strsplit(dailyfile.name, "_"){end}];

   if exist(savefile, 'file')
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

end





