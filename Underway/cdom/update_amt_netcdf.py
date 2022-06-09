# Creates a netcdf file from the final mat file of an AMT cruise
import numpy as np
import xarray as xr
import scipy.io as sio
import pandas as pd
import os
import argparse
import datetime as dt
import mat4py
# debug
import ipdb


def main(amt_n,amt_y):
    pathin_nc = '../../../Processed/Underway/Step3/'
    pathin_ay = '../../../Processed/Underway/cdom/'
    
    fname_nc = 'amt%s_final.nc' % amt_n
    fullname_nc = os.path.join(pathin_nc, fname_nc)
    
    fname_ay = 'amt29_cdom.mat' 
    fullname_ay = os.path.join(pathin_ay, fname_ay)

    # Check if file exists
    if not os.path.isfile(fullname_ay):
        print('File %s do not exists!!!!' % fullname_ay)
        ipdb.set_trace()
        return

    if not os.path.isfile(fullname_nc):
        print('File %s do not exists!!!!' % fullname_nc)
        ipdb.set_trace()
        return


    # read main optics dataset
    with xr.open_dataset(fullname_nc) as tmp_ds:
        ds_amt = tmp_ds.load()
        tmp_ds.close()

    # check that cdom data are not already inside the amt_final.nc
    if 'ay440' in ds_amt.variables:
        print('Warning: CDOM data already in netCDF file. Exiting.')
        return


    # initialize xr variables and coordinates
    xvars = {}
    xvars_attrs = {}

    # initialize dataset
    ds = xr.Dataset()

    # Read the file
    matvar = sio.loadmat(fullname_ay)
    amt = matvar['cdom']['hr'][0][0]
    
    # Get all the first level keys
    amtkeys = list(amt.dtype.fields.keys())

    # Check if time is there where it should be
    if 'time' not in amtkeys:
        print('variable time not found!')
        return

    # Read time dimension
    dtime = amt['time'].item().squeeze()

    # Convert time to datetime
    if dtime[0] < 367:
        dtime = np.array([dt.datetime(int(amt_y),1,1)+dt.timedelta(days=idtime) for idtime in dtime])
    else:
        dtime = pd.to_datetime(dtime-719529,unit='D')
        ## see https://stackoverflow.com/questions/13965740/converting-matlabs-datenum-format-to-python
        #dtime = dt.datetime.fromordinal(dtime[0].astype(int)) + dt.timedelta(days=dtime[0]%1) - dt.timedelta(days = 366) 
        #ipdb.set_trace()


    # Drop time from list of keys
    amtkeys.remove('time')

    # Add time to xrcoords
    ds.assign_coords(time = dtime)
    ds['time'] = dtime
    ds['time'].attrs = {'time zone' : 'UTC'}
    ds.time.encoding['units'] = "seconds since 1970-01-01 00:00:00"
    ds.time.encoding['calendar'] = "proleptic_gregorian"

    # create wv 
    wv = np.linspace(400,750,176)
    i440 = np.where(wv==440)[0][0] 

    # read ay(440)
    xvars['ay440'] = (['time'], amt['ay'].item().squeeze()[:,i440])
    xvars_attrs['ay440_units'] = '1/m'
    
    # read ay slope
    xvars['ay_slope'] = (['time'], amt['ay_slope'].item().squeeze())
    xvars_attrs['ay_slope_units'] = '1/nm'

    # read cy(440)
    xvars['cy440'] = (['time'], amt['cy'].item().squeeze()[:,i440])
    xvars_attrs['cy440_units'] = '1/m'

    # read cy slope
    xvars['cy_slope'] = (['time'], amt['cy_slope'].item().squeeze())
    xvars_attrs['cy_slope_units'] = '1/nm'
    
    # add variables and variable attributes
    for i in xvars.keys():
        print('xvars: '+i)
        ds[i] = xvars[i]
        ds[i].attrs = {'units' : xvars_attrs[i+'_units']}


    ##########################################################

    # merge acy with main optics dataset
    ds_new = xr.merge([ds_amt, ds])
   
    # need this to avoid errors later when I merge with acs_chl_debiased
    # https://stackoverflow.com/questions/35084071/concat-dataframe-reindexing-only-valid-with-uniquely-valued-index-objects
    ds_new = ds_new.reset_index('time')

    pathout = pathin_nc
    fnameout = 'amt%s_final.nc' % amt_n
    ds_new.to_netcdf(os.path.join(pathout,fnameout))



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--amt', default='29', help="Number of AMT cruise to process")
    parser.add_argument('--year', default='2019', help="Year of AMT cruise to process")
    args = parser.parse_args()
    amt_n = args.amt
    amt_y = args.year
    main(amt_n, amt_y)
