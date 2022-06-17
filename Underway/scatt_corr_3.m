function  [ap_corr, bp_corr] = scatt_corr_3(cp, ap)
#
# [ap_corr, bp_corr] = scatt_corr_3(cp, ap);
# proportional scattering correction for ac9 data
#

	bp = cp - ap;  %compute first estimate of scattering coefficient
	
   # below, "end" is the last element of the 2nd dimension of ap, which corresponds to the wavelength of 715 nm (i.e., the reference NIR wavelength)
	ap_corr = ap - (ap(:,end)./(bp(:,end))*ones(1,9)) .* bp;  %apply eq.12b of the ac9 manual (ac9p.pdf)
	
	clear bp  %free some memory
	
	bp_corr = cp - ap_corr;  %compute second estimate of bp
	
	
	
	
