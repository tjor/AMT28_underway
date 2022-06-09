function step2f_ctd_make_processed(ctd,dailyfile)

   % Global var from step2
   global din
   global proc_dir


   % check if instrument variable exists in WAPvars
   savefile = [proc_dir,'proc_',dailyfile.name];

   if (exist(savefile))
      load(savefile)
   endif
   out.ctd = ctd;

   save('-v6', savefile , 'out' )

