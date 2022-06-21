function chla = chlac9(ac9)
#function chla = chlac9(ac9)
#
# Compute chl from ac9 line height using Boss et al., 2007 formula
#
# ac9 contains at least ac9.wv and ac9.ap
#

  if ~all(isnan(ac9.ap))

    wv650 = find(ac9.wv==650); %  absorption at left of peak
    wv676 = find(ac9.wv==676); % peak absoprtion wavelength
    wv715 = find(ac9.wv==715); % absorption at right of peak

    % peak height relative to edges of peak re-scaled to Chl 
    chla = (ac9.ap(:,wv676) -39/65.*ac9.ap(:,wv650)-26/65*ac9.ap(:,wv715))./0.014; % conversion factor 0.014 m^2 mg^-1 of Chl
    
   else
    chla = nan(1440,1);

   endif
endfunction    

