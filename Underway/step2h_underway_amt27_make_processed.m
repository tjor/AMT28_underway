function step2h_underway_amt27_make_processed(jdayin, path_ts, ship_uway_fname,CRUISE)

   % Global variables from step2
   global din
   global proc_dir
   global YYYY

   %din_anc = glob([din '../../Ship_uway/ancillary/' num2str(YYYY) '*']);
   % Get total files saved (uses Surfmetv3; GPS and TSG will have same number of files)
   din_anc = glob([path_ts num2str(YYYY) ship_uway_fname]);

   % Get date and convert to jday
   yr = str2num(cell2mat(din_anc)(:,end-39:end-36));
   mm = str2num(cell2mat(din_anc)(:,end-35:end-34));
   day = str2num(cell2mat(din_anc)(:,end-33:end-32));
   jdays = jday(datenum([yr,mm,day]));
   jdays_str = num2str(jdays);

   fn_saved = glob([din '*mat']);

   idin = find(str2num(jdays_str) == jdayin );

   disp('Processing ship''s underway data...')

   % Fix bug: possibility to have more than one file if ship stops (e.g. Azores 2019)
   % Only one idin needed to retrieve date for the day
   % Multiple files will be read by the various rd_* function
   if length(idin) ~=1
     idin = idin(1);
   endif
   disp(din_anc{idin})
   fflush(stdout);

   %if strcmp(din_anc{idin}, '../../data/Underway/saved/../../Ship_uway/ancillary/2016277')
   %    keyboard
   %end%if

   % read ship's underway data
   % Identify the date
   date_str = datestr(datenum([yr(idin),mm(idin),day(idin)]),'yyyymmdd');
   % Load GPS files
   tmp1 = rd_seatech_gga_discovery(date_str);
   %tmp1 = rd_seatech_gga([din_anc{idin} '/seatex-gga.ACO']);
   tmp2 = rd_oceanlogger_discovery(date_str);
   %tmp2 = rd_oceanloggerJCR([din_anc{idin} '/oceanlogger.ACO']);

   tmp.time = y0(yr(idin))-1+jdays(idin)+[0:1440-1]'/1440; % create daily time vector with one record per minute of the day (24*60=1440)

   %interpolate underway data to one-minute samples
   flds1 = fieldnames(tmp1);
   for ifld1=2:length(flds1) % skips time field
      tmp.(flds1{ifld1}) = nan(size(tmp.time));
      if ~isempty(tmp1.time)
         tmp.(flds1{ifld1}) = interp1(tmp1.time, tmp1.(flds1{ifld1}), tmp.time);
      endif
   endfor

   flds2 = fieldnames(tmp2);
   for ifld2=2:length(flds2) % skips time field
      tmp.(flds2{ifld2}) = nan(size(tmp.time));
      if ~isempty(tmp2.time)
         tmp.(flds2{ifld2}) = interp1(tmp2.time, tmp2.(flds2{ifld2}), tmp.time);
      endif
   endfor

   % save underway ship's data to optics file
   savefile = [proc_dir,'proc_optics_' lower(CRUISE)  '_' jdays_str(idin,:) '.mat'];
   if (exist(savefile))
      load(savefile);
   endif

   out.uway = tmp;

   save('-v6', savefile , 'out' );

   disp('...done')
   disp(' ')

   endfunction
