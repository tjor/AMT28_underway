# understand how large the uncertainy in MQ becomes if instead of having 4 measurements per day we have less

# nogg = 10;
# 
# a_prc = nan(length(1:2:4*nogg),3);
# c_prc = nan(length(1:2:4*nogg),3);
# 
# ii = 1;
# for iw = 1:2:4*nogg
# 
# 
#     a_prc(ii,:) = prctile(acy.MQ.a(:,i440)-medfilt1(acy.MQ.a(:,i440), iw), [16 50 84]);
#     c_prc(ii,:) = prctile(acy.MQ.c(:,i440)-medfilt1(acy.MQ.c(:,i440), iw), [16 50 84]);
# 
#     ii = ii+1;
#     
# endfor
# 
# clf
# plot(1:2:4*nogg, a_prc, 'o-', ms, 3, mfc, 'auto')
# 
# xticks = 0:4:4*nogg;
# 
# xticklabels = strsplit(sprintf("%u ", xticks/4))(1:end-1);
# 
# set(gca, 'xtick', xticks, 'xticklabel', xticklabels)



ujday = unique(jday(acy.time));



a_std = c_std = nan(38,7,3);




for i_int = 1:7

    for ijday = 1:1:length(ujday)

        
        day_vec = [ujday(ijday):ujday(min(ijday+i_int-1,length(ujday))) ];
        
        
        if length(day_vec)<i_int
            break
        endif

#         sprintf(["%u %u " repmat("%u ", 1, length(day_vec))], [i_int ijday day_vec ])

        iMQ = ismember(jday(acy.time), day_vec);

        a_std(ijday,i_int,:) = [std(acy.MQ.a(iMQ)) ijday i_int];
        c_std(ijday,i_int,:) = [std(acy.MQ.c(iMQ)) ijday i_int];


    endfor


endfor





close all
fsz = 16;
figure(2, 'visible', 'off')
    clf     
        hold on
            plot(mean(a_std(:,:,1),1), 'bo-', ms, 8, mfc, 'auto', lw, 2)
#             plot(mean(a_std(:,:,1),1)+std(a_std(:,:,1),1), 'b--', ms, 8, mfc, 'auto')
#             plot(mean(a_std(:,:,1),1)-std(a_std(:,:,1),1), 'b--', ms, 8, mfc, 'auto')
            
            plot(mean(c_std(:,:,1),1), 'rs-', ms, 8, mfc, 'w', lw, 2)
#             plot(mean(c_std(:,:,1),1)+std(c_std(:,:,1),1), 'r--', ms, 8, mfc, 'auto')
#             plot(mean(c_std(:,:,1),1)-std(c_std(:,:,1),1), 'r--', ms, 8, mfc, 'auto')
            
        
        set(gca, fs, fsz, 'box', 'on')
        
        
        xlabel('Interval [days]', fs, fsz+4, fw, 'bold')
        ylabel('MQ uncertainty  [m^{-1}]', fs, fsz+4, fw, 'bold')
  
        leg = {'a', 'c'};
        plot(1.5, [0.0042], 'bo', ms, 8, mfc, 'auto')
        plot(1.5, [0.0039], 'rs', ms, 8, mfc, 'w', lw, 2)

        text(1.5+0.5, [0.0042], leg{1}, fs, fsz+4)
        text(1.5+0.5, [0.0039], leg{2}, fs, fsz+4)

        yticks = [0:0.001:0.0045];
        set(gca, 'ytick', yticks)       
        
        ylim([0 0.0045])
        
    fnout = [DOUT "figs/MQ_uncertainty.png"];
    print("-dpng", "-r300", fnout)

    ffigs = [DFIGS strsplit(fnout, '/'){end}];
    system(["cp " fnout " " ffigs]);
    
    
 









