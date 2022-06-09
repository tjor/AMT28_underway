# first extract ay_times
find_ay_times(); # this script writes a file, so it is not a problem if we have a clear all after this call


### process discrete cdom data


clear all
close all
graphics_toolkit("gnuplot");
addpath ../uway/

warning off
 
pkg load statistics # required for trimmean
pkg load parallel
# pkg load nan


disp("\n\n\nPLEASE UPDATE ./input/bad_MQs.dat\n\n\n");
fflush(stdout);



MANUAL = true;


# these are calculations that are repeated numerous times, so it is better to run them once only
    global theta 
    global theta_rad
    global cos_rad2
    global sin_theta
    global berrMQ_a
    global berrMQ_c
    
   
# load common parameters
common_processing_parameters;
    
 
    
# load Psi_TS
#     load([DOUT "/Output_files/amt26_da2dTS_wap.oct"]);

# load times
   tmp = load('./input/ay_times.dat');
   
# load bad MQ times
	tmp_bad = load('./input/bad_MQs.dat');

# remove bad MQs from tmp
	tmp = setdiff(tmp, tmp_bad, 'rows' );
   
   
   # note that I am adding one day to the JDAY found by find_ay_times because of how WAP saves the
   times_MQ = datenum(  [ones(length(tmp),1)*[YEAR 01]   tmp(:,1)+tmp(:,2)/24]    );
   times_MQ = times_MQ + 1; # this is to correct for the WAP jday 





close all
# for ifn = 120:124
for ifn = 1:length(times_MQ) 
	
	disp(sprintf("reading ACS and CTD raw files %u/%u", ifn, length(times_MQ)));
   fflush(stdout);
	
    clear acs

    disp([num2str(jday(times_MQ(ifn))) " " num2str(hour(times_MQ(ifn))) ]);
    fflush(stdout);

    dt_str = datestr(times_MQ(ifn), "yyyymmdd");
    nm_str = ["cdom_" datestr(times_MQ(ifn), "yyyymmddHHMMSS")];
    fn_str = [nm_str];
    
    if ~exist([DOUT dt_str])
      mkdir([DOUT dt_str]);
    endif


    # read ACS data
	 
        fn_acs = glob([DIN_WAP "amt" AMTstr "_" YEAR4WAP "_" num2str(jday(times_MQ(ifn))) "_" ACS_wap_port "_ACS." sprintf("%03u", hour(times_MQ(ifn))) ]){1};
         
        fnout = [DIN_ACS strsplit(fn_acs, "/"){end} ".oct"];
        
        if exist(fnout) & FORCE_ACS_intT_corr==0
            load(fnout);
        
        else
            [acs.msec,acs.c,acs.a,acs.cwl,acs.awl,acs.anc,acs.c_cal,acs.a_cal,acs.c_T_cal,acs.a_T_cal,acs.T_bins,acs.T_corrected] = rd_acs(fn_acs);
            
            
            
            
            if REMOVE_ACS_intT_corr
                acs = acs_T_corr(acs, REMOVE_ACS_intT_corr);
            endif

            acs.awl = acs.awl';
            acs.cwl = acs.cwl';   

            

        # read CTD data 
            fn_ctd = glob([DIN_WAP "amt" AMTstr "_" YEAR4WAP "_" num2str(jday(times_MQ(ifn))) "_" CTD_wap_port "_ASCII." sprintf("%03u", hour(times_MQ(ifn))) ]);
            
            # ensure that the CTD file has always 4 columns
                #create a "clean" tmp file
                system(["awk  \'NF==4 \{print\}\' " fn_ctd{1}  " > " [fn_ctd{1} ".tmp"]]);  # see http://unix.stackexchange.com/questions/151658/removal-of-lines-with-no-more-or-fewer-than-n-fields
                fn_ctd = [fn_ctd{1} ".tmp"];
                
            # read file  
            [msec T C S] = rd_sbe45(fn_ctd);
            
            # remove tmp file
                system(["rm " fn_ctd]);
            
            
            # interpolate ctd data onto acs times
                ctd.T = interp1(msec, T, acs.msec, 'extrap');
                ctd.S = interp1(msec, S, acs.msec, 'extrap');
                
                # this is to store the data in binary format after reading its raw version for the first time (SPEEDS things up)
                save("-binary", fnout, "acs", "ctd");
        
        endif

        
        a = interp1(acs.awl, acs.a', wv, 'extrap')';
        c = interp1(acs.cwl, acs.c', wv, 'extrap')';

        i440 = find(wv>=440,1);    

        
        
    # select part of the data set with MQ and with 0.2um filtered water to use
	indx = [1:length(a(:,i440))];
	
	# automatic selection
	
	
	
    if ~exist(["./selections/all/" fn_str "_selected_wap.dat"])

	 % if MANUAL
			
        happy = 'f';
		
		# automatic selection of 0.2um and MW times
		i02um = [700:2400];
		itmp = find(ctd.S<1);
		iMilQ = itmp(1:end-100);
		
		
		
        
      graphics_toolkit("qt");
        close all
        figure('Name', '1', 'units','normalized','outerposition',[0 0 1 1])
		
        while happy~="y"
            clf
            subplot(311)
            hold on            
                plot(indx, a(:,i440), 'o', ms, 2)
                ylim([-.06 0.065])
				ylabel("a(440) [1/m]")
				grid on
                title('select start and end of 0.2um (using T) and of MilliQ (using S) datasets', fs, 20)
                
            subplot(312)
            hold on         
                indx = [1:length(a(:,i440))];
                plot(indx, ctd.T, 'o', ms, 2)
                #ylim([-.1 0.055])
				ylabel("Temperature [degC]")
				grid on
                
            subplot(313)
            hold on              
                indx = [1:length(a(:,i440))];
                plot(indx, ctd.S, 'o', ms, 2)
#                ylim([-.1 0.055])
				ylabel("Salinity")
				grid on
				
                happy = 0;

			
			% set(gcf, 'pos', [0.1557   0.1883   0.6917   0.6275])
			

            subplot(311)
            hold on            
                h3111 = plot(indx(i02um), a(i02um, i440), 'ro', ms, 3);
                h3112 = plot(indx(iMilQ), a(iMilQ, i440), 'ro', ms, 3);

                xlabel('milliseconds')
                ylabel('a(440) [m^{-1}]')

            subplot(312)
            hold on                         
                h3121 = plot(indx(i02um), ctd.T(i02um), 'ro', ms, 2);
                h3122 = plot(indx(iMilQ), ctd.T(iMilQ), 'ro', ms, 2);
                
            subplot(313)
            hold on         
                h3131 = plot(indx(i02um), ctd.S(i02um), 'ro', ms, 2);
                h3132 = plot(indx(iMilQ), ctd.S(iMilQ), 'ro', ms, 2);

			



				# visually check that the slection is good
                happy = input("Happy? (y/n) [s to skip]:", "s")
                if happy=="y"

                    fnout = [DOUT dt_str "/" nm_str "_select_data_da2dTS5_wap.png"]
                    print("-dpng", fnout)

                    continue
					
				elseif happy=="s"
					
					iMilQ = [];
					i02um = [];
					break
					
                endif
				
			
                x = round(ginput(4));

                i02um = find(indx>=x(1) & indx<=x(2));
                iMilQ = find(indx>=x(3) & indx<=x(4));
				
	            subplot(311)
				
	            hold on     
					delete(h3111)
					delete(h3112)
	                h3111 = plot(indx(i02um), a(i02um, i440), 'ro', ms, 3);
	                h3111 = plot(indx(iMilQ), a(iMilQ, i440), 'ro', ms, 3);

	                xlabel('milliseconds')
	                ylabel('a(440) [m^{-1}]')

	            subplot(312)
	            hold on                         
					delete(h3121)
					delete(h3122)
	                h3121 = plot(indx(i02um), ctd.T(i02um), 'ro', ms, 2);
	                h3122 = plot(indx(iMilQ), ctd.T(iMilQ), 'ro', ms, 2);
                
	            subplot(313)
	            hold on         
					delete(h3131)
					delete(h3132)
	                h3131 = plot(indx(i02um), ctd.S(i02um), 'ro', ms, 2);
	                h3132 = plot(indx(iMilQ), ctd.S(iMilQ), 'ro', ms, 2);

        endwhile


#        save("-binary",  ["./selections/all/" fn_str "_selected_wap.dat"], "a_MilQ", "a_02um", "c_MilQ", "c_02um", "T_MilQ", "T_02um", "S_MilQ", "S_02um")
        save("-binary",  ["./selections/all/" fn_str "_selected_wap.dat"], "iMilQ", "i02um")

     else

        load(["./selections/all/" fn_str "_selected_wap.dat"])
 
     endif

%  else
%
% 	 # automatically find 0.2um and MQ time indices
%
% 	 # 0.2um part (based on temperature and times)
%
%      % i02um = find(indx>=x(1) & indx<=x(2));
% %      iMilQ = find(indx>=x(3) & indx<=x(4));
% %
%
%
%
%  endif
	

		if isempty(iMilQ) | isempty(i02um)
			continue
		endif

        a_MilQ = median(a(iMilQ,:));
        a_02um = median(a(i02um,:));

        c_MilQ = median(c(iMilQ,:));
        c_02um = median(c(i02um,:));

        T_MilQ = median(ctd.T(iMilQ));
        T_02um = median(ctd.T(i02um));

        S_MilQ = median(ctd.S(iMilQ));
        S_02um = median(ctd.S(i02um));






#         
        
        
        

        


    ##### ay #######

        ay_raw = a_02um - a_MilQ;
        if NORMto650
            ay_raw = ay_raw - ay_raw(:,i650);
        endif
        
        [tmp_pars_a, FVAL_a(ifn)] = fminsearch (@(pars) obj_ay2(ay_raw(wv_rng), ay_raw(wv_rng(iwvrng440)), wv(wv_rng)', pars), pars0, options);
#         [tmp_pars_a, FVAL_a(ifn)] = fminsearch (@(pars) obj_ay(ay_raw(wv_rng), ay_raw(wv_rng(iwvrng440)), wv(wv_rng)', pars), pars0(1), options);

        ay = ay_fun2(ay_raw(i440), wv', tmp_pars_a)-tmp_pars_a(:,2);        
#         ay = ay_fun(ay_raw(i440), wv', tmp_pars_a);        

        





    ##### cy #######

        cy_raw = c_02um - c_MilQ;
        if NORMto650
            cy_raw = cy_raw - cy_raw(:,i650);
        endif
        
        [tmp_pars_c, FVAL_a(ifn)] = fminsearch (@(pars) obj_ay2(cy_raw(wv_rng), cy_raw(wv_rng(iwvrng440)), wv(wv_rng)', pars), pars0, options);
#         [tmp_pars_c, FVAL_c(ifn)] = fminsearch (@(pars) obj_ay(cy_raw(wv_rng), cy_raw(wv_rng(iwvrng440)), wv(wv_rng)', pars), pars0(1), options);

        
        cy = ay_fun2(cy_raw(i440), wv', tmp_pars_c)-tmp_pars_c(:,2);        
#         cy = ay_fun(cy_raw(i440), wv', tmp_pars_c);        

     
        




    ###########################################################################################

    ## fill in structure with optimisation results

        dTS_obs_all.est.ay(ifn,:) = ay;  # separate optimisation
#         dTS_obs_all.est.a.slope(ifn) = tmp_pars_a(1);  # separate optimisation
#         dTS_obs_all.est.a.bkg(ifn) = tmp_pars_a(2);  # separate optimisation

        dTS_obs_all.est.cy(ifn,:) = cy;  # separate optimisation
#         dTS_obs_all.est.c.slope(ifn) = tmp_pars_c(1);  # separate optimisation
#         dTS_obs_all.est.c.bkg(ifn) = tmp_pars_c(2);  # separate optimisation

        dTS_obs_all.obs.T(ifn) = T_02um-T_MilQ; # measured T
        dTS_obs_all.obs.S(ifn) = S_02um-S_MilQ; # measured S
# 
# 
#     ##### plot figures
#         if PLOT
#             plot_cmp_ay;
#         endif


    #### store results for later summary

        acy.time(ifn,1) = times_MQ(ifn);
        acy.wv = wv;
        acy.dTS.obs(ifn,1:2) = [dTS_obs_all.obs.T(ifn) dTS_obs_all.obs.S(ifn)] ;
#         acy.dTS.est.a(ifn,1:2) = dTSa;
#         acy.dTS.est.c(ifn,1:2) = dTSc; 
        acy.MQ.a(ifn,:) = a_MilQ;
        acy.MQ.c(ifn,:) = c_MilQ;
        acy.MQ.T(ifn) = T_MilQ;
        acy.O2.a(ifn,:) = a_02um;
        acy.O2.c(ifn,:) = c_02um;
        acy.O2.T(ifn) = T_02um;
        acy.O2.S(ifn) = S_02um;
        acy.ay(ifn,:) = ay;
        acy.cy(ifn,:) = cy;
        acy.ay_raw(ifn,:) = ay_raw;
        acy.cy_raw(ifn,:) = cy_raw;
        acy.a.slope(ifn,:) = tmp_pars_a(1);
#         acy.a.bkg(ifn,:) = tmp_pars_a(2);
        acy.c.slope(ifn,:) = tmp_pars_c(1);
#         acy.c.bkg(ifn,:) = tmp_pars_c(2);
        acy.MQ.acs_intT(ifn) = median(acs.anc(iMilQ,1));
        acy.O2.acs_intT(ifn) = median(acs.anc(i02um,1));

        
      # record values of corrections and update processing variables  
#         if SALT_SCATTERING   
#             
#             #set salt-related scatterign errors to long values
#             berrMQ_a = berrMQlong_a;
#             berrMQ_c = berrMQlong_c;
# 
#             acy.corrections.a_aberr_salts(ifn,:) = aberr_salts(dTSa(2),wv);
#             acy.corrections.c_aberr_salts(ifn,:) = aberr_salts(dTSc(2),wv);
# 
#             acy.corrections.a_b_salts(ifn,:) = b_salts(dTSa(2),wv);
#             acy.corrections.c_b_salts(ifn,:) = b_salts(dTSc(2),wv);
# 
#         else
#             
#             acy.corrections.a_aberr_salts(ifn,:) = zeros(1,length(wv));
#             acy.corrections.c_aberr_salts(ifn,:) = zeros(1,length(wv));
# 
#             acy.corrections.a_b_salts(ifn,:) = zeros(1,length(wv));
#             acy.corrections.c_b_salts(ifn,:) = zeros(1,length(wv));
# 
#         endif

        
        
        #set salt-related scatterign errors back to short values
        berrMQ_a = berrMQshort_a;
        berrMQ_c = berrMQshort_c;

        
endfor









acy.time(acy.time==0) = nan;

acy.MQ.a(acy.MQ.a(:,4)==0,:) = nan;
acy.MQ.c(acy.MQ.c(:,4)==0,:) = nan;
acy.O2.a(acy.O2.a(:,4)==0,:) = nan;
acy.O2.c(acy.O2.c(:,4)==0,:) = nan;



# compute MQ spectra normalised by spectral temperature
    acy = acy_norm(acy);

        acy.MQ.norm.a = acy.MQ.a;  # these lines remove the normalisarion
        acy.MQ.norm.c = acy.MQ.c;










save("-binary", [DOUT "acy_simple_wap.oct"], "acy") ;








