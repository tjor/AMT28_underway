function undwy = rd_underway_amt22(fn)
%              5    6       7                8             9         10         11        12          13           14                           15         16           17              18              19              20                      21              22              23              24              25                      26
%       Time, lat, lon, smg,           cmg,            heading,    log,       uncdepth, cordepth,seatemp(DEG C),conductivity(S/m),         salinity(PSU),  fluo(V),     trans(V),       airtemp(DEG C), press(mbar),    humid(%),           ptir(mV),           stir(mV),       ppar(mV),       spar(mV),       trueWindSpeed(knots),   trueWindDir(DEG)

% 12 286 09:00:00,49.301691,-12.353316,9.600000,269.0,268.6,6.540000,1164.79,1165.65,15.4806,4.4131,35.5464,0.1574,2.3507,12.6001,1011.1535,71.4306,163.2696,154.1232,61.7232,65.4261,27.9,273.7


   fid = fopen(fn, 'r');


   % create structure to store the content of the file
        tmp_labels  = fgets(fid);  %skips header and get labet
        tmp_labels2 = strsplit (tmp_labels, ",");
        parenthesys = strfind(tmp_labels2, "(");

        for ilab = 1:length(tmp_labels2)
            if  ~isempty(parenthesys{ilab})
               tmp_labels3{ilab} = tmp_labels2{ilab}(1:parenthesys{ilab}-1);  % extract variable names
               tmp_units{ilab} = tmp_labels2{ilab}(parenthesys{ilab}:end);  % extract variable units
            else
               tmp_labels3{ilab} = tmp_labels2{ilab};  % extract variable names
               tmp_units{ilab} = [];  % extract variable units
            endif

            undwy.(tmp_labels3{ilab}) = [];  % create field in undwy with name of variable

        endfor

        undwy.units = tmp_units;  % create field in undwy with units


        % read data
        fmt = ['%f %f %f:%f:%f, ' repmat('%f,', 1, length(tmp_labels3)-2) '%f\n'];   % -1 needed to account for the date fields




        data = fscanf(fid, fmt, [length(tmp_labels3)+4 Inf])';  % read data

    fclose(fid);


    



        date_vector = [2000+data(:,1) month(data(:,2)) day(data(:,2)) data(:,3) data(:,4) data(:,5)];% extract date vector
        undwy.Time = datenum(date_vector);


        for ilab = 6:length(tmp_labels3)+4
            undwy.(tmp_labels3{ilab-4}) = data(:,ilab); % assign data to structure
        endfor


     








   
   
   
   
   
endfunction







