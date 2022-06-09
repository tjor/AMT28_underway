function plot_TS_fluo
   % Plot TS scatterplot with colorbar from fluorescence values
   %
   % Load paths
   run('../input_parameters.m')
   din = [OUT_PROC UWAY_DIR];
   proc_dir = [din 'Processed/'];
   PATH_UWAY_PROC = proc_dir;    % Output directory for processed oct and mat files
   
   % Initialize figure
   close('all')
   figure(1,'visible','off')
   hold on
   % Get saved processed files
   files = glob([PATH_UWAY_PROC,'proc_optics*.mat']);
   SST= [];
   SSS=[];
   for i=7:length(files)
      disp(files{i})
      fflush(stdout);
      load(files{i})
      chl = medfilt1(chlacs(out.acs),11);
      sst = out.uway.sst;
      sss = out.uway.sal;
      ibad = isnan(sss+sst+chl);
      sst = sst(~ibad);
      sss = sss(~ibad);
      chl = chl(~ibad);
      % Get only moving positions
      dlat = diff(out.uway.lat);
      dlat = [dlat;dlat(end)];
      vmin = -0.002;
      dlat = dlat(~ibad);
      stat_sst = sst(dlat>=vmin);
      stat_sss = sss(dlat>=vmin);
      sst =sst(dlat<vmin);
      sss =sss(dlat<vmin);
      chl =chl(dlat<vmin);
      SSS = [SSS;sss];
      SST = [SST;sst];
      plot(sss,sst,'color',[.3,.3,.3])
      % Plot fields
      for ii =1:50:length(sst)
         if ii+50<length(sst)
            scatter(sss(ii:ii+50),sst(ii:ii+50),[],chl(ii:ii+50))
         else
            scatter(sss(ii:end),sst(ii:end),[],chl(ii:end))
         end
      end
      scatter(stat_sss,stat_sst,[],'k')
   end
   Smax = 38;
   Smin = 34.5;
   Tmin = 24;
   Tmax = 29;
   xlim([Smin Smax])
   ylim([Tmin Tmax])
   caxis([0, 0.3])
   xlabel('Salinity (psu)')
   ylabel('Temperature (degC)')
   colorbar('ylabel','Chla')
   print -dpng test_scatter_v2.png

   keyboard

   % % Get 2d histogram
   % N =20;
   % dS = Smin:(Smax-Smin)/(N-1):Smax;
   % dT = Tmin:(Tmax-Tmin)/(N-1):Tmax;
   % hist2d = zeros(length(dS),length(dT));
   % for iS = 1:length(dS)-1
   %    for iT = 1:length(dT)-1
   %       hist2d(iT,iS) = length(find(SSS>=dS(iS) & SSS<=dS(iS+1) & SST>=dT(iT) & SST<=dT(iT+1)));
   %    end
   % end
   % close('all')
   % pcolor(dS+(Smax-Smin)/(N-1)/2,dT+(Tmax-Tmin)/(N-1)/2,hist2d)
   % shading flat
   % caxis([0 500])
   % colormap('jet')
   % colorbar
   % keyboard



