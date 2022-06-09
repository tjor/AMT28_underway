## Copyright (C) 2015 Giorgio Dallolmo
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## plot_spectra

## Author: Giorgio Dallolmo <gdal@pmpc1390>
## Created: 2015-09-24

function plot_spectra (jday_str)

fs = 'fontsize';
fw = 'fontweight';


dout = ["./output/" jday_str "/"];
if ~exist(dout)
    mkdir(dout);
endif


    fn = ls(["../../AMT25*/U*/saved/Proc*/*" jday_str "*mat"]);

    load(fn)




close all

cmap = colormap(jet);

cmap = cmap(round(linspace(1,64,24)),:);
colormap(cmap)

figure(1, 'visible', 'off')
    for ihr = 0:23
        hp = plot(out.acs.wv, medfilt1(out.acs.ap, 61)(1+20+ihr*1440/24, :));
        set(hp, 'linewidth', 3, 'color', cmap(ihr+1,:))
        hold on
    endfor

  
    hcl = colorbar;

    z = get(hcl, 'zticklabel');
    for iz = 1:length(z)
        z{iz} = sprintf("%02u", floor(str2num(z{iz})*23.9));
    endfor
    set(hcl, 'zticklabelmode', 'manual')
    set(hcl, 'ztick', str2num(cell2mat(z')));
    set(hcl, 'zticklabel', z, fs, 14);

    if strcmp(jday_str, '261')    
        axis([400 750 0 0.16])
    else
        axis([400 750 0 0.03])
    endif

    set(gcf, 'paperposition', [0.25         2.5           8           6])
    set(gca, 'pos', [0.15       0.12        0.78       0.815], fs, 14)
    set(hcl, 'pos', [0.7        0.6      0.0465       0.3] )

    ylabel("a_p [m^{-1}]\n", fs, 26, fw, "bold")
    xlabel("wavelength [nm]", fs, 20, fw, "bold")

    grid on

    set(gca, 'color', [1 1 1]*.6)

    fnout = [dout "spectral_ap_" jday_str ".png"];
    print("-dpng", fnout)







close all

cmap = colormap(jet);

cmap = cmap(round(linspace(1,64,24)),:);
colormap(cmap)

figure(1, 'visible', 'off')
    for ihr = 0:23
        hp = plot(out.acs.wv, out.acs.ap(1+20+ihr*1440/24, :)./out.acs.ap(1+20+ihr*1440/24, out.acs.wv==440));
        set(hp, 'linewidth', 3, 'color', cmap(ihr+1,:))
        hold on
    endfor

  
    hcl = colorbar;
 

    z = get(hcl, 'zticklabel');
    for iz = 1:length(z)
        z{iz} = sprintf("%02u", floor(str2num(z{iz})*23.9));
    endfor
    set(hcl, 'zticklabelmode', 'manual')
    set(hcl, 'ztick', str2num(cell2mat(z')));
    set(hcl, 'zticklabel', z, fs, 14);

        
    axis([400 750 0 1])

    set(gcf, 'paperposition', [0.25         2.5           8           6])
    set(gca, 'pos', [0.15       0.12        0.78       0.815], fs, 14)
    set(hcl, 'pos', [0.7        0.6      0.0465       0.3] )

    ylabel("a_p:a_p(440)\n", fs, 26, fw, "bold")
    xlabel("wavelength [nm]", fs, 20, fw, "bold")

    grid on

    set(gca, 'color', [1 1 1]*.6)

    fnout = [dout "norm440_spectral_ap_" jday_str ".png"];
    print("-dpng", fnout)






endfunction



















