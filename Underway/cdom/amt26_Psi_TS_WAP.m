## summarise Psi_T and Psi_S determined for ACS during AMT26


clear all
close all

# load common parameters
common_processing_parameters;



# load AMT results
    load([DOUT "/Output_files/da2dTS4_wap.oct"]);  
    da2dS4 = da2dS4_all';
    dc2dS4 = dc2dS4_all';
 

# load Sullivan et al., 2006
    ts = load("input/da2dTS_Sullivan_etal_2006.dat");  # Sullivan et al., 2006
    da2dT_Setal06 = ts(:,[1,2]);
    da2dS_Setal06 = ts(:,[1,3]);
    da2dT_Setal06 = interp1(da2dT_Setal06(:,1), da2dT_Setal06(:,2), awl)';
    da2dS_Setal06 = interp1(da2dS_Setal06(:,1), da2dS_Setal06(:,2), awl)';
    clear ts

# load Rottgers et al., 2014
    da2dT_Retal14 = load("input/da2dT.CSV");  # Rottgers et al., 2014
    da2dS_Retal14 = load("input/da2dS.CSV");
    da2dT_Retal14 = interp1(da2dT_Retal14(:,1), da2dT_Retal14(:,3), awl)';
    da2dS_Retal14 = interp1(da2dS_Retal14(:,1), da2dS_Retal14(:,3), awl)';
 

# interpolate amt26 resutls to a common set of wavelenths
    wv = [400:2:750]';
    da2dT4 = interp1(awl, da2dT4', wv, 'extrap');
    da2dS4 = interp1(awl, da2dS4, wv, 'extrap');
   
    dc2dT4 = interp1(cwl, dc2dT4', wv, 'extrap');
    dc2dS4 = interp1(cwl, dc2dS4, wv, 'extrap');


# compute stats of Psi from amt26
    
    all_dac2dT = [da2dT4';...
                   dc2dT4'];

    dac2dT.mean     =  mean(all_dac2dT);
    dac2dT.std     =    std(all_dac2dT)/sqrt(size(all_dac2dT,1));
    dac2dT.median  = median(all_dac2dT);
    dac2dT.prcrng  = prcrng(all_dac2dT)/sqrt(size(all_dac2dT,1));



    all_dac2dS = [da2dS4';...
                   dc2dS4'];

    dac2dS.mean     =  mean(all_dac2dS);
    dac2dS.std     =    std(all_dac2dS)/sqrt(size(all_dac2dS,1));
    dac2dS.median  = median(all_dac2dS);
    dac2dS.prcrng  = prcrng(all_dac2dS)/sqrt(size(all_dac2dS,1));


### now a and c separately
    
    all_da2dT = [da2dT4'];

    da2dT.mean     =  mean(all_da2dT);
    da2dT.std     =    std(all_da2dT)/sqrt(size(all_da2dT,1));
    da2dT.median  = median(all_da2dT);
    da2dT.prcrng  = prcrng(all_da2dT)/sqrt(size(all_da2dT,1));
    
    all_dc2dT = [dc2dT4'];

    dc2dT.mean     =  mean(all_dc2dT);
    dc2dT.std     =    std(all_dc2dT)/sqrt(size(all_dc2dT,1));
    dc2dT.median  = median(all_dc2dT);
    dc2dT.prcrng  = prcrng(all_dc2dT)/sqrt(size(all_dc2dT,1));
    


    all_da2dS = [da2dS4'];

    da2dS.mean     =  mean(all_da2dS);
    da2dS.std     =    std(all_da2dS)/sqrt(size(all_da2dS,1));
    da2dS.median  = median(all_da2dS);
    da2dS.prcrng  = prcrng(all_da2dS)/sqrt(size(all_da2dS,1));
    
    all_dc2dS = [dc2dS4'];

    dc2dS.mean     =  mean(all_dc2dS);
    dc2dS.std     =    std(all_dc2dS)/sqrt(size(all_dc2dS,1));
    dc2dS.median  = median(all_dc2dS);
    dc2dS.prcrng  = prcrng(all_dc2dS)/sqrt(size(all_dc2dS,1));






## save results
    save("-binary",  [DOUT "/Output_files/amt26_da2dTS_wap.oct"], "dac2dT", "dac2dS", "da2dT", "da2dS", "dc2dT", "dc2dS", "wv");






### plot stuff
close all
graphics_toolkit("gnuplot");


   figure(2, 'visible', 'off')
     clf
     subplot(211)
     hold on
         plot(wv, da2dT4, 'm', lw, 3)
         plot(wv, dc2dT4, 'c', lw, 3)
        
         plot(awl, da2dT_Setal06, 'b', lw, 5)
         plot(awl, da2dT_Retal14, 'k', lw, 5)
 
     grid on

#    hl = legend({"a", "c", "Sullivan et al 2006", "Rottgers et al 2014"}, "location", "northwest");


    ylim([-0.002 0.02])
    xlim([400 750])

    xlabel('wavelength [nm]', fw, 'bold')
    ylabel('\Psi_T [1/m 1/degC]', fw, 'bold')


    subplot(212)
     hold on
         plot(wv, da2dT4, 'm', lw, 3)
         plot(wv, dc2dT4, 'c', lw, 3)

         plot(awl, da2dT_Setal06, 'b', lw, 6)
         plot(awl, da2dT_Retal14, 'k', lw, 6)
 
     grid on

#    hl = legend("a amt25, Oct  8th", "location", "northwest");

    ylim([-0.0005 0.0015])
    xlim([400 750])

    xlabel('wavelength [nm]', fw, 'bold')
    ylabel('\Psi_T [1/m 1/degC]', fw, 'bold')




    fnout = [DOUT "/Psi_TS/da2dT_dc2dT_amt26_all_wap.png"];
    print("-dpng","-r300", fnout)








   figure(2, 'visible', 'off')
     clf
     subplot(211)
     hold on
         plot(wv, da2dS4, 'm', lw, 3)
         plot(wv, dc2dS4, 'c', lw, 3)

         plot(awl, da2dS_Setal06, 'b', lw, 5)
         plot(awl, da2dS_Retal14, 'k', lw, 5)
 
     grid on

#    hl = legend("a amt25, Oct  8th", "location", "northwest");


    ylim([-0.00075 0.001])
    xlim([400 750])

    xlabel('wavelength [nm]', fw, 'bold')
    ylabel('\Psi_S [1/m 1/S]', fw, 'bold')


    subplot(212)
     hold on
         plot(wv, da2dS4, 'm', lw, 3)
         plot(wv, dc2dS4, 'c', lw, 3)

         plot(awl, da2dS_Setal06, 'b', lw, 5)
         plot(awl, da2dS_Retal14, 'k', lw, 5)

     grid on

#    hl = legend("a amt25, Oct  8th", "location", "northwest");

    ylim([-8e-5 0.00012])
    xlim([400 750])

    xlabel('wavelength [nm]', fw, 'bold')
    ylabel('\Psi_S [1/m 1/S]', fw, 'bold')




    fnout = [DOUT "/Psi_TS/da2dS_dc2dS_amt26_all_wap.png"];
    print("-dpng","-r300", fnout)









   figure(2, 'visible', 'off')
     clf

     hold on
         plot(wv, da2dS4, 'r', lw, 3)
         plot(wv, dc2dS4, 'k', lw, 3)
     grid on

#    hl = legend("a amt25, Oct  8th", "location", "northwest");

    ylim([-8e-5 0.00012])
    xlim([400 750])

    xlabel('wavelength [nm]', fw, 'bold')
    ylabel('\Psi_S [1/m 1/S]', fw, 'bold')




    fnout = [DOUT "/Psi_TS/da2dS_dc2dS_amt26_all_a_vs_c_wap.png"];
    print("-dpng","-r300", fnout)








close all

   figure(2, 'visible', 'off')
     clf
     subplot(211)
     hold on

         plot(wv, da2dT.median, 'r', lw, 5);
#          plot(wv, da2dT.median+da2dT.prcrng, 'r', lw, 2);
#          plot(wv, da2dT.median-da2dT.prcrng, 'r', lw, 2);
         
         plot(wv, dc2dT.median, 'b', lw, 5);
#          plot(wv, dc2dT.median+dc2dT.prcrng, 'c', lw, 2);
#          plot(wv, dc2dT.median-dc2dT.prcrng, 'c', lw, 2);
         
         plot(awl, da2dT_Setal06, 'color', [0 0.5 0], lw, 2)
         plot(awl, da2dT_Retal14, 'k', lw, 2)

        
        labels = {"a","c","Sullivan et al., 2006","Rottgers et al., 2014"}; 
        c = {"\'r\'", "\'b\'", "[0 0.5 0]", "\'k\'"};
        s = [5 5 2 2];
        for ileg = 1:4
            eval(["line([420 435], [1 1]*0.017-0.002*" num2str(ileg-1) ", 'color', " c{ileg} ", lw, " num2str(s(ileg)) ")"]);
            text(450, 0.017-0.002*(ileg-1), labels{ileg}, fs, 13)
        endfor

        ylim([-0.005 0.018])
        xlim([400 750])

        yticks = get(gca, 'ytick');
        yticklabels = strsplit(sprintf("%.4f ", yticks), " ")(1:end-1);
        set(gca, 'yticklabel' , yticklabels, 'box', 'on');
        
#         xlabel('wavelength [nm]', fw, 'bold')
        hy1 = ylabel('{\it\Psi_{  T } }  [1/m 1/degC]', fw, 'bold');
        set(hy1, 'positionmode', 'manual', 'position', [362.     0.00900     0.00000])

        set(gca, 'position', [0.1900   0.6   0.77500   0.33847])

    subplot(212)
     hold on
#          plot(wv, all_da2dT, '-', 'color', [1 0.5 0.5], ms, 3, lw, 2)

         plot(wv, da2dT.median, 'r', lw, 5)
#          plot(wv, da2dT.median+da2dT.prcrng, 'r', lw, 2);
#          plot(wv, da2dT.median-da2dT.prcrng, 'r', lw, 2);

         plot(wv, dc2dT.median, 'b', lw, 5)
#          plot(wv, dc2dT.median+dc2dT.prcrng, 'c', lw, 2);
#          plot(wv, dc2dT.median-dc2dT.prcrng, 'c', lw, 2);
         
         #plot(wv, dac2dT.mean+dac2dT.std, 'r', lw, 2)
         #plot(wv, dac2dT.mean-dac2dT.std, 'r', lw, 2)

         plot(awl, da2dT_Setal06, 'color', [0 0.5 0], lw, 2)
         plot(awl, da2dT_Retal14, 'k', lw, 2)


        
#         for ileg = 1:4
#             eval(["line([420 435], [1 1]*0.0012-0.0002*" num2str(ileg-1) ", 'color', " c{ileg} ", lw, 5)"]);
#             text(450, 0.0012-0.0002*(ileg-1), labels{ileg}, fs, 13)
#         endfor

        ylim([-0.0005 0.0015])
        xlim([400 750])

        yticks = get(gca, 'ytick');
        yticklabels = strsplit(sprintf("%.4f ", yticks), " ")(1:end-1);
        set(gca, 'yticklabel' , yticklabels, 'box', 'on');

        xlabel('wavelength [nm]', fw, 'bold')
        hy2 = ylabel('{\it\Psi_{  T } }  [1/m 1/degC]', fw, 'bold');
        set(hy2, 'positionmode', 'manual', 'position', [362.     0.00050     0.00000])

        set(gca, 'position', [0.1900   0.14000   0.77500   0.33847])


    fnout = [DOUT "/Psi_TS/da2dT_dc2dT_amt26_stats_wap.png"];
    print("-dpng","-r300", fnout)


    # copy figure in paper dir
        ffigs = [DFIGS strsplit(fnout, '/'){end}];
        system(["cp " fnout " " ffigs]);
    






   figure(2, 'visible', 'off')
     clf
     subplot(211)
     hold on
         plot(wv, da2dS.median*1e4, 'r', lw, 5)
         plot(wv, dc2dS.median*1e4, 'b', lw, 5)

         plot(awl, da2dS_Setal06*1e4, lw, 2, 'color', [0 0.5 0])
         plot(awl, da2dS_Retal14*1e4, 'k', lw, 2)

        labels = {"a","c","Sullivan et al., 2006","Rottgers et al., 2014"}; 
        c = {"\'r\'", "\'b\'", "[0 0.5 0]", "\'k\'"};
        s = [5 5 2 2];
        for ileg = 1:4
            eval(["line([420 435], ([1 1]*0.0008-0.0002*" num2str(ileg-1) ")*1e4, 'color', " c{ileg} ", lw, " num2str(s(ileg)) ")"]);
            text(450, (0.0008-0.0002*(ileg-1))*1e4, labels{ileg}, fs, 13)
        endfor

        ylim([-0.0005 0.001]*1e4)
        xlim([400 750])
    
        yticks = get(gca, 'ytick');
        yticklabels = strsplit(sprintf("%.1f ", yticks), " ")(1:end-1);
        set(gca, 'yticklabel' , yticklabels, 'box', 'on');

        ylabel('{\it\Psi_{  S } }\times 10^4  [1/m 1/S]', fw, 'bold')

       set(gca, 'position', [0.1900   0.6   0.77500   0.33847])

    subplot(212)
     hold on
         plot(wv, da2dS.median*1e4, 'r', lw, 5)
         plot(wv, dc2dS.median*1e4, 'b', lw, 5)

         plot(awl, da2dS_Setal06*1e4, lw, 2, 'color', [0 0.5 0])
         plot(awl, da2dS_Retal14*1e4, 'k', lw, 2)

        ylim([-8e-5 0.00012]*1e4)
        xlim([400 750])
    
        yticks = get(gca, 'ytick');
        yticklabels = strsplit(sprintf("%.1f ", yticks), " ")(1:end-1);
        set(gca, 'yticklabel' , yticklabels, 'box', 'on');

        xlabel('wavelength  [nm]', fw, 'bold')
       ylabel('{\it\Psi_{  S } }\times 10^4  [1/m 1/S]', fw, 'bold')


        set(gca, 'position', [0.1900   0.14000   0.77500   0.33847])


    fnout = [DOUT "/Psi_TS/da2dS_dc2dS_amt26_stats_wap.png"];
    print("-dpng","-r300", fnout)



    # copy figure in paper dir
        ffigs = [DFIGS strsplit(fnout, '/'){end}];
        system(["cp " fnout " " ffigs]);









