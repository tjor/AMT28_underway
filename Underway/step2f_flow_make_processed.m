function flow = step2f_flow_make_processed(flow, dailyfile)

   % Global var from step2
   global DIR_STEP2


   % check if instrument variable exists in WAPvars
   savefile = [DIR_STEP2, 'proc_', dailyfile.name];

   if (exist(savefile))
      load(savefile)
   endif
   out.flow = flow;

   save('-v6', savefile , 'out' )

