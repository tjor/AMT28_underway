%function run_step1par(inidate,enddate)
   % First step to process and plot underway timeseries
   %

   clear all

   % Load paths
   run('../input_parameters.m')
   % Build directories
   din = [PATH_DATA UWAY_DIR];
   wapdir = [din DATA_WAPPED UWAY_WAP_SUBDIR];

   % Create date range
   [numdates, strdates, vecdates, jdays] = get_date_range(inidate,enddate);

   
   % exception to correct unusual file name from jday 300 onward
  
   
   
   % List all WAP_extracted files for the hour specified by WAPhour in ../input_parameters.m
   % day is processed is WAP file exists for the WAPhour hour
   % (so ideally processing should/could be done in the morning for day before)
   
   WAPdays = glob([wapdir, '*_MRG*',WAPhour]); 

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

   % The next one is a long operation
   % Therefore is run using multiple processors
   % These are defined by Nproc in input_parameters.m

   % Processed Nproc days at a time
   for iday = 1:NProc:length(jdays)
      % Check lenght of days to be processed
      if iday+NProc-1<length(jdays)
         nday = NProc-1;
      elseif
         nday = length(jdays)-iday;
      endif

      a = pararrayfun(  NProc, @step1par, jdays(iday+[0:nday]),"ErrorHandler", @errorFunc) ; % NEED TO ADD ERRORHANDLER OTHERWISE YOU CANT SEE ALL ERRORS!!!!!

   endfor
