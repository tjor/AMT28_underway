function [DTs, aTbcorr ] = T_sal_corr_0_rafael(acs, idays, nn, iap)

global dac2dTS
global Yt Ysa
global a b refNIR NIR 
global fval
global errO



%refNIR = find(acs.wl>=714,1);  %reference wavelength in the NIR (730nm)
refNIR = find(acs.wl>=714,1);  %reference wavelength in the NIR (730nm)
NIR = find(acs.wl>=710 & acs.wl<=740);  %spectral range for optimization (710:740nm)
Yt = dac2dTS(NIR,2)';
s_Yt = dac2dTS(NIR,3)'./sqrt(4);  %see Sullivan et al 2006
Ysa = dac2dTS(NIR,6)';
s_Ysa = dac2dTS(NIR,7)';





    
    
    %find DT and Ds s.t. ap(710:750) is spectrally flat and approx equal to zero



    %apply Tsb-correction to each spectrum(1:nn)

    if (acs.int.ap(nn(iap),NIR(1))~=NaN & acs.int.bp(nn(iap),NIR(1))~=NaN)
        
        a = acs.int.ap(nn(iap),NIR);
        b = acs.int.bp(nn(iap),NIR);

%       plot(acs.wl, acs.int.ap(nn(iap),:))
            


        %fit only T and plot the 2D error function
%         options = optimset('Display', 'off', 'NonlEqnAlgorithm', 'gn', 'MaxIter' , 20000000, 'MaxFunEvals', 20000, 'TolX', 1e-8, 'TolFun', 1e-8 );

%% options(1) - Show progress (if 1, default is 0, no progress)
%% options(2) - Relative size of simplex (default 1e-3)
%% options(6) - Optimization algorithm
%%    if options(6)==0 - Nelder & Mead simplex (default)
%%    if options(6)==1 - Multidirectional search Method
%%    if options(6)==2 - Alternating Directions search
%% options(5)
%%    if options(6)==0 && options(5)==0 - regular simplex
%%    if options(6)==0 && options(5)==1 - right-angled simplex
%%       Comment: the default is set to "right-angled simplex".
%%         this works better for me on a broad range of problems,
%%         although the default in nmsmax is "regular simplex"
%% options(10) - Maximum number of function evaluations


%         options = optimset( "MaxIter" , 20000000, "MaxFunEvals", 20000, "TolX", 1e-8 );
        options(1) = 0;
        options(2) = 1e-3;                %2

        options(5) = 1;                  %5   default is set to "right-angled simplex"
        options(6) = 0;                   %6   default is set to "right-angled simplex"

        options(10) = 20000;;              %10

%         [DTs, fval, exitflag] = fminsearch(@f_Ts, [0], options);   %without salinity
        [DTs, fval] = fminsearch(@f_Ts, [0], options);   %without salinity



%           T=[-1:.005:1];
%           for im=1:length(T)
%               out(im)=f_Ts(T(im));
%           end
%           figure(1)
%           plot(T, out, '-')
%           hold on
% %             plot(DTs(1), fval, 'ko', DTs(1), fval, 'k+')
% %             plot(DTs2, fval+errO, 'r+')
% %             plot(DTs3, fval+errO, 'g+')
% %             hold off
% %             xlabel('T')
%           grid on
%           axis([-.3 .3 0 0.01])
% % %           

            
            
            aTbcorr = acs.int.ap(nn(iap),:)      -dac2dTS(:,2)'    *DTs(1)  - ...
                                     (  acs.int.ap(nn(iap),refNIR) -dac2dTS(refNIR,2)*DTs(1)  ) * ... 
                                      acs.int.bp(nn(iap),:)/acs.int.bp(nn(iap),refNIR);
            
%           figure(2)
%           hold off
%           plot(acs.wl, acs.int.cp(nn(iap),:))
%           hold on
%           plot(acs.wl, aTbcorr, 'r')
% % %       
% %         
%       pause           
            
            
            
        %[idays iap DTs]
    end
    
    
    
    
    
    
% %show example of Tb-correction    
%   figure(1)
%   clf
% %     plot(acs.wl(:), acs.int.ap(nn(iap),:), 'k')
% %     plot(acs.wl(:), acs.int.ap(nn(iap),refNIR).*acs.int.bp(nn(iap),:)./acs.int.bp(nn(iap),refNIR), 'b')
% %     plot(acs.wl(:), acs.int.ap(nn(iap),:)- acs.int.ap(nn(iap),refNIR).*acs.int.bp(nn(iap),:)./acs.int.bp(nn(iap),refNIR), 'r');%  
%   
%   plot(acs.wl(:), acs.Tsb_corr.ap(nn(iap),:)./acs.Tsb_corr.ap(nn(iap),76) , 'r');%   
%   grid('on')
%   axis([400 750 8])

%   figure(2)
%   clf
% %     plot(acs.wl(:), acs.int.ap(nn(iap),:), 'k')
% %     plot(acs.wl(:), acs.int.ap(nn(iap),refNIR).*acs.int.bp(nn(iap),:)./acs.int.bp(nn(iap),refNIR), 'b')
% %     plot(acs.wl(:), acs.int.ap(nn(iap),:)- acs.int.ap(nn(iap),refNIR).*acs.int.bp(nn(iap),:)./acs.int.bp(nn(iap),refNIR), 'r');%  
%   
%   plot(acs.wl(:), acs.Tsb_corr.ap(nn(iap),:) , 'b');%   
%   grid('on')
%   axis([400 750 0 .025])

% %example of correction with Dt=0 or DT retrieved from ap(NIR)  DAY=16
%   %apply Tbcorrection: DT=0
%   for iDT=1:length(nn)
%       if (acs.bcorr.ap(nn(iDT),NIR(1))==NaN)
%           continue
%       end
%       
%       a=  acs.bcorr.ap(nn(iDT),NIR);
%       b=    acs.int.bp(nn(iDT),NIR);
%   
%       DT(iDT)=0;
%       
%       acs.Tbcorr.ap2(nn(iDT),:)=acs.bcorr.ap(nn(iDT),:) -dac2dTS(:,2)'*DT(iDT)  + (dac2dTS(refNIR,2)*DT(iDT)/acs.int.bp(nn(iDT),refNIR)) *acs.int.bp(nn(iDT),:);
%   end
%   
%   figure(1)
%   hold off
%   plot(acs.wl(:), acs.int.ap(nn(:),:), 'k')
%   axis([400 750 -.01 0.03])
%   
%   figure(2)
%       plot(acs.wl(:), acs.Tbcorr.ap2(nn(:),:) , 'k');%   
%   grid('on')
%   axis([400 750 -.01 0.03])

%   figure(3)
%       plot(acs.wl(:), acs.Tbcorr.ap(nn(:),:) , 'k');%   
%   grid('on')
%   axis([400 750 -.01 0.03])
    
    



end
