function dTS = fit_ay_raw(ay_raw, da2dT, da2dS, wv)

global ay_TScorr

    if any(isnan(ay_raw))
        dTS = [nan nan];
        return
    endif



#     ay_TScorr = inline("ay_raw  - p(1)*da2dT - p(2)*da2dS - aberr_salts(p(2), wv)", "ay_raw", "da2dT", "da2dS", "wv", "p");

    obj_a = inline("abs(max(y)-min(y))", "y");

    dTS0 = [0, 35];

    dTS = fminsearch (@(dTS) obj_a( ay_TScorr(ay_raw, da2dT, da2dS, wv, dTS) ), dTS0);

endfunction
