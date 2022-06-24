function step2a_ac9_amt_make_processed(ac9, dailyfile, ac9_lim, FORCE, flow)

   % tjor: function loads ac9 data and processes them using calibration-independent technique (filter/NOfilter).
   % The code follows ACs processing but without the NIR temperature correction from Sade et al. 2010 (instead a measurement eq,
   % of the form  ap_corrected = ap - ap_NIR/bp_NIR*bp is used) within the subfunction scatt_corr_3.m.
   % Uncertainty propagation was implemented in June 2022, following approacg for ACS (uncorreleted sources of uncertainty). This is
   % also done within scatt_corr_3.m.
  
   % Processed outputs (Stored in Step 2 matfile)

   % cp: particulate beam-attenuation
   % bp: particulate backscattering
   % ap_u: particulate absorption uncertainty
   % cp_u: particulate beam-attenuation uncertainty
   % bp_u: particulate backscattering uncertainty
   % N: number of data points in each hourly bin (typically 240 for AMT 28)
   % nn: number of data points that are not a NaN
   % time: 
   % wv : wavelengths



   % Global variables from step2
   global FN_ROOT_STEP2 
   global DIR_STEP2
   global DIR_FIGS
   global YYYY
   
    close all

    tic


    ac9outap = [];
    ac9outcp = [];
    ac9outtime = [];

    newT0 = y0(YYYY);  %reference time for plotting

    wave = [412 440 488 510 532 554 650 676 715]; % 9 channels of AC9




    % this is to skip AC9 processng or when there are no AC9 data
    if (FORCE != 1 & (~exist('ac9')) |  all(isnan(ac9.raw.med(:,1))))
        return % older versions of ocytave
    endif
      

    %ac9.raw
    time = ac9.raw.time - newT0;

    
    % Determine times for filtered and unfiltered measurements to be used in
    % calculating calibration independent particle properties
    % Select only times that we have data logged for
    tmp_time = datevec(time);
    tmp_sched = time;
    tmp_time_min = round(tmp_time(:,5)+tmp_time(:,6)/60);

    i_fl = (ismember(tmp_time_min, [2:9]) & tmp_sched) ;  %filtered times                                      %<<<====== CHANGE HERE
    i_uf = (ismember(tmp_time_min, [11:58]) & tmp_sched);  %unfiltered times                                   %<<<====== CHANGE HERE

    i_fl_med=(ismember(tmp_time_min, [5]) & tmp_sched) ;  %filtered times to be used for correction            %<<<====== CHANGE HERE

    

    %take median value of the xTF filtered times without using any loop
    xTF = 8;  % how many 0.2um filtered points we have
    n_wv = length(wave);

    tmp_fi_a = ac9.raw.med(i_fl,1:n_wv)';
    tmp_fi_a = reshape(tmp_fi_a,n_wv,xTF,size(ac9.raw.med(i_fl,1:n_wv),1)/xTF);
    med_fi_a = median(tmp_fi_a,2);
    med_fi_a = reshape(med_fi_a, n_wv,size(ac9.raw.med(i_fl,1:n_wv),1)/xTF)';

    tmp_fi_c = ac9.raw.med(i_fl,n_wv+1:end)';
    tmp_fi_c = reshape(tmp_fi_c,n_wv,xTF,size(ac9.raw.med(i_fl,n_wv+1:end),1)/xTF);
    med_fi_c = median(tmp_fi_c,2);
    med_fi_c = reshape(med_fi_c, n_wv,size(ac9.raw.med(i_fl,n_wv+1:end),1)/xTF)';

    % take median also of the within-bin variability of a and c
    tmp_fi_a_u = ac9.raw.prc(i_fl, 1:n_wv)';
    tmp_fi_a_u = reshape(tmp_fi_a_u, n_wv, xTF, size(ac9.raw.prc(i_fl,1:n_wv),1)/xTF);
    med_fi_a_u = median(tmp_fi_a_u, 2);
    med_fi_a_u = reshape(med_fi_a_u, n_wv, size(ac9.raw.prc(i_fl,1:n_wv),1)/xTF)'; # hourly absorption robust-std medians of the fist 10 minutes of every hour

    tmp_fi_c_u = ac9.raw.prc(i_fl, n_wv+1:end)';
    tmp_fi_c_u = reshape(tmp_fi_c_u, n_wv, xTF, size(ac9.raw.prc(i_fl,n_wv+1:end),1)/xTF);
    med_fi_c_u = median(tmp_fi_c_u, 2);
    med_fi_c_u = reshape(med_fi_c_u, n_wv,size(ac9.raw.prc(i_fl,n_wv+1:end),1)/xTF)';

    
    % Linear interpolation between filtered measurements
    ac9.afilt_i = interp1(time(i_fl_med), med_fi_a, time, 'extrap');
    ac9.cfilt_i = interp1(time(i_fl_med), med_fi_c, time, 'extrap');
   
    ac9.afilt_u_i = interp1(time(i_fl_med), med_fi_a_u, time, 'extrap');
    ac9.cfilt_u_i = interp1(time(i_fl_med), med_fi_c_u, time, 'extrap');

    
    %store filtered data
    ac9.cdom.a = med_fi_a;
    ac9.cdom.time = time(i_fl_med);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMMENTED 2019 10 21 FN
    % This is specific to AMT28 
    % if strcmp(dailyfile.name, 'optics_amt28_295.mat')
    % 
    %     [var_filt i_fl i_uf] = filt_time_exception_295(ac9.raw, flow_v);
    %     
    %     ac9.afilt_i = var_filt(:,1:n_wv);
    %     ac9.cfilt_i = var_filt(:,n_wv+1:end);
    % 
    %     ac9.cdom.a = [];
    %     ac9.cdom.time = [];
    % 
    % endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    %% Remove filtered data from measurements and estimated their uncertainties
    ac9.atot = nan(size(ac9.raw.med(:,1:n_wv)));
    ac9.ctot = nan(size(ac9.raw.med(:,n_wv+1:end)));
    ac9.atot(i_uf,:) = ac9.raw.med(i_uf,1:n_wv);
    ac9.ctot(i_uf,:) = ac9.raw.med(i_uf,n_wv+1:end);
   
    ac9.atot_u = nan(size(ac9.raw.prc(:,1:n_wv)));
    ac9.ctot_u = nan(size(ac9.raw.prc(:,n_wv+1:end)));
    ac9.atot_u(i_uf,:) = ac9.raw.prc(i_uf,1:n_wv) ./ sqrt(ac9.raw.N(i_uf,1:n_wv)) ; % note that I am dividing the uncertainty by sqrt(N)
    ac9.ctot_u(i_uf,:) = ac9.raw.prc(i_uf,n_wv+1:end) ./ sqrt(ac9.raw.N(i_uf,n_wv+1:end)); % note that I am dividing the uncertainty by sqrt(N)

  
    
   % compute approximate coefficient of variation within the bii_nning time 
   if ~isfield(ac9, 'a_cv')
      ac9.a_cv = [ac9.raw.std(:,1:n_wv)./ac9.raw.mean(:,1:n_wv)];
      ac9.c_cv = [ac9.raw.std(:,n_wv+1:end)./ac9.raw.mean(:,n_wv+1:end)];
   else  
      ac9.a_cv = [ac9.a_cv; ac9.raw.std(:,1:n_wv)./ac9.raw.mean(:,1:n_wv)];
      ac9.c_cv = [ac9.c_cv; ac9.raw.std(:,n_wv+1:end)./ac9.raw.mean(:,n_wv+1:end)];
   endif


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Calibration-independent particle optical properties
   ac9.ap = ac9.atot - ac9.afilt_i;
   ac9.cp = ac9.ctot - ac9.cfilt_i;

   % propagate uncertainties
   ac9.ap_u = sqrt(ac9.atot_u.^2 + ac9.afilt_u_i.^2);
   ac9.cp_u = sqrt(ac9.ctot_u.^2 + ac9.cfilt_u_i.^2);
   
   % store number of points binned in each bin
   ac9.N = ac9.raw.N(:,1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %-----  scattering correction  ------
    %--- method #3
    [ac9.corr.ap, ac9.corr.bp, ac9err] = scatt_corr_3(ac9); # this is the measurement equation for ap (error propagation still to do)

    ac9.corr.ap_u = ac9err.ap_u;
    ac9.corr.bp_u = ac9err.bp_u;
    ac9.corr.cp_u = ac9err.cp_u;


    ac9.corr.cp = ac9.cp;  %just to have all the data in the same sub-structure (this is the measurement equation for cp)
    
    
    iwv0 = 3;
    figure(1, 'visible', 'off')
    clf
    hold on
    plot(ac9.raw.time-newT0+1, ac9.raw.mean(:,iwv0), '.', 'MarkerSize', 6, 'linewidth', 0.5)
    plot(ac9.raw.time(i_fl)-newT0+1, ac9.raw.mean(i_fl,iwv0), 'ro', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.afilt_i(:,iwv0), 'k', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.ap(:,iwv0)+.2, 'mo', 'MarkerSize', 2, 'linewidth', 0.5)
    %axis([188 189 0 .25])
    set(gca, 'ylim', ac9_lim);
    title('raw a_p')
    hold off
    fnout = [DIR_FIGS 'raw_ap_ac9_' dailyfile.name(end-6:end-4)  '.png'];
    print('-dpng', fnout)

    figure(2, 'visible', 'off')
    clf
    hold on
    plot(ac9.raw.time-newT0+1, ac9.raw.mean(:,iwv0+n_wv), '.', 'MarkerSize', 6, 'linewidth', 0.5)
    plot(ac9.raw.time(i_fl)-newT0+1, ac9.raw.mean(i_fl,iwv0+n_wv), 'ro', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.cfilt_i(:,iwv0), 'k', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.cp(:,iwv0)+.2, 'mo', 'MarkerSize', 2, 'linewidth', 0.5)
    %axis([188 189 0 .25])
    set(gca, 'ylim', ac9_lim);
    title('raw c_p')
    hold off    
    fnout = [DIR_FIGS 'raw_cp_ac9_' dailyfile.name(end-6:end-4)  '.png'];
    print('-dpng', fnout)


    
    savefile = [FN_ROOT_STEP2 strsplit(dailyfile.name, "_"){end}];
    if exist(savefile, 'file')
       load(savefile)
    endif    
      
    out.ac9 = ac9.corr;
    out.ac9.N = ac9.N;
    out.ac9.wv = wave;
    out.ac9.filt02_a = ac9.afilt_i;
    out.ac9.filt02_c = ac9.cfilt_i;
    out.ac9.time = time;
datevec(out.ac9.time(1))
    
    save('-v6', savefile , 'out' )
    
    
    
    ac9outap = [ac9outap; [time, ac9.corr.ap]];
    ac9outcp = [ac9outcp; [time, ac9.corr.cp]];
    


endfunction










