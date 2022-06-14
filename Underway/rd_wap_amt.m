% Routine to read in extracted WAP data at full resolution
%
% Copied from rd_wap_amt28
% Function returns one variable with all instruments in the varaible dh8_instrumentds
%
% WAP extracted file naming convention
%   boum_<YY>_<DDD>_<ID>_<TYPE>.<EXT>
%   <YY> is the year, 06 for this data
%   <DDD> year day number
%   <ID> is the logger and port, e.g. 23 is the third digital port on dh4
%   <TYPE> is the instrument type, e.g. ASCII, BINARY, ACS
%   <EXT> is usually the hour of the day, except when files were not logged
%   in hourly file mode, in which case its a dummy extension, such as
%   ".00a"; a third case is when there are two files for the same hour
%   (logging was interrupted in the middle) in which case the extension can
%   be more than three characters, e.g. ".010a" and ".010b"
%
%   For example: boum_06_232_22_BINARY.019
%
% The files to be read by this routine are specified by supplying the
% "base" filename, e.g. "eqbox_06_232", and extension, e.g. "019".
% The base filename can include directory information.


function WAPvars = rd_wap_amt(flowdir, filename, fileext, dh8_instruments, dh8_ports)

   %global din

   tic
   %disp(' ')
   %disp(['WAP extracted processing started ' datestr(now)])
   %disp(' ')
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Commented 2019 10 18
   % Variables not used anywhere else in the function
   %
   % ddd = str2num(filename(end-2:end));
   % HHH = str2num(fileext);
   % dddHHH = ddd+HHH/24;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % 1) Read flow_meter ascii data
   disp('Read flow')
   try 
      fn_flow = ls([flowdir "*" filename(end-2:end) fileext(2:3) ".log"])    ;

      if exist(fn_flow)
         [tmp_flow] = rd_flow(fn_flow);
         flow.time = datenum([tmp_flow(:,1) tmp_flow(:,2) tmp_flow(:,3) tmp_flow(:,4) tmp_flow(:,5) tmp_flow(:,6)]);
         flow.Hz = tmp_flow(:,9);
         flow.valve = tmp_flow(:,7);
      else
         [tmp_flow] = deal([]) ;
         flow.time = [];
         flow.Hz = [];        
         flow.valve = [];
         
      endif
      % Add to output variable
      WAPvars.flow = flow;
   catch
       disp('No flow data');
       keyboard
   end_try_catch
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % 2) Read all variables in dh8_instruments
   for idh8 = 1:length(dh8_instruments)
       disp(['Read ',dh8_instruments{idh8}])
       port = sprintf('%d',dh8_ports{idh8});

       switch dh8_instruments{idh8}

           case 'bb3'
               % bb3 logged to DH4 ID=2 Port=3 as ASCII text (logged as binary)
               eco_old = ['_2',port,'_ASCII'];

               % Read bb3_old ascii data records using textread
               % Extracted data looks like this...
               % NOTE it is not the vsf, it's the BB3

               %1700    05/07/07    19:49:35    1143        122    1201    135    1241    155    522
               %2720    05/07/07    19:49:36    1143        121    1201    131    1241    145    522
               %3740    05/07/07    19:49:37    1143        120    1201    132    1241    147    522
               %4930    05/07/07    19:49:38    1143        121    1201    130    1241    146    522
               % msec  date        time       therm?     signals refs         
               fn_bb3 = ls([filename eco_old '.' fileext]);

               if exist(fn_bb3)
                  [msec_bb3_old time_bb3_old dat_bb3_old] = rd_ecobb3(fn_bb3);
               else
                  [msec_bb3_old dat_bb3_old,msec_bb3_old] = deal([]) ;
               endif

               % Read bb3_new ascii data records using textread
               % Extracted data looks like this...
               % NOTE it is not the vsf, it's the BB3

               %1700    05/07/07    19:49:35    470        122        532        135        595     155        522
               %2720    05/07/07    19:49:36    470        122        532        135        595     155        522
               %3740    05/07/07    19:49:37    470        122        532        135        595     155        522
               %4930    05/07/07    19:49:38    470        122        532        135        595     155        522
               % msec  date        time        wave    data    wave    data    wave    data        

               %if exist([filename eco_new '.' fileext])
               %    [filename eco_new '.' fileext]
               %    buff = textread([filename eco_new '.' fileext],'%s','delimiter','\n');
               %    size(buff)
               %    %dat_bb3 = repmat(-888,length(buff),3);  % predeclare output data matrix
               %    dat_bb3_new = repmat(-888,length(buff),3);  % predeclare output data matrix
               %    msec_bb3_new = zeros(length(buff),1);    
               %    for kr = 1:length(buff)
               %        rowbuff = sscanf(buff{kr}, '%d %*s %*s %*d   %d %*d   %d %*d   %d %*d')';
               %         %rowbuff(:,2:end)
               %         %size(rowbuff(:,2:end))
               %         %size(dat_bb3(kr,:))
               %        if ~isempty(rowbuff)
               %        %[num2str(kr)  '   '   [filename eco_new '.' fileext] ]
               %            dat_bb3_new(kr,:) = rowbuff(:,2:end);
               %            msec_bb3_new(kr,:) = rowbuff(:,1);
               %        end
               %    end
               %else
               %    [dat_bb3_new,msec_bb3_new] = deal([])
               %end

           case 'cstar'
               % cstar to DH4 ID=2 Port=4 as ASCII text (logged as binary)      
               cstarname = ['_2',port,'_ASCII'];

               %% read cstar data
               fn_cstar = ls([filename cstarname '.' fileext]);
               if exist(fn_cstar)      
                    [msec_cstar, dat_cstar] = rd_cstar(fn_cstar);
               else
                    [msec_cstar, dat_cstar] = deal([]);
               endif

           case 'ac9'
               ac9name = ['_2',port,'_AC9'];        
               % Read AC9 data
               fn_ac9 = ls([filename ac9name '.' fileext]);
               if exist(fn_ac9)      
                        [msec_ac9, araw_ac9, craw_ac9 wv_ac9] = rd_ac9(fn_ac9);
                        ac9.wv = wv_ac9;
               else
                        [msec_ac9, araw_ac9, craw_ac9 wv_ac9] = deal([]);
               endif

           case 'acs'
               acsname = ['_2',port,'_ACS'];

               % WAP extraction "Extract to Engr" with things configured so that 
               % port 21 is an "AC-S" type (and providing its dev file) will 
               % extract the binary acs data and write out a wetview style ascii 
               % file.

               % Read the ac-s ascii data
               fn_acs = ls([filename acsname '.' fileext]);
               if exist(fn_acs)
                   [msec_acs,craw,araw,cwl,awl,anc,c_cal,a_cal,c_T_cal,a_T_cal,T_bins] = rd_acs([fn_acs]);
               else
                   [msec_acs,craw,araw,cwl,awl,anc,c_cal,a_cal,c_T_cal,a_T_cal,T_bins] = deal([]);
               endif

           case 'acs2'
               acsname2 = ['_2',port,'_ACS'];
               % WAP extraction "Extract to Engr" with things configured so that 
               % port 21 is an "AC-S" type (and providing its dev file) will 
               % extract the binary acs data and write out a wetview style ascii 
               % file.

               % Read the ac-s ascii data
               fn_acs2 = ls([filename acsname2 '.' fileext]);
               if exist(fn_acs)
                  [msec_acs2,craw2,araw2,cwl2,awl2,anc2,c_cal2,a_cal2,c_T_cal2,a_T_cal2,T_bins2] = rd_acs(fn_acs2);
               else
                  [msec_acs2,craw2,araw2,cwl2,awl2,anc2,c_cal2,a_cal2,c_T_cal2,a_T_cal2,T_bins2] = deal([]);
               endif

           case 'ctd'
               ctdname = ['_2',port,'_ASCII'];
               %% read sbe45 data
               fn_sbe45 = ls([filename ctdname '.' fileext]);
               if exist(fn_sbe45)
                   [msec_sbe45, T_sbe45, C_sbe45, S_sbe45] = rd_sbe45(fn_sbe45);

               else
                   [msec_sbe45, T_sbe45, C_sbe45, S_sbe45] = deal([]);
               endif

           case 'clam'
               clamname = ['_2',port,'_ASCII'];
               fn_clam = ls([filename clamname '.' fileext]);
               if exist(fn_clam)
                   [msec_clam raw690 raw675 mon690 mon675 a690 a675 Tsample Tmonitor Tboard] = rd_clam(fn_clam);
               else
                   [msec_clam raw690 raw675 mon690 mon675 a690 a675 Tsample Tmonitor Tboard] = deal([]);
               endif

           otherwise
               disp('Please add the proper case tho have the instrument processed')
               keyboard
       endswitch
    endfor
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % 3) Read time from DH8 files
   disp('Read pctime')

   % Host PC clock is logged to ID=1 Port=9 as ASCII text, format described
   % below
   clockname = '_19_*ASCII';

   % Read PC clock ASCII data
   % PC time file looks like ...
   % 9000    08/20/06    23:00:10.200
   % 10000    08/20/06    23:00:11.200
   % 11000    08/20/06    23:00:12.200
   % 12000    08/20/06    23:00:13.200

   fn19 = ls([filename clockname '.' fileext])
   tmp_fn19 = dir(fn19);

   if tmp_fn19.bytes>0
      [MM,DD,YY,hh,mm,sssss] = rd_19(fn19);

      pctime = datenum(2000+YY,MM,DD,hh,mm,sssss); % Assumes year is >2000
      % Clock data is at 1 Hz, determine start and stop times of file
      pctime0 = pctime(1);
      pctime1 = pctime(end);

   else
      disp('No time from DH8, need to read it from somewhere else')
      keyboard
      pctime_minus_bb349time = datenum([00 00 00 6 42 27]) ;

      pctime_from_bb349 =  time_bb3_old + pctime_minus_bb349time;  % corrects bb349 time based on mean difference computed from bb3time_2_pctime.m

      p = polyfit(msec_bb3_old, pctime_from_bb349, 1);

      pctime0 = polyval(p, 0);
      pctime1 = 60*60*1000;  %this is the nyumber of msec in one hour

   endif


   %disp(['  Logging start (pc time) was ' datestr(pctime0)]);
   %disp(['  Logging end (pc time) was ' datestr(pctime1)]);
   %disp(' ')

   % Save time on output variable
   WAPvars.pctime = pctime;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Commented 2019 10 18
   % analogsname do not seem to be used anywhere else in the function
   %
   % % Analog voltages logged to DH4 ID=2 Port=9 as ASCII text
   % tmp_fn_analogs = dir([filename "*_29_*" fileext])  ;
   % if ~isempty(tmp_fn_analogs ) 
   %    %   if exist(ls([filename "*_29_*" fileext]) ) 
   %    %      if tmp_fn_analogs.bytes>0
   %    analogsname = tmp_fn_analogs.name((strfind(tmp_fn_analogs.name,'_')(end)-3  : strfind(tmp_fn_analogs.name,'.')-1));
%  %       analogsname = tmp_fn_analogs(1).name((strfind(tmp_fn_analogs(1).name,'_')(end)-3  : strfind(tmp_fn_analogs(1).name,'.')-1));
   %    %      endif
   % else
   %    analogsname = [];
   % endif
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Commented 2019 10 18
   % fileext should alway be a string, if not:
   % these lines should be moved way earlier (before fileext is used to list files)
   %
   % % Deal with hour parameter -- if numeric, convert to string
   % if isnumeric(fileext)
   %    buf = num2str(fileext(1));
   %    fileext = [repmat('0',1,3-length(buf)) buf];
   % endif
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % 4) Get the delta time for all the other instruments
   %    and save all variables to output variable

   % Now dat_acs, dat_bb3, dat_lisst, dat_flow, and dat_analogs are 
   % matrices containing raw data read from extracted files. Each row is a 
   % data record, with the number of columns corresponding to the number of 
   % variables recorded by the instrument, e.g. 40 columns for the LISST.

   % Next, generate time vectors from pctime0 to pctime1 for each data matrix

   for idh8 = 1:length(dh8_instruments)
       switch dh8_instruments{idh8}

           case 'acs'
               % Calculate delta t's
               dt_acs = (pctime1-pctime0)/size(craw,1);

               % *** acs sampling rate appears to be NOT constant 
               % (look at msec if you don't believe) ... 
               % we know the total time period of this data, and we have the
               % msec time stamp from the data file (which we assume to be correct),
               % so we can find a datenum-style timestamp for each row of araw 
               % (and craw).
               % Assume that pctime0 is when the acs data starts. 
               % Since pctime is only ~second resolution, this leads to a little 
               % uncertainty in absolute timing between instruments. 
               % Oh well. Really should be looking at the T0 file for start
               % and end timing of each datastream.
               acs.time = pctime0 + datenum(0,0,0, 0,0,msec_acs/1000);
               % acs.time = (pctime0:dt_acs:(pctime1-dt_acs))';
               acs.raw = [araw craw];
               acs.awl = awl;
               acs.cwl = cwl;
               acs.anc = anc;
               acs.c_cal = c_cal;
               acs.a_cal = a_cal;
               acs.c_T_cal = c_T_cal;
               acs.a_T_cal = a_T_cal;
               acs.T_bins = T_bins;

               % Save to output variable
               WAPvars.acs = acs;

           case 'acs2'
               dt_acs2 = (pctime1-pctime0)/size(craw2,1);

               acs2.time = pctime0 + datenum(0,0,0, 0,0,msec_acs2/1000);
               % acs.time = (pctime0:dt_acs:(pctime1-dt_acs))';
               acs2.raw = [araw2 craw2];
               acs2.awl = awl2;
               acs2.cwl = cwl2;
               acs2.anc = anc2;
               acs2.c_cal = c_cal2;
               acs2.a_cal = a_cal2;
               acs2.c_T_cal = c_T_cal2;
               acs2.a_T_cal = a_T_cal2;
               acs2.T_bins = T_bins2;

               % Save to output variable
               WAPvars.acs2 = acs2;

           case 'ac9'
               dt_ac9 = (pctime1-pctime0)/size(craw_ac9,1);

               ac9.time = pctime0 + datenum(0,0,0, 0,0,msec_ac9/1000);
               % acs.time = (pctime0:dt_acs:(pctime1-dt_acs))';
               ac9.raw = [araw_ac9 craw_ac9];
               ac9.wv = wv_ac9;

               % Save to output variable
               WAPvars.ac9 = ac9;

           case 'bb3'
               dt_bb3_old = (pctime1-pctime0)/size(dat_bb3_old,1);
               %dt_bb3_new = (pctime1-pctime0)/size(dat_bb3_new,1);

               % Should be using the timestamp that WAP puts as first column
               %bb3.time = (pctime0:dt_bb3:(pctime1-dt_bb3))';
               bb3_old.time = pctime0 + datenum(0,0,0, 0,0,msec_bb3_old/1000);
               bb3_old.raw = dat_bb3_old;

               %bb3_new.time = pctime0 + datenum(0,0,0, 0,0,msec_bb3_new/1000);
               %bb3_new.raw = dat_bb3_new;

               % Save to output variable
               WAPvars.bb3_old = bb3_old;

           case 'cstar'
               dt_cstar = (pctime1-pctime0)/size(dat_cstar,1);

               cstar.time = pctime0 + datenum(0,0,0, 0,0,msec_cstar/1000);
               cstar.raw = dat_cstar;
               
               % Save to output var
               WAPvars.cstar = cstar;

           case 'ctd'
               dt_sbe45 = (pctime1-pctime0)/size(msec_sbe45,1);

               ctd.time = pctime0 + datenum(0,0,0, 0,0,msec_sbe45/1000);
               ctd.raw = [T_sbe45 C_sbe45 S_sbe45];
               
               % Save to output var
               WAPvars.ctd = ctd;

           case 'clam'
               clam.time = pctime0 + datenum(0,0,0, 0,0,msec_clam/1000);
               clam.raw = [msec_clam raw690 raw675 mon690 mon675 a690 a675 Tsample Tmonitor Tboard];
               
               % Save to output var
               WAPvars.clam = clam;

           otherwise
               disp('Please add the proper case tho have the instrument processed')
               keyboard

       endswitch

   endfor


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % 2019 10 18
   % Not sure what to do about these two
   %dt_lisst = (pctime1-pctime0)/size(dat_lisst,1);
   %dt_analogs = (pctime1-pctime0)/size(dat_analogs,1);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   % Display delta t's
   %disp(['  ac-s delta t = ' num2str(dt_acs/datenum([0 0 0 0 0 1]))])
   %%disp(['  LISST-100 delta t = ' num2str(dt_lisst/datenum([0 0 0 0 0 1]))])
   %disp(['  bb3_old delta t = ' num2str(dt_bb3_old/datenum([0 0 0 0 0 1]))])
   %%disp(['  bb3_new delta t = ' num2str(dt_bb3_new/datenum([0 0 0 0 0 1]))])
   %disp(['  analogs delta t = ' num2str(dt_analogs/datenum([0 0 0 0 0 1]))])


   % Need to have wetlabs make the LISST output option in WAP better (would be
   % nice if it was like other instruments: msec timestamp in first column,
   % and then 40 columns of data...
   %lisst.time = (pctime0:dt_lisst:(pctime1-dt_lisst))';
   %lisst.raw = dat_lisst;


   % % Should be using the timestamp that WAP puts as first column
   % %flow.time = (pctime0:dt_flow:(pctime1-dt_flow))';
   % bb3_old.time = pctime0 + datenum(0,0,0, 0,0,msec_bb3_old/1000);
   % bb3_old.raw = dat_bb3_old;


   %disp(['WAP extracted processing ended ' datestr(now)])

endfunction
