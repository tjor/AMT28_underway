# Implement Salde et al (2010) scattering and residual temperature corrections
# and propagate uncertainties
function [DTs, aTbcorr, ap_err, cp_err ] = T_sal_corr_0(acs, idays, i_nn, iap)

global dac2dTS
global Yt Ysa
global a b i_refNIR i_NIR 
global fval
global errO

global DIR_FIGS

i_refNIR = find(acs.wl>=730,1);  % index of reference wavelength in the NIR (730nm)
i_NIR = find(acs.wl>=710 & acs.wl<=740);  % indices of spectral range for optimization (710:740nm)

Yt = dac2dTS(i_NIR,2)'; # Yt = Psi_t (the T-dependence coeffs of pure H2O absorption ) in Slade et al 2010
s_Yt = dac2dTS(i_NIR,3)'./sqrt(4);  % see Sullivan et al 2006 (this is the uncertainty of Yt)
Ysa = dac2dTS(i_NIR,6)'; # this is the salinity dependence of pure H2O absorption
s_Ysa = dac2dTS(i_NIR,7)'; # uncertainty of Ysa



    
    
    %find DT and Ds s.t. ap(710:750) is spectrally flat and approx equal to zero



    %apply Tsb-correction to each spectrum(1:i_nn)

    if (acs.int.ap(i_nn(iap),i_NIR(1))~=NaN & acs.int.bp(i_nn(iap),i_NIR(1))~=NaN)
        
        a = acs.int.ap(i_nn(iap),i_NIR);
        b = acs.int.bp(i_nn(iap),i_NIR);


        %-----------------------------------------------
        %         'fminsearch' is a function from the file /usr/share/octave/4.2.2/m/optimization/fminsearch.m
        % 
        %  -- X = fminsearch (FUN, X0)
        %  -- X = fminsearch (FUN, X0, OPTIONS)
        %  -- [X, FVAL] = fminsearch (...)
        % 
        %      Find a value of X which minimizes the function FUN.
        % 
        %      The search begins at the point X0 and iterates using the Nelder &
        %      Mead Simplex algorithm (a derivative-free method).  This algorithm
        %      is better-suited to functions which have discontinuities or for
        %      which a gradient-based search such as 'fminunc' fails.
        % 
        %      Options for the search are provided in the parameter OPTIONS using
        %      the function 'optimset'.  Currently, 'fminsearch' accepts the
        %      options: "TolX", "MaxFunEvals", "MaxIter", "Display".  For a
        %      description of these options, see 'optimset'.
        % 
        %      On exit, the function returns X, the minimum point, and FVAL, the
        %      function value thereof.
        % 
        %--------------------------
        % From optimset
        %--------------------------
        %      TolX
        %           Termination criterion for the function input.  If the
        %           difference in X, the current search point, between one
        %           algorithm iteration and the next is less than 'TolX' the
        %           optimization stops.  Must be a positive scalar.
        %
        %      MaxFunEvals
        %            Maximum number of function evaluations before optimization
        %            stops.  Must be a positive integer.
        %
        %      MaxIter
        %           Maximum number of algorithm iterations before optimization
        %           stops.  Must be a positive integer.
        %
        %      Display
        %            Request verbose display of results from optimizations.  Values
        %            are:

        %            "off" [default]
        %                 No display.

        %            "iter"
        %                 Display intermediate results for every loop iteration.

        %            "final"
        %                 Display the result of the final loop iteration.

        %            "notify"
        %                 Display the result of the final loop iteration if the
        %                 function has failed to converge.
        %-----------------------------------------------

        % run minimisation to find DTs, which is \DeltaT in Slade et al 2010
        [DTs, fval] = fminsearch(@f_Ts, [0]);    %without salinity
        
        % apply correction to ap
        aTbcorr = acs.int.ap(i_nn(iap),:)      -dac2dTS(:,2)'    *DTs(1)  - ...
                                     (  acs.int.ap(i_nn(iap),i_refNIR) -dac2dTS(i_refNIR,2)*DTs(1)  ) * ... 
                                      acs.int.bp(i_nn(iap),:)/acs.int.bp(i_nn(iap),i_refNIR); # eq 5 in Slade et al., 2010
            
        % compute uncertainties
        [ap_err, cp_err] = acp_err(  acs.int.ap(i_nn(iap),:),     acs.int.cp(i_nn(iap),:), ...
                                     DTs(1),          dac2dTS(:,2), ...
                                     acs.int.ap_u(i_nn(iap),:),   acs.int.cp_u(i_nn(iap),:), ...
                                     DTs(1)*0.5,     dac2dTS(:,3), ...
                                     i_refNIR, ...
                                     iap,...
                                     acs);






            
    endif
    


endfunction





function [ap_err, cp_err] = acp_err(ap0,   cp0,   DT,   PSI,   ...
                                   ap0_u, cp0_u, DT_u, PSI_u, ...
                                   iref,...
                                   iap,...
                                   acs) 

global DIR_FIGS                           
                           
PSI = PSI(:)';
PSI_u = PSI_u(:)';

bp0 = cp0 - ap0;
bp0_u = sqrt(cp0_u.^2 + ap0_u.^2);


ap = ap0 - PSI * DT - (ap0(iref) - PSI(iref)*DT) * bp0/bp0(iref);
cp = cp0 - PSI * DT;


% compute ap uncertainty
da2dap0     = 1;
da2dap0_ref = 0;
da2dPSI     = -DT + DT*bp0/bp0(iref);
da2dPSI_ref = 0;
da2dbp0     = -(ap0(iref) - PSI(iref)*DT) / bp0(iref);
da2dbp0_ref = 0;
da2dDT      = -PSI + PSI.*bp0/bp0(iref);

ap_var_ap0      = (da2dap0 .* ap0_u).^2;
ap_var_ap0ref   = (da2dap0_ref .* ap0_u(iref)).^2;
ap_var_PSI      = (da2dPSI .* PSI_u).^2;
ap_var_PSIref   = (da2dbp0 .* PSI_u(iref)).^2;
ap_var_bp0      = (da2dbp0 .* bp0_u).^2;
ap_var_bp0ref   = (da2dbp0_ref .* bp0_u(iref)).^2;
ap_var_DT       = (da2dDT .* DT_u).^2;

ap_var = ap_var_ap0 + ...
         ap_var_ap0ref + ...
         ap_var_PSI + ...
         ap_var_PSIref + ...
         ap_var_bp0 + ...
         ap_var_bp0ref + ...
         ap_var_DT;

ap_err = sqrt(ap_var);


if iap == 1000

   wv = [400:2:750](:)';
   iwv0 = find(wv==650);
  

#   ap_var_ap0(iwv0)
#   ap_var_ap0ref
#   ap_var_PSI(iwv0)    
#   ap_var_PSIref 
#   ap_var_bp0(iwv0)       
#   ap_var_bp0ref 
#   ap_var_DT(iwv0)

   figure(1, 'visible', 'off')
   clf
   hold on
      semilogy(wv, sqrt(ap_var_ap0), ";ap0;", 'linewidth', 2 )
      semilogy(wv, sqrt(ap_var_PSI), ";PSI;", 'linewidth', 2 )
      semilogy(wv, sqrt(ap_var_bp0), ";bp0;", 'linewidth', 2)
      semilogy(wv, sqrt(ap_var_DT), ";\DeltaT;", 'linewidth', 2)

      semilogy(wv, sqrt(ap_var), 'ko;total;', 'markerfacecolor', 'none')
      semilogy(wv, ap, 'r;ap;', 'linewidth', 4)
   set(gca, 'yscale', 'linear')
   ylim([0, 0.03])
   grid('on')
   set(gca, 'gridlinestyle', '--') 
   fnout = [DIR_FIGS, 'ap_var_budget_', datestr(acs.raw.time(iap), "YYYYmmdd"), '.png'];
   print('-dpng', fnout)
   close all   
endif




% compute cp uncertainty
dc2dc0 = 1;
dc2dPSI = -DT;
dc2dDT = -PSI;

cp_var_cp0 = (dc2dc0 .* cp0_u) .^2;
cp_var_PSI = (dc2dPSI .* PSI_u).^2;
cp_var_DT  = (dc2dDT .* DT_u)  .^2;


cp_var = cp_var_cp0 + ...
         cp_var_PSI + ...
         cp_var_DT;

 cp_err = sqrt(cp_var);


if iap == 1000
#   cp_var_cp0(iwv0)
#   cp_var_PSI(iwv0)    
#   cp_var_DT(iwv0)

   figure(1, 'visible', 'off')
   clf
   hold on
      semilogy(wv, sqrt(cp_var_cp0), ";cp0;", 'linewidth', 2 )
      semilogy(wv, sqrt(cp_var_PSI), ";PSI;", 'linewidth', 2 )
      semilogy(wv, sqrt(cp_var_DT), ";\DeltaT;", 'linewidth', 2)

      semilogy(wv, sqrt(cp_var), 'ko;total;', 'markerfacecolor', 'none')
      semilogy(wv, cp, 'r;ap;', 'linewidth', 4)
   set(gca, 'yscale', 'linear')
   ylim([0, 0.2])
   grid('on')
   set(gca, 'gridlinestyle', '--') 
   fnout = [DIR_FIGS, 'cp_var_budget_', datestr(acs.raw.time(iap), "YYYYmmdd"), '.png'];
   print('-dpng', fnout)
   close all   
endif

endfunction
