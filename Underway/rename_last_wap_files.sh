!#/usr/bin/bash
for f in /home/amt/Data/AMT28/Data/Underway/Raw_underway/amt28b_18_300.00018_30*;
  do 
    cp "$f" "$(echo "$f" | sed s/_300.00018_/_/)"; 
  done
  
  
  