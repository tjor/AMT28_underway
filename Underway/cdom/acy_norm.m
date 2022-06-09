## Copyright (C) 2015 Giorgio Dallolmo
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## acy_norm

## Author: Giorgio Dallolmo <gdal@pmpc1390>
## Created: 2015-10-14

function acy = acy_norm (acy)
#
#### normalize all ac_MQ values to the same "spectral" temperature using the Psi_T we derived
#
#
#
    load ./output/Output_files/amt26_da2dTS_wap.oct

    i440 = find(acy.wv==440);
    i720 = find(acy.wv==720);
    i738 = find(acy.wv==738);




    #### now normalize all MQ values to the same "spectral" temperature using the Psi_T we derived
    iref = 13; # number of file used as the reference spectral temperature

    aMQ_ref = acy.MQ.a(iref,:);
    cMQ_ref = acy.MQ.a(iref,:);


    # compute reference spectral temperatures for a and c
        delta_aNIR_ref = aMQ_ref(i738) - aMQ_ref(i720);
        delta_cNIR_ref = cMQ_ref(i738) - cMQ_ref(i720);


    % delta_aNIR = inline("aMQ738-aMQ720 -(PsiT738-PsiT720)*dT", "aMQ738", "aMQ720", "PsiT738", "PsiT720", "dT");
    % delta_cNIR = inline("cMQ738-cMQ720 -(PsiT738-PsiT720)*dT", "cMQ738", "cMQ720", "PsiT738", "PsiT720", "dT");
    delta_aNIR = @(aMQ738, aMQ720, PsiT738, PsiT720, dT) aMQ738-aMQ720 -(PsiT738-PsiT720)*dT ;
    delta_cNIR = @(cMQ738, cMQ720, PsiT738, PsiT720, dT) cMQ738-cMQ720 -(PsiT738-PsiT720)*dT;

    % obj = inline("abs(diff(delta_NIR))", "delta_NIR");
    obj = @(delta_NIR) abs(diff(delta_NIR));


#     for ifn = 6:length(acy.time)  # WHY 6?
    for ifn = 1:length(acy.time) 

        dT0 = [0];

        [dTa, FVAL] = fminsearch (@(dT) obj( [delta_aNIR(acy.MQ.a(ifn,i738), acy.MQ.a(ifn,i720), da2dT.mean(i738), da2dT.mean(i720), dT); delta_aNIR_ref] ), dT0);
        [dTc, FVAL] = fminsearch (@(dT) obj( [delta_cNIR(acy.MQ.c(ifn,i738), acy.MQ.c(ifn,i720), dc2dT.mean(i738), dc2dT.mean(i720), dT); delta_cNIR_ref] ), dT0);

        acy.MQ.norm.dTa(ifn) = dTa;
        acy.MQ.norm.a(ifn,:) = acy.MQ.a(ifn,:)-da2dT.mean*dTa;

        acy.MQ.norm.dTc(ifn) = dTc;
        acy.MQ.norm.c(ifn,:) = acy.MQ.c(ifn,:)-dc2dT.mean*dTc;

    endfor



endfunction
