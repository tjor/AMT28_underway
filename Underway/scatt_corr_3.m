function  [ap_corr, bp_corr, ac9err] = scatt_corr_3(ac9)
#
# [ap_corr, bp_corr] = scatt_corr_3(cp, ap);
# proportional scattering correction for ac9 data
#

	ac9.bp = ac9.cp - ac9.ap;  %compute first estimate of scattering coefficient
	
   # below, "end" is the last element of the 2nd dimension of ap, which corresponds to the wavelength of 715 nm (i.e., the reference NIR wavelength)
	ap_corr = ac9.ap - (ac9.ap(:,end)./(ac9.bp(:,end))*ones(1,9)) .* ac9.bp;  %apply eq.12b of the ac9 manual (ac9p.pdf)
	
	bp_corr = ac9.cp - ap_corr;  %compute second estimate of bp
	

   # estimate uncertainties
   ac9err = acp_err_ac9(ac9);

endfunction

function ac9err = acp_err_ac9(ac9)

# measurement equation
# y = ap - ap_NIR/bp_NIR*bp

# compute bp
bp = ac9.cp - ac9.ap;
bp_u = sqrt(ac9.cp_u.^2 + ac9.ap_u.^2);


# input variables  
       ap = ac9.ap;
   ap_NIR = ac9.ap(:,end)*ones(1,9); 
       bp = bp;
   bp_NIR = bp(:,end)*ones(1,9);

# sensitivities (y=ap_corr)
   dy2dap = ones( size(ap) );
dy2dap_NIR = -bp./bp_NIR ; 
    dy2dbp = -ap_NIR./bp_NIR ;
dy2dbp_NIR = ap_NIR.*bp ./ bp_NIR.^2 ;

# uncertainties in input parameters
    ap_u = ac9.ap_u;
ap_NIR_u = ac9.ap_u(:,end)*ones(1,9);
    bp_u = bp_u;
bp_NIR_u = bp_u(:,end)*ones(1,9);

# variances
ap_u2 = (ap_u.*dy2dap).^2;
ap_NIR_u2 = (ap_NIR_u.*dy2dap_NIR).^2;
bp_u2 = (bp_u.*dy2dbp).^2;
bp_NIR_u2 = (bp_NIR_u.*dy2dbp_NIR).^2;


# combined uncertainty in ap
ac9err.ap_u = sqrt( ap_u2 + ap_NIR_u2 + bp_u2 + bp_NIR_u2 );

# combined uncertainty in cp
ac9err.cp_u = ac9.cp_u;

# combined uncertanty in bp
ac9err.bp_u = sqrt(ac9.ap_u.^2 + ac9.cp_u.^2);

endfunction        
