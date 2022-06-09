function chla = chlacs(acs)
#function chla = chlacs(acs)
#
# Compute chl from acs line height using Boss et al., 2007 formula
#
# acs contains at least acs.wv and acs.ap
#



    wv650 = find(acs.wv==650);
    wv676 = find(acs.wv==676);
    wv714 = find(acs.wv==714);


    chla = (acs.ap(:,wv676) -39/65.*acs.ap(:,wv650)-26/65*acs.ap(:,wv714))./0.014;
    
endfunction    

