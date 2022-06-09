function abs_err = b_salts(S, wv2)
# compute the scattering error due to salts
#
# SAME AS ABERR_SALTS.m, but integrated over the entire range of angles (excluding acceptance angle)
#

#     all these global varibles are used to speed up calculations
    global sin_theta
    global theta_rad
    global theta
    global berrMQ_c

    
    # here we use a coarser wv range to speed up calculations
    wv = [wv2(1):15:wv2(end)]';
    nwv = length(wv);

    ### compute b_errsalt to be removed from a02-aMQ spectrum

#     [theta_,betaswMQ,bswMQ,beta90sw] = betasw_ZHH2009(wv, 0, Tc=18);
    [theta_,betasw02,bsw02,beta90sw] = betasw_ZHH2009(wv, S, Tc=18);

#     theta_rad = deg2rad(theta);

    acceptance_angle = 0.93;  #  [degrees]
    ideg = find(theta>=acceptance_angle);

    # to speed things up a little
#     sin_theta = sin(theta_rad(ideg))';
    
#     berrMQ = 2*pi*trapz(theta_rad(ideg).*ones(1,nwv), sin_theta(ideg).*ones(1,nwv).*betaswMQ(ideg,:));
    berr02 = 2*pi*trapz(theta_rad(ideg).*ones(1,nwv), sin_theta(ideg).*ones(1,nwv).*betasw02(ideg,:));

    abs_err = berr02 - berrMQ_c;

    
    # here we interpolate the coarse result into the same range needed by the obj function
    abs_err = interp1(wv, abs_err, wv2(:)', 'extrap');

endfunction


