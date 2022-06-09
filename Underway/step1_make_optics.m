
clear all
close all

global din

din = "../../data/Underway/";


flowdir = "../../Uway/Flow/";
wapdir = [din "WAP_Extracted/"];


daynm = glob([wapdir,"amt25_14*MRG*000"]);   %LIST the days we have to process (these are non-extracted files)   

 



for iday = 1:length(daynm)
    
    
    doy = daynm{iday}(end-10:end-8);
    
    savedir = [din "saved/"];
    savefile = [savedir 'optics_amt25_', doy, '.mat'];
    
    if exist(savefile)
        load(savefile)
        
        flowdir = [din "Flow/"];
        wapdir = [din "WAP_Extracted/"];
        savedir = [din "saved/"];
        savefile = [savedir 'optics_amt25_', doy, '.mat'];
        
    endif
    

    
    fn1 = ["amt25_16_",doy]  %needed for reading the wapfiles in the next loop below
    fflush(stdout);
    
  # gmtday = datestr(   y0(2014)+str2num(doy)  -1 );  % the "-1" is needed to match the time read inside the "*_19_ASCII.???" files
    gmtday = datestr(   y0(2016)+str2num(doy)   -1); # the "-1" is needed to match the actual date in which the data were collected
    
    
    %---GRG----
    wp = dir([wapdir,fn1,'*ACS.*']);  %identify each hour of "iday"
    
    
    
    %break up the name
    for iwp = 1:size(wp,1)
        [token, remainder] = strtok(wp(iwp).name,'.');
        wapfiles{iwp,1} = fn1;
        wapfiles{iwp,2} = strtok(remainder,'.');    
    endfor
    %---GRG----
    
    acsNoWL = 74;
    %create structures where data will be stored
    acs.raw = bindata_new(gmtday, acsNoWL*2);
    bb3.counts = bindata_new(gmtday, 3);
    #cstar.volts = bindata_new(gmtday, 2);
    flow = bindata_new(gmtday, 1);
    
    
    
    
       first_hour = 1;
       last_hour = size(wapfiles,1);

    
    for ihour = first_hour:first_hour#last_hour  %reads each hour of data and assign the data to their specific structures
    
        % this part is to save a progrees report file
          out_report = [iday ihour size(wapfiles,1)];
          save -ascii step1_status.txt out_report
    
    
    
             [tmp_pctime, tmp_analogs, tmp_acs, tmp_bb3 tmp_flow] = ...
                          rd_wap_amt24([wapdir wapfiles{ihour,1}], wapfiles{ihour,2});
    
    
    
    %      %read flow sensors
    %      fl_nm  =['amt22_2012' wapfiles{ihour,1}(end-2:end) wapfiles{ihour,2}(2:3) '.log']     
    %      if exist([flowdir fl_nm])
    %          [tmp_flow] = rd_flow([flowdir fl_nm]);
    %      else
    %          [tmp_flow.time tmp_flow.raw] = deal([]);
    %      end
    
    
    
        
        
        % Analogs
    %     chlfl.volts = bindata_merge(chlfl.volts, tmp_analogs.time, tmp_analogs.raw(:,3));
    %     cdmfl.volts = bindata_merge(cdmfl.volts, tmp_analogs.time, tmp_analogs.raw(:,4));
        if ~isempty(tmp_analogs.time)
            cstar.volts = bindata_merge(cstar.volts, tmp_analogs.time, tmp_analogs.raw(:,[1:2]));
        endif
        
        
        % AC-S
        acs.awl = tmp_acs.awl;  
        acs.cwl = tmp_acs.cwl;
        acs.raw = bindata_merge(acs.raw, tmp_acs.time, tmp_acs.raw(:,:));
    
        % LISST-100x
    %    lisst.counts = bindata_merge(lisst.counts, tmp_lisst.time, tmp_lisst.raw(:,:));
    
        % bb3
        bb3.counts = bindata_merge(bb3.counts, tmp_bb3.time, tmp_bb3.raw(:,:));
        
        % bb3_new
        %bb3_new.counts = bindata_merge(bb3_new.counts, tmp_bb3_new.time, tmp_bb3_new.raw(:,:));
        
        % ac9
    %    ac9.wl=tmp_ac9.awl;
    %    ac9.counts = bindata_merge(ac9.counts, tmp_ac9.time, tmp_ac9.raw(:,:));   %<<<<<==========================================
    %
        % flow sensors
        flow = bindata_merge(flow, tmp_flow.time, tmp_flow.Hz(:,:));
    
    
    %     disp('Packing memory...')
        %clear tmp*
    
    
    
    endfor
    clear ihour
    
    
    
    
    % -------------------------------------------------------------------------
    % Data QC
    % -------------------------------------------------------------------------
    
    % ACS Data Quality 
    % (1) questionable data, (2) not operational or under repair, (4) suspect
    % bubbles
    
    % acs.raw.qcflag(acs.raw.time>=datenum('22-Aug-2006 08:30') & acs.raw.time<=datenum('22-Aug-2006 08:35')) = 4;
    % acs.raw.qcflag(acs.raw.time>=datenum('22-Aug-2006 16:35') & acs.raw.time<=datenum('22-Aug-2006 16:40')) = 4;
    
    
    % hold on
    t0 = datenum([2013 12 31 23 59 59.999]);
     figure(1, 'visible', 'off')
     hold on
     plot(acs.raw.time-t0, acs.raw.mean(:,30),'-')
     ylabel('acs.raw.mean(:,30)')
     set(gca, 'ylim', [0 0.4]);
     print -dpng ./output/raw_acs.png
    
    % hold on
    % figure(2)
    % plot(flow.Hz.time-t0, flow.Hz.mean(:,2),'r-')
    % ylabel('flow.Hz.mean(:,3)')
    
    figure(3, 'visible', 'off')
    hold on
    plot(bb3.counts.time-t0, bb3.counts.mean(:,2),'-')
    ylabel('BB3-349 (532 nm)');
    set(gca, 'ylim', [0 200]);
     print -dpng ./output/aw_bb532.png
    
    % hold on
    % figure(4)
    % plot(lisst.counts.time-t0, lisst.counts.mean(:,[1:3: 10 30]),'-')
    % ylabel('lisst');
    
    %hold on
    %figure(5)
    %plot(ac9.counts.time-t0, ac9.counts.mean(:,:),'-')
    %ylabel('ac9');
    
    
    
    
    % -------------------------------------------------------------------------
    % Save data to MAT file for future use
    % -------------------------------------------------------------------------
    
    #save("-v6", savefile, "acs", "bb3", "flow")
    
    clear wapfiles
    
    
    
endfor %iday cycle








% % Default parameters for plots
% set(0, 'DefaultLineLineWidth', 1.5)
% set(0, 'DefaultAxesLineWidth', 0.75)
% set(0, 'DefaultLineMarkerSize', 4)
% set(0, 'DefaultTextFontSize', 10)
% set(0, 'DefaultAxesFontSize', 10)    
% figsize = [8.0 10.5]
% figpos = [0.25 0.25 7.5 10.0]

% figure, hold on
% set(gcf, 'paperunits', 'inches', 'papersize', figsize, 'paperposition', figpos)
% subplot(311)
%     plot(acs.raw.time,acs.raw.mean(:,10),'g-')
%     axis tight
%     ylabel('raw a(440) [1/m]')
%     datetick('keeplimits')
% subplot(312)
%     plot(acs.raw.time,acs.raw.mean(:,83+60),'r-')
%     axis tight
%     ylabel('raw c(675) [1/m]')
%     datetick('keeplimits')
% subplot(313)
%     plot(bb3.lpm.time, bb3.lpm.mean(:,1),'k-')
%     axis tight
%     ylabel('ac-s bb3 rate [L/min]')
%     datetick('keeplimits')




