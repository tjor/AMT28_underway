## extract chl for bob
clear all


din = "../../data/Underway/saved/Processed/";

dout = "../../data/Secchi_power/";

fn = glob([din "*mat"]);

secchi.chl = [];
secchi.cp532 = [];
secchi.time = [];
secchi.lat = [];
secchi.lon = [];


for ifn = 3:length(fn)

    load(fn{ifn});

    out.acs.chl = chlacs(out.acs);


    secchi.chl = [secchi.chl; chlacs(out.acs)];
    secchi.cp532 = [secchi.cp532; out.acs.cp(:,out.acs.wv==532)];
    secchi.time = [secchi.time; out.acs.time];
    secchi.lat = [secchi.lat; out.uway.lat];
    secchi.lon = [secchi.lon; out.uway.lon];


endfor

nnan = find(~isnan(secchi.chl));

out = [datevec(secchi.time(nnan)+y0(2015)) secchi.lat(nnan) secchi.lon(nnan) secchi.chl(nnan) secchi.cp532(nnan)];

fnout = 'yyyy_mm_dd_HH_MM_SS_lat_lon_chl_cp532.txt';

save("-ascii", [dout fnout], 'out');






