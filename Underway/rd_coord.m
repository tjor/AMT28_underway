function undwy = rd_coord(fn)

         % 12 284 10:00:00	50.89175856	-1.394885331
         fmt = "%f %f %f:%f:%f %f %f\n";


         fid = fopen(fn, "r");
         d = fscanf(fid, fmt, [7, Inf])';
         fclose(fid)   ;

         undwy.time = datenum([2012*ones(size(d(:,2))) month(d(:,2)) day(d(:,2)) d(:,3) d(:,4) d(:,5)]);

          
         undwy.lat = d(:,6);
         undwy.lon = d(:,7);


endfunction










