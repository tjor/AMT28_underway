function A = errorFunc(S,varargin)
    warning(S.identifier, S.message);
    A = NaN;
endfunction
