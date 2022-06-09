clear all
close all
pkg load parallel
pkg load signal
pkg load statistics # required for trimmean
pkg load financial # required for dateaxis

graphics_toolkit("gnuplot");

#addpath ../uway/


# these are for calculations that are repeated numerous times, so it is better to run them once only
    global theta 
    global theta_rad
    global cos_rad2
    global sin_theta
    global berrMQ_a
    global berrMQ_c
    


 

# load common parameters
common_processing_parameters;
        



# load([DOUT "Output_files/amt26_da2dTS_wap.oct"]);
load([DOUT "acy_simple_wap.oct"]);



fn = glob([DINPROC "*mat"]);
fnp = glob([DINPROC "../Step1/*mat"]);

i440 = find(wv==440);
i730 = find(wv==730);




#initialize variables
    tmp.acs.a = [];
    tmp.acs.ap = [];
    tmp.acs.c = [];
    tmp.acs.wv = [400:2:750]';
    tmp.acs.T = [];

    tmp.time = [];
    tmp.lat = [];
    tmp.lon = [];
    tmp.sst = [];
    tmp.sal = [];


### read and store all raw data
disp("reading data...");
fflush(stdout);

    for ifn = 1:length(fn)

        load(fn{ifn})
        load(fnp{ifn})
		
		acs = WAPvars.acs;


        n_wv = length(acs.awl);

        cdom.fn = fn{ifn};
        tmp.time = [tmp.time; acs.raw.time];
        tmp.lat = [tmp.lat; out.uway.lat];
        tmp.lon = [tmp.lon; out.uway.long];
        tmp.sst = [tmp.sst; out.uway.sst];
        tmp.sal = [tmp.sal; out.uway.sal];
        tmp.acs.a = [tmp.acs.a; interp1(acs.awl, acs.raw.mean(:,1:n_wv)',     tmp.acs.wv, 'extrap')' ];
        tmp.acs.c = [tmp.acs.c; interp1(acs.cwl, acs.raw.mean(:,n_wv+1:end)', tmp.acs.wv, 'extrap')' ];

        try
            tmp.acs.T = [tmp.acs.T; acs.anc.mean(:,[1,4])];
        catch
            tmp.acs.T = [tmp.acs.T; nan(size(acs.raw.time,1),2)];
        end_try_catch


        ### now read cp and ap 
            fnproc = glob([DINPROC "*" strsplit(fn{ifn}, {"_","."}){end-1} "*.mat"]);
            load(fnproc{1})

            tmp.acs.ap = [tmp.acs.ap; out.acs.ap];

    endfor
disp("...done");
fflush(stdout);


### Extract filtered data
disp("Extracting filtered data...");
fflush(stdout);

        tmp_time = datevec(tmp.time);
        tmp_sched = tmp.time;
        tmp_time_min = round(tmp_time(:,5)+tmp_time(:,6)/60);
        
        tm_fl = (ismember(tmp_time_min, [2:9]) & tmp_sched) ;  %filtered times                                     
        tm_uf = (ismember(tmp_time_min, [11:58]) & tmp_sched);  %unfiltered times                                   
    
        tm_fl_med = (ismember(tmp_time_min, [5]) & tmp_sched) ;  %filtered times to be used for correction           
disp("...done");
fflush(stdout);

    
### take mean value of the xTF filtered times without using any loop   
disp("taking their median...");
fflush(stdout);
        xTF = 8;  % how many 0.2um filtered points we have
        n_wv = length(tmp.acs.wv);
    
        tmp_fi_a = tmp.acs.a(tm_fl,:)';
        tmp_fi_a = reshape(tmp_fi_a, n_wv, xTF, size(tmp.acs.a(tm_fl,:),1)/xTF);
        med_fi_a = mean(tmp_fi_a,2);
        med_fi_a = reshape(med_fi_a, n_wv, size(tmp.acs.a(tm_fl,:),1)/xTF)';
    
        tmp_fi_c = tmp.acs.c(tm_fl,:)';
        tmp_fi_c = reshape(tmp_fi_c, n_wv, xTF, size(tmp.acs.c(tm_fl,:),1)/xTF);
        med_fi_c = mean(tmp_fi_c,2);
        med_fi_c = reshape(med_fi_c, n_wv, size(tmp.acs.c(tm_fl,:),1)/xTF)';
disp("...done");
fflush(stdout);

    
### store 0.2-um filtered data
        cdom.hr.O2.a = med_fi_a;
        cdom.hr.O2.c = med_fi_c;
        cdom.hr.time = tmp.time(tm_fl_med);
        cdom.hr.lat = tmp.lat(tm_fl_med);
        cdom.hr.lon = tmp.lon(tm_fl_med);
        cdom.hr.sst = tmp.sst(tm_fl_med);
        cdom.hr.sal = tmp.sal(tm_fl_med);

    


    # rough filtering of data

        ineg = find(tmp.acs.ap(:,20)<0);

        tmp.acs.ap(ineg,:) = nan;
        tmp.acs.cp(ineg,:) = nan;
       

    # compute chlorophyll
      disp("computing chl...");
      fflush(stdout);
      
        tmp.acs.chl = chlacs(tmp.acs);
        nnan = find(~isnan(tmp.acs.chl));
      
      disp("debiasing ACS_chl...")
      fflush(stdout);
      
        tmp.acs.chl = tmp.acs.chl*DEBIASING_FACTOR_4_ACSCHL;      


      disp("...done");
      fflush(stdout);
       
        # more filtering  
      disp("filtering...");
      fflush(stdout);
            tmp.acs.chl(nnan) = medfilt1(tmp.acs.chl(nnan), 171);
            tmp.acs.ap(nnan,:) = medfilt1(tmp.acs.ap(nnan,:), 171);
      disp("...done");
      fflush(stdout);

        # and interpolation to fill gaps
      disp("filling gaps...");
      fflush(stdout);
            tmp.acs.chl = interp1(tmp.time(nnan), tmp.acs.chl(nnan), tmp.time);
            tmp.acs.ap = interp1(tmp.time(nnan), tmp.acs.ap(nnan,:), tmp.time);
      disp("...done");
      fflush(stdout);

    ## now interpolate daily ap and chl to cdom.hr.O2.time
      disp("interpolating ap to ay...");
      fflush(stdout);
            cdom.hr.chl = interp1(tmp.time, tmp.acs.chl, cdom.hr.time  );
            cdom.hr.ap = interp1(tmp.time, tmp.acs.ap, cdom.hr.time  );
      disp("...done");
      fflush(stdout);



#######
### Now I need T-normalised MilliQ spectra for every hour
#
## so I interpolate daily nMQ to cdom.hr.O2.time
      disp("extracting T-normalised spectra for every hour...");
      fflush(stdout);

	  innan_a = find(~isnan(acy.MQ.norm.a(:,10)));
	  innan_c = find(~isnan(acy.MQ.norm.c(:,10)));
        cdom.hr.MQ.a = interp1(acy.time(innan_a), acy.MQ.norm.a(innan_a,:), cdom.hr.time  );
        cdom.hr.MQ.c = interp1(acy.time(innan_c), acy.MQ.norm.c(innan_c,:), cdom.hr.time  );
        
      disp("...done");
      fflush(stdout);
 
 
 
 


 
	
  ### Compute 0.2um-MQ hourly spectra
      cdom.hr.ay_raw = cdom.hr.O2.a - cdom.hr.MQ.a;
      cdom.hr.cy_raw = cdom.hr.O2.c - cdom.hr.MQ.c;
      if NORMto650
          cdom.hr.ay_raw = cdom.hr.ay_raw - cdom.hr.ay_raw(:,i650);
		  cdom.hr.cy_raw = cdom.hr.cy_raw - cdom.hr.cy_raw(:,i650);
      endif
  

  ####### remove hourly data before and after the first and last MQ measurements, respectively
  	i2rm = find(cdom.hr.time<acy.time(1) | cdom.hr.time>acy.time(end));

  	flds = fieldnames(cdom.hr);
  	for ifl = 1:length(flds)
  		if strcmp(flds{ifl}, "O2") | strcmp(flds{ifl}, "MQ")
  			cdom.hr.(flds{ifl}).a(i2rm,:) = [];
  			cdom.hr.(flds{ifl}).c(i2rm,:) = [];
  		else
  			cdom.hr.(flds{ifl})(i2rm,:) = [];
  		endif
  	endfor

 
 
################### process ABSORPTION data ################################
        cdom.hr.ay = nan(size(cdom.hr.MQ.a));

    #############################################
    ### fit 0.2um-MQ hourly spectra in the blue to get cdom and slope between 450 and 550 nm

        innan = find( ~isnan(cdom.hr.ay_raw(:,1)) );  

#         ay_pars = nan(length(cdom.hr.time),1); # use this with obj_ay
        ay_pars = nan(length(cdom.hr.time),2); # use this with obj_ay2

        disp("fitting ay slope");
        fflush(stdout);
        
        ay_pars(innan,:) = cell2mat(  parcellfun(NPROC, @(x) fminsearch(@(pars) obj_ay2(x, x(:,iwvrng440), wv(wv_rng)', pars), pars0, options), ...
							num2cell(cdom.hr.ay_raw(innan,wv_rng),2), "ErrorHandler", @parcellfunERRFUNC, "UniformOutput", false)       ) ;
        
		% ay_pars(innan,:) = cellfun(@(x) fminsearch(@(pars) obj_ay2(x, x(:,iwvrng440), wv(wv_rng)', pars), pars0, options), ...
        %                                     num2cell(cdom.hr.ay_raw(innan,wv_rng),2), "ErrorHandler", @parcellfunERRFUNC, "UniformOutput", false);
                                  
        cdom.hr.ay_slope =   ay_pars(:,1);                                
        cdom.hr.ay_bkg =   ay_pars(:,2);                                
                                                
        cdom.hr.ay(innan,:) =   ay_fun2(cdom.hr.ay_raw(innan,i440), wv', ay_pars(innan,:)) - cdom.hr.ay_bkg(innan);                      
                                

        
#         ay_pars(innan,:) = parcellfun(NPROC, @(x) fminsearch(@(pars) obj_ay(x, x(:,iwvrng440), wv(wv_rng)', pars), pars0(1), options), ...
#                                             num2cell(cdom.hr.ay_raw(innan,wv_rng),2), "ErrorHandler", @parcellfunERRFUNC);
#                                             
#         cdom.hr.ay_slope =   ay_pars(:,1);     
#         cdom.hr.ay(innan,:) =   ay_fun(cdom.hr.ay_raw(innan,i440), wv', ay_pars(innan,:)) ;                      
                                
                                
                                
                                
################### process ATTENUATION data ################################
        cdom.hr.cy = nan(size(cdom.hr.MQ.c));

    #############################################
    ### fit 0.2um-MQ hourly spectra in the blue to get cdom and slope between 450 and 550 nm

        innan = find( ~isnan(cdom.hr.cy_raw(:,1)) );  

#         cy_pars = nan(length(cdom.hr.time),1); # use this with obj_ay
        cy_pars = nan(length(cdom.hr.time),2); # use this with obj_ay2

        disp("fitting cy slope");
        fflush(stdout);
        
        
        cy_pars(innan,:) = cell2mat(  parcellfun(NPROC, @(x) fminsearch(@(pars) obj_ay2(x, x(:,iwvrng440), wv(wv_rng)', pars), pars0, options), ...
										num2cell(cdom.hr.cy_raw(innan,wv_rng),2), "ErrorHandler", @parcellfunERRFUNC, "UniformOutput", false) 	);
                                            
        cdom.hr.cy_slope =   cy_pars(:,1);                                
        cdom.hr.cy_bkg =   cy_pars(:,2);                                
                                                
        cdom.hr.cy(innan,:) =   ay_fun2(cdom.hr.cy_raw(innan,i440), wv', cy_pars(innan,:)) - cdom.hr.cy_bkg(innan);                      
                                

        
#         cy_pars(innan,:) = parcellfun(NPROC, @(x) fminsearch(@(pars) obj_ay(x, x(:,iwvrng440), wv(wv_rng)', pars), pars0(1), options), ...
#                                             num2cell(cdom.hr.cy_raw(innan,wv_rng),2), "ErrorHandler", @parcellfunERRFUNC);
#                                             
#         cdom.hr.cy_slope =   cy_pars(:,1);     
#         cdom.hr.cy(innan,:) =   ay_fun(cdom.hr.cy_raw(innan,i440), wv', cy_pars(innan,:)) ;                      




## remove hourly acy estimates before and after acs cleaning times
	tmp2 = load("input/acs_cleaned_times.dat");
	tmp2(:,1) = tmp2(:,1); 

	acs_cleaned_times = datenum([   ones(size(tmp2,1), 1)*[YEAR 1] tmp2(:,1) tmp2(:,2) tmp2(:,3)   ]);


	# find MQ measurements before and after acs cleaning and remove hourly estimates of acy during those periods
	for it = 1:length(acs_cleaned_times)
		iclosest = find( abs(acs_cleaned_times(it)-acy.time) == min(abs(acs_cleaned_times(it)-acy.time)) );

		# find acy times around acs_cleaning
		if acs_cleaned_times(it)<acy.time(iclosest)

			iLT = find(acy.time<acs_cleaned_times(it),1, "last");
			iGT = iclosest;

			if abs(acy.time(iLT)-acs_cleaned_times(it))*24 >12
				keyboard
			endif

		elseif acs_cleaned_times(it)>acy.time(iclosest)

			iLT = iclosest;
			iGT = find(acy.time>acs_cleaned_times(it),1);

			if abs(acy.time(iGT)-acs_cleaned_times(it))*24 >12
				keyboard
			endif

		else
			keyboard

		endif

		if isempty(iLT)
			iLT = 1;
		endif

		if isempty(iGT)
			iGT = length(acy.time);
		endif

		# remove cdom.hr data within this window
		i2rm = find(cdom.hr.time >= acy.time(iLT)  &   cdom.hr.time <= acy.time(iGT));
		cdom.hr.MQ.a(i2rm,:) = nan;	
		cdom.hr.MQ.c(i2rm,:) = nan;
		cdom.hr.O2.a(i2rm,:) = nan;	
		cdom.hr.O2.c(i2rm,:) = nan;
		cdom.hr.ay(i2rm,:) = nan;	
		cdom.hr.cy(i2rm,:) = nan;



	endfor

# save results
	save("-v6", [DOUT "cdom.mat"], "cdom")







cmp_ay_transect_print_figures;













