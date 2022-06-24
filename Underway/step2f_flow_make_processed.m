function flow = step2f_flow_make_processed(flow, dailyfile)

   %tjor: The flow function is used for initialization (it checks if WAP variables are present).
   %       If it is present, it then loads the function and itializaes the output data structure  

   % Global var for step2
   global FN_ROOT_STEP2 


   % check if instrument variable exists in WAPvars
   savefile = [FN_ROOT_STEP2 strsplit(dailyfile.name, "_"){end}];
   if exist(savefile, 'file')
      load(savefile);
   endif
   
   out.flow = flow;
   
   save('-v6', savefile , 'out' )


endfunction
