function step2f_ctd_make_processed(ctd,dailyfile)

   % Global var from step2
   global FN_ROOT_STEP2 


   % check if instrument variable exists in WAPvars
   savefile = [FN_ROOT_STEP2 strsplit(dailyfile.name, "_"){end}];
   if exist(savefile, 'file')
      load(savefile)
   endif
   out.ctd = ctd;

   save('-v6', savefile , 'out' )

