
disp("printing figures");
fflush(stdout);





### plot some results to check things


    figure(2, 'visible', 'off')
        clf            
            hold on
                plot(tmp.time, tmp.acs.a(:, i440), 'o', ms, 1)
                plot(tmp.time(tm_fl), tmp.acs.a(tm_fl, i440), 'r.')
                plot(tmp.time(tm_fl_med), tmp.acs.a(tm_fl_med, i440), 'ko', ms, 2, mfc, 'auto')

                plot(acy.time, acy.MQ.norm.a(:,i440), 'ko', ms, 6, mfc, 'y')
                plot(cdom.hr.time, cdom.hr.MQ.a(:,i440), 'ks', ms, 2, mfc, 'y')

                plot(cdom.hr.time, cdom.hr.ay(:,i440)*2, 'ks', ms, 4, mfc, 'm')


            grid on
        	
			ymin = -0.02;
        	plot(acs_cleaned_times, ymin, 'k^', ms, 20, mfc, 'k')
			
            ylim([ymin 0.12])


            xlims = [   floor(min(acy.time(1), acs_cleaned_times(1)))-1  ceil(max(acy.time(end), acs_cleaned_times(end)))+1  ];
            #xlims = [acs.raw.time(1) acs.raw.time(end)];
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):2:xlims(2)], 'xminortick', 'on'  )

            dateaxis('x', 'mmmdd')

            #ylim([-0.02 0.04])
            #xlim([296 299])

            set(gca, fs, 16)


            xlabel('jday', fs, 12, fw, 'bold')
            ylabel('a_x [m^{-1}]', fs, 16, fw, 'bold')

#         pos = get(gca, 'position');
        set(gcf, 'paperposition', [0.25 2.5 16 6])


        fnout = [DOUT "raw_a_time_series_wap.png"];
        print("-dpng", fnout)







    figure(3, 'visible', 'off')
        clf
            hold on
                plot(tmp.time, tmp.acs.T(:,1), 'ro-;internal;', ms, 2, mfc, 'r')
                plot(tmp.time, tmp.acs.T(:,2), 'bo-;external;', ms, 2, mfc, 'b')

            grid on
        
        
           
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):2:xlims(2)], 'xminortick', 'on')

            dateaxis('x', 'mmmdd')

            ylim([15 40])
            #xlim([296 299])
 


            xlabel('jday', fs, 12, fw, 'bold')
            ylabel('T [^{o}C]', fs, 16, fw, 'bold')

        set(gcf, 'paperposition', [0.25 2.5 16 6])
            set(gca, fs, 16)    


        fnout = [DOUT "raw_T_time_series_wap.png"];
        print("-dpng", fnout)


    
#### plot example

    figure(2, 'visible', 'off')
        clf        
          subplot(211)    
            hold on
                plot(tmp.time, tmp.acs.a(:, i440), 'o', ms, 2)
                plot(tmp.time(tm_fl), tmp.acs.a(tm_fl, i440), 'r.', ms, 8)
                plot(tmp.time(tm_fl_med), tmp.acs.a(tm_fl_med, i440), 'ko', ms, 12, mfc, 'none', lw, 2)

                plot(acy.time, acy.MQ.norm.a(:,i440), 'ko', ms, 12, mfc, [0.8 0.4 0.1])
                plot(cdom.hr.time, cdom.hr.MQ.a(:,i440), 'ks-', ms, 8, mfc, 'y')

            grid on
        
        


            xlims = floor([acy.time(1) acy.time(end)]);
            #xlims = [acs.raw.time(1) acs.raw.time(end)];
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):1:xlims(2)], 'xminortick', 'on'  )

            dateaxis('x', 'mmmdd')

            ylim([-0.025 0.05])

            set(gca, fs, 16)


            xlabel('jday', fs, 16, fw, 'bold')
            ylabel('a_x [m^{-1}]', fs, 16, fw, 'bold')



     


          subplot(212)    
            hold on
                plot(tmp.time, tmp.acs.T(:,1), 'ro-;internal;', ms, 2, mfc, 'r')
                plot(tmp.time, tmp.acs.T(:,2), 'bo-;external;', ms, 2, mfc, 'b')

            grid on
        
        
           
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):1:xlims(2)], fs, 16)

            dateaxis('x', 'mmmdd')

            ylim([15 26])
 
            grid on

            xlabel('jday', fs, 16, fw, 'bold')
            ylabel('T [^{o}C]', fs, 16, fw, 'bold')



        set(gcf, 'paperposition', [0.25 2.5 20 12])


        fnout = [DOUT "raw_aT_time_series_wap_eg.png"];
        print("-dpng", fnout)









    
#### plot example 2

    figure(2, 'visible', 'off')
        clf        
          subplot(211)    
            hold on
                plot(tmp.time, tmp.acs.a(:, i440), 'o', ms, 2)
                plot(tmp.time(tm_fl), tmp.acs.a(tm_fl, i440), 'r.', ms, 8)
                plot(tmp.time(tm_fl_med), tmp.acs.a(tm_fl_med, i440), 'ko', ms, 12, mfc, 'none', lw, 2)

                plot(acy.time, acy.MQ.norm.a(:,i440), 'ko', ms, 12, mfc, [0.8 0.4 0.1])
                plot(cdom.hr.time, cdom.hr.MQ.a(:,i440), 'ks-', ms, 8, mfc, 'y')

            grid on
        
        

            xlims = floor([acy.time(14) acy.time(20)]);
            #xlims = [acs.raw.time(1) acs.raw.time(end)];
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):1:xlims(2)], 'xminortick', 'on'  )

            dateaxis('x', 'mmmdd')

            ylim([-0.025 0.05])

            set(gca, fs, 16)


            xlabel('jday', fs, 16, fw, 'bold')
            ylabel('a_x [m^{-1}]', fs, 16, fw, 'bold')



     


          subplot(212)    
            hold on
                plot(tmp.time, tmp.acs.T(:,1), 'ro-;internal;', ms, 2, mfc, 'r')
                plot(tmp.time, tmp.acs.T(:,2), 'bo-;external;', ms, 2, mfc, 'b')

            grid on
        
        
           
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):1:xlims(2)], fs, 16)

            dateaxis('x', 'mmmdd')

            ylim([24 38])
 
            grid on

            xlabel('jday', fs, 16, fw, 'bold')
            ylabel('T [^{o}C]', fs, 16, fw, 'bold')



        set(gcf, 'paperposition', [0.25 2.5 20 12])


        fnout = [DOUT "raw_aT_time_series_wap_eg2.png"];
        print("-dpng", fnout)











    
#### plot example 3

    figure(2, 'visible', 'off')
        clf        
          subplot(211)    
            hold on
                plot(tmp.time, tmp.acs.a(:, i440), 'o', ms, 2)
                plot(tmp.time(tm_fl), tmp.acs.a(tm_fl, i440), 'r.')
                plot(tmp.time(tm_fl_med), tmp.acs.a(tm_fl_med, i440), 'ko', ms, 4, mfc, 'auto')

                plot(acy.time, acy.MQ.norm.a(:,i440), 'ko', ms, 6, mfc, [0.8 0.4 0.1])
                plot(cdom.hr.time, cdom.hr.MQ.a(:,i440), 'ks-', ms, 2, mfc, 'y')

            grid on
        
        

            xlims = [floor([acy.time(60) ]) ceil(acy.time(end))];
            #xlims = [acs.raw.time(1) acs.raw.time(end)];
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):6/24:xlims(2)], 'xminortick', 'on', fs, 8  )

            dateaxis('x', 'dd,HH')

            ylim([-0.025 0.05])
            #ylim([-0.005 0.015])

            set(gca, fs, 10)


            xlabel('jday', fs, 16, fw, 'bold')
            ylabel('a_x [m^{-1}]', fs, 16, fw, 'bold')



     


          subplot(212)    
            hold on
                plot(tmp.time, tmp.acs.T(:,1), 'ro-;internal;', ms, 2, mfc, 'r')
                plot(tmp.time, tmp.acs.T(:,2), 'bo-;external;', ms, 2, mfc, 'b')

            grid on
        
        
           
            xlim(xlims)
        
            set(gca, 'xtick', [xlims(1):6/24:xlims(2)], fs, 10)

            dateaxis('x', 'dd,HH')

            ylim([24 35])
 
            grid on

            xlabel('jday', fs, 16, fw, 'bold')
            ylabel('T [^{o}C]', fs, 16, fw, 'bold')



        set(gcf, 'paperposition', [0.25 2.5 20 12])


        fnout = [DOUT "raw_aT_time_series_wap_eg3.png"];
        print("-dpng", fnout)












%
%
%
% #### plot example 2
%
%     figure(2, 'visible', 'off')
%         clf
%           subplot(211)
%             hold on
%                 plot(tmp.acs.T(tm_fl,1), tmp.acs.a(tm_fl, i440), 'o', ms, 2)
%
%             grid on
%
%             xlim([20 40])
%             ylim([-0.15 0.15])
%
%             set(gca, fs, 16)
%
%             set(gca, 'position', [0.15 0.58384 0.775 0.32])
%
%             #xlabel('T_{int} [degC]', fs, 16, fw, 'bold')
%             ylabel('a_{02}(440) [m^{-1}]', fs, 16, fw, 'bold')
%
%
%           subplot(212)
%             hold on
%                 plot(tmp.acs.T(tm_fl,1), tmp.acs.a(tm_fl, i730), 'ro', ms, 2)
%
%             grid on
%
%             xlim([20 40])
%             ylim([-0.35 0.1])
%
%             set(gca, fs, 16)
%
%             set(gca, 'position', [0.15 0.12 0.775 0.32])
%
%             xlabel('T_{int} [degC]', fs, 16, fw, 'bold')
%             ylabel('a_{02}(730) [m^{-1}]', fs, 16, fw, 'bold')
%
%
%
%
%         fnout = [DOUT "a440_730_Tint.png"];
%         print("-dpng", fnout)
%
%
%
%
%
%
%
%
%
%
%
%
%
% #### plot example 2
%
%     figure(2, 'visible', 'off')
%         clf
%           subplot(211)
%             hold on
%                 plot(tmp.acs.T(tm_fl,2), tmp.acs.a(tm_fl, i440), 'o', ms, 2)
%
%             grid on
%
%             xlim([15 35])
%             ylim([-0.15 0.15])
%
%             set(gca, fs, 16)
%
%             set(gca, 'position', [0.15 0.58384 0.775 0.32])
%
%             #xlabel('T_{int} [degC]', fs, 16, fw, 'bold')
%             ylabel('a_{02}(440) [m^{-1}]', fs, 16, fw, 'bold')
%
%
%           subplot(212)
%             hold on
%                 plot(tmp.acs.T(tm_fl,2), tmp.acs.a(tm_fl, i730), 'ro', ms, 2)
%
%             grid on
%
%             xlim([15 35])
%             ylim([-0.35 0.05])
%
%             set(gca, fs, 16)
%
%             set(gca, 'position', [0.15 0.12 0.775 0.32])
%
%             xlabel('T_{ext} [degC]', fs, 16, fw, 'bold')
%             ylabel('a_{02}(730) [m^{-1}]', fs, 16, fw, 'bold')
%
%
%
%
%         fnout = [DOUT "a440_730_Text.png"];
%         print("-dpng", fnout)
%




















    
#### plot example 2

    figure(2, 'visible', 'off')
        clf        
          subplot(211)    
            hold on
                plot(tmp.acs.T(tm_fl,1)-tmp.acs.T(tm_fl,2), tmp.acs.a(tm_fl, i440), 'bo', ms, 2)

            grid on
        
            #xlim([20 32])
            ylim([-0.15 0.15])

            set(gca, fs, 16)

            set(gca, 'position', [0.15 0.58384 0.775 0.32])

            #xlabel('T_{int} [degC]', fs, 16, fw, 'bold')
            ylabel('a_{02}(440) [m^{-1}]', fs, 16, fw, 'bold')


          subplot(212)    
            hold on
                plot(tmp.acs.T(tm_fl,1)-tmp.acs.T(tm_fl,2), tmp.acs.a(tm_fl, i730), 'ro', ms, 2)

            grid on
        
            #xlim([20 32])
            ylim([-0.35 0.1])

            set(gca, fs, 16)

            set(gca, 'position', [0.15 0.12 0.775 0.32])

            xlabel('T_{int} - T{ext}[degC]', fs, 16, fw, 'bold')
            ylabel('a_{02}(730) [m^{-1}]', fs, 16, fw, 'bold')

     


        fnout = [DOUT "a440_730_Tint_minus_Text.png"];
        print("-dpng", fnout)



