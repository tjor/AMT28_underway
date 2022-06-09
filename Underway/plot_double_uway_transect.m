function plot_figure(proc_dir, strvar, strvar2, limits, latlim, fig_dir, units)
   disp(["Plotting " strvar " and " strvar2]);
   fflush(stdout);

   fs = 'fontsize';
   fw= 'fontweight';
   ms = 'markersize';
   
   % Get all files
   fnames = glob([proc_dir,"proc_optics*.mat"]);
   
   % Initialize figure
   close("all")
   figure(1,"visible","off")
   hold on;
   maxlat = 0;
   
   for ifn = 1:length(fnames)
      load(fnames{ifn})
      plot(out.uway.lat,out.uway.(strvar),"bo", ms, 2)
      plot(out.uway.lat,out.uway.(strvar2),"ro", ms, 2)
      if max(abs(out.uway.lat))>maxlat
         maxlat = max(abs(out.uway.lat));
      end
   endfor
   
   legend(strrep(strvar, "_", "\\_"),strrep(strvar2, "_", "\\_"))
   maxlat = latlim;
   
   
   
   ylabel([strrep(strvar, "_", "\\_") " and " strvar2 "\n" units], fs, 14, fw, "bold")
   xlabel("Latitude [degN]", fs, 14, fw, "bold")
   
#    set(gca,'plotboxaspectratio',[2 1 1], ...
   set(gca, ...
      "ylim",limits, ...
      "xlim",[-maxlat maxlat], ...
      "xdir","reverse", ...
      fw, "bold", ...
      fs, 14)
      
   grid("on")
       
   set(gcf, "paperposition", [0.25 2.5 8 3]);
   
   fnameout = [fig_dir "total_transect_" strvar "_" strvar2 ".png"];
   print("-f1",fnameout,"-dpng","-r150")
   close("all")

   
   
   disp(["Plotting " strvar " minus " strvar2]);
   fflush(stdout);
   
   % Get all files
   fnames = glob([proc_dir,"proc_optics*.mat"]);
   
   % Initialize figure
   close("all")
   figure(1,"visible","off")
   hold on;
   maxlat = 0;
   
   for ifn = 1:length(fnames)
      load(fnames{ifn})
      plot(out.uway.lat,out.uway.(strvar)-out.uway.(strvar2),"bo", ms, 2)
      if max(abs(out.uway.lat))>maxlat
         maxlat = max(abs(out.uway.lat));
      end
   endfor
   
   maxlat = latlim;
   
   ylabel([strrep(strvar, "_", "\\_") "-" strrep(strvar2, "_", "\\_") " " units ], fs, 14, fw, "bold")
   xlabel("Latitude [degN]", fs, 14, fw, "bold")
   
#    set(gca,'plotboxaspectratio',[2 1 1], ...
   set(gca, ...
      "ylim",[-4 4], ...
      "xlim",[-maxlat maxlat], ...
      "xdir","reverse", ...
       fw, "bold", ...
       fs, 14)
       
   grid("on")
      
   set(gcf, "paperposition", [0.25 2.5 8 3]);
   fnameout = [fig_dir "total_transect_diff_" strvar "_" strvar2 ".png"];
   print("-f1",fnameout,"-dpng","-r150")
   close("all")
