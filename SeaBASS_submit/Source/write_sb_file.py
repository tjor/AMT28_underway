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
    # extract start and end dates and times
    start_date = pd.to_datetime(str( amt.time.values.min())).strftime('%Y%m%d')
    start_time = pd.to_datetime(str( amt.time.values.min())).strftime('%H:%M:%S[GMT]')
    end_date = pd.to_datetime(str( amt.time.values.max())).strftime('%Y%m%d')
    end_time = pd.to_datetime(str(amt.time.values.max())).strftime('%H:%M:%S[GMT]')

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
        sys.path.append('../documents')

        # read ncdf file
        amt = rd_amt_ncdf(finalnc)

        # add cruise no (all caps) to amt xr.dataset
        amt.attrs['cruise_name'] = amt_no.upper()

        # prepare header
        header_acs = hdr(amt, fn_cal_acs, fn_docs_acs)
        header_ac9 = hdr(amt, fn_cal_ac9, fn_docs_ac9, 'AC9')
        
        # prepare data
        amt2csv_acs = data_table(amt)
        amt2csv_ac9 = data_table_ac9(amt)

        # write file
        fnout_acs = '../sb_processed/' + header_acs['/data_file_name=']
        export_2_seabass(header_acs, amt2csv_acs, fnout_acs)

        # write file
        fnout_ac9 = '../sb_processed/' + header_ac9['/data_file_name=']
        export_2_seabass(header_ac9, amt2csv_ac9, fnout_ac9)

        # run fcheck
        #run_fcheck(fnout_acs)
        run_fcheck(fnout_ac9)

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






