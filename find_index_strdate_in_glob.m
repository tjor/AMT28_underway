function idir = find_index_strdate_in_glob(glob_list,strdate)
   % Find indices of dirs/file in glob_list that contain string strdate
   % (format 'yyyymmdd')
   istr = strfind(glob_list,strdate);
   idir = []; % Initialize list of indices of directories with strdates(i,:) in name
   for ii = 1:length(istr)
      if ~isempty(istr{ii})
         % Record indices of directories with strdates(i,:) in name
         idir = [idir, ii];
      end%if
   end%for

