# compute stats for ACs 2 AC9 chl correction
clear all

% Load paths and common variables
run('../input_parameters.m')
global din = [OUT_PROC UWAY_DIR];
global proc_dir = [din 'Processed/'];
global gps_dir = PATH_GPS;
global ts_dir = PATH_TS;
% Create path for saving figures
global fig_dir = [OUT_FIGS,UWAY_DIR];


jday_strs = [{'268'},{'269'},{'270'}]; # these are the days for which we have concurrent measurements of ACs and AC9


chlACs = [];
chlAC9 = [];

for ifn = 1:length(jday_strs)

    dout = [fig_dir jday_strs{ifn} '/'];

    tmp = load([dout 'chlACS_chlAC9_' jday_strs{ifn} '.dat']);
    
    chlACs = [chlACs; tmp(:,1)];
    chlAC9 = [chlAC9; tmp(:,2)];
    
endfor

chlACs2AC9 = [median(chlACs./chlAC9) prcrng(chlACs./chlAC9)];

save("-ascii", [OUT_PROC UWAY_DIR "chlACs2AC9_median_prcrng.dat"], "chlACs2AC9");









