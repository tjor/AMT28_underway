function [bindata] = bindata_merge(bindata, time, data)

    bintime = bindata.time;
    deltat = bindata.deltat;
%     
%     plot(bintime, 'r')
%     hold on
%     plot(time, 'b')
%     stop
    
    
       if ~isempty(time)
    
        % Loop through each time bin and find data that belongs... e.g.
        % for bin M find all data from time M <= t < M+1. Calculate mean,
        % median, and standard deviation stats on data for each bin
        
        
        
            for kb = 1:(length(bintime)-1)
            
                binidx = (time>=bintime(kb)) & (time<bintime(kb+1));

                
                bindata.ns(kb) = length(find(binidx==1));


                                
                if bindata.ns(kb)>0
                    bindata.med(kb,:) = median(data(binidx,:));
                    bindata.mean(kb,:) = mean(data(binidx,:));
                    bindata.std(kb,:) = std(data(binidx,:));
                    bindata.prc(kb,:) = (prctile(data(binidx,:),84)-prctile(data(binidx,:),16))/2;
                    bindata.N(kb,:) = size(data(binidx,:),1);
                endif
                
            endfor            
            
            
        endidx = length(bintime);
        binidx = (time>=bintime(endidx)) & (time<(bintime(endidx)+deltat));
        bindata.ns(endidx) = length(find(binidx==1));
        
        
        
        if bindata.ns(endidx) > 0
            bindata.med(endidx,:) = median(data(binidx,:));
            bindata.mean(endidx,:) = mean(data(binidx,:));
            bindata.std(endidx,:) = std(data(binidx,:));
            bindata.prc(endidx,:) = (prctile(data(binidx,:),84)-prctile(data(binidx,:),16))/2;
            bindata.N(endidx,:) = size(data(binidx,:),1);
        endif

        bindata.comments = [bindata.comments; {['Data merged ' datestr(now,0) ', ' num2str(length(time)) ...
                ' samples, from ' datestr(time(1),0) ' to ' datestr(time(end),0)]}];
       
                
            
       
                 
    endif




