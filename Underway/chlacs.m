function chla = chlacs(acs)
#function chla = chlacs(acs)
#
# Compute chl from acs line height using Boss et al., 2007 formula
#
# acs contains at least acs.wv and acs.ap
#

  if ~all(isnan(acs.ap))

    wv650 = find(acs.wv==650); %  absorption at left of peak
    wv676 = find(acs.wv==676); % peak absoprtion wavelength
    wv714 = find(acs.wv==714); % absorption at right of peak

    % peak height relative to edges of peak re-scaled to Chl (65 used in-place of 64 wv units - legacy mistake - no concern) 
    chla = (acs.ap(:,wv676) -39/65.*acs.ap(:,wv650)-26/65*acs.ap(:,wv714))./0.014; % conversion factor 0.014 m^2 mg^-1 of Chl
   
   else
    chla = nan(1440,1);
   endif
endfunction    

