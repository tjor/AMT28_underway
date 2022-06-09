function [time_ms, a, c wv ] = rd_ac9(fn)
# [ac9.time_ms, ac9.a, ac9.c ac9.wv]  = rd_ac9(fn)
#


   fid = fopen(fn, "r");
   
       for ihdr = 1:31
            fgets(fid);
       endfor

       fmt = [repmat("%f ", 1, 24) "\n"];        
       tmp = fscanf(fid, fmt, [24, Inf])';

    fclose(fid);




   if ~isempty(tmp)
      time_ms = tmp(:,1);
      a = [tmp(:,8:10), tmp(:,14:16), tmp(:,2:4)];
      c = [tmp(:,17:19), tmp(:,5:7), tmp(:,11:13)];
   else
      [time_ms, a, c]= deal([]);
   end
      
   wv = [412 440 488 510 532 554 650 676 715];



endfunction

