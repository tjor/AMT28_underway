
   clear all

   % Load paths
   run('../input_parameters.m')
   % Build directories
   din = [PATH_DATA UWAY_DIR];
   wapdir = [din DATA_WAPPED UWAY_WAP_SUBDIR];

   % Create date range
   [numdates, strdates, vecdates, jdays] = get_date_range(inidate,enddate);

   
   % List all WAP_extracted files for the hour specified by WAPhour in ../input_parameters.m
   % day is processed is WAP file exists for the WAPhour hour
   % (so ideally processing should/could be done in the morning for day before)
   
   WAPdays = glob([wapdir, WAP_ROOT, '_*MRG*',WAPhour])

   % Define indices of days to be processed
   % Initialize index variable
   ijdays = []; 
   

   % Cycle through all dates
   for i = 1:size(strdates,1)

      % Find indices of file with strdates(i,:) in name
      itmp = find_index_strdate_in_glob(WAPdays,sprintf('%d',jdays(i)));
  
      % itmp must be a 1 element array (one file per daily cast)
      % Return error messages if it is not
      if length(itmp) == 0
         disp(['No underway for day ' sprintf('%d',jdays(i))])
  
      elseif length(itmp) > 1
         disp(['Something wrong with underway on day ' sprintf('%d',jdays(i)) ', ' str2num(length(itmp)) ' files found!!!'])
      
      else
         ijdays = [ijdays, i];

      endif
   endfor

   % Select only jdays with wapped files
   jdays = jdays(ijdays);

   # parallelise using xargs
   % system( ["echo  " num2str(jdays'), "| xargs -n1 octave -qf pass2step1par.m"] )
   % system( ["echo  " num2str(jdays'), "| xargs -P" NProc" -n1 octave -qf pass2step1par.m"] ) 
   system( ["echo  " num2str(jdays'), "| xargs -P 7 -n1 octave -qf pass2step1par.m"] ) % temporary fix - hardcoded NProc

