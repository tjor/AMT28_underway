#!/usr/bin/bash

#rsync -u -e  ssh -avz --bwlimit=2000 /home/gdal/AMT25/source/uway/output/??? soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/ACs_output/
rsync -u -e  ssh --delete -avz --bwlimit=4000 /home/gdal/AMT25/AMT25_Optics_Data/UWay/{WAP*,saved,ancillary} soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/UWay/
rsync -u -e  ssh --delete -avz --bwlimit=4000 /home/gdal/AMT25/AMT25_Optics_Data/CTD/With_voltages/ soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/CTD/With_voltages/

rsync -u -e  ssh -rltDvz --delete --bwlimit=4000 /home/gdal/AMT25/source soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/

rsync -u -e  ssh --delete -avz --bwlimit=4000 /home/gdal/AMT25/AMT25_Optics_Data/Secchi_power soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data


