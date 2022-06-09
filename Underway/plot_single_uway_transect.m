function plot_figure(proc_dir, strvar, limits, latlim, fig_dir, units)

   disp(['Plotting ' strvar]);
   fflush(stdout);

   fs = 'fontsize';
   fw= 'fontweight';
   ms = 'markersize';
   
   
   % Get all files
   fnames = glob([proc_dir,'proc_optics*.mat']);
   
   % Initialize figure
   close('all')
   figure(1,'visible','off')
   hold on;
   maxlat = 0;
   
   for ifn = 1:length(fnames)
   
      load(fnames{ifn})
      
      if ~strcmp(strvar,'chl')
         plot(out.uway.lat,out.uway.(strvar),'bo', ms, 2)
         
      else
         try
            chl = medfilt1(chlacs(out.acs),11);  
         catch         
            chl = medfilt1(chlac9(out.ac9.ap),11);
         end_try_catch
         
         semilogy(out.uway.lat,chl,'bo', ms, 2)
         
      endif
      
      if max(abs(out.uway.lat))>maxlat
         maxlat = max(abs(out.uway.lat));
      endif
      
   endfor
   
   maxlat = latlim;
   
   ylabel([strrep(strvar, "_", "\\_") " " units],fs,14, fw, 'bold')
   xlabel('Latitude [degN]',fs,14, fw, 'bold')
   
%    set(gca,'plotboxaspectratio',[2 1 1], ...
   set(gca, ...
      'ylim',limits, ...
      'xlim',[-maxlat maxlat], ...
      'xdir', 'reverse', ...
      fw, "bold", ...
      fs, 14)
      
   grid('on')
   
   
   set(gcf, 'paperposition', [0.25 2.5 8 3]);
   
   fnameout = [fig_dir 'total_transect_' strvar '.png'];
   print('-f1',fnameout,'-dpng','-r150')
   close('all')

   
   
   
   figure(1,'visible','off')
   hold on;
   maxlat = 0;
   
   for i = 1:length(fnames)
      load(fnames{i})
      
      if ~strcmp(strvar,'chl')
         pltvar = out.uway.(strvar);
         
      else
      
         try 
            pltvar = medfilt1(chlacs(out.acs),11);
            set(gca, 'yscale', 'log')
         catch
            pltvar = medfilt1(chlac9(out.ac9.ap),11);
            set(gca, 'yscale', 'log')
          end_try_catch
         
      endif
      
      iN = out.uway.lat>0;
      iS = out.uway.lat<0;
      
      if i == 2
         plot(1000,1000,'bo','markerfacecolor','b', ms, 2)
         plot(1000,1000,'ro','markerfacecolor','r', ms, 2)
         legend('North','South')
         
      endif
      if ~isempty(iN)
         plot(abs(out.uway.lat(iN)),pltvar(iN),'bo', ms, 2)
         
      endif
      
      if ~isempty(iS)
         plot(abs(out.uway.lat(iS)),pltvar(iS),'ro', ms, 2)       
      endif
      
      if max(abs(out.uway.lat))>maxlat
         maxlat = max(abs(out.uway.lat));
      endif
      
   endfor
   
   maxlat = latlim;
   
   
   ylabel([strrep(strvar, "_", "\\_") " " units], fs, 14, fw, 'bold')
   xlabel("Latitude [degN]", fs, 14, fw, 'bold')
   
#    set(gca,'plotboxaspectratio', [2 1 1], ...
   set(gca, ...
      'ylim',limits, ...
      'xlim',[0 maxlat], ...
      fw, "bold", ...
      fs, 14)
      
   set(gcf, 'paperposition', [0.25 2.5 8 3]);
      
   grid('on')
   
   fnameout = [fig_dir 'split_transect_' strvar '.png'];
   print('-f1',fnameout,'-dpng','-r150')
   close('all')
