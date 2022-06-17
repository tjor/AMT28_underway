%load bb3 data and process them
function [bb_3, bb_02, bb_err, ...
      bb_3_bdgt_X, bb_3_bdgt_SF, bb_3_bdgt_Bsw, ...
      bb_3_bdgt_DC, bb_3_bdgt_C, bb_3_bdgt_WE, bb_02_err] = step2b_bb3_amt_make_processed(bb3, uway, dailyfile, idays, bb_opt_lim, CRUISE)

   % Global variables from step2
   global FN_ROOT_STEP2 
   global DIR_FIGS 
   global YYYY

   % Initialize output matrices
   bb_err = [];
   bb_3_bdgt_X = [];
   bb_3_bdgt_WE = [];
   bb_3_bdgt_SF = [];
   bb_3_bdgt_Bsw = [];
   bb_3_bdgt_DC = [];
   bb_3_bdgt_C = [];
   bb_3 = [];
   bb_02 = [];
   bb_02_err = [];
   bb_02b = [];
   Ts = [];
   Ts_u = [];
   Ts_d = [];
   diffe = [];%this is the matrix where we store the step-difference in cp
   flux = [];
   bdgt = [];
   noF = [];
   XXX = [];
   YYY = [];

   %---prepare sst and salinity data to be used in the processing

   %    
   %    %find only unique und.time
   %    [b,itime,j]=unique(und.time);   
   %    tmp_salinity=interp1(und.time(itime), und.sal(itime), amt19.time, 'linear', 35);
   %    salinity=nan(size(tmp_salinity));
   %    salinity(tmp_salinity>31)=tmp_salinity(tmp_salinity>31);
   %    salinity=interp1(amt19.time(~isnan(salinity)), salinity(~isnan(salinity)), amt19.time);


   %    [b,itime,j]=unique(und.time);    
   %    surf_temp=interp1(und.time(itime), und.sst(itime), amt19.time, 'linear', 15);

   %      %--changed on May 11th, 2012---
   %      salinity = amt19.uway.sal;
   %      surf_temp = amt19.uway.sst;
   % 
   %      %---this is needed because there was one day missing in the underway dataset 
   %      %-so I filled that day with the average values collected the previous day (it should not make a big difference in the derived bbp data)	 
   %      salinity(1440*[43:44]+1) = nanmedian(salinity(1440*[42:43]+1));
   %      surf_temp(1440*[43:44]+1) = nanmedian(surf_temp(1440*[42:43]+1)); 
   % 
   %      salinity(1440*[45:46]+1) = nanmedian(salinity(1440*[44:45]+1));
   %      surf_temp(1440*[45:46]+1) = nanmedian(surf_temp(1440*[44:45]+1)); 

   %


   time = bb3.counts.time - y0(YYYY) ;
 
   % Determine times for filtered and unfiltered measurements to be used in
   % calculating calibration independent particle properties
   % Select only times that we have data logged for
   tmp_time = datevec(time);
   tmp_sched = time;
   tmp_time_min = round(tmp_time(:,5)+tmp_time(:,6)/60);
 
   i_tm_fl = (ismember(tmp_time_min, [1:7]) & tmp_sched) ;  %filtered times
   i_tm_uf = (ismember(tmp_time_min, [19:57]) & tmp_sched);  %unfiltered times
   i_tm_fl0 = (ismember(tmp_time_min, [7]) & tmp_sched) ;  %filtered times    



   ##### HARDCODED 2 REMOVE 
   if strcmp(dailyfile.name, 'optics_amt28_295.mat')
       [var_filt i_tm_fl i_tm_uf] = filt_time_exception_295(bb3.counts, flow_v);
   endif
   #333333333333333333
   
   
   figure(1,'visible','off')
   clf
   hold on
   plot(time, bb3.counts.med(:,1), 'o-', 'markersize',4, 'linewidth', 0.5)
   plot(time(i_tm_fl), bb3.counts.med(i_tm_fl,1), 'r*', 'markersize',4, 'linewidth', 0.5)
   plot(time(i_tm_uf), bb3.counts.med(i_tm_uf,1), 'g*', 'markersize',4, 'linewidth', 0.5)
   hold off
   set(gca, 'ylim', bb_opt_lim, 'fontsize', 10)   
   grid on 
   title(num2str(time(1)), 'fontsize', 12)
   fnout =  [DIR_FIGS, 'bb_optics_' lower(CRUISE) '_' num2str(round(time(1))) '.png'];
   print('-dpng', fnout)




   %%%%% extract temperature and salinity from underway data to compute beta_sw             
   %% NOTE: at this point of the processing, the underway time is one day ahead of the time of the optics               
   Salinity = uway.sal;   
   SST = uway.sst;
 
   %initialize structure for results
   bb3.bbp = nan(size((bb3.counts.mean)));
   bb3.err = nan(size((bb3.counts.mean)));
   bb3.rel_err = nan(size((bb3.counts.mean)));
   bb3.bdgt.X = nan(size((bb3.counts.mean)));
   bb3.bdgt.SF = nan(size((bb3.counts.mean)));
   bb3.bdgt.C = nan(size((bb3.counts.mean)));
   bb3.bdgt.Bw = nan(size((bb3.counts.mean)));
   bb3.bdgt.DC = nan(size((bb3.counts.mean)));
   bb3.bdgt.WE = nan(size((bb3.counts.mean)));
 
   %initialize structure for results ("Fl" stands for "filtered measurements")
   bb3_Fl.bbp = nan(size((bb3.counts.mean)));
   bb3_Fl.err = nan(size((bb3.counts.mean)));
   bb3_Fl.rel_err = nan(size((bb3.counts.mean)));
   bb3_Fl.bdgt.X = nan(size((bb3.counts.mean)));
   bb3_Fl.bdgt.SF = nan(size((bb3.counts.mean)));
   bb3_Fl.bdgt.C = nan(size((bb3.counts.mean)));
   bb3_Fl.bdgt.Bw = nan(size((bb3.counts.mean)));
   bb3_Fl.bdgt.DC = nan(size((bb3.counts.mean)));
   bb3_Fl.bdgt.WE = nan(size((bb3.counts.mean)));
 
   %Chi_p factor used
   X = 1.076;    
 
   %    Salinity = 30;
   %    SST = 28;
 
   %compute bbp and its uncertainty
   [bb3.bbp(i_tm_uf,:) bb3.err(i_tm_uf,:) bb3.rel_err(i_tm_uf,:) ...
      bb3.bdgt.X(i_tm_uf,:) bb3.bdgt.SF(i_tm_uf,:) bb3.bdgt.C(i_tm_uf,:) bb3.bdgt.Bw(i_tm_uf,:) bb3.bdgt.DC(i_tm_uf,:) bb3.bdgt.WE(i_tm_uf,:)] =...
      bb3_err_revised(bb3.counts.mean(i_tm_uf,:), bb3.counts.prc(i_tm_uf,:), X, Salinity(i_tm_uf), SST(i_tm_uf));
 
   %compute bbp and its uncertainty for 0.2um filtered data
   %[bb3_Fl.bbp(i_tm_fl,:) bb3_Fl.err(i_tm_fl,:) bb3_Fl.rel_err(i_tm_fl,:) bb3_Fl.bdgt.X(i_tm_fl,:) bb3_Fl.bdgt.SF(i_tm_fl,:) bb3_Fl.bdgt.C(i_tm_fl,:) bb3_Fl.bdgt.Bw(i_tm_fl,:)] =bb3_err_revised_bb3(bb3.counts.med(i_tm_fl,:), bb3.counts.prc(i_tm_fl,:), X);
   [bb3_Fl.bbp(:,:) bb3_Fl.err(:,:) bb3_Fl.rel_err(:,:) ...
      bb3_Fl.bdgt.X(:,:) bb3_Fl.bdgt.SF(:,:) bb3_Fl.bdgt.C(:,:) bb3_Fl.bdgt.Bw(:,:)] =...
      bb3_err_revised(bb3.counts.mean(:,:), bb3.counts.prc(:,:), X, Salinity, SST);
 
   % %---------------------------------------------------------
   % %----- fit hourly 0.2um filtered data to get the ---------
   % %----- background 0.2um bbp signal               ---------
   %---------------------------------------------------------
   t02um = find(i_tm_fl0==1);
 
   bb3.time = time;%(i_tm_uf);
   bb3_Fl.time = time;
   bbp02 = fit_02um_filtered_bbp(t02um, time, bb3_Fl, idays);     % this function is at the end of this script (Fig 2a in D09)
   %---------------------------------------------------------
   %---------------------------------------------------------
   %---------------------------------------------------------
   % %compute median value of <0.2um filtered data
   %     tmp_fi_c=bb3_Fl.bbp(i_tm_fl,:)';
   %     noFilTimes=7;
   %     tmp_fi_c=reshape(tmp_fi_c,3,noFilTimes,size(bb3_Fl.bbp(i_tm_fl,:),1)/noFilTimes);
   %     med_fi_c=median(tmp_fi_c,2);  
   % %     size(tmp_fi_c)
   %     med_fi_c=reshape(med_fi_c,3,size(bb3_Fl.bbp(i_tm_fl,:),1)/noFilTimes)';
   % %      size(med_fi_c)
   % % stop
   %     bb_02b=[bb_02b; [bb3.time(i_tm_fl0) med_fi_c] ];
 
   % ---GRG---
   % select only non-NaN points
   bb3.nn = ~isnan(bb3.bbp(:,1));
   % ---GRG---
   c1 = rmfield(bb3, ['counts']);
 
   savefile = [FN_ROOT_STEP2 strsplit(dailyfile.name, "_"){end}];
   if exist(savefile, 'file')
      load(savefile)
   end
 
   out.bb3.bbp = bb3.bbp;
   out.bb3.bbp_err = bb3.err;
   out.bb3.bdgt.X = bb3.bdgt.X;
   out.bb3.bdgt.SF = bb3.bdgt.SF;
   out.bb3.bdgt.C = bb3.bdgt.C;
   out.bb3.bdgt.Bw = bb3.bdgt.Bw;
   out.bb3.bdgt.DC = bb3.bdgt.DC;
   out.bb3.bdgt.WE = bb3.bdgt.WE;
   out.bb3.X = X;
   out.bb3.SN = 1173;
   valid = find(bbp02.time>0);
   out.bb3.bbp02um = NaN(size(bb3.bbp));
   out.bb3.bbp02um = interp1(bbp02.time(valid), bbp02.x(valid,:), bb3.time);
   out.bb3.bbp02um_err = interp1(bbp02.time(valid), bbp02.x3_err(valid,:), bb3.time);
   out.bb3.bbp_corr = bb3.bbp - out.bb3.bbp02um;
 
   save('-v6', savefile , 'out' )








# the variables below are used to "check things"
 
   bb_3            = [bb_3;[bb3.time, bb3.bbp]];
   bb_err          = [bb_err;[bb3.time, bb3.err]];    
   bb_3_bdgt_X     = [bb_3_bdgt_X;[bb3.time, bb3.bdgt.X]];    
   bb_3_bdgt_SF    = [bb_3_bdgt_SF;[bb3.time, bb3.bdgt.SF]];    
   bb_3_bdgt_Bsw   = [bb_3_bdgt_Bsw;[bb3.time, bb3.bdgt.Bw]];    
   bb_3_bdgt_DC    = [bb_3_bdgt_DC;[bb3.time, bb3.bdgt.DC]];    
   bb_3_bdgt_C     = [bb_3_bdgt_C;[bb3.time, bb3.bdgt.C]];    
   bb_3_bdgt_WE    = [bb_3_bdgt_WE;[bb3.time, bb3.bdgt.WE]];    
   bb_02           = [bb_02;[bbp02.time, bbp02.min]];
   bb_02_err       = [bb_02_err;[bbp02.time, bbp02.x3_err]];
 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % COMMENTED 2019 10 21 FN#
   % This if statement is useless since idays is always a scalar
   % if idays == first_day
      bdgt.X  = [ bb3.bdgt.X ];
      bdgt.SF = [ bb3.bdgt.SF];
      bdgt.C  = [ bb3.bdgt.C ];
      bdgt.Bw = [ bb3.bdgt.Bw];
      bdgt.DC = [ bb3.bdgt.DC];
      bdgt.WE = [ bb3.bdgt.WE];
      noF = [i_tm_uf];
   % else
   %    bdgt.X  = [bdgt.X ; bb3.bdgt.X ];
   %    bdgt.SF = [bdgt.SF; bb3.bdgt.SF];
   %    bdgt.C  = [bdgt.C ; bb3.bdgt.C ];
   %    bdgt.Bw = [bdgt.Bw; bb3.bdgt.Bw];
   %    bdgt.DC = [bdgt.DC; bb3.bdgt.DC];
   %    bdgt.WE = [bdgt.WE; bb3.bdgt.WE];
   %    noF = [noF; i_tm_uf];
   % endif
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
   clear bb3 bbp02 time

      % 

   %figure
   %    semilogy(bb_3(:,1), bb_3(:,2:4), 'o', 'MarkerSize', 2)
   %hold on
   %    semilogy(bb_02(:,1), bb_02(:,2:4), 'o', 'MarkerSize', 2)    
   %    semilogy(filterchanged, ones(size(filterchanged))*0.005, 'ko')
   %    semilogy(casketcleaned, ones(size(casketcleaned))*0.006, 'm*')
   %hold off
   %xlabel('Decimal days since Jan. 1, 2009');
   %ylabel('b_{bp}(\lambda)')
   %axis([285 335 0.0002 0.01])

   % size bb_02
   % figure
   % hold on
   %     semilogy(bb_02(:,1), bb_02(:,2:4), 'o', 'MarkerSize', 2)
   % %     semilogy(bb_02b(:,1), bb_02b(:,2:4), 'o', 'MarkerSize', 4)
   %     semilogy(filterchanged, ones(size(filterchanged))*0.0005, 'ko')
   %     semilogy(casketcleaned, ones(size(casketcleaned))*0.0006, 'm*')
   % hold off
   % xlabel('Decimal days since Jan. 1, 2009');
   % ylabel('b_{bp}<0.2um(\lambda)')
   % axis([285 335 0.0002 0.001])

   % 
   % %plot error budget
   % bbp_var = bb_3_bdgt_Bsw.^2+bb_3_bdgt_C.^2+bb_3_bdgt_DC.^2+bb_3_bdgt_SF.^2+bb_3_bdgt_X.^2+bb_3_bdgt_WE.^2;
   % figure
   % hold on
   % plot(bb_3(:,1), medfilt1(bb_3_bdgt_Bsw(:,3).^2./bbp_var(:,3), 31), 'o', 'markersize', 4)
   % plot(bb_3(:,1), medfilt1(bb_3_bdgt_X(:,3).^2./bbp_var(:,3), 31), 'go', 'markersize', 4)
   % plot(bb_3(:,1), medfilt1(bb_3_bdgt_DC(:,3).^2./bbp_var(:,3), 31), 'ko', 'markersize', 4)
   % plot(bb_3(:,1), medfilt1(bb_3_bdgt_C(:,3).^2./bbp_var(:,3), 31), 'ro', 'markersize', 4)
   % plot(bb_3(:,1), medfilt1(bb_3_bdgt_SF(:,3).^2./bbp_var(:,3), 31), 'mo', 'markersize', 4)
   % plot(bb_3(:,1), medfilt1(bb_3_bdgt_WE(:,3).^2./bbp_var(:,3), 31), 'yo', 'markersize', 4)
   % grid on
   % legend( { '\beta_{sw}' '\chi_p' 'DC' 'C' 'S' 'we'}, 'fontsize', 18)
   % ylabel('\sigma^2_i / \sigma_{tot}^2', 'fontsize', 24, 'fontname', 'New Century Schoolbook')
   % 
endfunction
%-----------------------------------------------
%-----------------------------------------------
%-----------------------------------------------
%-----------------------------------------------
%-----------------------------------------------
%-----------------------------------------------

function bbp02 = fit_02um_filtered_bbp(t02um, time, bb3_Fl, idays)
   global DIR_FIGS
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % COMMENT 2019 10 21 FN
   % In the new version of octave fminsearch accepts only 4 types of options
   % We decided to leave them to their default values
   % See also T_sal_corr_0.m
   %
   %    options = optimset('Display', 'off', 'NonlEqnAlgorithm', 'gn', 'MaxIter' , 20000000, 'MaxFunEvals', 20000, 'TolX', 1e-10, 'TolFun', 1e-10 );
   % options(10) = 2000;%modified for octave
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for iFL = 1:length(t02um)

      if (isnan(bb3_Fl.bbp(t02um(iFL)+3,2))==1)
         % bbp02.x(iFL,1:3) = []  ;  
         % bbp02.x3_err(iFL,1:3) = []  ;  
         % bbp02.time(iFL,1) = [];
         % bbp02.bulk.end(iFL,:) = []; 
         % bbp02.min(iFL,:) = [];  
         % bbp02.min_err(iFL,:) = []   ; 
         continue
      endif
      %--------to handle exceptions 
      add = 0;
      tempo = round(time(1));
      %             if tempo==300 | tempo==331
      %                 add = 1;
      %             elseif  tempo==300
      %                 add = 1;
      % %            elseif  tempo==288
      % %                add = 1;
      %             elseif  tempo>=301 & tempo<=302
      %                 add = 2;
      %             elseif  tempo>=303 & tempo<=307
      %                 add = 4;
      %             end
      %-----------------------
      %pos=[t02um(iFL)+3:t02um(iFL)+11];
      %pos=[t02um(iFL)+3-5:t02um(iFL)+10-4];
      pos = [t02um(iFL) - 6 + add  :  t02um(iFL) + 1 + add];
      %pos=[t02um(iFL)+2:t02um(iFL)+10];
      p0 = [bb3_Fl.bbp(pos(1),2), 500, bb3_Fl.bbp(pos(end),2)];
      %modified for octave
      [medP470(1:3)] = fminsearch(@(x) fit_exp_with_base(x, bb3_Fl.time(pos)-bb3_Fl.time(pos(1)), bb3_Fl.bbp(pos,1)), p0,optimset('MaxFunEvals',2000));  
      [medP526(1:3)] = fminsearch(@(x) fit_exp_with_base(x, bb3_Fl.time(pos)-bb3_Fl.time(pos(1)), bb3_Fl.bbp(pos,2)), p0,optimset('MaxFunEvals',2000));  
      [medPred(1:3)] = fminsearch(@(x) fit_exp_with_base(x, bb3_Fl.time(pos)-bb3_Fl.time(pos(1)), bb3_Fl.bbp(pos,3)), p0,optimset('MaxFunEvals',2000));  
      %[medP656(1:3), fval, flag]=fminsearch(@(x) fit_exp_with_base(x, bb3_Fl.time(pos)-bb3_Fl.time(pos(1)), bb3_Fl.bbp(pos,3)), p0, options);  

      %         %bootstrap the fit to get an error estimate for he parameters
      %             X = bb3_Fl.time(pos)-bb3_Fl.time(pos(1));
      %             Y = bb3_Fl.bbp(pos,2);
      %             
      %             Nbtsrp = 100;%number of bootstrap respampling
      %             %[P, medP, prcrngP, meaP, stdP, medR, prcrngR] = bstrp_bbp02um(X,Y,p0, Nbtsrp);                
      %         %---------------------------------


      if iFL == round(length(t02um)/2)
         close all
         figure(10, 'visible', 'off')
         clf  
         plot(bb3_Fl.time(pos)-bb3_Fl.time(1), bb3_Fl.bbp(pos,1), 'ro');         hold on
         plot(bb3_Fl.time(pos)-bb3_Fl.time(1), bb3_Fl.bbp(pos,1)+bb3_Fl.err(pos,1), 'r-')
         plot(bb3_Fl.time(pos)-bb3_Fl.time(1), bb3_Fl.bbp(pos,1)-bb3_Fl.err(pos,1), 'r-')
         %         plot(bb3_Fl.time([pos, pos(end)+[1:20]])-bb3_Fl.time(1), exp_with_base(medP526(1:3), bb3_Fl.time([pos, pos(end)+[1:20]])-bb3_Fl.time(pos(1))), 'b-')    
         plot(bb3_Fl.time([pos, pos(end)+[1:20]])-bb3_Fl.time(1), exp_with_base(medP470(1:3), bb3_Fl.time([pos, pos(end)+[1:20]])-bb3_Fl.time(pos(1))), 'b-')
         title([num2str(idays),' ', num2str(iFL),' ', num2str(time(1))])
         plot(bb3_Fl.time(:)-bb3_Fl.time(1), bb3_Fl.bbp(:,1), 'k*')
         plot(bb3_Fl.time(pos(end)+7+[1:10])-bb3_Fl.time(1), bb3_Fl.bbp(pos(end)+7+[1:10],1), 'co')
         %plot(bb3_Fl.time(pos(1)-10:pos(1)-3)-bb3_Fl.time(1), bb3_Fl.bbp(pos(1)-10:pos(1)-3,2), 'co')
         [pos(end)-20 pos(end)+20 ];

         %--------------
         if pos(end)-20<0
            axis([bb3_Fl.time(pos(1))-bb3_Fl.time(1) bb3_Fl.time(pos(end)+20)-bb3_Fl.time(1)  -0.0005 0.003   ] )
         else      
            axis([bb3_Fl.time(pos(end)-20)-bb3_Fl.time(1) bb3_Fl.time(pos(end)+20)-bb3_Fl.time(1)  -0.0005 0.003   ] )
         endif
         %--------------

         grid on
         set(gca, 'linewidth', 1)
         hold off

         %--------------
         if ~exist([DIR_FIGS '02um/'])
            system(['mkdir -p ' DIR_FIGS '02um/']);
         endif
         %--------------

         fnsave = [DIR_FIGS '02um/' num2str(idays), '_', num2str(iFL), '_', num2str(time(1)), '_0.2um.png'];

         print('-dpng', fnsave)

      endif

      %store results in a structure for saving later
      %bbp02.x(iFL,1:3)=[medP470(3), medP526(3), medP595(3)];
      bbp02.x(iFL,1:3) = [medP470(3), medP526(3), medPred(3)];

      %bbp02.x_prcrng(iFL,:)=prcrngP;
      %         bbp02.x3_err(iFL,1:3)=median([    sqrt(bb3_Fl.err(pos,1).^2.*(1- bb3_Fl.bdgt.Bw(pos,1))), ...  %here I save the total error minus the error by Bw 
      %                                         sqrt(bb3_Fl.err(pos,1).^2.*(1- bb3_Fl.bdgt.Bw(pos,1))), ...  %(because in deltaS_595.m I do not need the error by Bw)
      %                                         sqrt(bb3_Fl.err(pos,3).^2.*(1- bb3_Fl.bdgt.Bw(pos,3))) ] )  ;

      bbp02.x3_err(iFL,1:3) = median([    sqrt(bb3_Fl.err(pos,1).^2.*(1- bb3_Fl.bdgt.Bw(pos,1))), ...  %here I save the total error minus the error by Bw
         sqrt(bb3_Fl.err(pos,1).^2.*(1- bb3_Fl.bdgt.Bw(pos,1))), ...
         sqrt(bb3_Fl.err(pos,3).^2.*(1- bb3_Fl.bdgt.Bw(pos,3)))  ] )  ;  %(because in deltaS_595.m I do not need the error by Bw)


      %         bbp02.flag(iFL)=flag;
      %         bbp02.fval(iFL)=fval;

      bbp02.time(iFL,1) = (time(pos(end)));
      %bbp02.bulk.beg(iFL,:)=median(bb3_Fl.bbp( pos(1)-10:pos(1)-3,:  ));  %bulk bbp before filtration
      bbp02.bulk.end(iFL,:) = median(bb3_Fl.bbp( pos(end)+7+[1:10],:  ));  %bulk bbp after fitlration
      bbp02.min(iFL,:) = min(bb3_Fl.bbp( pos,:));  %minimal value during filtrationg to be compared to the fitted x(3)  )
      bbp02.min_err(iFL,:) = bbp02.x3_err(iFL,1:3)   ; %min(bb3_Fl.bbp( pos,:));  %minimal value during filtrationg to be compared to the fitted x(3)  )

   endfor

   %         %validation for the fit to 0.2um data 
   %         idays=19; iFL=23
   %        plot(bb3_Fl.time([pos, pos(end)+[1:20]])-bb3_Fl.time(1), exp_with_base(x, bb3_Fl.time([pos, pos(end)+[1:20]])-bb3_Fl.time(pos(1))), 'b-')    

endfunction
