#!/usr/bin/bash 
# rsync -uavz -e  ssh soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/scs/Compress/{gyro,oceanlogger,seatex-gga,seatex-hdt,seatex-vtg,seatex-gll,anemometer,tsshrp}.* /home/amt/Data/AMT28/Data/Ship_uway/Compress/

year=2018
start_day=301
day=$start_day

while [ $day -lt 302 ]; do 
  echo $day

  # check to see if that particular day exists in complete file
  matches=`awk -F "," -v var=$day '$3 ~ var {print $0}' /home/amt/Data/AMT28/Data/Ship_uway/Compress/seatex-gga.ACO | wc -l`

  if [ $matches -ne 0 ]
    then
         # check if directory exists: if it does not create new dir and extract data
         dirname="/home/amt/Data/AMT28/Data/Ship_uway/Compress/2018${day}"

         #if [ -d "$dirname" ]
         if [ -d "dddd" ]
         then 
            echo "already have ancillary data on day ${day}: skipping"
         else
            mkdir -p $dirname;
            pushd /home/amt/Data/AMT28/Data/Ship_uway/Compress
            for i in *.ACO;
               do echo $i
               awk -F "," -v var=$day '$3 ~ var {print $0}' $i > ./2018${day}/${i}
            done
            popd
     fi
  fi
  day=$[$day+1]
done

exit 0


