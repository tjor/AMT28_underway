#!/usr/bin/bash 
rsync -uavz -e  ssh soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/scs/Compress/{gyro,oceanlogger,seatex-gga,seatex-hdt,seatex-vtg,seatex-gll,anemometer}.* ../../data/Ship_uway/ancillary/complete/

year=2016
start_day=267
day=$start_day
while [ $day -lt 310 ]; do 
  echo $day
  # check to see if that particular day exists in complete file
  matches=`awk -F "," -v var=$day '$3 ~ var {print $0}' ../../data/Ship_uway/ancillary/complete/anemometer.ACO | wc -l`
  if [ $matches -ne 0 ];
     # check if directory exists: if it does not create new dir and extract data
     if []
     then mkdir -p ../../data/Ship_uway/ancillary/2016${day};
     pushd ../../data/Ship_uway/ancillary/complete
     for i in *.ACO;
        do echo $i
        awk -F "," -v var=$day '$3 ~ var {print $0}' $i > ../2016${day}/${i}
     done
     popd
  fi
  day=$[$day+1]
done

exit 0


