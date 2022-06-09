function [tmp] = rd_flow(fn)

t0 = datenum([2011 12 31 23 59 59] );  %reference time for plotting

	fid = fopen(fn);
		fgetl(fid);	%skip the first line that contains three weired characters at the beginning

        %2012-10-11 11:15:38 UTC	0	00000000	0.00	0.00	0.00	0.00	0.000	0.000	0.000	0.000
  		fmt = "%f-%f-%f %f:%f:%f UTC %f %f %f %f %f %f %f %f %f %f \n";
		tmp  =  fscanf(fid, fmt, [16, Inf])';

	fclose(fid);



% 	flow.time = datenum([tmp(:,1) tmp(:,2) tmp(:,3) tmp(:,4) tmp(:,5) tmp(:,6)])-t0;
% 
% 
% 
% 	flow.raw(:,1) = tmp(:,9);   	%Hz1
%   flow.raw(:,2) = tmp(:,1);       %Hz2
%   flow.raw(:,3) = tmp(:,1);       %flow1
%   flow.raw(:,4) = tmp(:,1);       %flow2



endfunction