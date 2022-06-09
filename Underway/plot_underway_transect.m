% Plot lat transect of given underway variable

clear all

% Load paths
run('../input_parameters.m')
din = [OUT_PROC UWAY_DIR];
proc_dir = [din 'Step2/'];
fig_dir = [OUT_FIGS,UWAY_DIR];


plot_single_uway_transect(proc_dir,'air_temp',trans_SST,latlim,fig_dir, '[degC]');
plot_single_uway_transect(proc_dir,'sst',trans_SST,latlim,fig_dir, '[degC]');
plot_single_uway_transect(proc_dir,'sal',trans_SSS,latlim,fig_dir, '[-]');
plot_single_uway_transect(proc_dir,'chl',trans_chl,latlim,fig_dir, '[mg/m3]');
plot_double_uway_transect(proc_dir,'air_temp','sst',trans_SST,latlim,fig_dir, '[degC]');
% plot_single_uway_transect_doy(proc_dir,'chl',trans_chl, latlim, fig_dir, '[mg/m3]');
% plot_single_uway_transect_doy(proc_dir,'cp650',trans_cp650, latlim, fig_dir, '[1/m]');

% function plot_figure(proc_dir,strvar,limits,fig_dir)
%    disp(['Plotting ' strvar]);
%    fflush(stdout);
%    % Get all files
%    fnames = glob([proc_dir,'proc_optics*.mat']);
%    % Initialize figure
%    close('all')
%    figure(1,'visible','off')
%    hold on;
%    maxlat = 0;
%    for i = 2:length(fnames)
%       load(fnames{i})
%       if ~strcmp(strvar,'chl')
%          plot(out.uway.lat,out.uway.(strvar),'bo')
%       else
%          chl = medfilt1(chlacs(out.acs),11);
%          plot(out.uway.lat,chl,'bo')
%       endif
%       if max(abs(out.uway.lat))>maxlat
%          maxlat = max(abs(out.uway.lat));
%       end
%    endfor
%    maxlat=40;
%    title(strvar,'fontsize',14)
%    xlabel('Latitude','fontsize',14)
%    set(gca,'plotboxaspectratio',[2 1 1], ...
%       'ylim',limits, ...
%       'xlim',[-maxlat maxlat], ...
%       'fontsize',14)
%    grid('on')
%    fnameout = [fig_dir 'total_transect_' strvar '.png'];
%    print('-f1',fnameout,'-dpng','-r150')
%    close('all')
% 
%    figure(1,'visible','off')
%    hold on;
%    maxlat = 0;
%    for i = 2:length(fnames)
%       load(fnames{i})
%       if ~strcmp(strvar,'chl')
%          pltvar = out.uway.(strvar);
%       else
%          pltvar = medfilt1(chlacs(out.acs),11);
%       endif
%       iN = out.uway.lat>0;
%       iS = out.uway.lat<0;
%       if i == 2
%          plot(1000,1000,'bo','markerfacecolor','b')
%          plot(1000,1000,'ro','markerfacecolor','r')
%          legend('North','South')
%       endif
%       if ~isempty(iN)
%          plot(abs(out.uway.lat(iN)),pltvar(iN),'bo')
%       end
%       if ~isempty(iS)
%          plot(abs(out.uway.lat(iS)),pltvar(iS),'ro')
%       end
%       if max(abs(out.uway.lat))>maxlat
%          maxlat = max(abs(out.uway.lat));
%       end
%    endfor
%    maxlat=40;
%    title(strvar,'fontsize',14)
%    xlabel('Latitude','fontsize',14)
%    set(gca,'plotboxaspectratio',[2 1 1], ...
%       'ylim',limits, ...
%       'xlim',[0 maxlat], ...
%       'fontsize',14)
%    grid('on')
%    fnameout = [fig_dir 'split_transect_' strvar '.png'];
%    print('-f1',fnameout,'-dpng','-r150')
%    close('all')
