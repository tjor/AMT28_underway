




    close all
    figure(1, 'visible', 'off')
    clf
    subplot(211)
    hold on
     plot(acs.awl, a_02um(iexp,:)-a_MilQ1(iexp,:), 'r', lw, 3)
     plot(acs.awl, a_02um(iexp,:)-a_MilQ2(iexp,:), 'k', ms, 6, mfc, 'r', lw, 3)

     plot(acs.cwl, c_02um(iexp,:)-c_MilQ1(iexp,:), 'g', lw, 3)
     plot(acs.cwl, c_02um(iexp,:)-c_MilQ2(iexp,:), 'b', ms, 6, mfc, 'r', lw, 3)

     hl = legend({'a MQ1', 'a MQ2', 'c MQ1', 'c MQ2'});
     set(hl, 'location', 'southwest', fs, 10)
     
     
         grid on

        ylim([-0.05 0.1])
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold')
        ylabel('[a,c]_{0.2}-[a,c]_w [1/m]', fw, 'bold')


    subplot(212)
    hold on
     plot(acs.awl, a_02um(iexp,:)-a_MilQ1(iexp,:), 'r', lw, 3)
     plot(acs.awl, a_02um(iexp,:)-a_MilQ2(iexp,:), 'k', ms, 6, mfc, 'r', lw, 3)

     plot(acs.cwl, c_02um(iexp,:)-c_MilQ1(iexp,:), 'g', lw, 3)
     plot(acs.cwl, c_02um(iexp,:)-c_MilQ2(iexp,:), 'b', ms, 6, mfc, 'r', lw, 3)

     hl = legend({'a MQ1', 'a MQ2', 'c MQ1', 'c MQ2'});
     set(hl, 'location', 'southwest', fs, 10)
     
         grid on

        ylim([-0.01 0.02])
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold')
        ylabel('[a,c]_{0.2}-[a,c]_w [1/m]', fw, 'bold')


     fnout = [DOUT "Psi_TS/a02_aw_da2dT4_dc2dT4_exp" num2str(iexp)];
     if WITH_TRANS_CORR==0
         fnout = [fnout "_no_corr_wap.png"];
     elseif WITH_TRANS_CORR==1
         fnout = [fnout "_wap.png"];
     endif
     print("-dpng","-r300", fnout)






    close all
    figure(1, 'visible', 'off')
    clf
    subplot(121)
       hold on
        plot(acs.awl, ay_with_salt_MQ1(iexp,:), 'r', lw, 5)
        plot(acs.awl, ay_MQ1(iexp,:), 'ko', ms, 3, mfc, 'k')
     

        ylim([-0.02 0.02])
        xlim([400 750])

        # this is to print a decent legend
         ylims = get(gca, 'ylim');
         Dy = abs(diff(ylims))/10;
 
         leg = {'a_{y,S}', 'a_y'};
         c = {"r", "k"};  # colors
         s = {"none", "o", }; # symbols
         lws = [3 0];
         
         yo = ylims(1)+Dy;
         for id = 1:2
            hp = plot(xlims(1)+[20 40 60], [1 1 1]*(yo+Dy*(id-1)), 'color', c{id}, 'marker', s{id}, lw, lws(id), ms, 3, mfc, c{id}, mec, 'k');
            if lws(id)==0
                set(hp, 'linestyle', 'none');
            endif
            text(xlims(1)+80, yo+Dy*(id-1), leg{id}, fs, 16, 'interpreter', 'tex')
         endfor

        xlabel('wavelength  [nm]', fw, 'bold', fs, 20)
        ylabel("a  [1/m]", fw, "bold", fs, 20)

         # this is to make sure all ticklabels have the same format
         yticks = get(gca, 'ytick');
         yticks = strsplit(sprintf("%.3f ",yticks), " ")(1:end-1);
         set(gca, 'yticklabel', yticks);

        set(gca, 'position', [0.13 0.12 0.32 0.8])
        set(gca, fs, 16, 'box', 'on')

        

    subplot(122)
       hold on
        plot(acs.cwl, cy_with_salt_MQ1(iexp,:), 'b', lw, 5)
        plot(acs.cwl, cy_MQ1(iexp,:), 'ko', ms, 3, mfc, 'k')
        
     
        ylim([-0.02 0.02])
        xlim([400 750])

         # this is to print a decent legend
         ylims = get(gca, 'ylim');
         Dy = abs(diff(ylims))/10;
         
        
         leg = {'c_{y,S}', 'c_y'};
         c = {"b", "k"};  # colors
         s = {"none", "o"}; # symbols
         lws = [3 0];
         
         yo = ylims(1)+Dy;
         for id = 1:2
            hp = plot(xlims(1)+[20 40 60], [1 1 1]*(yo+Dy*(id-1)), 'color', c{id}, 'marker', s{id}, lw, lws(id), ms, 3, mfc, c{id}, mec, 'k');
            if lws(id)==0
                set(hp, 'linestyle', 'none');
            endif
            text(xlims(1)+80, yo+Dy*(id-1), leg{id}, fs, 16, 'interpreter', 'tex')
         endfor

        
        xlabel('wavelength  [nm]', fw, 'bold', fs, 20)
        ylabel("c  [1/m]", fw, "bold", fs, 20)

         # this is to make sure all ticklabels have the same format
         yticks = get(gca, 'ytick');
         yticks = strsplit(sprintf("%.3f ",yticks), " ")(1:end-1);
         set(gca, 'yticklabel', yticks);
     
        set(gca, fs, 16, 'box', 'on')
        set(gca, 'position', [0.59 0.12 0.32 0.8])

        set(gcf, 'paperposition', [0.25         2.5           15           6])


        fnout = [DOUT "Psi_TS/ac_y_da2dT4_exp" num2str(iexp)];
        if WITH_TRANS_CORR==0
            fnout = [fnout "_no_corr_wap.png"];
        elseif WITH_TRANS_CORR==1
            fnout = [fnout "_wap.png"];
        endif
        print("-dpng","-r300", fnout)


    # copy figure in directory containing figures for paper
    if iexp == 1
        ffigs = [DFIGS strsplit(fnout, '/'){end}]
        system(["cp " fnout " " ffigs]);
    endif





#    close all
#    figure(1, 'visible', 'off')
#    clf
#    subplot(211)
#    hold on
#     plot(acs.cwl, cy_with_salt_MQ1(iexp,:), 'r;c_S MQ1;', lw, 3)
#     plot(acs.cwl, cy_with_salt_MQ2(iexp,:), 'k;c_S MQ2;', ms, 6, mfc, 'r', lw, 3)

#     plot(acs.cwl, cy_MQ1(iexp,:), 'ro;c_y MQ1;', ms, 1, lw, 3)
#     plot(acs.cwl, cy_MQ2(iexp,:), 'ko;c_y MQ2;', ms, 1, lw, 3)
#     

#     
#         grid on

#        ylim([-0.02 0.03])
#        xlim([400 750])

#        xlabel('wavelength [nm]', fw, 'bold')
#        ylabel('c_{0.2}-c_w-\Psi_T\DeltaT [1/m]', fw, 'bold')


#    subplot(212)
#    hold on
#     plot(acs.cwl, cy_with_salt_MQ1(iexp,:), 'r;c_S MQ1;', lw, 3)
#     plot(acs.cwl, cy_with_salt_MQ2(iexp,:), 'k;c_S MQ2;', ms, 6, mfc, 'r', lw, 3)

#     plot(acs.cwl, cy_MQ1(iexp,:), 'ro;c_y MQ1;', ms, 1, lw, 3)
#     plot(acs.cwl, cy_MQ2(iexp,:), 'ko;c_y MQ2;', ms, 1, lw, 3)
#     
#         grid on

#        ylim([-0.003 0.02])
#        xlim([400 750])

#        xlabel('wavelength [nm]', fw, 'bold')
#        ylabel('c_{0.2}-c_w-\Psi_T\DeltaT [1/m]', fw, 'bold')


#        fnout = ["./output/Psi_TS/c02_cw_noT_dc2dT4_exp" num2str(iexp)];
#        if WITH_TRANS_CORR==0
#            fnout = [fnout "_no_corr_wap.png"];
#        elseif WITH_TRANS_CORR==1
#            fnout = [fnout "_wap.png"];
#        endif
#        print("-dpng","-r300", fnout)











    close all
    figure(1, 'visible', 'off')
    clf
    subplot(211)
        hold on
         plot(acs.awl, (ay_with_salt_MQ1(iexp,:) - ay_MQ1(iexp,:))/S1(1), 'r', lw, 3)
         plot(acs.awl, (ay_with_salt_MQ2(iexp,:) - ay_MQ2(iexp,:))/S2(1), 'rx', ms, 6, mfc, 'r')

         plot(acs.cwl, (cy_with_salt_MQ1(iexp,:) - cy_MQ1(iexp,:))/S1(1), 'g', lw, 3)
         plot(acs.cwl, (cy_with_salt_MQ2(iexp,:) - cy_MQ2(iexp,:))/S2(1), 'ko', ms, 3, mfc, 'g')

         plot(acs.awl, da2dS2, 'b;Sullivan et al 2006;', lw, 3)
         plot(acs.awl, da2dS1, 'k;Rottgers et al 2014;', lw, 3)
     
     
#        hl = legend({'c_S MQ1', 'c_S MQ2', 'c_y MQ1', 'c_y MQ2'});
#        set(hl, 'location', 'southwest', fs, 10)


         grid on

        ylim([-0.00075 0.001])
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold')
        ylabel('\Psi_S [1/m 1/psu]', fw, 'bold')

    subplot(212)
        hold on
         plot(acs.awl, (ay_with_salt_MQ1(iexp,:) - ay_MQ1(iexp,:))/S1(1), 'r', lw, 3)
         plot(acs.awl, (ay_with_salt_MQ2(iexp,:) - ay_MQ2(iexp,:))/S2(1), 'rx', ms, 6, mfc, 'r')

         plot(acs.cwl, (cy_with_salt_MQ1(iexp,:) - cy_MQ1(iexp,:))/S1(1), 'g', lw, 3)
         plot(acs.cwl, (cy_with_salt_MQ2(iexp,:) - cy_MQ2(iexp,:))/S2(1), 'ko', ms, 3, mfc, 'g')

         plot(acs.awl, da2dS2, 'b', lw, 3)
         plot(acs.awl, da2dS1, 'k', lw, 3)
     
         grid on

        ylim([-8e-5 0.00012])
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold')
        ylabel('\Psi_S [1/m 1/psu]', fw, 'bold')



    fnout = [DOUT "Psi_TS/da2dS4_dc2dS4_exp" num2str(iexp)];
    if WITH_TRANS_CORR==0
        fnout = [fnout "_no_corr_wap.png"];
    elseif WITH_TRANS_CORR==1
        fnout = [fnout "_wap.png"];
    endif
    print("-dpng","-r300", fnout)

