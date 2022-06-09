function dTS = fit_cy_raw(cy_raw, dc2dT, dc2dS, wv)

global cy_TScorr

    if any(isnan(cy_raw))
        dTS = [nan nan];
        return
    endif



#     cy_TScorr = inline("cy_raw  - p(1)*dc2dT - p(2)*dc2dS - b_salts(p(2), wv)", "cy_raw", "dc2dT", "dc2dS", "wv", "p");

    obj_c = inline("abs(max(y)-min(y))", "y");

    dTS0 = [0, 35];

    dTS = fminsearch (@(dTS) obj_c( cy_TScorr(cy_raw, dc2dT, dc2dS, wv, dTS) ), dTS0);

endfunction
