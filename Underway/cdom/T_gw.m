function tgw = T_gw(T,S,wv)
# transmittance of a glass-water interface
#
# tgw = T_gw(T,S,wv)
# 
# INPUT:    T:  water temperature [degC]
#           S:  water salinity [-]
#           wv: wavelength [nm]

    n_silica = sqrt(    1 +   0.6961663*(wv/1000).^2./((wv/1000).^2 - 0.06840430^2) ...
                          +   0.4079426*(wv/1000).^2./((wv/1000).^2 - 0.11624140^2) ...
                          +   0.8974794*(wv/1000).^2./((wv/1000).^2 - 9.89616100^2)    );  # this formula uses wv in um, thus the 1/1000 factor

    n_water = nw(T,S,wv);


    tgw = 4.*n_water.*n_silica ./ (n_water + n_silica).^2;


endfunction




