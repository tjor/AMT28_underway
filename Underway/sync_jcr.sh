#!/usr/bin/bash

#rsync -u -e  ssh -avz --bwlimit=2000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/Raw_UWay/ /home/gdal/AMT25/AMT25_Optics_Data/UWay/Raw_UWay/
#rsync -u -e  ssh -avz --bwlimit=2000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/Flow/ /home/gdal/AMT25/AMT25_Optics_Data/UWay/Flow/
#rsync -u -e  ssh -avz --bwlimit=2000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/Optics_Rig/ /home/gdal/AMT25/AMT25_Optics_Data/Optics_Rig/
#rsync -u -e  ssh -avz --bwlimit=2000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/CTD/AMT25_H6/ /home/gdal/AMT25/AMT25_Optics_Data/CTD/AMT25_H6/
#rsync -u -e  ssh -avz --bwlimit=2000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/CDOM/ /home/gdal/AMT25/AMT25_Optics_Data/CDOM/



rsync -u -e  ssh -avz --bwlimit=2000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/DallOlmo/AMT25_Optics_Data/{CDOM,CTD/AMT25_H6,Optics_Rig,Flow,Raw_UWay} /home/gdal/AMT25/AMT25_Optics_Data/


#rsync -u -e  ssh -avz --bwlimit=4000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/Bargery/CTD_CNV_files/With_voltages /home/gdal/AMT25/AMT25_Optics_Data/CTD/
rsync -u -e  ssh -avz --bwlimit=4000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/work/Bargery/Grg_24Hz /home/gdal/AMT25/AMT25_Optics_Data/CTD/

