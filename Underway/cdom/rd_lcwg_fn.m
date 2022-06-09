function d = rd_lcwg_fn(fn)
# read summary files with names, times and depths

   #Sal	#day	#depth	#hour	#mattime	#minute	#month	#sample	#year
   #35.5338333333	21	5.0	17	736624.721528	19	10	20161021_1719_und054	2016
   tmpa = textread(fn, "%s", Inf, 'headerlines', 1); # read the whole file

   d.fns = tmpa(8:9:length(tmpa));
   d.sal = cellfun(@str2num,  tmpa(1:9:length(tmpa)));
   d.time = cellfun(@str2num,  tmpa(5:9:length(tmpa)));
   d.depth = cellfun(@str2num,  tmpa(3:9:length(tmpa)));

endfunction






