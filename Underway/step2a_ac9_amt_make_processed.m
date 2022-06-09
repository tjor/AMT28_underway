%load ac9 data and process them using calibration independent technique (filter/NOfilter)
% and a NIR-base correction for residual temperature dependence

function step2a_ac9_amt_make_processed(WAPvars.ac9, dailyfile, ac9_lim, force, flow)

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


    ac9outap = [];
    ac9outcp = [];
    ac9outtime = [];

    newT0 = y0(YYYY);  %reference time for plotting

    wave = [412 440 488 510 532 554 650 676 715];




    % this is to skip AC9 processng or when there are no AC9 data
    if (force!=1 & (~exist('ac9')) |  all(isnan(ac9.raw.med(:,1))))
        continue
    endif
      

    %ac9.raw
    time = ac9.raw.time-newT0;

    
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
    n_wv = length(wave);

    tmp_fi_a = ac9.raw.med(tm_fl,1:n_wv)';
    tmp_fi_a = reshape(tmp_fi_a,n_wv,xTF,size(ac9.raw.med(tm_fl,1:n_wv),1)/xTF);
    med_fi_a = median(tmp_fi_a,2);
    med_fi_a = reshape(med_fi_a, n_wv,size(ac9.raw.med(tm_fl,1:n_wv),1)/xTF)';

    tmp_fi_c = ac9.raw.med(tm_fl,n_wv+1:end)';
    tmp_fi_c = reshape(tmp_fi_c,n_wv,xTF,size(ac9.raw.med(tm_fl,n_wv+1:end),1)/xTF);
    med_fi_c = median(tmp_fi_c,2);
    med_fi_c = reshape(med_fi_c, n_wv,size(ac9.raw.med(tm_fl,n_wv+1:end),1)/xTF)';

    
    % Linear interpolation between filtered measurements
    ac9.afilt_i = interp1(time(tm_fl_med), med_fi_a, time, 'extrap');
    ac9.cfilt_i = interp1(time(tm_fl_med), med_fi_c, time, 'extrap');

    
    %store filtered data
    ac9.cdom.a = med_fi_a;
    ac9.cdom.time = time(tm_fl_med);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMMENTED 2019 10 21 FN
    % This is specific to AMT28 
    % if strcmp(dailyfile.name, 'optics_amt28_295.mat')
    % 
    %     [var_filt tm_fl tm_uf] = filt_time_exception_295(ac9.raw, flow_v);
    %     
    %     ac9.afilt_i = var_filt(:,1:n_wv);
    %     ac9.cfilt_i = var_filt(:,n_wv+1:end);
    % 
    %     ac9.cdom.a = [];
    %     ac9.cdom.time = [];
    % 
    % endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    %% Remove filtered data from measurements
    ac9.atot = nan(size(ac9.raw.med(:,1:n_wv)));
    ac9.ctot = nan(size(ac9.raw.med(:,n_wv+1:end)));
    ac9.atot(tm_uf,:) = ac9.raw.med(tm_uf,1:n_wv);
    ac9.ctot(tm_uf,:) = ac9.raw.med(tm_uf,n_wv+1:end);

  
    
   % compute approximate coefficient of variation within the binning time 
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % select only non-NaN points
    nn = ~isnan(ac9.cp(:,1));

    %-----  scattering correction  ------
    %--- method #3
    [ac9.corr.ap, ac9.corr.bp] = scatt_corr_3(ac9.cp, ac9.ap);

    ac9.corr.cp = ac9.cp;  %just to have all the data in the same sub-structure
    
    
    iwv0 = 3;
    figure(1, 'visible', 'off')
    clf
    hold on
    plot(ac9.raw.time-newT0+1, ac9.raw.mean(:,iwv0), '.', 'MarkerSize', 6, 'linewidth', 0.5)
    plot(ac9.raw.time(tm_fl)-newT0+1, ac9.raw.mean(tm_fl,iwv0), 'ro', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.afilt_i(:,iwv0), 'k', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.ap(:,iwv0)+.2, 'mo', 'MarkerSize', 2, 'linewidth', 0.5)
    %axis([188 189 0 .25])
    set(gca, 'ylim', ac9_lim);
    title('raw a_p')
    hold off
    fnout = [fig_dir 'raw_ap_ac9_' dailyfile.name(end-6:end-4)  '.png'];
    print('-dpng', fnout)

    figure(2, 'visible', 'off')
    clf
    hold on
    plot(ac9.raw.time-newT0+1, ac9.raw.mean(:,iwv0+n_wv), '.', 'MarkerSize', 6, 'linewidth', 0.5)
    plot(ac9.raw.time(tm_fl)-newT0+1, ac9.raw.mean(tm_fl,iwv0+n_wv), 'ro', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.cfilt_i(:,iwv0), 'k', 'linewidth', 0.5)
    plot(ac9.raw.time-newT0+1, ac9.cp(:,iwv0)+.2, 'mo', 'MarkerSize', 2, 'linewidth', 0.5)
    %axis([188 189 0 .25])
    set(gca, 'ylim', ac9_lim);
    title('raw c_p')
    hold off    
    fnout = [fig_dir 'raw_cp_ac9_' dailyfile.name(end-6:end-4)  '.png'];
    print('-dpng', fnout)


    
    savefile = [proc_dir,'proc_',dailyfile.name];
    if (exist(savefile))
       load(savefile)
    endif    
      
    out.ac9 = ac9.corr;
    out.ac9.wv = wave;
    out.ac9.filt02_a = ac9.afilt_i;
    out.ac9.filt02_c = ac9.cfilt_i;
    out.ac9.time = time;

    
    save('-v6', savefile , 'out' )
    
    
    
    ac9outap = [ac9outap; [time, ac9.corr.ap]];
    ac9outcp = [ac9outcp; [time, ac9.corr.cp]];
    


endfunction










