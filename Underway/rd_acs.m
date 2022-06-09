function [msec,c,a,cwl,awl,anc,c_cal,a_cal,c_T_cal,a_T_cal,T_bins] = rd_acs(fname)


    fid = fopen(fname, "r");

        # skip header
            for ihead = 1:8
                fgets(fid);
            endfor

        # read number of wavelength
            tmp = fgets(fid);
            nwv = str2num(tmp(1:3));

        # read number of temperature bins
            tmp = fgets(fid);
            nbins = str2num(tmp(1:3));



        # read temperature bins
            T_bins = fscanf(fid, [repmat("%f\t",[1,nbins]),"\t\t; temperature bins\n"] );

        #fgets(fid);


        # read wavelengths and calibration coefficients
            #C400.1	A400.3	8	-0.918445	-0.915805		0.032623	0.031427	0.029366	0.028139	0.026826	0.023904	0.022859	0.020651	0.019739	0.01617	0.015954	0.012912	0.012545	0.01002	0.009955	0.006453	0.006399	0.004083	0.005227	0.002806	0.002653	0.001293	0.001855	0.000554	0	0.000115	-0.001689	-0.002112	-0.002013	-0.002351	-0.003674	-0.003182	-0.004659	-0.003783	-0.005294	-0.004522	-0.004167		-0.057499	-0.0551	-0.052067	-0.049597	-0.046952	-0.042846	-0.040096	-0.037215	-0.033698	-0.031295	-0.029685	-0.027377	-0.026549	-0.024264	-0.02187	-0.020324	-0.020483	-0.016737	-0.015056	-0.015309	-0.010153	-0.008455	-0.004184	-0.002359	0	0.003249	0.004753	0.008686	0.013011	0.016858	0.023627	0.02678	0.027938	0.031418	0.036246	0.038068	0.039836		"; C and A offset, and C and A temperature correction info"
            fmt = ["C%f\tA%f\t%f\t%f\t%f\t\t" repmat("%f\t",[1,nbins]) "\t" repmat("%f\t",[1,nbins]), "\t\"; C and A offset, and C and A temperature correction info\"" char(13) char(10)];
            fmt = ["C%f\tA%f\t%*s\t%f\t%f\t\t" repmat("%f\t",[1,nbins]) "\t" repmat("%f\t",[1,nbins]), "\t\"; C and A offset, and C and A temperature correction info\"" char(13) char(10)];
            tmp = fscanf(fid, fmt, [4+nbins*2, nwv]);

            cwl = tmp(1,:);
            awl = tmp(2,:);

        # these are the pure water calibration coefficients
            c_cal = tmp(3,:);
            a_cal = tmp(4,:);

        # these are the temperature correction coefficients
            c_T_cal = tmp(6:6+nbins-1,:);
            a_T_cal = tmp(end-nbins+1:end,:);


            #cwl = awl = nan(nwv,1);
            #
            #for iwv = 1:nwv
            #    tmp = fgets(fid);
            #
            #    cwl(iwv) = str2num(tmp(2:6));
            #    awl(iwv) = str2num(tmp(9:13));
            #    
            #endfor

        # skip 3 lines
            fgets(fid);
            fgets(fid);
            fgets(fid);




        nrecs = 1+nwv*2+5;
        dat = fscanf(fid, [repmat("%f ", 1, nrecs) "\n"], [nrecs, Inf])';

    fclose(fid);


#	[dat] = textread(fname,'','headerlines',95);
#	[dat] = textread(fname,'','delimiter','\t', 'headerlines',95);

	if ~isempty(dat)
		msec = dat(:,1);
		c = dat(:,2:nwv+1);
		a = dat(:,nwv+2:2*nwv+1);
        anc = dat(:,end-4:end);
	else
		[msec,a,c,anc] = deal([]);
	end

		

endfunction

