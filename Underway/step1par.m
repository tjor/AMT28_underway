function step1par(jday)

   % Load paths and common variables
   run('../input_parameters.m')

   din = [PATH_DATA UWAY_DIR];
   wapdir = [din DATA_WAPPED UWAY_WAP_SUBDIR]
   flowdir = [din,DATA_FLOW];
   savedir = [OUT_PROC UWAY_DIR 'Step1/'];

   % Create directory if it does not exists
   if ~exist(savedir,'dir')
      mkdir(savedir)
   endif

   % Create date range
   [numdates, strdates, vecdates, jdays] = get_date_range(inidate,enddate);
   % Get strdates corresponding to jday
   strdate = strdates(jdays==jday,:);

   doy = sprintf('%d',jday);
   % Check if save file exists
   savefile = [savedir, fproc_name , doy, '.mat'];

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Comment 2019 10 18 FN
   % Not sure why this is here, or what function it has
   % commented out!!!
   %
   % % Load savefile if it already exists
   % if exist(savefile)
   %   load(savefile)
   % endif
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %fn1 = [lower(CRUISE) '_*' doy ];  %needed for reading the wapfiles in the next loop below
   fn1 = [WAP_ROOT '_*' doy ];  % needed for reading the wapfiles in the next loop below - accounts for caseb

   % fflush(stdout);

   %---GRG----
   wp = dir([wapdir,fn1, '*19_T_ASCII*']);  %identify each hour of 'iday'

   %break up the name
   for iwp = 1:size(wp,1)
      [token, remainder] = strtok(wp(iwp).name,'.');
      wapfiles{iwp,1} = fn1
      wapfiles{iwp,2} = strtok(remainder,'.');  
      
      % exception to handle two file names on the same day when we swapped ac9 with cstar
      %   ddd = str2num(doy);
      %   HHH = str2num(strtok(remainder,'.'));
      %   if ddd==270 & HHH==11
      %       i270 = strfind(wp(iwp).name, '270')+2;
      %       wapfiles{iwp,1} = [wp(iwp).name(1:i270)];
      %   endif
   endfor

   %---GRG----

   % Initialize variables based on dh8_instruments
   for idh8 = 1:length(dh8_instruments)
       % create structures where data will be stored for all instruments		
       switch dh8_instruments{idh8} 
           case 'acs'
               %-------------------------------------
               % TO DO: MOVE INTO input_parameters
               % Read number of acs wavelengths from calibration file
	       acsNoWL = get_acs_NoWL(D_CAL_FILES, ACS_CAL_FILE_NAME);   
               %-------------------------------------
               acs.raw = bindata_new(strdate, acsNoWL*2);
               acs.anc = bindata_new(strdate, 5);
           case 'acs2'
               %-------------------------------------
               % TO DO: MOVE INTO input_parameters
               % Read from calibration file
               %-------------------------------------
               acsNoWL2 = get_acs_NoWL(D_CAL_FILES, ACS_CAL_FILE_NAME);   	
               acs2.raw = bindata_new(strdate, acsNoWL2*2);
               acs2.anc = bindata_new(strdate, 5);
           case 'ac9'
               ac9.raw = bindata_new(strdate, 9*2)
           case 'bb3'
               bb3.counts = bindata_new(strdate, 3);
           case 'cstar'
               cstar.raw = bindata_new(strdate, 1);
           case 'ctd'
               ctd = bindata_new(strdate, 3);
           case 'clam'
               clam = bindata_new(strdate,10);
           otherwise
               error('Please add the proper case to have the instrument processed')
               keyboard
       endswitch
   endfor
   % We assume that flow will always be there
   flow = bindata_new(strdate, 1);
   flow_v = bindata_new(strdate, 1);

   first_hour = 1
   last_hour = size(wapfiles,1)

   for ihour = first_hour:last_hour  %reads each hour of data and assign the data to their specific structures
   % for ihour = last_hour-1:last_hour  %reads each hour of data and assign the data to their specific structures

      disp([fn1 ' ' (wapfiles{ihour,2})]);
      fflush(stdout);

      %[tmp_pctime, tmp_acs, tmp_bb3 tmp_flow tmp_cstar tmp_ctd tmp_ac9] = ...
      tmp_WAPvars = rd_wap_amt(flowdir, [wapdir wapfiles{ihour,1}], wapfiles{ihour,2},dh8_instruments,dh8_ports);

      % Fill the variable for each instrument
      % And save each variable to the variable to save
      for idh8 = 1:length(dh8_instruments)
          % create structures where data will be stored for all instruments
          switch dh8_instruments{idh8} 

              case 'cstar'
                 tmp_cstar = tmp_WAPvars.cstar;
                 cstar.raw = bindata_merge(cstar.raw, tmp_cstar.time, tmp_cstar.raw(:,[1]));
                 % Save to output var
                 WAPvars.cstar = cstar;
              case 'ctd'
                 tmp_ctd = tmp_WAPvars.ctd;
                 ctd = bindata_merge(ctd, tmp_ctd.time, tmp_ctd.raw(:,:));
                 % Save to output var
                 WAPvars.ctd = ctd;

              case 'ac9' 
                  tmp_ac9 = tmp_WAPvars.ac9;
                  ac9.wv = tmp_ac9.wv;
                  ac9.time = tmp_ac9.time;
                  ac9.raw = bindata_merge(ac9.raw, tmp_ac9.time, tmp_ac9.raw(:,:));
                 % Save to output var
                 WAPvars.ac9 = ac9;

              case 'acs' 
                  tmp_acs = tmp_WAPvars.acs;
                  % AC-S
                  acs.awl = tmp_acs.awl;  
                  acs.cwl = tmp_acs.cwl;
                  acs.a_cal = tmp_acs.a_cal;
                  acs.c_cal = tmp_acs.c_cal;
                  acs.a_T_cal = tmp_acs.a_T_cal;
                  acs.c_T_cal = tmp_acs.c_T_cal;
                  acs.T_bins = tmp_acs.T_bins;
                  acs.anc = bindata_merge(acs.anc, tmp_acs.time, tmp_acs.anc);
                  acs.raw = bindata_merge(acs.raw, tmp_acs.time, tmp_acs.raw(:,:));
                 % Save to output var
                 WAPvars.acs = acs;

              case 'acs2' 
                  tmp_acs2 = tmp_WAPvars.acs2;
                  % AC-S
                  acs2.awl = tmp_acs2.awl;  
                  acs2.cwl = tmp_acs2.cwl;
                  acs2.a_cal = tmp_acs2.a_cal;
                  acs2.c_cal = tmp_acs2.c_cal;
                  acs2.a_T_cal = tmp_acs2.a_T_cal;
                  acs2.c_T_cal = tmp_acs2.c_T_cal;
                  acs2.T_bins = tmp_acs2.T_bins;
                  acs2.anc = bindata_merge(acs2.anc, tmp_acs2.time, tmp_acs2.anc);
                  acs2.raw = bindata_merge(acs2.raw, tmp_acs2.time, tmp_acs2.raw(:,:));
                 % Save to output var
                 WAPvars.acs2 = acs2;

              case 'bb3'
                  tmp_bb3 = tmp_WAPvars.bb3_old;
                  % bb3
                  bb3.counts = bindata_merge(bb3.counts, tmp_bb3.time, tmp_bb3.raw(:,:));
                  % Save to output var
                  WAPvars.bb3 = bb3;

              case 'clam'
                  tmp_clam = tmp_WAPvars.clam;
                  clam = bindata_merge(clam, tmp_clam.time,tmp_clam.raw(:,:));
                  % Save to output var
                  WAPvars.clam = clam;

              otherwise
                  disp('Please add the proper case tho have the instrument processed')
          endswitch
      endfor

      % flow sensors
      tmp_flow = tmp_WAPvars.flow;
      try
         flow = bindata_merge(flow, tmp_flow.time, tmp_flow.Hz(:,:));
         flow_v = bindata_merge(flow_v, tmp_flow.time, tmp_flow.valve(:,:));
         % Save to output var
         WAPvars.flow = flow;
         WAPvars.flow_v = flow_v;
      catch
         disp('No flow data');
         keyboard
      end_try_catch

    endfor

    
    clear ihour
    % ------------------------------------------------------------------------
    % Save data to MAT file for future use
    % ------------------------------------------------------------------------
   if (exist(savefile,"file"))
            tmp_WAPvars = load(savefile);
            % Check if file is different by comparing the index of first available ctd measure
            if min(find(~isnan(WAPvars.ctd.mean(:,1)))) != min(find(~isnan(tmp_WAPvars.WAPvars.ctd.mean(:,1))))
                % If file not the same, then merge the two
                WAPvars = merge_WAPvars(WAPvars,tmp_WAPvars.WAPvars);
            endif
        endif


    disp(['Saving',savefile])
    save('-v6', savefile, 'WAPvars')
    disp('Done!')

    % ------------------------------------------------------------------------
    % In case UWAY_WAP_SUBDIR is not the root directory, core measurements need 
    % to be also saved on root directory
    %-------------------------------------------------------------------------
   % if ~strcmp(UWAY_WAP_SUBDIR,'/')
    %    if strfind(UWAY_WAP_SUBDIR,'ACS')
            % removed acs2 from variables
      %      WAPvars = rmfield(WAPvars,'acs2');
     %   elseif strfind(UWAY_WAP_SUBDIR,'AC9')
            % removed ac9 from variables
       %     WAPvars = rmfield(WAPvars,'ac9');
        %endif
        % New file name in root directory
        %savedir = [OUT_PROC UWAY_DIR];
        %savefile = [savedir, fproc_name , doy, '.mat'];
        % Need to check if file exists
        %if (exist(savefile,"file"))
         %   tmp_WAPvars = load(savefile);
            % Check if file is different by comparing the index of first available ctd measure
          %  if min(find(~isnan(WAPvars.ctd.mean(:,1)))) != min(find(~isnan(tmp_WAPvars.WAPvars.ctd.mean(:,1))))
                % If file not the same, then merge the two
            %    WAPvars = merge_WAPvars(WAPvars,tmp_WAPvars.WAPvars);
           % endif
        %endif
        %disp(['Saving root file ',savefile])
        %save('-v6', savefile, 'WAPvars')
        %disp('Done!')
    %endif

    clear wapfiles
    

endfunction
