



    graphics_toolkit("gnuplot")
    close all

    figure(2, 'visible', 'off')
        clf            
        hold on
            plot(wv, a_MilQ, 'b;MilliQ;', lw, 2)
            plot(wv, a_02um, 'r;0.2 um;', lw, 2)

        grid on
    
        xlabel('wavelength [nm]', fw, 'bold')
        ylabel('a [m^{-1}]', fw, 'bold')
    
        xlim([400 750])

        ylm = get(gca, 'ylim');

        fnout = [DOUT dt_str "/" nm_str "_a_raw_spectra_da2dTS_amt26_wap.png"];
        print("-dpng", "-r300", fnout)



    close all

    figure(2, 'visible', 'off')
        clf            
        hold on
            plot(wv, a_02um-a_MilQ, 'r;a;', lw, 2)
            plot(wv, c_02um-c_MilQ, 'b;c;', lw, 2)

        grid on
    
        xlabel('wavelength [nm]', fw, 'bold')
        ylabel('a [m^{-1}]', fw, 'bold')
    
        xlim([400 750])

        title('0.2um - MilliQ', fw, 'bold')

        ylm = get(gca, 'ylim');

        fnout = [DOUT dt_str "/" nm_str "_02_minus_MQ_wap.png"];
        print("-dpng", "-r300", fnout)




    figure(2, 'visible', 'off')
        clf            
        hold on
            plot(wv, c_MilQ, 'b;MilliQ;', lw, 2)
            plot(wv, c_02um, 'r;0.2 um;', lw, 2)

        grid on
    
        xlabel('wavelength [nm]', fw, 'bold')
        ylabel('c [m^{-1}]', fw, 'bold')
    
        xlim([400 750])
    

        ylm2 = get(gca, 'ylim');

        set(gca, 'ylim', [ylm2(1) ylm2(1)+ (ylm(2)-ylm(1))])

        fnout = [DOUT dt_str "/" nm_str  "_c_raw_spectra_da2dTS_amt26_wap.png"];
        print("-dpng", "-r300", fnout)


figure(2, 'visible', 'off')
clf
subplot(121)
    hold on
        plot(wv, ay_raw, 'r', lw, 2)
        plot(wv([2:5:end length(wv)-1]), ay([2:5:end length(wv)-1])      ,'ro-', ms, 3, mfc, 'auto', lw, 2)

        plot(wv, cy_raw, 'b', lw, 2)
        plot(wv([2 10:5:end length(wv)-1]), cy([2 10:5:end length(wv)-1])      ,'bo-', ms, 3, mfc, 'auto', lw, 2)

        plot(wv, wv*0, 'k--')

        yrng = [-0.025 0.02];
        ylim(yrng)
        yticks = [yrng(1):0.005:yrng(2)];
        ylbls = strsplit(sprintf("%5.3f ", yticks), ' ')(1:end-1);
        set(gca, 'ytick', yticks, 'yticklabel', ylbls)
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold', fs, 20)
        ylabel("a,c [m^{-1}]\n", fw, "bold", fs, 20)

        set(gca, fs, 16, 'box', 'on')

        
        # this is to print a decent legend
         leg = {'a_{02}-a_{MQ}','a_y','c_{02}-c_{MQ}','c_y'};
         
         ylims = get(gca, 'ylim');
         xlims = get(gca, 'xlim');
         Dy = abs(diff(ylims))/10;
         
         c = {"r", "r", "b", "b"};  # colors
         s = {"none", "o", "none", "o"}; # symbols
         
         yo = ylims(2)-3*Dy;
         for id = 1:4
            plot(630+[0 15 30], [1 1 1]*(yo+Dy/1.5*(id-1)), '-', 'color', c{id}, 'marker', s{id}, lw, 3, ms, 3, mfc, c{id}, mec, c{id})
            text(630+50, yo+Dy/1.5*(id-1), leg{id}, fs, 16, 'interpreter', 'tex')
         endfor
 
 
 
        set(gca, 'pos', [0.13 0.13 0.33466 0.8])


        #dTS_obs = [27.74-28.12 36.301];# 2015-10-05

        text(420, -0.010, ['\DeltaT_a = ' sprintf('%+4.2f', dTSa(1)) '^oC'], fs, 16)#, fw, 'bold')
        text(420, -0.013, ['\DeltaT_c = ' sprintf('%+4.2f', dTSc(1)) '^oC'], fs, 16)#, fw, 'bold')
        text(420, -0.018, ['\DeltaT_{o} = ' sprintf('%+4.2f', dTS_obs_all.obs.T(ifn)) '^oC'], fs, 16)#, fw, 'bold')

        text(570, -0.010, ['S_a = ' sprintf('%6.3f', dTSa(2)) ], fs, 16)#, fw, 'bold')
        text(570, -0.013, ['S_c = ' sprintf('%6.3f', dTSc(2)) ], fs, 16)#, fw, 'bold')
        text(570, -0.018, ['S_{o} = ' sprintf('%6.3f', dTS_obs_all.obs.S(ifn)) ], fs, 16)#, fw, 'bold')

        text(450, 0.017, ['a_y(440) = ' sprintf('%7.4f', ay(wv==440)) ' m^{-1}'], fs, 16)#, fw, 'bold')
        text(450, 0.014, ['c_y(440) = ' sprintf('%7.4f', cy(wv==440)) ' m^{-1}'], fs, 16)#, fw, 'bold')



berrMQ_a = berrMQlong_a;
berrMQ_c = berrMQlong_c;

subplot(122)
    hold on
         plot(wv, dTSa(1)*da2dT.mean/15      ,"r-", lw, 4)
         plot(wv, dTSa(2)*da2dS.mean/5      ,"r.", lw, 4)
         if SALT_SCATTERING
            plot(wv(1:5:end), aberr_salts(dTSa(2),wv(1:5:end)) ,"r.-", lw, 2)
         else
            plot(wv(1:5:end), aberr_salts(dTSa(2),wv(1:5:end))*0 ,"r.-", lw, 2)
         endif
         plot(wv, dTSc(1)*dc2dT.mean/15      ,"b-;;", lw, 4)
         plot(wv, dTSc(2)*dc2dS.mean/5      ,"b.;;", lw, 4)
         
        if SALT_SCATTERING
            plot(wv(1:5:end), b_salts(dTSc(2),wv(1:5:end))     ,"b.-", lw, 2)
        else
            plot(wv(1:5:end), b_salts(dTSc(2)*0,wv(1:5:end))     ,"b.-", lw, 2)
        endif
        
        if cy_bkgnd!=0
            plot(wv(1:5:end), cy_bkgnd.*ones(1,length(wv(1:5:end)))     ,'k-', lw, 2)
            plot(wv(1:5:end), ay_bkgnd.*ones(1,length(wv(1:5:end)))     ,'m.', lw, 2)
        endif

        plot(wv, wv*0, 'k--')

        yrng = [-0.005 0.002];
        ylim(yrng)
        yticks = [yrng(1):0.001:yrng(2)];
        ylbls = strsplit(sprintf("%5.3f ", yticks), ' ')(1:end-1);
        set(gca, 'ytick', yticks, 'yticklabel', ylbls, 'box', 'on')
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold', fs, 20)
        ylabel('corrections [m^{-1}]', fw, 'bold', fs, 20)

        set(gca, fs, 16)
         
        
        # this is to print a decent legend
         leg = {'\Psi_T dT/15','\Psi_S dS/5','a_{b_{salts}}','\Psi_T dT/15', '\Psi_S dS/5', 'b_{salts}'};
         
         ylims = get(gca, 'ylim');
         xlims = get(gca, 'xlim');
         Dy = abs(diff(ylims))/10;
         
         c = {"r", "r", "r", "b", "b", "b"};  # colors
         s = {"none", ".", ".", "none", ".", "."}; # symbols
         lst = {"-", "none", "-", "-", "none", "-"};
         yo = ylims(1)+Dy;
         for id = 1:6
            plot(420+[0 15 30], [1 1 1]*(yo+Dy/1.5*(id-1)), 'linestyle', lst{id}, 'color', c{id}, 'marker', s{id}, lw, 3, ms, 6, mfc, c{id}, mec, c{id})
            text(420+50, yo+Dy/1.5*(id-1), leg{id}, fs, 16, 'interpreter', 'tex')
         endfor

        set(gca, 'pos', [0.6 0.13 0.33466 0.8])


    set(gcf, 'paperposition', [0.25 2.5 16 6])
    
    fnout = [DOUT dt_str "/" nm_str  "_eg_cdom_derivation_dx2dTS_amt26_wap_norm_last.png"];
    print("-dpng", "-r300", fnout)

    if ifn==89
        ffigs = [DFIGS strsplit(fnout, '/'){end}];
        system(["cp " fnout " " ffigs]);
    endif
