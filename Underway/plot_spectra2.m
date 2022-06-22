% Copyright (C) 2015 Giorgio Dallolmo
%% 
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%% 
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%% 
%% You should have received a copy of the GNU General Public License
%% along with Octave; see the file COPYING.  If not, see
%% <http://www.gnu.org/licenses/>.

%% plot_spectra

%% Author: Giorgio Dallolmo <gdal@pmpc1390>
%% Created: 2015-09-24

function plot_spectra (jday_str, spectra_alim, spectra_clim, chl_lim)

   pkg load signal
   
   % Global var defined in step2
   global DIR_FIGS
   global DIR_STEP2
   global OUT_PROC 
   global UWAY_DIR
   
   #run('../input_parameters.m')

   dout = [DIR_FIGS jday_str '/'];
   if ~exist(dout)
      mkdir(dout);
   endif

   fn = ls([DIR_STEP2 '*' jday_str '*mat']);

   load(fn)

   close all

   cmap = colormap(jet);

   cmap = cmap(round(linspace(1,64,24)),:);
   colormap(cmap)

   

   if isfield(out, 'acs')
     if ~all(isnan(out.acs.ap))

        figure(1, 'visible', 'off')
        subplot(121)
        for ihr = 0:23
            hp = plot(out.acs.wv, out.acs.ap(1+35+ihr*1440/24, :));
            set(hp, 'linewidth', 3, 'color', cmap(ihr+1,:))
            hold on
        endfor

        
        axis([400 750 0 spectra_alim])
        
        set(gca, 'position', [0.11        0.13     0.36       0.8], 'fontsize', 18)
        
        ylabel("a_p [m^{-1}]\n", 'fontsize', 26, 'fontweight', 'bold')
        xlabel('wavelength [nm]', 'fontsize', 20, 'fontweight', 'bold')

        grid on

        set(gca, 'color', [1 1 1]*.6)

        
        subplot(122)
        for ihr = 0:23
            hp = plot(out.acs.wv, out.acs.ap(1+35+ihr*1440/24, :)./out.acs.ap(1+35+ihr*1440/24, out.acs.wv==440));
            set(hp, 'linewidth', 3, 'color', cmap(ihr+1,:))
            hold on
        endfor

        hcl = colorbar;

        %z = get(hcl, 'zticklabel');
        %for iz = 1:length(z)
         %   z{iz} = sprintf('%02u', floor(str2num(z{iz})*23.9));
        %endfor
        %set(hcl, 'zticklabelmode', 'manual')
        %set(hcl, 'ztick', str2num(cell2mat(z')));
        %set(hcl, 'zticklabel', z, 'fontsize', 14);

        axis([400 750 0 spectra_clim])

        set(gcf, 'paperposition', [0.25         2.5           16           6])
        set(gca, 'position', [0.57034        0.13     0.4       0.8], 'fontsize', 18)
        set(hcl, 'position', [0.9        0.6      0.02       0.3], 'fontsize', 18 )

        ylabel("a_p:a_p(440)\n", 'fontsize', 26, 'fontweight', 'bold')
        xlabel('wavelength [nm]', 'fontsize', 20, 'fontweight', 'bold')

        grid on

        set(gca, 'color', [1 1 1]*.6)

        fnout = [dout 'ap_' jday_str '_ACs.png'];
        print('-dpng', fnout)

    
    
        #### now plot chl estimate

        #chlacs = medfilt1(chlacs(out.acs),11);
        chlacs = chlacs(out.acs);

        close all
        figure(1, 'visible', 'off')

        semilogy(out.acs.time+1, chlacs, '.')

        %ylim([0 prctile(chl,97)+0.25])
        %ylim([0.02 5])    
        ylim(chl_lim)    

        set(gcf, 'paperposition', [0.25         2.5           8           4])
        set(gca, 'position', [0.2        0.2     0.75       0.7], 'fontsize', 18)
        set(gca, 'yscale', 'log')
        
        ylabel("chl_{ACs} [mg m^{-3}]\n", 'fontsize', 24, 'fontweight', 'bold')
        xlabel('decimal day of the year', 'fontsize', 20, 'fontweight', 'bold')

        grid on

        set(gca, 'color', [1 1 1]*.6)

        fnout = [dout 'chl_' jday_str '_ACs.png'];
        print('-dpng', fnout)
        
        
        #save file with chl estimates 
        outchl = [out.acs.time+1 chlacs];
        fnout = [dout 'chl_' jday_str '_ACs.dat'];
        save("-ascii", fnout, "outchl");

      endif  
    endif

    
    
    if isfield(out, 'ac9')
            if ~all(isnan(out.ac9.ap))

        #medap = medfilt1(out.ac9.ap, 31);

        figure(1, 'visible', 'off')
        subplot(121)
        for ihr = 0:23
            % hp = plot(out.ac9.wv, medap(1+20+ihr*1440/24, :));
            hp = plot(out.ac9.wv, out.ac9.ap(1+35+ihr*1440/24, :));
            set(hp, 'linewidth', 3, 'color', cmap(ihr+1,:))
            hold on
        endfor

        
        axis([400 750 0 spectra_alim])
        
        set(gca, 'position', [0.11        0.13     0.36       0.8], 'fontsize', 18)
        
        ylabel("a_p [m^{-1}]\n", 'fontsize', 26, 'fontweight', 'bold')
        xlabel('wavelength [nm]', 'fontsize', 20, 'fontweight', 'bold')

        grid on

        set(gca, 'color', [1 1 1]*.6)

        
        subplot(122)
        for ihr = 0:23
            % hp = plot(out.ac9.wv, medap(1+20+ihr*1440/24, :)./medap(1+20+ihr*1440/24, out.ac9.wv==440));
            hp = plot(out.ac9.wv, out.ac9.ap(1+35+ihr*1440/24, :)./out.ac9.ap(1+35+ihr*1440/24, out.ac9.wv==440));
            set(hp, 'linewidth', 3, 'color', cmap(ihr+1,:))
            hold on
        endfor

        hcl = colorbar;

        #z = get(hcl, 'zticklabel'); % tjor: requires fix to jdayu

#        # this is to account for different behaviour between different octave versions
#        oct_ver = version;
#        oct_ver = str2num(oct_ver(1));

        tmpz = [0:6:24]; 


        for iz = 1:length(tmpz)-1
                #z{iz} = sprintf('%02u', floor(str2num(z{iz})*23.9));
                z{iz} = sprintf("%02u", tmpz(iz));
        endfor
        
        set(hcl, 'zticklabelmode', 'manual')
        set(hcl, 'ztick', str2num(cell2mat(z')));
        set(hcl, 'zticklabel', z, 'fontsize', 14);

        axis([400 750 0 spectra_clim])

        set(gcf, 'paperposition', [0.25         2.5           16           6])
        set(gca, 'position', [0.57034        0.13     0.4       0.8], 'fontsize', 18)
        set(hcl, 'position', [0.9        0.6      0.02       0.3], 'fontsize', 18 )

        ylabel("a_p:a_p(440)\n", 'fontsize', 26, 'fontweight', 'bold')
        xlabel('wavelength [nm]', 'fontsize', 20, 'fontweight', 'bold')

        grid on

        set(gca, 'color', [1 1 1]*.6)

        fnout = [dout 'ap_' jday_str '_AC9.png'];
        print('-dpng', fnout)

    
    
        #### now plot chl estimate

        chlac9 = chlac9(out.ac9);

        close all
        figure(1, 'visible', 'off')

        semilogy(out.ac9.time+1, chlac9, 'r.;chlAC9;')
        
        # check if we have data for correction and if so plots also the corrected AC9 chl
        fnACs2AC9 = [OUT_PROC UWAY_DIR "chlACs2AC9_median_prcrng.dat"];
        if exist(fnACs2AC9)
            load(fnACs2AC9);
            hold on
            semilogy(out.ac9.time+1, chlac9*chlACs2AC9_median_prcrng(1), 'b.;chlAC9 corr;')        
        endif
        
                
        %ylim([0 prctile(chl,97)+0.25])
        %ylim([0.02 5])    
        ylim(chl_lim)    

        set(gcf, 'paperposition', [0.25         2.5           8           4])
        set(gca, 'position', [0.2        0.2     0.75       0.7], 'fontsize', 18)
        set(gca, 'yscale', 'log')
        
        ylabel("chl_{AC9} [mg m^{-3}]\n", 'fontsize', 24, 'fontweight', 'bold')
        xlabel('decimal day of the year', 'fontsize', 20, 'fontweight', 'bold')

        grid on

        set(gca, 'color', [1 1 1]*.6)

        fnout = [dout 'chl_' jday_str '_AC9.png'];
        print('-dpng', fnout)
        
        if exist(fnACs2AC9)
           #save file with chl estimates 
           outchl = [out.ac9.time+1 chlac9*chlACs2AC9_median_prcrng(1)];
           fnout = [dout 'chl_' jday_str '_AC9.dat'];
           save("-ascii", fnout, "outchl");     
        endif        
     endif  
    endif
    
    
    
   if isfield(out, 'acs') & isfield(out, 'ac9') 
     if  ~all(isnan(out.acs.ap(:,10))) & ~all(isnan(out.ac9.ap(:, 1))) 

        chlratio = chlacs./chlac9;

        if all(isnan(chlratio))
           return 
        endif

        close all
        figure(1, 'visible', 'off')

        plot(out.ac9.time+1, chlratio, '.')

        %ylim([0 prctile(chl,97)+0.25])
        %ylim([0.02 5])    
        ylim([ 0 1])    

        innan = find(~isnan(chlratio));
        title(sprintf("%2.2f +/- %2.2f", median(chlratio(innan)), prcrng(chlratio(innan))));
        
        
        set(gcf, 'paperposition', [0.25         2.5           8           4])
        set(gca, 'position', [0.2        0.2     0.75       0.65], 'fontsize', 18)

        ylabel('chl_{ACs}/chl_{AC9}', 'fontsize', 24, 'fontweight', 'bold')
        xlabel('decimal day of the year', 'fontsize', 20, 'fontweight', 'bold')

        grid on

        set(gca, 'color', [1 1 1]*.6)

        fnout = [dout 'chl_2_chlAC9_' jday_str '.png'];
        print('-dpng', fnout)
     
        out = [chlacs(innan) chlac9(innan)];
        save("-ascii", [dout 'chl_chlAC9_' jday_str '.dat'], "out");
    
    endif
  endif  
    
    
endfunction

  
