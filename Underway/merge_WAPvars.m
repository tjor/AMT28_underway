function WAPvars = merge_WAPvars(WAPvars1,WAPvars2)
    % The function merges two variables containing wapped data
    names1 = fieldnames(WAPvars1);
    names2 = fieldnames(WAPvars2);
    % 1) Merge the fields common to both arrays
    names = intersect(names1,names2);
    % Cycle through those fields to merge the two
    for iname = 1:length(names)
        instrument = names{iname};
        disp(['Merge ' instrument]);
        % Data are a level down
        fields = fieldnames(WAPvars1.(names{iname}));
        % Cycle through all fields of given field
        for ifield = 1:length(fields)
            disp(['  ',fields{ifield}])
            if strcmp(typeinfo(WAPvars1.(names{iname}).(fields{ifield})),'scalar struct')
                field1 = WAPvars1.(names{iname}).(fields{ifield});
                field2 = WAPvars2.(names{iname}).(fields{ifield});
                variables = fieldnames(field1);
                % Cycle through all variables of given field
                for ivar = 1:length(variables)
                    disp(['     ',variables{ivar}])
                    var1 = field1.(variables{ivar});
                    % Merge var2 only if matrices
                    if strcmp(typeinfo(var1),'matrix')
                        var2 = field2.(variables{ivar});
                        % Find non-nan values in var2
                        igood = find(~isnan(var2));
                        % Overwrite only if less then all array
                        % (some nan  must be present)
                        if length(igood)<length(var2(:))
                            % Overwrite non-nan values of var2 on var1
                            var1(igood) = var2(igood);
                        endif
                    endif
                    WAPvars.(names{iname}).(fields{ifield}).(variables{ivar}) =  var1;
                endfor
            % Merge var2 only if matrices
            elseif strcmp(typeinfo(WAPvars1.(names{iname}).(fields{ifield})),'matrix')
                % Data are at this level
                % Cycle through all variables of given field
                var1 = WAPvars1.(names{iname}).(fields{ifield});
                var2 = WAPvars2.(names{iname}).(fields{ifield});
                % Find non-nan values in var2
                igood = find(~isnan(var2));
                % Overwrite only if less then all array
                % (some nan  must be present)
                if length(igood)<length(var2(:))
                    % Overwrite non-nan values of var2 on var1
                    var1(igood) = var2(igood);
                endif
                WAPvars.(names{iname}).(fields{ifield}) =  var1;
            endif
        endfor
        disp(' ')
    endfor

    % 2) Add fields present only in first array
    only_in_1 = setdiff(names1,names);
    if ~isempty(only_in_1)
        for ifields = 1:length(only_in_1)
            WAPvars.(only_in_1{ifields}) = WAPvars1.(only_in_1{ifields});
        endfor
    endif

    % 3) Add fields present only in second array
    only_in_2 = setdiff(names2,names);
    if ~isempty(only_in_2)
        for ifields = 1:length(only_in_2)
            WAPvars.(only_in_2{ifields}) = WAPvars2.(only_in_2{ifields});
        endfor
    endif

endfunction
