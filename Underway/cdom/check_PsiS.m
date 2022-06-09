# this script is used to check if Psi_S depends on temperature.

clear all
close all

pkg load nan

warning off

# load common parameters
common_processing_parameters;

graphics_toolkit("gnuplot");

   
load([DOUT "Output_files/acy_dx2dTS_wap.oct"])  



fsz = 14;

# plot estimated salinity vs. observed Delta_T
figure(1)
clf

# subplot(121)
#     plot(acy.dTS.obs(:,2), acy.dTS.est.a(:,2), 'o', lw, 2)
#     
#     xlabel('observed S  [-]', fw, 'bold', fs, fsz)
#     ylabel("estimated S [-]", fw, 'bold', fs, fsz)

#     xlim([20 45])
    
# subplot(132)
#     plot(acy.dTS.obs(:,1), acy.dTS.est.a(:,2), 'rs', lw, 2)
#     
#     xlabel('observed \Delta_T  [degC]', fw, 'bold', fs, fsz)
#     ylabel("estimated S [-]", fw, 'bold', fs, fsz)
# 
# set(gcf, 'paperposition', [0.25   2.50   15.0   6.0])    
subplot(121)
  hold on
#     plot(acy.O2.T, acy.dTS.est.a(:,2), 'rs', lw, 2)
    plot(acy.MQ.T, acy.dTS.est.a(:,2), 'bo', lw, 4)
    
    xlabel('observed T_{MQ}  [degC]', fw, 'bold', fs, fsz)
    ylabel("estimated S [-]", fw, 'bold', fs, fsz)
    
subplot(122)
  hold on
    plot(acy.O2.T, acy.dTS.est.a(:,2), 'rs', lw, 2)
#     plot(acy.MQ.T, acy.dTS.est.a(:,2), 'bo', lw, 2)
    
    xlabel('observed T_{0.2um}  [degC]', fw, 'bold', fs, fsz)
    ylabel("estimated S [-]", fw, 'bold', fs, fsz)

set(gcf, 'paperposition', [0.25   2.50   15.0   6.0])    
    
fnout = [DOUT "figs/PsiS_check_obsDeltaT_vs_estS.png"];
  print("-dpng", "-r300", fnout)
    
    
 
 
 
# compute salinity corrections for all hourly measurements 
    
load([DOUT "/Output_files/amt26_da2dTS_wap.oct"]);  # load d[a,c]2dTS

acy.Sxda2dS = acy.O2.S'.*da2dS.median;

i736 = find(wv==736);    

figure(2)    

    plot(acy.O2.T, acy.Sxda2dS(:,i736), 'o', lw, 4)
    
    xlabel('observed T_{0.2um}  [degC]', fw, 'bold', fs, fsz)
    ylabel("estimated S*da2dS(736) [m^{-1}]", fw, 'bold', fs, fsz)
   
   
fnout = [DOUT "figs/PsiS_check_obsDeltaT_vs_used_da2dS_from_median_da2dS.png"];
  print("-dpng", "-r300", fnout)
    
    
    
    

################################
# correct for DeltaT and cdom to get individual Psi_S


    ay_Tcorr = inline("ay_raw - Delta_T.*da2dT", "ay_raw", "da2dT", "Delta_T");
    cy_Tcorr = inline("cy_raw - Delta_T.*dc2dT", "cy_raw", "dc2dT", "Delta_T");


    acy.a_yS = ay_Tcorr(acy.O2.a-acy.MQ.a, da2dT.median, acy.dTS.obs(:,1)   );
    acy.c_yS = cy_Tcorr(acy.O2.c-acy.MQ.c, dc2dT.median, acy.dTS.obs(:,1)   );

    
    i650 = find(wv==650);    

    clf
    hold on
        plot(acy.O2.T, acy.Sxda2dS(:,i736), 'bo', lw, 4)
        plot(acy.O2.T, acy.a_yS(:,i736), 'rs', lw, 4)

    xlabel('observed T_{0.2um}  [degC]', fw, 'bold', fs, fsz)
    ylabel("estimated S*da2dS(736) [m^{-1}]", fw, 'bold', fs, fsz)
    


    
    
    fnout = [DOUT "figs/PsiS_check_obsDeltaT_vs_measured_da2dS.png"];
        print("-dpng", "-r300", fnout)
    
   
    
    
    
    
    
    
    
