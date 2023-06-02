# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.
# Script to submit ACS data to SeaBASS
import pdb
import sys
import xarray as xr
import pandas as pd
import numpy as np
import datetime
import ipdb
import subprocess


def rd_amt_ncdf(fn):
    print('reading NetCDF file...')

    amt = xr.open_dataset(fn)

    if hasattr(amt, 'wv'):
        print('...done')
    else:
        amt['wv'] = amt.acs_wv.values
        print('...done')
        
    return amt


def hdr(amt, fn_cal, fn_docs, model='ACS'):
    print('creating header...')

    header = {
    "/begin_header": "",
    "/received=": "",
    "/investigators=": "Giorgio_DallOlmo,Gavin_Tilstone,Tom_Jordan",
    "/affiliations=": "Plymouth_Marine_Laboratory,OGS",
    "/contact=": "gdallolmo@ogs.it,ghti@pml.ac.uk,tjor@pml.ac.uk",
    "/experiment=": "AMT",
    "/cruise=": amt.attrs['cruise_name'],
    "/station=": "NA",
    "/data_file_name=": "",
    "/documents=": fn_docs, 
    "/instrument_model=": model,
    "/instrument_manufacturer=": "SBE",
    "/calibration_files=": fn_cal, #
    "/data_type=": "flow_thru",
    "/data_status=": "preliminary",
    "/start_date=": "yyyymmdd",
    "/end_date=": "yyyymmdd",
    "/start_time=": "HH:MM:SS[GMT]",
    "/end_time=": "HH:MM:SS[GMT]",
    "/north_latitude=": "DD.DDD[DEG]",
    "/south_latitude=": "DD.DDD[DEG]",
    "/east_longitude=": "DD.DDD[DEG]",
    "/west_longitude=": "DD.DDD[DEG]",
    "/water_depth=": "NA",
    "/measurement_depth=": "7",
    "/missing=": "-9999",
    "/delimiter=": "comma",
    "/fields=": "",
    "/units=": "yyyymmdd, hh:mm: ss, degrees, degrees, degreesC, PSU, 1/m, 1/m, 1/m, 1/m, none, ug/L",
    "/end_header": "",
    }

    # save the order in which the fields need to be printed
    order = header.keys()

    # add wavelengths to /fields and 1/m to units
    _fields = "date,time,lat,lon,Wt,sal,"
    _units = "yyyymmdd,hh:mm:ss,degrees,degrees,degreesC,PSU,"

    if model == 'ACS':
        for iwv in amt.wv.values:# add ap
            _fields = _fields + "ap" + str(iwv) + ","
            _units = _units + "1/m,"
        for iwv in amt.wv.values:# add std_ap
            _fields = _fields + "ap" + str(iwv) + "_sd,"
            _units = _units + "1/m,"
        for iwv in amt.wv.values:# add std_ap
            _fields = _fields + "cp" + str(iwv) + ","
            _units = _units + "1/m,"
        for iwv in amt.wv.values:# add std_cp
            _fields = _fields + "cp" + str(iwv) + "_sd,"
            _units = _units + "1/m,"
    elif model == 'AC9':
        for iwv in amt.ac9_wv.values:# add ap
            _fields = _fields + "ap" + str(iwv) + ","
            _units = _units + "1/m,"
        for iwv in amt.ac9_wv.values:# add std_ap
            _fields = _fields + "ap" + str(iwv) + "_sd,"
            _units = _units + "1/m,"
        for iwv in amt.ac9_wv.values:# add std_ap
            _fields = _fields + "cp" + str(iwv) + ","
            _units = _units + "1/m,"
        for iwv in amt.ac9_wv.values:# add std_cp
            _fields = _fields + "cp" + str(iwv) + "_sd,"
            _units = _units + "1/m,"

    # add final parts to strings
    _fields = _fields + "bincount,Chl_lineheight"
    _units = _units + "none,ug/L"

    # add strings to keys
    header["/fields="] = _fields
    header["/units="] = _units

    ### fill in file name
    # extract start and end dates and times - mask applied as ac-s does not run all cruise
    if model == 'ACS':
        i_good = amt['acs_ap'].values[:,10] != -9999
    elif model == 'AC9':
        i_good = amt['ac9_ap'].values[:,5] != -9999
    
    start_date = pd.to_datetime(str(amt.time[i_good].values.min())).strftime('%Y%m%d')
    start_time = pd.to_datetime(str(amt.time[i_good].values.min())).strftime('%H:%M:%S[GMT]')
    end_date = pd.to_datetime(str( amt.time[i_good].values.max())).strftime('%Y%m%d')
    end_time = pd.to_datetime(str(amt.time[i_good].values.max())).strftime('%H:%M:%S[GMT]')

    ##todays_date
    # set a random timestamp in Pandas
    timestamp = pd.Timestamp(datetime.datetime(2021, 10, 10))
    todays_date = pd.to_datetime(timestamp.today()).strftime('%Y%m%d')

    # create variable with name of seabass file
    sb_filename = amt_no.upper() + "_InLine0_" + model +  "_" + start_date + "_" + end_date + "_Particulate_v" + todays_date + ".sb"

    # add string to key
    header["/data_file_name="] = sb_filename

    header["/start_date="] = start_date
    header["/start_time="] = start_time

    header["/end_date="] = end_date
    header["/end_time="] = end_time

    header["/received="] = todays_date


    # extract geographic boundaries
    innan = np.where(~np.isnan(amt.uway_lat.values))[0] # non-nan values
    north_latitude = f'{amt.uway_lat.values[innan].max():+07.3f}[DEG]'
    south_latitude = f'{amt.uway_lat.values[innan].min():+07.3f}[DEG]'

    innan = np.where(~np.isnan(amt.uway_lon.values))[0] # non-nan values
    east_longitude = f'{amt.uway_lon.values[innan].max():+07.3f}[DEG]'
    west_longitude = f'{amt.uway_lon.values[innan].min():+07.3f}[DEG]'

    # add strings to keys
    header["/north_latitude="] = north_latitude
    header["/south_latitude="] = south_latitude
    header["/east_longitude="] = east_longitude
    header["/west_longitude="] = west_longitude

    print('...done')

    return header


def hdr_hplc(amt, fn_docs):
    print('creating header...')

    header = {
    "/begin_header": "",
    "/received=": "",
    #"/identifier_product_doi": "",
    "/investigators=": "Giorgio_DallOlmo,Gavin_Tilstone,Tom_Jordan",
    "/affiliations=": "Plymouth_Marine_Laboratory,OGS",
    "/contact=": "gdallolmo@ogs.it,ghti@pml.ac.uk,tjor@pml.ac.uk",
    "/experiment=": "AMT",
    "/cruise=": amt.attrs['cruise_name'],
    "/station=": "NA",
    "/data_file_name=": "",
    "/documents=": fn_docs,     
    "/calibration_files=": 'DAN-2019-012.pdf', 
    "/data_type=": "pigment",
    "/data_status=": "preliminary",
    "/start_date=": "yyyymmdd",
    "/end_date=": "yyyymmdd",
    "/start_time=": "HH:MM:SS[GMT]",
    "/end_time=": "HH:MM:SS[GMT]",
    "/north_latitude=": "DD.DDD[DEG]",
    "/south_latitude=": "DD.DDD[DEG]",
    "/east_longitude=": "DD.DDD[DEG]",
    "/west_longitude=": "DD.DDD[DEG]",
    "/water_depth=": "NA",
    "/HPLC_lab=": 'DHI',
    "/missing=": "-9999",
    "/delimiter=": "comma",
    "/fields=": "", 
    "/units=": "",
    "/end_header": "",
    }

    # save the order in which the fields need to be printed
    order = header.keys()

    # add wavelengths to /fields and 1/m to units    
    #_fields ='hplc_dhi_id,sample,station,depth,lat,lon,dates,times,bottle,volfilt,allo,alpha-beta-car,but-fuco,chl-c1c2,chl-c3,chlide-a,diadino,diato,dp,dv-chl-a,fuco,hex-fuco,lut,mv-chl_a,neo,perid,phide-a,phytin-a,ppc,pras,psc,psp,tacc,tcar,tchl,tot-chl-a,tot-chl-b,tot-chl-c,tpg,viola,zea'
    _fields ='sample,station,depth,lat,lon,year,month,day,time,bottle,volfilt,allo,alpha-beta-car,but-fuco,chl_c1c2,chl_c3,chlide_a,diadino,diato,dp,dv_chl_a,fuco,hex-fuco,lut,mv_chl_a,neo,perid,phide_a,phytin_a,ppc,pras,psc,psp,tacc,tcar,tchl,tot_chl_a,tot_chl_b,tot_chl_c,tpg,viola,zea' # caution: copied from hdr function
    _units = 'none,none,m,degrees,degrees,yyyy,mo,dd,HH:MM:SS,none,l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l,ug/l'
    
    # add strings to keys
    header["/fields="] = _fields
    header["/units="] = _units
    

    ### fill in file name
    # extract start and end dates and times (hplc time, etc)
    start_date = pd.to_datetime(str(amt.hplc_time.values.min())).strftime('%Y%m%d')
    start_time = pd.to_datetime(str(amt.hplc_time.values.min())).strftime('%H:%M:%S[GMT]')
    end_date = pd.to_datetime(str(amt.hplc_time.values.max())).strftime('%Y%m%d')
    end_time = pd.to_datetime(str(amt.hplc_time.values.max())).strftime('%H:%M:%S[GMT]')

    ##todays_date
    # set a random timestamp in Pandas
    timestamp = pd.Timestamp(datetime.datetime(2021, 10, 10))
    todays_date = pd.to_datetime(timestamp.today()).strftime('%Y%m%d')

  
    # create variable with name of seabass file
    sb_filename = amt_no.upper() + "_HPLC" +  "_" + start_date + "_" + end_date + "_v" + todays_date + ".sb"


    # add string to key
    header["/data_file_name="] = sb_filename

    header["/start_date="] = start_date
    header["/start_time="] = start_time

    header["/end_date="] = end_date
    header["/end_time="] = end_time

    header["/received="] = todays_date


    # extract geographic boundaries
    innan = np.where(~np.isnan(amt.uway_lat.values))[0] # non-nan values
    north_latitude = f'{amt.uway_lat.values[innan].max():+07.3f}[DEG]'
    south_latitude = f'{amt.uway_lat.values[innan].min():+07.3f}[DEG]'

    innan = np.where(~np.isnan(amt.uway_lon.values))[0] # non-nan values
    east_longitude = f'{amt.uway_lon.values[innan].max():+07.3f}[DEG]'
    west_longitude = f'{amt.uway_lon.values[innan].min():+07.3f}[DEG]'

    # add strings to keys
    header["/north_latitude="] = north_latitude
    header["/south_latitude="] = south_latitude
    header["/east_longitude="] = east_longitude
    header["/west_longitude="] = west_longitude

    print('...done')

    return header


def data_table(amt):
    print('creating data table...')

    #### create pandas DataFrame before exporting to csv
    print('     creating dates...')
    dates = [pd.to_datetime(str(idt)).strftime('%Y%m%d') for idt in amt.time.values]
    dates = pd.Series(dates, index = amt.time.values)
    print('     creating times...')
    times = [pd.to_datetime(str(idt)).strftime('%H:%M:%S') for idt in amt.time.values]
    times = pd.Series(times, index = amt.time.values)
    print('     creating pandas dataframes with data...')
    lat = amt['uway_lat'].to_pandas()
    lon = amt['uway_lon'].to_pandas()
    sst = amt['uway_sst'].to_pandas()
    sal = amt['uway_sal'].to_pandas()
    acs_ap = amt['acs_ap'].to_pandas()
    acs_ap_u = amt['acs_ap_u'].to_pandas()
    acs_cp = amt['acs_cp'].to_pandas()
    acs_cp_u = amt['acs_cp_u'].to_pandas()
    acs_N = amt['acs_N'].to_pandas()
    acs_chl_debiased = amt['acx_chl_debiased'].to_pandas() # xfield is used -  i_acs_ap_good mask ensures we select acs

    # remove acs_ap == -9999
    i_acs_ap_good = acs_ap.values[:,10] != -9999

    dates            = dates[i_acs_ap_good]
    times            = times[i_acs_ap_good]
    lat              = lat[i_acs_ap_good]
    lon              = lon[i_acs_ap_good]
    sst              = sst[i_acs_ap_good]
    sal              = sal[i_acs_ap_good]
    acs_ap           = acs_ap[i_acs_ap_good]
    acs_ap_u         = acs_ap_u[i_acs_ap_good]
    acs_cp           = acs_cp[i_acs_ap_good]
    acs_cp_u         = acs_cp_u[i_acs_ap_good]
    acs_N            = acs_N[i_acs_ap_good]
    acs_chl_debiased =   acs_chl_debiased[i_acs_ap_good]

    print('     concatenating Series...')
    amt2csv = pd.concat([dates, times, lat, lon, sst, sal, acs_ap, acs_ap_u, acs_cp, acs_cp_u, acs_N, acs_chl_debiased], axis=1)

    print('     removing NaNs from lat and lon...')
    # remove NaNs from lat
    amt2csv = amt2csv[ amt2csv[2].notnull() ]
    # remove NaNs from lon
    amt2csv = amt2csv[ amt2csv[3].notnull() ]


    print('...done')

    return amt2csv

def data_table_ac9(amt):
    print('creating data table...')

    #### create pandas DataFrame before exporting to csv
    print('     creating dates...')
    dates = [pd.to_datetime(str(idt)).strftime('%Y%m%d') for idt in amt.time.values]
    dates = pd.Series(dates, index = amt.time.values)
    print('     creating times...')
    times = [pd.to_datetime(str(idt)).strftime('%H:%M:%S') for idt in amt.time.values]
    times = pd.Series(times, index = amt.time.values)
    print('     creating pandas dataframes with data...')
    lat = amt['uway_lat'].to_pandas()
    lon = amt['uway_lon'].to_pandas()
    sst = amt['uway_sst'].to_pandas()
    sal = amt['uway_sal'].to_pandas()
    ac9_ap = amt['ac9_ap'].to_pandas()
    ac9_ap_u = amt['ac9_ap_u'].to_pandas()
    ac9_cp = amt['ac9_cp'].to_pandas()
    ac9_cp_u = amt['ac9_cp_u'].to_pandas()
    ac9_N = amt['ac9_N'].to_pandas()
    ac9_chl_debiased = amt['acx_chl_debiased'].to_pandas()  # xfield is used -  i_a9s_ap_good mask ensures we select ac9

    # remove acs_ap == -9999
    i_ac9_ap_good = ac9_ap.values[:,5] != -9999

    dates            = dates[i_ac9_ap_good]
    times            = times[i_ac9_ap_good]
    lat              = lat[i_ac9_ap_good]
    lon              = lon[i_ac9_ap_good]
    sst              = sst[i_ac9_ap_good]
    sal              = sal[i_ac9_ap_good]
    ac9_ap           = ac9_ap[i_ac9_ap_good]
    ac9_ap_u         = ac9_ap_u[i_ac9_ap_good]
    ac9_cp           = ac9_cp[i_ac9_ap_good]
    ac9_cp_u         = ac9_cp_u[i_ac9_ap_good]
    ac9_N            = ac9_N[i_ac9_ap_good]
    ac9_chl_debiased =   ac9_chl_debiased[i_ac9_ap_good]

    print('     concatenating Series...')
    amt2csv = pd.concat([dates, times, lat, lon, sst, sal, ac9_ap, ac9_ap_u, ac9_cp, ac9_cp_u, ac9_N, ac9_chl_debiased], axis=1)

    print('     removing NaNs from lat and lon...')
    # remove NaNs from lat
    amt2csv = amt2csv[ amt2csv[2].notnull() ]
    # remove NaNs from lon
    amt2csv = amt2csv[ amt2csv[3].notnull() ]


    print('...done')

    return amt2csv


def data_table_hplc(amt):
    print('creating data table...')

    #### create pandas DataFrame before exporting to csv
    print('     creating dates...')
    dates = [pd.to_datetime(str(idt)).strftime('%Y%m%d') for idt in amt.hplc_time.values] # picks out hplc dates and times
    dates = pd.Series(dates, index = amt.hplc_time.values)
    print('     creating times...')
    times = [pd.to_datetime(str(idt)).strftime('%H:%M:%S') for idt in amt.hplc_time.values] # picks out hplc dates and times
    times = pd.Series(times, index = amt.hplc_time.values)
    print('     creating pandas dataframes with data...')
    
    # metadata - as far as possible, the labels match the amt29 sb file - these also match the fields in the hplc header (care: hard-coding in both places)
   # hplc_dhi_id = amt['hplc_dhi_no.'].to_pandas()
    sample = amt['hplc_label'].to_pandas()
    station = amt['hplc_station'].to_pandas()
    depth = amt['hplc_depth'].to_pandas()
    lat = amt['hplc_lat'].to_pandas()
    lon = amt['hplc_lon'].to_pandas()
    year = [pd.to_datetime(str(idt)).strftime('%Y') for idt in amt.hplc_time.values] # picks out hplc dates and times
    year = pd.Series(year, index = amt.hplc_time.values)
    month = [pd.to_datetime(str(idt)).strftime('%m') for idt in amt.hplc_time.values] # picks out hplc dates and times
    month = pd.Series(month, index = amt.hplc_time.values)
    day = [pd.to_datetime(str(idt)).strftime('%d') for idt in amt.hplc_time.values] # picks out hplc dates and times
    day = pd.Series(day, index = amt.hplc_time.values)
    time = times
    bottle = amt['hplc_bottle'].to_pandas()
    volfilt = amt['hplc_volume'].to_pandas() # litee
      
    # pigments
    allo = amt['hplc_Allo'].to_pandas()
    alpha_beta_car  = amt['hplc_Alpha-beta-Car'].to_pandas()
    but_fuco = amt['hplc_But-fuco'].to_pandas()
    chl_c1c2 = amt['hplc_Chl_c1c2'].to_pandas()
    chl_c3 = amt['hplc_Chl_c3'].to_pandas()
    chlide_a = amt['hplc_Chlide_a'].to_pandas() 
    diadino = amt['hplc_Diadino'].to_pandas()
    diato = amt['hplc_Diato'].to_pandas()
    dp = amt['hplc_DP'].to_pandas()
    dv_chl_a = amt['hplc_DV_Chl_a'].to_pandas()
    # dv_chl_b - not present in AMT28
    fuco = amt['hplc_Fuco'].to_pandas()
    # gyro - not present in AMT28
    hex_fuco = amt['hplc_Hex-fuco'].to_pandas()
    lut = amt['hplc_Lut'].to_pandas()
    mv_chl_a = amt['hplc_MV_Chl_a'].to_pandas()
    # mv_chl_b - not present in AMT28
    neo = amt['hplc_Neo'].to_pandas()
    perid = amt['hplc_Perid'].to_pandas()
    phide_a = amt['hplc_Phide_a'].to_pandas()
    phytin_a = amt['hplc_Phytin_a'].to_pandas()
    ppc = amt['hplc_PPC'].to_pandas()
    # ppc_tcar - not present in AMT28 
    # ppc_tpg- not present in AMT28 
    pras = amt['hplc_Pras'].to_pandas()
    psc = amt['hplc_PSC'].to_pandas()
    # psc_tar- not present in AMT28 
    psp = amt['hplc_PSP'].to_pandas()
    # psc_tpg- not present in AMT28 
    tacc = amt['hplc_Tacc'].to_pandas()
    # tacc_tchla - not present in AMT28 
    tcar = amt['hplc_Tcar'].to_pandas()
    tchl = amt['hplc_Tchl'].to_pandas()
    # tchla_tpg - not present in AMT28
    # tchla_tcar - not present in AMT28
    tot_chl_a = amt['hplc_Tot_Chl_a'].to_pandas()
    tot_chl_b = amt['hplc_Tot_Chl_b'].to_pandas()
    tot_chl_c = amt['hplc_Tot_Chl_c'].to_pandas()
    tpg = amt['hplc_Tpg'].to_pandas()
    viola = amt['hplc_Viola'].to_pandas()
    zea = amt['hplc_Zea'].to_pandas()



    print('     concatenating Series...')

    
    amt2csv = pd.concat([sample,station,depth,lat,lon,year,month,day,time,bottle,volfilt,allo,alpha_beta_car,but_fuco,chl_c1c2, chl_c3, chlide_a,diadino,diato,dp,dv_chl_a,fuco,hex_fuco,lut,mv_chl_a,neo,perid,phide_a,phytin_a,ppc,pras,psc,psp,tacc,tcar,tchl,tot_chl_a,tot_chl_b,tot_chl_c,tpg,viola,zea],  axis=1)

    # assign column names (hardcoded based on _fields)
    print(' assigning hplc pigments...')
  #  _fields ='sample,station,depth,lat,lon,year,month,day,time,bottle,volfilt,allo,alpha-beta-car,but-fuco,chl_c1c2, chl_c3, chlide_a,diadino,diato,dp,dv_chl_a,fuco,hex-fuco,lut,mv_chl_a,neo,perid,phide_a,phytin_a,ppc,pras,psc,psp,tacc,tcar,tchl,tot_chl_a,tot_chl_b,tot_chl_c,tpg,viola,zea' # caution: copied from hdr function
   # col_hplc = _fields.strip().split(',') 
    
  #  amt2csv.columns = col_hplc
    
    
    print('...done')

    return amt2csv


def export_2_seabass(header, amt2csv, fnout):
    print('writing SeaBASS file...')

    with open(fnout, 'w') as ict:
        # Write the header lines, including the index variable for
        # the last one if you're letting Pandas produce that for you.
        # (see above).
        for key in header.keys():
            ict.write(key + header[key] + "\n")

        # Just write the data frame to the file object instead of
        # to a filename. Pandas will do the right thing and realize
        # it's already been opened.
        amt2csv.to_csv(ict, header = False,
                            index = False,
                            na_rep = header['/missing='])

    print('...done')

    return fnout

def run_fcheck(fnout):
    print('running fcheck...')

    subprocess.run(["../fcheck4/fcheck4.pl", fnout])

    print('...done')

    return


# Press the green button in the gutter to run the script.
### %run write_sb_file.py /Users/gdal/Documents/AMT_processed/AMT29/Step3/amt29_final_with_debiased_chl.nc acs122.dev checklist_acs_particulate_inline_AMT29.rtf,checklist_acs_ag_cg_AMT29.rtf,AMT29_ACS_inline_ProcessingReport_v20220810.docx
if __name__ == '__main__':
    
        
# nc file #
        finalnc = '/users/rsg/tjor/scratch_network/AMT_underway/AMT28/Processed/Underway/Step3/amt28_final_with_debiased_chl.nc' # hardcoded
        amt_no = finalnc.split("/")[-1].split("_")[0]
        
        # calibrati  on file
        fn_cal_acs = 'acs122.dev' 
        fn_cal_ac9 = 'ac90277.dev' 
        
        # document files
        fn_docs_acs = 'checklist_acs_particulate_inline_AMT28.rtf,checklist_acs_ag_cg_AMT28.rtf,AMT28_ACS_inline_ProcessingReport.docx' # hardcoded
        fn_docs_ac9 = 'checklist_a9s_particulate_inline_AMT28.rtf,checklist_ac9_ag_cg_AMT28.rtf,AMT28_ACS_inline_ProcessingReport.docx' # hardcoded
        fn_docs_hplc = 'checklist_hplc_DHI_AMT28.rtf,DAN-2019-012.pdf,Results_DAN_2019_012.xlsx'
        sys.path.append('../documents')
        
        # read ncdf file
        amt = rd_amt_ncdf(finalnc)

        # add cruise no (all caps) to amt xr.dataset
        amt.attrs['cruise_name'] = amt_no.upper()

        # prepare header
        header_acs = hdr(amt, fn_cal_acs, fn_docs_acs, 'ACS')
        header_ac9 = hdr(amt, fn_cal_ac9, fn_docs_ac9, 'AC9') # ACS and AC9 use same header writer function
        header_hplc = hdr_hplc(amt,fn_docs_hplc)
        
        # prepare data
        amt2csv_acs = data_table(amt)
        amt2csv_ac9 = data_table_ac9(amt)
        amt2csv_hplc = data_table_hplc(amt)

        # write file
        fnout_acs = '../sb_processed/' + header_acs['/data_file_name=']
        export_2_seabass(header_acs, amt2csv_acs, fnout_acs)

        # write file
        fnout_ac9 = '../sb_processed/' + header_ac9['/data_file_name=']
        export_2_seabass(header_ac9, amt2csv_ac9, fnout_ac9)

        # write file
        fnout_hplc = '../sb_processed/' + header_hplc['/data_file_name=']
        export_2_seabass(header_hplc, amt2csv_hplc, fnout_hplc)

        # run fcheck
        # run_fcheck(fnout_acs)
        #run_fcheck(fnout_ac9)
        run_fcheck(fnout_hplc)


# previous argv implementation
   # if len(sys.argv) == 1:
    #    print('ERROR: missing path of NetCDF file to process')
    #else:
    #    print(sys.argv[1]) # argv[1] = path of debiased nc file
    #    # extract cruise name
    #    amt_no = sys.argv[1].split("/")[-1].split("_")[0]

        # calibration file
    #    fn_cal = sys.argv[2] # argv[2] = acs dev file

        # document files
    #    fn_docs = sys.argv[3]  # checklist_acs_particulate_inline_AMT29.rtf,checklist_acs_ag_cg_AMT29.rtf,AMT29_ACS_inline_ProcessingReport_v20220810.docx

        # read ncdf file
    #    amt = rd_amt_ncdf(sys.argv[1])

        # add cruise no (all caps) to amt xr.dataset
     #   amt.attrs['cruise_name'] = amt_no.upper()

        # prepare header
     #   header = hdr(amt, fn_cal, fn_docs)

        # prepare data
       # amt2csv = data_table(amt)

        # write file
        #fnout = '../sb/' + header['/data_file_name=']
        #export_2_seabass(header, amt2csv, fnout)

        # run fcheck
        #run_fcheck(fnout)






