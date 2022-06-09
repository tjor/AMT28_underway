1;

clear all



din = "/users/rsg/fne/DATA/AMT26/LWCC/Data/20161006/1322_und023/";

fn = glob([din "*sample1*txt"]);
fnMQ1 = glob([din "*milliq_ini*txt"]);
fnMQ2 = glob([din "*milliq_end*txt"]);

fnSal_ini = glob([din "../Ini/*seawater*00060*"]);
fnSal_ini_MQ = glob([din "../Ini/*Ini_milliq_ini*"]);
fnSal_end = glob([din "../End/*seawater*00857*"]);



[wv sample] = cmp_avg(fn);
[wv MQ1] = cmp_avg(fnMQ1);
[wv MQ2] = cmp_avg(fnMQ2);
[wv MQ_S1] = cmp_avg(fnSal_ini_MQ);

[S1] = medfilt1(rd_OO(fnSal_ini)(:,2), 30);
[S2] = medfilt1(rd_OO(fnSal_end)(:,2), 30);


ay = 2.303/0.98*(sample-MQ1-(S1-MQ_S1));

i650 = find(wv>650,1);

figure(1)
   plot(wv, ay-ay(i650))
   axis([400 700 -0.05 0.1])


figure(2)
clf
hold on
   plot(wv, 2.303/0.98*(sample-sample(i650)), 'r;sample;')
   plot(wv,  2.303/0.98*(MQ1-MQ1(i650)), 'g;MQ1;')
#   plot(wv, MQ2, 'm;MQ2;')
   plot(wv,  2.303/0.98*(S1-S1(i650)), 'b;S1;')
#   plot(wv, S2, 'k;S2;')
   plot(wv, ay-ay(i650), 'm;final;')

   axis([400 700 -0.05 0.1])





######################################
function [wv avg] = cmp_avg(fn)

   for ifn = 1:length(fn)

      tmp(:,ifn) = rd_OO(fn{ifn})(:,2);
         
   endfor

   wv = rd_OO(fn{ifn})(:,1);
   avg = medfilt1(mean(tmp,2), 30);


endfunction

######################################
function d = rd_OO(fn)

   fid = fopen(fn, 'r');

   for ihdr=1:17
      fgets(fid);
   endfor

   d = fscanf(fid, "%f %f\n", [2, 2048])';
   fclose(fid);

endfunction


