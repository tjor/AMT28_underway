REM copy L:\AMT24\DallOlmo\HSAS\2014-305*.raw D:\data\cruises\AMT24\HyperSAS\level0\

md C:\cygwin\home\tjsm\ancillary\complete
rsync -u -e  ssh -avz --bwlimit=2000 soc@jrlc.jcr.nerc-bas.ac.uk:/users/soc/cruisedata/scs/Compress/anemometer.* ../../AMT25_Optics_Data/UWay/ancillary/ancillary/complete/

copy K:\scs\Compress\gyro.* C:\cygwin\home\tjsm\ancillary\complete\
copy K:\scs\Compress\oceanlogger.* C:\cygwin\home\tjsm\ancillary\complete\
copy K:\scs\Compress\seatex-hdt.* C:\cygwin\home\tjsm\ancillary\complete\
copy K:\scs\Compress\seatex-vtg.* C:\cygwin\home\tjsm\ancillary\complete\
copy K:\scs\Compress\seatex-gll.* C:\cygwin\home\tjsm\ancillary\complete\
copy K:\scs\Compress\tsshrp.* C:\cygwin\home\tjsm\ancillary\complete\

REM copy K:\scs\Compress\anemometer.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\
REM copy K:\scs\Compress\ashtech.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\
REM copy K:\scs\Compress\gyro.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\
REM copy K:\scs\Compress\oceanlogger.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\
REM copy K:\scs\Compress\seatex-hdt.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\
REM copy K:\scs\Compress\seatex-vtg.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\
REM copy K:\scs\Compress\seatex-gga.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\
REM copy K:\scs\Compress\tsshrp.* D:\data\cruises\AMT24\HyperSAS\ancillary\complete\

