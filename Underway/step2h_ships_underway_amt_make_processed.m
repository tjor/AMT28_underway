function tmp = step2h_ships_underway_amt_make_processed(doy, DIR_GPS, GLOB_GPS, FN_GPS, FNC_GPS, DIR_METDATA, GLOB_METDATA, FN_METDATA, FNC_METDATA)
	
   % tjor: The `ships underway’ function loads the ships meteorological data. There are some hard-coded inputs to this function that are supplied in input_parameters.m. For AMT 28  	 these were: 

	%GLOB_GPS = "2018\*"; 

	%FN_GPS = "seatex-gga.ACO"; 

	%FNC_GPS = @rd_seatech_gga; 

	%GLOB_METDATA = "2018\*"; 

   global YYYY
   global DIR_STEP1
   global FN_ROOT_STEP2

   % Get total files saved (uses Surfmetv3; GPS and TSG will have same number of files)
   din_gps = glob([DIR_GPS GLOB_GPS num2str(doy)]);
   if length(din_gps)>1
      disp('found more than one file');
      keyboard()
   endif

   din_met = glob([DIR_METDATA GLOB_METDATA num2str(doy)]);
   if length(din_met)>1
      disp('found more than one file');
      keyboard()
   endif

#   disp([din_gps{1}, "\n" din_met{1}])
#      fflush(stdout);


      % read ship's underway data
      % Load GPS files
      tmp1 = FNC_GPS([din_gps{1} '/' FN_GPS]);
      tmp2 = FNC_METDATA([din_met{1} '/' FN_METDATA]);

      % create daily time vector with one record per minute of the day (24*60=1440)
      tmp.time = y0(YYYY)-1 + doy + [0:1440-1]'/1440; # time vector to match 1-min binned optics data 

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
      savefile = [FN_ROOT_STEP2 num2str(doy) '.mat'];
      if (exist(savefile))
         load(savefile);
      endif

      out.uway = tmp;

      save('-v6', savefile , 'out' );


   endfunction
