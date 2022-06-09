function flow = step2f_flow_make_processed(flow,dailyfile)

   % Global var from step2
   global din
   global proc_dir


   % check if instrument variable exists in WAPvars
   savefile = [proc_dir,'proc_',dailyfile.name];

   if (exist(savefile))
      load(savefile)
   endif
   out.flow = flow;

   save('-v6', savefile , 'out' )

