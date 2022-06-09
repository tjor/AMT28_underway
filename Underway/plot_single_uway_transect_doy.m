function plot_figure(proc_dir, strvar, limits, latlim, fig_dir, units)


   % Load paths
    run('../input_parameters.m')

   % Create date range
    [numdates, strdates, vecdates, jdays] = get_date_range(inidate,enddate);
    yr = vecdates(1);
    
   disp(['Plotting ' strvar]);
   fflush(stdout);

   
   % Get all files
   fnames = glob([proc_dir,'proc_optics*.mat']);
   
   % Initialize figure
   close('all')
   figure(1,'visible','off')
   hold on;
   
   
   
   for ifn = 1:length(fnames)
   
#     disp(fnames{ifn});
    fflush(stdout);
    
      load(fnames{ifn})
      
      if ~strcmp(strvar,'chl') & ~strcmp(strvar,'cp650')
      
         continue;#plot(out.uway.time-y0(yr), eval(["out." strvar]), 'b.', ms, 1)
         
         
         
      elseif strcmp(strvar,'chl')
         try
            chl = medfilt1(chlacs(out.acs),11);  
         catch         
            chl = medfilt1(chlac9(out.ac9.ap),11);
         end_try_catch
         
         semilogy(out.uway.time-y0(yr), chl, 'b.', ms, 1)
         
         
         
         
      elseif strcmp(strvar,'cp650')
         try
            cp650 = medfilt1(out.acs.cp(:,1:126),11);  
         catch         
            cp650 = medfilt1(out.ac9.cp(:,end-2),11);
         end_try_catch
         
         plot(out.uway.time-y0(yr), cp650, 'b.', ms, 0.1)
         
      endif
           
   endfor
   
   
   ylabel([strrep(strvar, "_", "\\_") " " units], fs, 14, fw, 'bold')
   xlabel('decimal doy', fs, 14, fw, 'bold')
   

 xticks = unique(numdates-y0(yr))(1:2:end);

   set(gca, ...
      'ylim',limits, ...
      fw, "bold", ...
      fs, 10, ...
      'xtick', xticks, ...
      'xticklabel', strsplit(sprintf("%3u ", xticks), " ")(1:end-1), ...
      'xlim', [xticks(1)-1 xticks(end)+1])
      
   grid('on')
   
   
   set(gcf, 'paperposition', [0.25 2.5 8 3]);
   
   fnameout = [fig_dir 'total_transect_doy_' strvar '.png'];
   print('-f1',fnameout,'-dpng','-r150')
   close('all')

   