## prepare figures for paper
clear all
close all

warning off

% addpath ../uway/
graphics_toolkit("gnuplot");

pkg load nan

# load common parameters
common_processing_parameters;


disp("PLEASE UPDATE ./input/acs_cleaned_times.dat   and ./input/acs_off_times.dat");
fflush(stdout);

aymax = 0.035;
FS = 12;



load([DOUT "acy_simple_wap.oct"]);
load([DOUT "cdom.oct"]);


acs_cleaned_times = load("input/acs_cleaned_times.dat");
acs_off_times = load("input/acs_off_times.dat");



i440 = find(acy.wv==440);
i440_550 = find(acy.wv>=440 & acy.wv<=550);
i550 = find(acy.wv==550);

fn = glob([DINPROC "*mat"]);






### extract chlorophyll
    jday_str = strsplit(sprintf("%3u ", jday(acy.time)), ' ')(1:end-1);

    acy.chl_acs = nan(size(acy.time));
    acy.chl_acs_prcrng = nan(size(acy.time));
    acy.ap = nan(size(acy.ay));
    acy.ap_prcrng = nan(size(acy.ay));
    acy.ay_slope = nan(size(acy.time));
    acy.cy_slope = nan(size(acy.time));

    


	if ~exist([DOUT "acy_acs_only.oct"])
	   
	    for ifn = 1:length(acy.time)


	        disp(datestr(acy.time(ifn), "mmm-dd HH:MM"));
	        fflush(stdout);


	        ## extract chlorophyll
	            load([DINPROC 'proc_optics_amt' AMTstr '_' jday_str{ifn} '.mat'])

	            out.acs.time = out.acs.time + y0(YEAR);
	            itime = find(abs(out.acs.time - acy.time(ifn))*24 <= 1 ); # take data within +/- 1 hr

	            acy.chl_acs(ifn,1) = median(chlacs(out.acs)(itime));
	            acy.chl_acs_prcrng(ifn,1) = prcrng(chlacs(out.acs)(itime));

	        ## extract ap
	            acy.ap(ifn,:) = median(out.acs.ap(itime,:));
	            acy.ap_prcrng(ifn,:) = prcrng(out.acs.ap(itime,:));


	        ## extract lat and lon
	            acy.lat(ifn,1) = median(out.uway.lat(itime));
	            acy.lon(ifn,1) = median(out.uway.long(itime));

	    endfor

	    save("-binary", [DOUT "acy_acs_only.oct"], "acy")

	    acy.lat = tmp_acy.acy.lat;
	    acy.lon = tmp_acy.acy.lon;
	    acy.chl_acs = tmp_acy.acy.chl_acs;
	    acy.chl_acs_prcrng = tmp_acy.acy.chl_acs_prcrng;
	    acy.ap = tmp_acy.acy.ap;
	    acy.ap_prcrng = tmp_acy.acy.ap_prcrng;
		clear tmp_acy
    
	else
		load([DOUT "acy_acs_only.oct"]);
		
	endif
	
	
	
	
	
	
    ### Morel's model
        x = logspace(log10(0.001),log10(5), 200)';
        acy.ay440_morel = 0.032*x.^0.63;   # Morel 2009, eq. 11'

    ### Bricaud's models
        acy.ay440_bricaud = 0.034*x.^0.619;   # Bricaud et al., 2010; eq. 5a
        acy.ap440_B98 = 0.052*x.^0.635;   # Bricaud et al., 1998; eq. 1

        acy.aphi440_B10 = 0.0617*x.^0.93;  # B2010 (1st optical depth)
        acy.aphi440_B04 = 0.0654*x.^0.73;  # B2004

        acy.anap440_B10 = 0.0067*x.^0.675;  # B2010 (1st optical depth BIOSOPE)
        acy.anap440_B04 = 0.0136*x.^0.615;  # B2010 (1st optical depth all regions)

        acy.ap440_B10 = acy.aphi440_B10 + acy.anap440_B10;
        acy.ap440_B04 = acy.aphi440_B04 + acy.anap440_B04;
        
        
    figure(2, 'visible', 'off')
        clf     
        ii = 100;
            hold on
                plot(wv, cdom.hr.ay_raw(ii,:), 'k', lw, 3)
#                 plot(wv(wv_rng), cdom.hr.ay_raw(ii,wv_rng), 'k', lw, 3)
                plot(wv, cdom.hr.ay(ii,:), 'r', lw, 3)
                plot(wv, cdom.hr.ay(ii,:)*0, 'k-', lw, 1)

			%             hl = legend('{\it a}_{0.2} - {\it a}_{MQ}','{\it a}_y');
			%             set(hl, 'fontsize', 16, 'box', 'off', fw, 'bold')
			% set(get(hl, 'children')(3), 'position', [0.3580   0.7500        0])
			% set(get(hl, 'children')(4), 'position', [0.3580   0.7500        0])
#             grid on

            set(gca, fs, 16, 'box', 'on')

            
            xlabel('Wavelength  [nm]', fs, 16, fw, 'bold')
            ylabel('{\it a}  [m^{-1}]', fs, 16, fw, 'bold')

            
            

        fnout = [DFIGS "eg_fit_ay.png"];
        print("-dpng", "-r300", fnout)

        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
        % system(["cp " fnout " " ffigs]);
 

        keyboard




 
 
 
		chlmin = 0.02;
		chlmax = 20;
		ytickschla = [0.02 0.08 0.3 1.30 5 chlmax]; 
		# ytickschla = logspace(log10(chlmin), log10(chlmax), 6); 


		close all
		    figure(2, 'visible', 'off')
		        clf     
		          subplot(212) 
		            hold on
		                [hax, h1, h2] = plotyy(cdom.hr.lat, cdom.hr.ay(:,i440), cdom.hr.lat, cdom.hr.chl);
		                plot(acy.lat, acy.ay(:,i440), 'ko', mfc, [1 0.6 0.2])
		#                 plot(cdom.hr.lat, cdom.hr.cy(:,i440), 'ko', ms, 4)
                
		                set(hax(1), 'ylim', [0 aymax], 'xdir', 'reverse', fs, FS, 'xlim', [-45 50], 'box', 'on', ...
		                    'xtick', [-55:10:55], 'ytick', yticksay = [0.0:aymax/5:aymax], 'yticklabel', strsplit(sprintf("%4.3f ", yticksay)))
                    
		                set(hax(2),                   'xdir', 'reverse', fs, FS, 'xlim', [-45 50], 'box', 'on', 'ylim', [chlmin chlmax],  ...
		                    'xtick', [-55:10:55], 'ytick', ytickschla, 'yscale', 'log')#, 'yticklabel', '')
		#                     'xtick', xticks = [-55:10:55], 'ytick', yticks = [0.0:chlmax/5:chlmax], 'yticklabel', '')
                    
		                set(h1, 'linestyle', 'none', 'marker', 'o', ms, 4, mfc, [1 0.6 0.2], 'color', [.5 0.3 0.1]) 
		                set(h2, 'linestyle', 'none', 'marker', 's', ms, 1, 'color', [0 0.6   0], mfc, 'g')

 
		                hy1 = ylabel(hax(1), '{\it a_y}(440)  [m^{-1}]', fs, FS, fw, 'bold', 'color', 'k');
		                % set(hy1, 'color', [1 0.6 0.2])
		                hy2 = ylabel(hax(2), 'chl  [mg m^{-3} ]', fs, FS, fw, 'bold');
						% set(hy2, 'color', [0 0.6   0])

		                set(hax(1), 'ycolor', 'k')#[1 0.6 0.2]*0.8)
		                xlabel(hax(1), 'Latitude  [degrees N]', fs, FS, fw, 'bold')


		            pos = [0.18 0.16 0.68 0.42];
		            set(hax(1), 'pos', pos, 'ycolor', [0.8 0.4 0.1])
		            set(hax(2), 'pos', pos, 'ycolor', [0 0.6   0])#, 'ycolor', [0 0.6   0])

        

		          subplot(211) 
		            hold on
		                [hax, h1, h2] = plotyy(cdom.hr.lat, cdom.hr.sst, cdom.hr.lat, cdom.hr.sal);
		                #plot(acy.lat, acy.ay(:,i440), 'ko', mfc, [1 0.6 0.2])
                
		                set(hax(1), 'ylim', [0 32], 'xdir', 'reverse', fs, FS, 'xlim', [-45 50], 'xtick', [-55:10:55], 'box', 'on')
		                set(hax(2), 'ylim', [33 38], 'xdir', 'reverse', fs, FS, 'xlim', [-45 50], 'xtick', [-55:10:55], 'box', 'on')#, 'yticklabel', '')
		                set(h1, 'linestyle', 'none', 'marker', 'o', ms, 2, 'color', 'b', mfc, 'auto')
		                set(h2, 'linestyle', 'none', 'marker', 's', ms, 2, 'color', 'r', mfc, 'auto')

 
		                ylabel(hax(1), 'SST  [^{o}C]', fs, FS, fw, 'bold')
		                hy2 = ylabel(hax(2), 'SSS  [-]', fs, FS, fw, 'bold');


		                set(hax(2), 'ycolor', 'k')
		                set(hax(1), 'ycolor', 'k')


		            pos = [0.18 0.66 0.68 0.3];
		            set(hax(1), 'pos', pos, 'ycolor', 'b')
		            set(hax(2), 'pos', pos, 'ycolor', 'r')

		            #get(hax(2), 'pos')
        

		        fnout = [DFIGS "lat_vs_ay.png"];
		        print("-dpng", "-r300", fnout)


		        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
		        % system(["cp " fnout " " ffigs]); 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
        
         
        
        
        
    fsz = 20;
    figure(2, 'visible', 'off')
        clf     
#         ii = 100;
            hold on
                plot(jday(acy.time(1))+acy.time-floor(acy.time(1)), acy.MQ.a(:,i440), 'bo', ms, 8, mfc, 'auto')
                plot(jday(acy.time(1))+acy.time-floor(acy.time(1)), acy.MQ.c(:,i440), 'rs', ms, 8, mfc, 'w', lw, 2)
				
			
                
                plot(acs_cleaned_times(:,1)+acs_cleaned_times(:,2)/24, 0.1+zeros(size(acs_cleaned_times(:,1))), 'kv', ms, 15, lw, 3, mfc, 'k')
                plot(acs_off_times(:,1)+acs_off_times(:,2)/24, 0.1+zeros(size(acs_cleaned_times(:,1))), 'kv', ms, 15, lw, 3, mfc, 'w')

                                
                leg = {'{\it a}_{MQ}', '{\it c}_{MQ}'};
                plot([1]*315, [0.06], 'bo', ms, 8, mfc, 'auto')
                plot([1]*315, [0.075], 'rs', ms, 8, mfc, 'w', lw, 2)

                text([1]*315+0.5, [0.06], leg{1}, fs, fsz+4)
                text([1]*315+0.5, [0.075], leg{2}, fs, fsz+4)
                
                
                
#             grid on
#             set(gca, 'gridlinestyle', '--')
            
            set(gca, fs, fsz, 'box', 'on')
            
            xticks = [jday(acy.time(1)) : 2 : jday(acy.time(end))+2];
            set(gca, 'xtick', xticks)
            
            xlabel('Julian day', fs, fsz+4, fw, 'bold')
            ylabel('[{\ita,c}]_{MQ}(440)  [m^{-1}]', fs, fsz+4, fw, 'bold')

            ylim([-0.1 0.1])
            xlim([xticks(1) xticks(end)])
			grid on
            
         set(gca, 'pos', [0.1  0.18  0.85  0.74])   

         set(gcf, 'paperposition', [0.25 2.5 18 6])
            
        fnout = [DFIGS "a_MQ.png"];
        print("-dpng", "-r300", fnout)

        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
        % system(["cp " fnout " " ffigs]);
       
        
        
 
 
# run sensitivity analysis for MQ water
% mq_sens;

        
        
        
        
        
        
        
        
        
        
        
%
%     figure(2, 'visible', 'off')
%         clf
%           subplot(211)
%             hold on
%                 plot(acy.chl_acs, acy.ay(:,i440), 'ko', lw, 4, mfc, 'g')
% #                 plot(acy.chl_acs, acy.ay(:,i440)+acy.corrections.a_aberr_salts(:,i440), ms, 3, 'ko', lw, 4, mfc, 'r')
%
%                 plot(x, acy.ay440_morel, 'k', lw, 6)
%                 plot(x, acy.ay440_bricaud, 'b', lw, 6)
%
%             ylims = [0 0.02];
%             ylim(ylims)
%             xlim([0 1])
%             grid on
%
%             set(gca, fs, 16)
%
%             xlabel('{\it chl}_{ACs} [mg m^{-3}]', fs, 16, fw, 'bold')
%             ylabel('{\it a_y}(440)  [m^{-1}]', fs, 16, fw, 'bold')
%
%             set(gca, 'pos', [0.2 0.58384 0.73 0.38])
%
%             hl = legend('','incl. salts','Morel 2009', 'Bricaud et al., 2010');
%             set(hl, 'fontsize', 16)
%
%
%           subplot(212)
%             hold on
% #                 plot(acy.chl_acs, acy.ay_norm(:,i440), 'ko', lw, 2, mfc, 'y')
%
%                 plot(x, acy.ay440_morel, 'k', lw, 6)
%
%
%             ylim(ylims)
%             xlim([0 1])
%             grid on
%
%             set(gca, fs, 16)
%
%             xlabel('{\it chl}_{ACs} [mg m^{-3}]', fs, 16, fw, 'bold')
%             ylabel('{\it a_y} - a_y(550)  [m^{-1}]', fs, 16, fw, 'bold')
%
%             set(gca, 'pos', [0.2 0.11 0.73 0.38])
%
%             hl = legend('','Morel 2009');
%             set(hl, 'fontsize', 16)
%
%         set(gcf, 'paperposition', [0.25 2.5 8 11])
%
%
%         fnout = [DFIGS "ay_vs_chl.png"];
%         print("-dpng", "-r300", fnout)
%






 



### fit relationships
# # # # # #        fun = inline("PP(2)+PP(1)*x", "PP", "x"); % function to be fitted
# # # # # #        N = 200; %number of bootstrap estimates
# # # # # # 
# # # # # #        xx = real(log10(cdom.hr.chl));
# # # # # #        y = real(log10(cdom.hr.ay(:,i440)));
# # # # # #        innan = find(!isnan(xx) & !isnan(y) & xx>log10(0.02));
# # # # # #        xx = xx(innan);
# # # # # #        y = y(innan);
# # # # # #        pp0 = fliplr(polyfit(xx, y, 1)); %initial values of parameters
# # # # # #        [phr, pehr, ci95phr, Ahr] = robust_btstrp_regression(xx, y, fun, pp0, N, want_plot=0, not_neg=0);

#        %
		% fun = inline("PP(1)*x.^PP(2)", "PP", "x"); % function to be fitted




# 
# # 

if ~exist([DOUT "amt_chl_vs_ayp440.oct"])
	
	fun = @(PP, x) PP(1)*x.^PP(2); % function to be fitted
	N = 200; %number of bootstrap estimates

	xx = cdom.hr.chl;
	y = cdom.hr.ay(:,i440);
	innan = find(!isnan(xx) & !isnan(y) & xx>(0.02));
	xx = xx(innan);
	y = y(innan);
	pp0 = fliplr(polyfit(real(log10(xx)), real(log10(y)), 1)); %initial values of parameters
	pp0(1) = 10^pp0(1);
	[phr, pehr, ci95phr, Ahr, rr] = robust_btstrp_regression(xx, y, fun, pp0, N, want_plot=0, not_neg=0);


	xx = cdom.hr.chl;
	y = cdom.hr.ap(:,i440);
	innan = find(!isnan(xx) & !isnan(y) & xx>log10(0.02));
	xx = xx(innan);
	y = y(innan);
	pp0 = fliplr(polyfit(log10(xx), log10(y), 1)); %initial values of parameters
	pp0(1) = 10^pp0(1);
	[pap, peap, ci95pap, Aap] = robust_btstrp_regression(xx, y, fun, pp0, N, want_plot=0, not_neg=0);

	save ("-binary", [DOUT "amt_chl_vs_ayp440.oct"], "pap", "peap", "ci95pap", "Aap", "phr", "pehr", "ci95phr", "Ahr");

else
	load([DOUT "amt_chl_vs_ayp440.oct"]);
	
endif
	
	
    close all
    figure(2, 'visible', 'off')
        clf     
#           subplot(211)       
            hold on
                # ay
                innan = find(~isnan(cdom.hr.ay(:,i440)) & ~isnan(cdom.hr.chl));
                hs1 = scatter(cdom.hr.chl(innan), cdom.hr.ay(innan,i440), 5+250, cdom.hr.sst(innan), "filled")

                loglog(cdom.hr.chl(innan), cdom.hr.ay(innan,i440), 'ko', mfc, 'none', lw, 0.5)

                fun = inline("p(1)*x.^p(2)","p", "x");
                % loglog(x, fun(phr, x), 'r', lw, 6, 'color', 'k')
                loglog(x, acy.ay440_morel, 'r..', lw, 6, 'color', 'r')
                loglog(x, acy.ay440_bricaud, 'b--', lw, 6)


            ylims = [0.0005 0.07];
            ylim(ylims)
            xlims = [0.015 3.5];
            xlim(xlims)
            

            xticks = [0.01 0.03 0.10 0.3 1 3 ];
            xticklabels = strsplit(sprintf("%4.2g ", xticks), ' ', true);

            yticks = [0.001 0.003 0.006 0.01 0.02 0.03 0.1];
            yticklabels = strsplit(sprintf("%4.3g ", yticks), ' ', true);



            hcb1 = colorbar;
            caxis([0 30])

            set(gca, 'pos', [0.18   0.14   0.65  0.77])

            set(hcb1, 'pos', [0.85   0.14   0.02   0.77], fs, 16)


            ht = text(9.7, 0.01, 'SST   [^{\circ}C]', fs, 16, fw, 'bold') ;
            set(ht, 'rotationmode', 'manual', 'rotation', -90)

            set(gca, fs, 16, 'xtick', xticks, 'xticklabel', xticklabels, 'ytick', yticks, 'yticklabel', yticklabels)

            xlabel('{\it chl}_{ACs} [mg m^{-3}]', fs, 16, fw, 'bold')
            ylabel('{\it a_y}(440)  [m^{-1}]', fs, 16, fw, 'bold')

            hl = legend({'', '', ['AMT' AMTstr], 'M09', 'B10'}, 'location', 'southeast');
            set(hl, fs, 12, fw, 'bold', 'box', 'off')
            
            
            box on
            
        set(gcf, 'paperposition', [0.25 2.5 7 6])
        

        fnout = [DFIGS "ay_vs_chl_log10.png"];
        print("-dpng", "-r300", fnout)

        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
        % system(["cp " fnout " " ffigs]);



        
        
        
        
        
        
load([DOUT "amt_chl_vs_ayp440.oct"]);

amt.ap440 = 10.^polyval(pap, log10(x));
amt.ay440 = 10.^polyval(phr, log10(x));




aw440_pf97 = 0.00635;# [1/m]  Pope and Fry (1997) pure water absorption at 440 nm
blu = [0.4 0.4 1];
close all
    figure(2, 'visible', 'off')
          clf  
            hold on
                semilogx(cdom.hr.chl, cdom.hr.ay(:,i440)./(cdom.hr.ap(:,i440)+cdom.hr.ay(:,i440)+aw440_pf97), 'ko', ms, 4, lw, 0.5)
#                 semilogx(cdom.hr.chl, cdom.hr.cy(:,i440)./(cdom.hr.ap(:,i440)+cdom.hr.cy(:,i440)+aw440_pf97), 'ro', ms, 4, lw, 0.5, mfc, 'y')
                semilogx(acy.chl_acs, acy.ay(:,i440)./(acy.ay(:,i440)+acy.ap(:,i440)+aw440_pf97), 'ko', mfc, blu)
        
#                 semilogx(x, amt.ay440./(amt.ay440 + amt.ap440 + aw440_pf97), 'k', lw, 6)
				semilogx(x, acy.ay440_bricaud./(acy.ap440_B98 + acy.ay440_bricaud + aw440_pf97), 'k', lw, 6)
				semilogx(x, acy.ay440_bricaud./(acy.ap440_B04 + acy.ay440_bricaud + aw440_pf97), 'b', lw, 6)
				semilogx(x, acy.ay440_bricaud./(acy.ap440_B10 + acy.ay440_bricaud + aw440_pf97), 'r', lw, 6)
               
            ylim([0 1])
            xlim([0.01 5])
            #grid('on');

            xticks = [0.01 0.03 0.10 0.3 1 3 ];
            xticklabels = strsplit(sprintf("%4.2g ", xticks), ' ', true);

            set(gca, fs, 16, 'xtick', xticks, 'xticklabel', xticklabels, 'box', 'on', 'gridlinestyle', '--')

            xlabel('{\it chl}_{ACs} [mg m^{-3}]', fs, 16, fw, 'bold')
            ylabel('{\it a_y}(440) : {\it a_{tot}}(440)', fs, 16, fw, 'bold')

            % [HLEG, HLEG_OBJ, HPLOT, LABELS] = legend({'', '',  'B10:(B10+B98+P97)', 'B10:(B10+B10+P97)', 'B10:(B10+B04+P97)'}, 'location', 'northeast');
            [HLEG, HLEG_OBJ, HPLOT, LABELS] = legend({'', '',  'B98', 'B04', 'B10'}, 'location', 'northeast');
            set(HLEG, fs, 16, 'location', 'northeast', 'box', 'off', 'color', 'k', fw, 'bold')

            
        set(gcf, 'paperposition', [0.25 2.5 7 6])

        fnout = [DFIGS "ay2atot440_vs_chl.png"];
        print("-dpng", "-r300", fnout)


        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
        % system(["cp " fnout " " ffigs]);









%
%
%
%     figure(2, 'visible', 'off')
%         clf
%           subplot(211)
%             hold on
%                 plot(acy.chl_acs, acy.cy(:,i440), 'ko', lw, 4, mfc, 'g')
% #                 plot(acy.chl_acs, acy.cy(:,i440)+acy.corrections.c_b_salts(:,i440), 'ko', ms, 3, lw, 4, mfc, 'r')
%
%                 plot(x, acy.ay440_morel, 'k', lw, 6)
%
%             ylims = [-0.005 0.025];
%             ylim(ylims)
%             xlim([0 1])
%             grid on
%
%             set(gca, fs, 16)
%
%             xlabel('{\it chl}_{ACs} [mg m^{-3}]', fs, 16, fw, 'bold')
%             ylabel('{\it c_y}(440)  [m^{-1}]', fs, 16, fw, 'bold')
%
%             set(gca, 'pos', [0.2 0.58384 0.73 0.38])
%
%             hl = legend('','incl. salts','Morel 2009');
%             set(hl, 'fontsize', 16)
%
%
%
%           subplot(212)
%             hold on
%                 plot(acy.chl_acs, acy.cy(:,i440)-acy.cy(:,acy.wv==550), 'ko', lw, 2, mfc, 'y')
%
%                 plot(x, acy.ay440_morel, 'k', lw, 6)
%
%             ylims = [0 0.02];
%             ylim(ylims)
%             xlim([0 1])
%             grid on
%
%             set(gca, fs, 16)
%
%             xlabel('{\it chl}_{ACs} [mg m^{-3}]', fs, 16, fw, 'bold')
%             ylabel('{\it c_y} - {\it c_y}(550)  [m^{-1}]', fs, 16, fw, 'bold')
%
%             set(gca, 'pos', [0.2 0.11 0.73 0.38])
%
%             hl = legend('','Morel 2009');
%             set(hl, 'fontsize', 16)
%
%         set(gcf, 'paperposition', [0.25 2.5 8 11])
%
%
%         fnout = [DFIGS "cy_vs_chl.png"];
%         print("-dpng", "-r300", fnout)





 
            
  % iSOcean = find(acy.time-y0(YEAR)>=295);


mspoints = 2;
ylims = [-0.005 0.02];
fsz = 12;
    figure(2, 'visible', 'off')
        clf     
          subplot(221)      
            hold on
                plot(acy.wv, acy.ay_raw, 'k-', lw, 0.25)
                plot(acy.wv(wv_rng), acy.ay_raw(:,wv_rng), 'r.', ms, mspoints)
                plot(acy.wv, acy.wv*0, 'r..', ms, 2)


            ylim(ylims)
            xlim([400 750])
            
            box on
           
 
            set(gca, fs, fsz)

            xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
            ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
            text(600, ylims(2)*0.85, '{\it a_{y,raw}}', fs, fsz, fw, 'bold')

#             set(gca, 'pos', [0.13 0.15 0.36 0.75])
            
            xticks = [400:100:750];
            set(gca, 'xtick', xticks)
            yticks = [ylims(1):0.005:ylims(2)];
            yticklabels = strsplit(sprintf("%.3f ", yticks), " ")(1:end-1);
            set(gca, 'ytick', yticks, 'yticklabel', yticklabels)


          subplot(222)    
            hold on
                plot(acy.wv, acy.cy_raw, 'k-', lw, 0.25)
                plot(acy.wv(wv_rng), acy.cy_raw(:,wv_rng), 'r.', ms, mspoints)
                plot(acy.wv, acy.wv*0,  'r..', ms, 2)

            xlim([400 750])
            ylim(ylims)
            
            box on
           
            set(gca, fs, fsz)


            xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
#             ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
            text(600, ylims(2)*0.85, '{\it c_{y,raw}}', fs, fsz, fw, 'bold')

#             set(gca, 'pos', [0.6 0.15 0.36 0.75])
            set(gca, 'xtick', xticks)
            set(gca, 'ytick', yticks, 'yticklabel', yticklabels)









           subplot(223)      
#             hold on
#                 plot(acy.wv, acy.ay, 'k-', lw, 1)
#                 plot(acy.wv, acy.wv*0, 'r..', ms, 2)
# 
# 
#             ylim(ylims)
#             xlim([400 750])
#             
#             box on
#            
# 
#             set(gca, fs, fsz)
# 
#             xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
#             ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
#             text(600, ylims(2)*0.85, '{\it a_y}', fs, fsz, fw, 'bold')
# 
# #             set(gca, 'pos', [0.13 0.15 0.36 0.75])
#             
#             xticks = [400:100:750];
#             set(gca, 'xtick', xticks)
#             yticks = [ylims(1):0.005:ylims(2)];
#             yticklabels = strsplit(sprintf("%.3f ", yticks), " ")(1:end-1);
#             set(gca, 'ytick', yticks, 'yticklabel', yticklabels)
            hold on
                plot(acy.wv(:), acy.ay_raw(:,:)-acy.ay(:,:), 'k-', lw, 1)
                plot(acy.wv(wv_rng), acy.ay_raw(:,wv_rng)-acy.ay(:,wv_rng), 'r.', ms, mspoints)
#                 plot(acy.wv(wv_rng), acy.ay_raw(iSOcean,wv_rng)-acy.ay(iSOcean,wv_rng), 'c.', ms, mspoints)
                plot(acy.wv, acy.wv*0, 'r..', ms, 2)

            ylim([-0.005 0.005])
            xlim([400 750])
            
            box on
           
            set(gca, fs, fsz)

            xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
            ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
            text(450, 0.004, '{\it a_{y,raw} - a_{y}}', fs, fsz, fw, 'bold')

#             set(gca, 'pos', [0.13 0.15 0.36 0.75])
#             posi = get(gca, 'pos');
#             posi(2) = posi(2)+0.05;
#             posi(4) = posi(4)-0.05;
#             set(gca, 'pos', posi);      
#             
#             
            xticks = [400:100:750];

            yticks = [ylims(1):0.005:ylims(2)];
            yticklabels = strsplit(sprintf("%.3f ", yticks), " ")(1:end-1);
            set(gca, 'xtick', xticks)
            set(gca, 'ytick', [-0.005:0.001:0.005], 'yticklabel', strsplit(num2str([-0.005:0.001:0.005])))

            
            
            

          









          subplot(224)    
#             hold on
#                 plot(acy.wv, acy.cy, 'k-', lw, 1)
#                 plot(acy.wv, acy.wv*0,  'r..', ms, 2)
# 
#             xlim([400 750])
#             ylim(ylims)
#             
#             box on
#            
#             set(gca, fs, fsz)
# 
# 
#             xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
# #             ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
#             text(600, ylims(2)*0.85, '{\it c_y}', fs, fsz, fw, 'bold')
# 
# #             set(gca, 'pos', [0.6 0.15 0.36 0.75])
#             set(gca, 'xtick', xticks)
#             set(gca, 'ytick', yticks, 'yticklabel', yticklabels)
            hold on
                plot(acy.wv(:), acy.cy_raw(:,:)-acy.cy(:,:), 'k-', lw, 1)
                plot(acy.wv(wv_rng), acy.cy_raw(:,wv_rng)-acy.cy(:,wv_rng), 'r.', ms, mspoints)
                plot(acy.wv, acy.wv*0, 'r..', ms, 2)

            xlim([400 750])
            ylim([-0.005 0.005])
            
            box on
           
            set(gca, fs, fsz)


            xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
#             ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
            text(450, 0.004, '{\it c_{y,raw} - c_{y}}', fs, fsz, fw, 'bold')

#             set(gca, 'pos', [0.6 0.15 0.36 0.75])
#             posi = get(gca, 'pos');
#             posi(2) = posi(2)+0.05;
#             posi(4) = posi(4)-0.05;
#             set(gca, 'pos', posi);
            set(gca, 'xtick', xticks)
            set(gca, 'ytick', [-0.005:0.001:0.005], 'yticklabel', strsplit(num2str([-0.005:0.001:0.005])))

            
            
            

        set(gcf, 'paperposition', [0.25 2.5 8 8])


        fnout = [DFIGS "acy_spectra.png"];
        print("-dpng", "-r300", fnout)


        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
%         system(["cp " fnout " " ffigs]);
 





ylims = [-0.005 0.005];
fsz = 12;
    figure(2, 'visible', 'off')
        clf     
          subplot(121)      
            hold on
                
                plot(acy.wv(wv_rng), acy.ay_raw(:,wv_rng)-acy.ay(:,wv_rng), 'b-', lw, 1)
                % plot(acy.wv(wv_rng), acy.ay_raw(iSOcean,wv_rng)-acy.ay(iSOcean,wv_rng), 'r-', lw, 1)
                plot(acy.wv, acy.wv*0, 'r..', ms, 2)


            ylim(ylims)
            xlim([400 550])
            
            box on
           
 
            set(gca, fs, fsz)

            xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
            ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
            text(480, 0.004, '{\it a_{y,raw,n} - a_{y}}', fs, fsz, fw, 'bold')

#             set(gca, 'pos', [0.13 0.15 0.36 0.75])
            posi = get(gca, 'pos');
            posi(2) = posi(2)+0.05;
            posi(4) = posi(4)-0.05;
            set(gca, 'pos', posi);      
            
            
            xticks = [400:100:750];

            yticks = [ylims(1):0.005:ylims(2)];
            yticklabels = strsplit(sprintf("%.3f ", yticks), " ")(1:end-1);
            set(gca, 'xtick', [400:50:550], 'xticklabel', strsplit(num2str([400:50:550])))
            set(gca, 'ytick', [-0.005:0.001:0.005], 'yticklabel', strsplit(num2str([-0.005:0.001:0.005])))


          subplot(122)    
            hold on
                plot(acy.wv(wv_rng), acy.cy_raw(:,wv_rng)-acy.cy(:,wv_rng), 'b-', lw, 1)
                plot(acy.wv, acy.wv*0, 'r..', ms, 2)

            xlim([400 550])
            ylim(ylims)
            
            box on
           
            set(gca, fs, fsz)


            xlabel('Wavelength [nm]', fs, fsz, fw, 'bold')
#             ylabel('[m^{-1}]', fs, fsz, fw, 'bold')
            text(480, 0.004, '{\it c_{y,raw,n} - c_{y}}', fs, fsz, fw, 'bold')

#             set(gca, 'pos', [0.6 0.15 0.36 0.75])
            posi = get(gca, 'pos');
            posi(2) = posi(2)+0.05;
            posi(4) = posi(4)-0.05;
            set(gca, 'pos', posi);
            set(gca, 'xtick', [400:50:550], 'xticklabel', strsplit(num2str([400:50:550])))
            set(gca, 'ytick', [-0.005:0.001:0.005], 'yticklabel', strsplit(num2str([-0.005:0.001:0.005])))


        set(gcf, 'paperposition', [0.25 2.5 8 4])


        fnout = [DFIGS "acy_spectra_residuals.png"];
        print("-dpng", "-r300", fnout)

        
        
        
        
        
        

#         ffigs = [DFIGS strsplit(fnout, '/'){end}];
#         system(["cp " fnout " " ffigs]);
%
%
%     figure(2, 'visible', 'off')
%         clf
%           subplot(211)
%             hold on
%                 plot(acy.wv, acy.ay, 'k-', lw, 2)
%                 plot(acy.wv, acy.wv*0, 'r--', lw, 6)
%
%
%             ylims = [1e-4 0.025];
%             ylim(ylims)
%             xlim([400 750])
%             grid on
%
%             set(gca, fs, 16)
%
%             xlabel('Wavelength [nm]', fs, 16, fw, 'bold')
%             ylabel('{\it a_y}  [m^{-1}]', fs, 16, fw, 'bold')
%
%             set(gca, 'pos', [0.17 0.58384 0.755 0.38], 'yscale', 'log')
%
%
%
%           subplot(212)
%             hold on
% #                 plot(acy.wv, acy.ay_norm, 'k-', lw, 2)
%                 plot(acy.wv, acy.wv*0,  'r--', lw, 6)
%
%             xlim([400 750])
%             ylim(ylims)
%             grid on
%
%             set(gca, fs, 16)
%
%
%             xlabel('Wavelength [nm]', fs, 16, fw, 'bold')
%             ylabel('{\it a_y} - a_y(550)  [m^{-1}]', fs, 16, fw, 'bold')
%
%             set(gca, 'pos', [0.17 0.11 0.755 0.38], 'yscale', 'log')
%
%         set(gcf, 'paperposition', [0.25 2.5 8 11])
%
%
%         fnout = [DFIGS "log_ay_spectra.png"];
%         print("-dpng", "-r300", fnout)




















    %
    %
    %
    % figure(2, 'visible', 'off')
    %     clf
    %       subplot(211)
    %         hold on
    %             plot(acy.wv, acy.cy, 'k-', lw, 2)
    %             plot(acy.wv, acy.wv*0, 'r--', lw, 6)
    %
    %         xlim([400 750])
    %         ylims = [-0.005 0.025];
    %         ylim(ylims)
    %         grid on
    %
    %         set(gca, fs, 16)
    %
    %         xlabel('Wavelength [nm]', fs, 16, fw, 'bold')
    %         ylabel('c_y  [m^{-1}]', fs, 16, fw, 'bold')
    %
    %         set(gca, 'pos', [0.17 0.58384 0.755 0.38])
    %
    %
    %
    %       subplot(212)
    %         hold on
    %             plot(acy.wv, acy.cy-acy.cy(:,acy.wv==550), 'k-', lw, 2)
    %             plot(acy.wv, acy.wv*0,  'r--', lw, 6)
    %
    %         xlim([400 750])
    %         ylim(ylims)
    %
    %         grid on
    %
    %         set(gca, fs, 16)
    %
    %
    %         xlabel('Wavelength [nm]', fs, 16, fw, 'bold')
    %         ylabel('c_y - c_y(550)  [m^{-1}]', fs, 16, fw, 'bold')
    %
    %         set(gca, 'pos', [0.17 0.11 0.755 0.38])
    %
    %     set(gcf, 'paperposition', [0.25 2.5 8 11])
    %
    %
    %     fnout = [DFIGS "cy_spectra.png"];
    %     print("-dpng", "-r300", fnout)
    %
    %






        
acy.ay440_B12ay440 = logspace(log10(0.001), log10(0.025), 100);
acy.ay440_B12_S_Feb07 = 10.^(-0.448 * log10(acy.ay440_B12ay440) -2.574);   # Bricaud et al., 2012; Table 1
acy.ay440_B12_S_May07 = 10.^(-0.426 * log10(acy.ay440_B12ay440) -2.534);   # Bricaud et al., 2012; Table 1
acy.ay440_B12_S_Aug07 = 10.^(-0.419 * log10(acy.ay440_B12ay440) -2.519);   # Bricaud et al., 2012; Table 1
acy.ay440_B12_S_Nov07 = 10.^(-0.448 * log10(acy.ay440_B12ay440) -2.581);   # Bricaud et al., 2012; Table 1


fsz = 16;
msz = 5;
yticks = [0.01:0.002:0.03];
yticklabels = strsplit(sprintf("%.3f ", yticks))(1:end-1);

xticks = [0.0:0.005:0.025];
xticklabels = strsplit(sprintf("%.3f ", xticks))(1:end-1);
     %
    % figure(2, 'visible', 'off')
    %     clf
    %       subplot(121)
    %         hold on
    %             plot(cdom.hr.ay(:,i440), cdom.hr.ay_slope(:,1), 'ko', ms, msz, mfc, 'none', lw, 0.5)
    %
    %             plot(acy.ay(:,i440), acy.a.slope, 'ko', mfc, 'b', ms, msz)
    %             plot(acy.bob.ay440, acy.bob.S, 'k-', lw, 6)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_Feb07, 'k-', lw, 2)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_May07, 'k-', lw, 2)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_Aug07, 'k-', lw, 2)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_Nov07, 'k-', lw, 2)
    %
    %         ylims = [0.01 0.03];
    %         xlims = [0 0.025];
    %         ylim(ylims)
    %         xlim(xlims)
    %         box on
    %
    %
    %         set(gca, fs, fsz, 'ytick', yticks, 'yticklabel', yticklabels, 'xtick', xticks, 'xticklabel', xticklabels)
    %
    %         xlabel('a_{y}(440) [m^{-1}]', fs, fsz, fw, 'bold')
    %         ylabel('S_y  [nm^{-1}]', fs, fsz, fw, 'bold')
    %
    %         set(gca, 'pos', [0.13 0.15 0.32 0.78])
    %
    %
    %
    %
    %       subplot(122)
    %         hold on
    %             plot(cdom.hr.cy(:,i440), cdom.hr.cy_slope(:,1), 'ko', ms, msz, mfc, 'none', lw, 0.5)
    %
    %             plot(acy.cy(:,i440), acy.c.slope, 'ko', mfc, 'r', ms, msz)
    %
    %             plot(acy.bob.ay440, acy.bob.S, 'k-', lw, 6)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_Feb07, 'k-', lw, 2)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_May07, 'k-', lw, 2)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_Aug07, 'k-', lw, 2)
    %             plot(acy.ay440_B12ay440, acy.ay440_B12_S_Nov07, 'k-', lw, 2)
    %
    %         ylim(ylims)
    %         xlim(xlims)
    %         box on
    %
    %
    %         set(gca, fs, fsz, 'ytick', yticks, 'yticklabel', yticklabels, 'xtick', xticks, 'xticklabel', xticklabels)
    %
    %         xlabel('c_{y}(440) [m^{-1}]', fs, fsz, fw, 'bold')
    %         ylabel('S_y  [nm^{-1}]', fs, fsz, fw, 'bold')
    %
    %         set(gca, 'pos', [0.62 0.15 0.32 0.78])
    %
    %
    %
    %      set(gcf, 'paperposition', [0.25 2.5 12 5])
    %
    %
    %     fnout = [DFIGS "acy440_vs_Sy.png"];
    %     print("-dpng", "-r300", fnout)
    %
    %
    %     ffigs = [DFIGS strsplit(fnout, '/'){end}];
    %     system(["cp " fnout " " ffigs]);







    ### Bob's model
        xay400 = logspace(log10(0.00001), log10(10), 354);
        acy.bob.S = 0.0086*xay400.^-0.2024;
        acy.bob.ay440 = xay400.*exp(-acy.bob.S*(440-400));

 	    fsz = 16;
	    figure(2, 'visible', 'off')
	        clf     
	          subplot(121)       
	            hold on
					innan = find(~isnan(cdom.hr.ay(:,i440)) & ~isnan(cdom.hr.ay_slope(:,1)) & ~isnan(cdom.hr.sst));
	                scatter(cdom.hr.ay(innan,i440), cdom.hr.ay_slope(innan,1), msz+250, cdom.hr.sst(innan), "filled")
					plot(cdom.hr.ay(innan,i440), cdom.hr.ay_slope(innan,1), 'ko', mfc, 'none', lw, 0.02)
					
	                plot(acy.bob.ay440, acy.bob.S, 'r-', lw, 6)   
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_Feb07, 'k-', lw, 2)   
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_May07, 'k-', lw, 2)   
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_Aug07, 'k-', lw, 2)   
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_Nov07, 'k-', lw, 2)   
	            ylims = [0.01 aymax];
	            xlims = [0 0.035];
	            ylim(ylims)
	            xlim(xlims)
	            box on
	            set(gca, fs, fsz, 'ytick', yticks, 'yticklabel', yticklabels, 'xtick', xticks, 'xticklabel', xticklabels)
	            xlabel('{\it a_{y}}(440) [m^{-1}]', fs, fsz, fw, 'bold')
	            ylabel('{\it S_y}  [nm^{-1}]', fs, fsz, fw, 'bold')
	            set(gca, 'pos', [0.13 0.15 0.32 0.78])


        
 
	          subplot(122)       
	            hold on
					innan = find(~isnan(cdom.hr.cy(:,i440)) & ~isnan(cdom.hr.cy_slope(:,1)) & ~isnan(cdom.hr.sst));
		            scatter(cdom.hr.cy(innan,i440), cdom.hr.cy_slope(innan,1), msz+250, cdom.hr.sst(innan), "filled")
					plot(cdom.hr.cy(innan,i440), cdom.hr.cy_slope(innan,1), 'ko', mfc, 'none', lw, 0.02)
                
	                plot(acy.bob.ay440, acy.bob.S, 'r-', lw, 6)
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_Feb07, 'k-', lw, 2)   
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_May07, 'k-', lw, 2)   
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_Aug07, 'k-', lw, 2)   
	                plot(acy.ay440_B12ay440, acy.ay440_B12_S_Nov07, 'k-', lw, 2)   

	            ylim(ylims)
	            xlim(xlims)
	            box on


	            set(gca, fs, fsz, 'ytick', yticks, 'yticklabel', yticklabels, 'xtick', xticks, 'xticklabel', xticklabels)

	            xlabel('{\it c_{y}}(440) [m^{-1}]', fs, fsz, fw, 'bold')
	            % ylabel('S_y  [nm^{-1}]', fs, fsz, fw, 'bold')



				hcb = colorbar;
				caxis([0 30])

	            set(gca, 'pos', [0.55 0.15 0.32 0.78])

				set(hcb, 'pos', [0.9   0.15   0.02   0.78], fs, fsz)

				ht = text(0.033, 0.023, 'SST   [^{\circ}C]', fs, fsz, fw, 'bold') ;
				set(ht, 'rotationmode', 'manual', 'rotation', -90)


	         set(gcf, 'paperposition', [0.25 2.5 12 5])
        

	        fnout = [DFIGS "acy440_vs_Sy_with_SST.png"];
	        print("-dpng", "-r300", fnout)


	        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
	        % system(["cp " fnout " " ffigs]);
			
	
	
	
	
			
fsz = 20;
# close all
# fsz = 16;
#     figure(2, 'visible', 'off')
#         clf     
#           subplot(211)       
#             hold on
#                 plot(acy.dTS.obs(:,1), acy.dTS.est.a(:,1), 'ko', lw, 0.1, ms, 8, mfc, 'r')
#                 plot(acy.dTS.obs(:,1), acy.dTS.est.c(:,1), 'b+', ms, 8, lw, 3)
#                 plot(xx=[-15 5], xx, 'k--')
#             
#             ylims = [-15 5];
#             xlims = ylims;        
#        
#             ylim(ylims)
#             xlim(xlims)
#             
#             box on
#           
#           
#             # prepare legend
#                 plot(-13*[1 1], 2*[1 1], 'ko', lw, 0.1, ms, 8, mfc, 'r')
#                 plot(-13*[1 1], 0*[1 1], 'b+', ms, 8, lw, 3)
#                 text(-11, 2, "a", fs, fsz, fw, 'bold')
#                 text(-11, 0, "c", fs, fsz, fw, 'bold')
# 
#             set(gca, fs, fsz)
# 
#             xlabel('\DeltaT_{obs}  [^{o}C]', fs, fsz, fw, 'bold')
#             ylabel('\DeltaT_{est}  [^{o}C]', fs, fsz, fw, 'bold')
# 
#             set(gca, 'pos', [0.2 0.58384 0.73 0.38])
# 
# 
#           subplot(212) 
#             hold on      
#                 plot(acy.dTS.obs(:,2), acy.dTS.est.a(:,2), 'ko', lw, 0.1, ms, 8, mfc, 'r')
#                 plot(acy.dTS.obs(:,2), acy.dTS.est.c(:,2), 'b+', ms, 8, lw, 3)
#                 plot(xx=[20 40], xx, 'k--')
#             
#             ylims = [min(xx) 40];
#             xlims = ylims;
#             ylim(ylims)
#             xlim(xlims)
#                 
#             box on
# 
#             # prepare legend
#                 plot(22*[1 1], 37*[1 1], 'ko', lw, 0.1, ms, 8, mfc, 'r')
#                 plot(22*[1 1], 35*[1 1], 'b+', ms, 8, lw, 3)
#                 text(24, 37, "a", fs, fsz, fw, 'bold')
#                 text(24, 35, "c", fs, fsz, fw, 'bold')
# 
# 
#             set(gca, fs, fsz)
# 
#             xlabel('S_{obs}  [-]', fs, fsz, fw, 'bold')
#             ylabel('S_{est}  [-]', fs, fsz, fw, 'bold')
# 
#             set(gca, 'pos', [0.2 0.11 0.73 0.38])
# 
#         set(gcf, 'paperposition', [0.25 2.5 8 11])
#         
# 
#         fnout = [DFIGS "TSobs_vs_TSest.png"];
#         print("-dpng", "-r300", fnout)
# 
#         ffigs = [DFIGS strsplit(fnout, '/'){end}];
#         system(["cp " fnout " " ffigs]);













        
        
        
        
        
        
% close all
%     figure(2, 'visible', 'off')
%         clf
%
%
%         subplot(211)
%           hold on
%               [hax, h1, h2] = plotyy(cdom.hr.lon, cdom.hr.sal, cdom.hr.lon, cdom.hr.sst );
%
%               set(hax(2), 'ylim', [0 32], 'xdir', 'reverse', fs, 16, 'xlim', [-55 -32], 'box', 'on', 'yticklabel', '', 'yaxislocation', 'left')
%               set(hax(1), 'ylim', [33 38], 'xdir', 'reverse', fs, 16, 'xlim', [-55 -32], 'box', 'on', 'yaxislocation', 'right')
%               set(h2, 'linestyle', 'none', 'marker', 'o', ms, 2, 'color', 'b', mfc, 'auto')
%               set(h1, 'linestyle', 'none', 'marker', 's', ms, 2, 'color', 'r', mfc, 'auto')
%
%
%               hy1 = ylabel(hax(1), 'SSS  [-]', fs, 16, fw, 'bold');
%
%
%
%
%           pos = [0.01 0.58384 0.725 0.36];
%           set(hax(1), 'pos', pos, 'ycolor', 'r')
%           set(hax(2), 'pos', pos, 'ycolor', 'k')
%
%
%
%
%
%           subplot(212)
%             hold on
%                 [hax, h1, h2] = plotyy(cdom.hr.lon, cdom.hr.chl, cdom.hr.lon, cdom.hr.ay(:,i440));
%                 plot(hax(2), acy.lon, acy.ay(:,i440), 'ko', mfc, [1 0.6 0.2])
%
%                 set(hax(1),'xdir', 'reverse', fs, 16, 'box', 'on', 'ylim', [chlmin chlmax], 'yaxislocation', 'right', 'yscale', 'log', ...
%                     'ytick', ytickschla, 'yticklabel', strsplit(sprintf("%2.2g ", ytickschla(1:end-1))), 'xlim', [-55 -32])
%
%                 set(hax(2), 'ylim', [0 aymax], 'xdir', 'reverse', fs, 16, 'box', 'on', 'yaxislocation', 'left', ...
%                     'ytick', [0.0:aymax/5:aymax], 'yticklabel', '', 'xlim', [-55 -32])
%
%                 set(h2, 'linestyle', 'none', 'marker', 'o',  ms, 4, mfc, [1 0.6 0.2], 'color', [1 0.6 0.2])
%                 set(h1, 'linestyle', 'none', 'marker', 's', ms, 2, 'color', [0 0.6   0], mfc, 'g')
%
%
%                 ylabel(hax(1), '{\it chl}  [mg m^{-3}]       ', fs, 16, fw, 'bold', 'color', [0 0.6   0])
%
%                 xlabel(hax(2), 'Longitude  [degrees E]', fs, 16, fw, 'bold')
%
%
%
%
%
%             pos = [0.01 0.13 0.725 0.36];
%             set(hax(1), 'pos', pos, 'ycolor', [0 0.6   0])
%             set(hax(2), 'pos', pos, 'ycolor', 'k')
%
%
%
%
%
%
%
%
%         set(gcf, 'paperposition', [0.25         2.5           4           6])
%
%         fnout = [DFIGS "lon_vs_ay.png"];
%         print("-dpng", "-r300", fnout)


        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
        % system(["cp " fnout " " ffigs]);




% system(["montage -density 400 " DFIGS "lat_vs_ay.png " DFIGS "lon_vs_ay.png  -geometry +1+1  " DFIGS "lat_lon_vs_ay.png"])
% system(["cp "  DFIGS "lat_lon_vs_ay.png " DFIGS "lat_lon_vs_ay.png"]);





























fsz = 20;
close all
    figure(2, 'visible', 'off')
        clf     
            hold on
                plot(xx = [270 310], xx*0, 'r-', lw, 2)
                plot(jday(acy.time(1))+acy.time-floor(cdom.hr.time(1)), acy.ay(:,i440)-acy.cy(:,i440), 'ko', mfc, [0.8 0.5 1], ms, 10)
                plot(jday(acy.time(1))+cdom.hr.time-floor(cdom.hr.time(1)), cdom.hr.ay(:,i440)-cdom.hr.cy(:,i440), 'ko', ms, 5, lw, 1)
 
 
                ylabel('a_y(440) - c_y(440)  [m^{-1}]', fs, fsz+4, fw, 'bold', 'color', 'k');

                xlabel('Julian day', fs, fsz+4, fw, 'bold')

                set(gca, fs, fsz)

        ylim([-1 1]*0.006)
        
        medres = median(cdom.hr.ay(:,i440)-cdom.hr.cy(:,i440));
        prngres = prcrng(cdom.hr.ay(:,i440)-cdom.hr.cy(:,i440));

        ht = text(300, -0.003, ['\delta' sprintf(" = %+.4f  m^{-1}", medres)], fs, fsz+4, fw, 'bold', 'backgroundcolor', 'w');
        ht2 = text(300, -0.004, ['\sigma' sprintf(" = %.4f  m^{-1}", prngres)], fs, fsz+4, fw, 'bold', 'backgroundcolor', 'w');
        
        
        
        
        
        box on
        
#         grid on
#         set(gca, 'gridlinestyle', '--')

         set(gcf, 'paperposition', [0.25 2.5 18 6])
                

        fnout = [DFIGS "time_vs_ay_minus_cy.png"];
        print("-dpng", "-r300", fnout)


        % ffigs = [DFIGS strsplit(fnout, '/'){end}];
        % system(["cp " fnout " " ffigs]);

        #### here compute stats
        disp(sprintf('%f +/- %f', [medres prngres]))
#         meares = mean(cdom.hr.ay(:,i440)-cdom.hr.cy(:,i440));
#         stdres = std(cdom.hr.ay(:,i440)-cdom.hr.cy(:,i440));
#         disp(sprintf('%f +/- %f', [meares stdres]))






