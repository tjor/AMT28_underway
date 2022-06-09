## prepare plots to better understand (c_02 - c_MQ) - (a_02 - a_MQ)

close all

graphics_toolkit("gnuplot");


DOUTdiff = [DOUT "diffs/" ];

load([DOUT "Output_files/acy_dx2dTS_wap.oct"]);


wv = [400:2:750]';


diff_a = acy.O2.a-acy.MQ.a;
diff_c = acy.O2.c-acy.MQ.c;
diff_c_minus_diff_a = diff_c-diff_a;

i440 = find(wv==440);


  


figure(2, 'visible', 'off')
clf
        plot(wv, diff_c_minus_diff_a)

        grid on

        ylim([-0.01 0.01])
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold', fs, 20)
        ylabel("\Delta c - \Delta a [m^{-1}]", fw, "bold", fs, 20)

        set(gca, fs, 16)

   
    fnout = [DOUTdiff 'diff_spectra.png'];
    print("-dpng", fnout)



figure(2, 'visible', 'off')
clf
        plot(wv, diff_c_minus_diff_a-diff_c_minus_diff_a(:,wv==570))

        grid on

        yrng = [-0.01 0.006];
        ylim(yrng)
        xlim([400 750])

        xlabel('wavelength [nm]', fw, 'bold', fs, 20)
        ylabel("\Delta (c-a) - \Delta (c-a)(570) [m^{-1}]", fw, "bold", fs, 20)

        set(gca, fs, 16)

   
    fnout = [DOUTdiff 'norm_diff_spectra.png'];
    print("-dpng", fnout)







nordiff = diff_c_minus_diff_a-diff_c_minus_diff_a(:,wv==570);


figure(2, 'visible', 'off')
clf
        plot(nordiff(:,wv==440), nordiff(:,wv==740), 'o', ms, 6, mfc, 'auto')

        grid on

       
        xlabel('normdiff(440) [1/m]', fw, 'bold', fs, 20)
        ylabel('normdiff(740) [1/m]', fw, 'bold', fs, 20)

        set(gca, fs, 16)

   
    fnout = [DOUTdiff 'norm_diff_blue_vs_nir.png'];
    print("-dpng", fnout)







yrng = [-0.01 0.005];

figure(2, 'visible', 'off')
clf
subplot(321)
        plot(acy.dTS.obs(:,1), diff_c_minus_diff_a(:,i440), 'ko', ms, 4, mfc, 'r')

        grid on


        ylim(yrng)
        xlim([-5 10])

        xlabel('obs T [degC]', fw, 'bold', fs, 12)
        ylabel('diff(c-a,440) [m^{-1}]', fw, "bold", fs, 14)

        set(gca, fs, 12)

        title('Temperature', fw, 'bold', fs, 12)


   
subplot(322)
        plot(acy.dTS.obs(:,2), diff_c_minus_diff_a(:,i440), 'ko', ms, 4, mfc, 'b')

        grid on

        #yrng = [-0.003 0.003];
        ylim(yrng)
        xrngS = [34 44];
        xlim(xrngS)

        xlabel('obs S [-]', fw, 'bold', fs, 12)
        #ylabel('diff(c-a,440) [m^{-1}]', fw, "bold", fs, 14)

        set(gca, fs, 12)

        title('Salinity', fw, 'bold', fs, 12)

   
subplot(323)
        plot(acy.dTS.est.a(:,1), diff_c_minus_diff_a(:,i440), 'ko', ms, 4, mfc, 'r')

        grid on

        #yrng = [-0.003 0.003];
        ylim(yrng)
        xlim([-5 10])

        xlabel('a-est T [degC]', fw, 'bold', fs, 12)
        ylabel('diff(c-a,440) [m^{-1}]', fw, "bold", fs, 14)

        set(gca, fs, 12)

   
subplot(324)
        plot(acy.dTS.est.a(:,2), diff_c_minus_diff_a(:,i440), 'ko', ms, 4, mfc, 'b')

        grid on

        #yrng = [-0.003 0.003];
        ylim(yrng)
        xlim(xrngS)

        xlabel('a-est S [-]', fw, 'bold', fs, 12)
        #ylabel('diff(c-a,440) [m^{-1}]', fw, "bold", fs, 14)

        set(gca, fs, 12)

   

   
subplot(325)
        plot(acy.dTS.est.c(:,1), diff_c_minus_diff_a(:,i440), 'ko', ms, 4, mfc, 'r')

        grid on

        #yrng = [-0.003 0.003];
        ylim(yrng)
        xlim([-5 10])

        xlabel('c-est T [degC]', fw, 'bold', fs, 12)
        ylabel('diff(c-a,440) [m^{-1}]', fw, "bold", fs, 14)

        set(gca, fs, 12)

   
subplot(326)
        plot(acy.dTS.est.c(:,2), diff_c_minus_diff_a(:,i440), 'ko', ms, 4, mfc, 'b')

        grid on

        #yrng = [-0.003 0.003];
        ylim(yrng)
        xlim(xrngS)

        xlabel('c-est S [-]', fw, 'bold', fs, 12)
        #ylabel('diff(c-a,440) [m^{-1}]', fw, "bold", fs, 14)

        set(gca, fs, 12)

   
    fnout = [DOUTdiff 'scatterplots.png'];
    print("-dpng", fnout)













figure(2, 'visible', 'off')
clf
        plot(real(acy.cy(:,i440)-acy.ay(:,i440)), diff_c_minus_diff_a(:,i440), 'o', ms, 5, mfc, 'auto')

        grid on

        xlabel('cy(440)-ay(440)', fw, 'bold', fs, 20)
        ylabel("\Delta c - \Delta a [m^{-1}]", fw, "bold", fs, 20)

        set(gca, fs, 16)

        axis([-0.01 0.01 -0.01 0.01])
   
    fnout = [DOUTdiff 'diff_vs_acy.png'];
    print("-dpng", fnout)








figure(2, 'visible', 'off')
clf
        plot(real(acy.ay(:,i440)), diff_c_minus_diff_a(:,i440), 'o', ms, 5, mfc, 'auto')

        grid on

        xlabel('ay(440)', fw, 'bold', fs, 20)
        ylabel("\Delta c - \Delta a [m^{-1}]", fw, "bold", fs, 20)

        set(gca, fs, 16)

        
    fnout = [DOUTdiff 'diff_vs_ay440.png'];
    print("-dpng", fnout)



