# here I store parameters and variables that are common between different scripts: 
# the objective of this file is to make the selected processing options consistent among different scripts

YEAR = 2019;
YEAR4WAP = num2str(YEAR)(3:4);
AMTno = 29;
AMTstr = "29";

ACS_wap_port = "27";
CTD_wap_port = "22";

FORCE = 0;  # force lower part of the spectrum equal to 0
NPROC = nproc()-1; # set number of processors to use for parallel fits
PLOT = false; # decide is you want to plot data (if so, the execution is much slower)
REMOVE_ACS_intT_corr = false;  # if 'true', then remove the instrumnetal T correction
FORCE_ACS_intT_corr = false;
NORMto650 = false; # option to subtract value at 650 nm from [ac]_y
options = optimset ( "fminsearch" ); ### optimisation options
options = optimset ( options , "Display", 0, "MaxFunEvals", 5000, "Display", "notify"); ### optimisation options

SALT_SCATTERING = true; # if 'true', then remove the scattering error due to salt in filtered seawater


DEBIASING_FACTOR_4_ACSCHL = 1.; # median(ACS_CHL/HPLC_TCHLA-1) = -0.15

WITH_TRANS_CORR = 0;


MAIN_DIR = "/Users/gdal/Cruises/AMT29/";  
DINPROC = [MAIN_DIR "Processed/Underway/Step2/"];

DIN = [MAIN_DIR "Uway_CDOM/"]; 				# <===================================================== ?
DIN_WAP = [MAIN_DIR "Data/Underway/WAP_extracted/"];

DOUT = [DINPROC "../cdom/" ];					
DIN_ACS = "./input/acs/";					
# DFIGS = "~/Dropbox/Papers/ay/Figures/";
DFIGS = [MAIN_DIR "Figures/cdom/"];

if ~exist(DOUT)
	mkdir(DOUT);
endif

if ~exist(DIN_ACS)
	mkdir(DIN_ACS);
endif

if ~exist(DFIGS)
	mkdir(DFIGS);
endif



# common set of wavelengths
    wv = [400:2:750]';
#     wv_rng = find(wv>=440 & wv<=550); # used for fitting spectral slopes
#     wv_rng = find(wv>=400 & wv<=550); # used for fitting spectral slopes
#     wv_rng_discrete = find((wv>=575 & wv<=578) | (wv>=658 & wv<=670));
    wv_rng_discrete = [];#find((wv>=540 & wv<=550));
    wv_rng = [find(wv>=430 & wv<=490); wv_rng_discrete]; # used for fitting spectral slopes
    iwvrng440 = find(wv(wv_rng)>=440,1);
    
    i440 = find(wv==440);
    

####### functions for fitting [a,c]_y ###############
## NOTE that these have been written as functions in separate files so that parcellfun can use them ###
	% ay_fun = inline("ay440.*exp(ay_slope.*(440-wv))", "ay440", "wv", "ay_slope");
	% obj_ay = inline("sum(abs(ay_obs - ay_fun(ay440, wv, ay_slope) ))", "ay_obs", "ay440", "wv", "ay_slope");
	% ay_fun = @(ay440, wv, ay_slope) ay440.*exp(ay_slope.*(440-wv)) ;
	% obj_ay = @(ay_obs, ay440, wv, ay_slope) sum(abs(ay_obs - ay_fun(ay440, wv, ay_slope) ));
   
    % ay_fun2 = inline("ay440.*exp(pars(:,1)*(440-wv)) + pars(:,2)", "ay440", "wv", "pars");#+pars(:,2)
    % obj_ay2 = inline("sum(abs(ay_obs - ay_fun2(ay440, wv, pars) ))", "ay_obs", "ay440", "wv", "pars");
    % ay_fun2 = @(ay440, wv, pars) ay440.*exp(pars(:,1)*(440-wv)) + pars(:,2);#+pars(:,2) 
    % obj_ay2 = @(ay_obs, ay440, wv, pars) sum(  abs( ay_obs - ay_fun2(ay440, wv, pars) )  );
   
    slope_0 = 0.010; # initial value
    acy_offset0 = 0; # initial value

    pars0 = [slope_0 acy_offset0];

global ay_TScorr
if SALT_SCATTERING
    % ay_TScorr = inline("ay_raw  - p(1)*da2dT - p(2)*da2dS - aberr_salts(p(2), wv)", "ay_raw", "da2dT", "da2dS", "wv", "p");
    ay_TScorr = @(ay_raw, da2dT, da2dS, wv, p) ay_raw  - p(1)*da2dT - p(2)*da2dS - aberr_salts(p(2), wv);
else
    % ay_TScorr = inline("ay_raw  - p(1)*da2dT - p(2)*da2dS                        ", "ay_raw", "da2dT", "da2dS", "wv", "p");
    ay_TScorr = @(ay_raw, da2dT, da2dS, wv, p) ay_raw  - p(1)*da2dT - p(2)*da2dS                        ;
endif

global cy_TScorr
if SALT_SCATTERING
    % cy_TScorr = inline("cy_raw  - p(1)*dc2dT - p(2)*dc2dS - b_salts(p(2), wv)", "cy_raw", "dc2dT", "dc2dS", "wv", "p");
    cy_TScorr = @(cy_raw, dc2dT, dc2dS, wv, p) cy_raw  - p(1)*dc2dT - p(2)*dc2dS - b_salts(p(2), wv);
else 
    % cy_TScorr = inline("cy_raw  - p(1)*dc2dT - p(2)*dc2dS                    ", "cy_raw", "dc2dT", "dc2dS", "wv", "p");
    cy_TScorr = @(cy_raw, dc2dT, dc2dS, wv, p) cy_raw  - p(1)*dc2dT - p(2)*dc2dS                    ;
endif







###############################################################################################
################### these are parameters used to speed up calculations ########################

    theta = [0:.01:180]';
    theta_rad = deg2rad(theta);
    cos_rad2 = cos(theta_rad).^2;
    sin_theta = sin(theta_rad);


    
    
    
    
    
### wavelength range for the optimisation
    #iwv = find(wv>=650 & wv<=750);
    iwv = find(wv>=640 & wv<=750);
    i650 = find(wv==650);
    
    # first for a (accounting for partial reflection of the reflective tube)
        ideg = find(theta>=41.7);

        wv2s = [wv(iwv)(1):15:wv(iwv)(end)]';
        nwvs = length(wv2s);
        [theta_,betaswMQs,bswMQ,beta90sw] = betasw_ZHH2009(wv2s, 0, Tc=18);
        berrMQshort_a = 2*pi*trapz(theta_rad(ideg).*ones(1,nwvs), sin_theta(ideg).*ones(1,nwvs).*betaswMQs(ideg,:));
        
        wv2l = [wv(1):15:wv(end)]';
        nwvl = length(wv2l);
        [theta_,betaswMQl,bswMQ,beta90sw] = betasw_ZHH2009(wv2l, 0, Tc=18);    
        berrMQlong_a = 2*pi*trapz(theta_rad(ideg).*ones(1,nwvl), sin_theta(ideg).*ones(1,nwvl).*betaswMQl(ideg,:));

        berrMQ_a = berrMQshort_a;


    # second for c (with acceptance angle)
        acceptance_angle = 0.93;  #  [degrees]
        ideg_c = find(theta>=acceptance_angle);
        
        berrMQshort_c = 2*pi*trapz(theta_rad(ideg_c).*ones(1,nwvs), sin_theta(ideg_c).*ones(1,nwvs).*betaswMQs(ideg_c,:));
        
        berrMQlong_c = 2*pi*trapz(theta_rad(ideg_c).*ones(1,nwvl), sin_theta(ideg_c).*ones(1,nwvl).*betaswMQl(ideg_c,:));

        berrMQ_c = berrMQshort_c;
        
###############################################################################################
