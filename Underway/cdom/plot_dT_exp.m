

for iexp = 1:3

close all

graphics_toolkit("gnuplot");

    figure(2, 'visible', 'off')

     clf
#      subplot(211)
     hold on
         plot(acs.awl, a_MilQ1(iexp,:), 'r-', lw, 3)
         plot(acs.awl, a_MilQ2(iexp,:), 'ro-', lw, 3, ms, 3, mfc, 'r', mec, 'k')

         plot(acs.cwl, c_MilQ1(iexp,:), 'b-', lw, 3)
         plot(acs.cwl, c_MilQ2(iexp,:), 'bo-', lw, 3, ms, 3, mfc, 'b', mec, 'k')
 
         leg{4} = sprintf('{\\ita_{MQ}}, %5.2f^{{\\fontsize{20}o}}C',  T_MilQ1(iexp));
         leg{3} = sprintf('{\\ita_{MQ}}, %5.2f^{{\\fontsize{20}o}}C',  T_MilQ2(iexp));
         leg{2} = sprintf('{\\itc_{MQ}}, %5.2f^{{\\fontsize{20}o}}C',  T_MilQ1(iexp));
         leg{1} = sprintf('{\\itc_{MQ}}, %5.2f^{{\\fontsize{20}o}}C',  T_MilQ2(iexp));
 
#          hl = legend({leg1,leg2,leg3,leg4});
#          set(hl, 'location', 'southwest', lw, 0);
         
         # this is to make sure all ticklabels have the same format
         yticks = get(gca, 'ytick');
         yticks = strsplit(sprintf("%.2f ",yticks), " ")(1:end-1);
         set(gca, 'yticklabel', yticks);
         
         
         # this is to print a decent legend
         ylims = get(gca, 'ylim');
         xlims = get(gca, 'xlim');
         Dy = abs(diff(ylims))/10;
         
         c = {"r", "r", "b", "b"};  # colors
         s = {"none", "o", "none", "o"}; # symbols
         
         yo = ylims(1)+Dy/2;
         for id = 1:4
            plot(xlims(1)+[20 27 35], [1 1 1]*(yo+Dy/2*(id-1)), '-', 'color', c{id}, 'marker', s{id}, lw, 3, ms, 3, mfc, c{id}, mec, 'k')
            text(xlims(1)+50, yo+Dy/2*(id-1), leg{id}, fs, 16, 'interpreter', 'tex')
         endfor
         
         
         
#      grid on

     set(gca, fs, 16, 'box', 'on') 
     
    #ylim([-0.002 0.02])
    xlim([400 750])

    xlabel('wavelength  [nm]', fw, 'bold')
    ylabel('a,c  [1/m]', fw, 'bold')


#     subplot(212)
#      hold on
#          plot(acs.awl, DMilliQ_a(iexp,:), 'b', lw, 3)   
#          plot(acs.cwl, DMilliQ_c(iexp,:), 'r', lw, 3)
# 
#          leg1 = sprintf('a (%5.2f-%5.2f)',  T_MilQ2(iexp),T_MilQ1(iexp));
#          leg2 = sprintf('c (%5.2f-%5.2f)',  T_MilQ2(iexp),T_MilQ1(iexp));
# 
#          hl = legend({leg1,leg2});
#          set(hl, 'location', 'northwest', lw, 0);
# 
# 
#      grid on
# 
#     ylim([-0.002 0.005])
#     xlim([400 750])
# 
#     xlabel('wavelength [nm]', fw, 'bold')
#     ylabel('\Delta a,c [1/m]', fw, 'bold')




    fnout = [DOUT "Psi_TS/MilliQ_used_4_da2dT4_dc2dT4_exp" num2str(iexp)];
    
    if WITH_TRANS_CORR==0
        fnout = [fnout "_no_corr_wap.png"];
    elseif WITH_TRANS_CORR==1
        fnout = [fnout "_wap.png"];
    endif

    print("-dpng","-r300", fnout)

    # copy figure in directory containing figures for paper
    if iexp == 1
        ffigs = [DFIGS strsplit(fnout, '/'){end}];
        system(["cp " fnout " " ffigs]);
    endif








    figure(2, 'visible', 'off')

     clf
     subplot(211)
     hold on
         plot(acs.awl, da2dT4(iexp,:), 'r', lw, 3)
         plot(acs.cwl, dc2dT4(iexp,:), 'g', lw, 3)
         plot(acs.awl, da2T2, 'b', lw, 3)
         plot(acs.awl, da2T1, 'k', lw, 3)
 

    leg = {sprintf('a amt26, exp %u', iexp), sprintf('c amt26, exp %u',iexp), 'Sullivan et al 2006', 'Rottgers et al 2014' };
    hl = legend(leg);
    
    set( hl, 'location', 'northwest', lw, 0);
 
 
 
     grid on

    ylim([-0.002 0.02])
    xlim([400 750])

    xlabel('wavelength [nm]', fw, 'bold')
    ylabel('\Psi_T [1/m 1/degC]', fw, 'bold')


    subplot(212)
     hold on
         #plot(acs.awl, da2dT3, 'r;amt25, Oct 8th;', lw, 3)
         plot(acs.awl, da2dT4(iexp,:), 'r', lw, 3)
         plot(acs.cwl, dc2dT4(iexp,:), 'g', lw, 3)
         #plot(acs.awl, da2dT3-da2dT3(i440a), 'k;amt25, Oct 4th;', lw, 1)
         #plot(acs.awl, da2dT4-da2dT4(i440a), 'b;amt25, Oct 8th;', lw, 1)
         plot(acs.awl, da2T2, 'b', lw, 3)
         plot(acs.awl, da2T1, 'k', lw, 3)
 

    leg = {sprintf('a amt26, exp %u', iexp), sprintf('c amt26, exp %u',iexp), 'Sullivan et al 2006', 'Rottgers et al 2014' }; 
    hl = legend(leg);
    
    set( hl, 'location', 'northwest', lw, 0);
 

     grid on

    ylim([-0.0005 0.0015])
    xlim([400 750])

    xlabel('wavelength [nm]', fw, 'bold')
    ylabel('\Psi_T [1/m 1/degC]', fw, 'bold')




    fnout = [DOUT "Psi_TS/da2dT4_dc2dT4_exp" num2str(iexp)];
    if WITH_TRANS_CORR==0
        fnout = [fnout "_no_corr_wap.png"];
    elseif WITH_TRANS_CORR==1
        fnout = [fnout "_wap.png"];
    endif
    print("-dpng","-r300", fnout)



endfor

