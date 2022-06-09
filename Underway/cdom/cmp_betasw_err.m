function [b_salts, b_err_salts] = cmp_betasw_err(acs, T, S)
# compute the contribution of scattering by pure water
#
# INPUT: acs structure
#        T([1:2]), where T(1) is the temperature of the 0.2um-filtered sample and T(2) the temperature of the MilliQ run
#        S([1:2]), where S(1) is the salinity of the 0.2um-filtered sample and S(2) the salinity of the MilliQ run (i.e., S(2) = 0)


    ### compute b_salt to be removed from c02-cMQ spectrum
    [theta,betasw02,bsw02,beta90sw] = betasw_ZHH2009(lambda=acs.cwl, S(1), Tc=T(1));
    [theta,betaswMQ,bswMQ,beta90sw] = betasw_ZHH2009(lambda=acs.cwl, S(2), Tc=T(2));

    theta_rad = deg2rad(theta);

    acceptance_angle = 0.93; #[degrees]
    ibdegACs = find(theta>=acceptance_angle);

    bMQ = 2*pi*trapz(theta_rad(ibdegACs)'.*ones(1,length(acs.cwl)), sin(theta_rad(ibdegACs))'.*ones(1,length(acs.cwl)).*betaswMQ(ibdegACs,:));
    b02 = 2*pi*trapz(theta_rad(ibdegACs)'.*ones(1,length(acs.cwl)), sin(theta_rad(ibdegACs))'.*ones(1,length(acs.cwl)).*betasw02(ibdegACs,:));

    b_salts = b02 - bMQ;


    ### compute b_errsalt to be removed from a02-aMQ spectrum
    [theta,betasw02,bsw02,beta90sw] = betasw_ZHH2009(lambda=acs.awl, S(1), Tc=T(1));
    [theta,betaswMQ,bswMQ,beta90sw] = betasw_ZHH2009(lambda=acs.awl, S(2), Tc=T(2));


    idegACs = find(theta>=41.7);
    #idegACs = find(theta>=90.0);

    berrMQ = 2*pi*trapz(theta_rad(idegACs)'.*ones(1,length(acs.cwl)), sin(theta_rad(idegACs))'.*ones(1,length(acs.cwl)).*betaswMQ(idegACs,:));
    berr02 = 2*pi*trapz(theta_rad(idegACs)'.*ones(1,length(acs.cwl)), sin(theta_rad(idegACs))'.*ones(1,length(acs.cwl)).*betasw02(idegACs,:));

    b_err_salts = berr02 - berrMQ;





endfunction


