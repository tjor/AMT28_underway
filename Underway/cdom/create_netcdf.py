# Creates a netcdf file from the final mat file of an AMT cruise
import numpy as np
import xarray as xr
import scipy.io as sio
import pandas as pd
import os
import argparse
# debug
import ipdb


def main(amt_n):

    pathin = './'
    fname = 'amt%s_ay.mat' % amt_n
    fullname = os.path.join(pathin,fname)

    # Check if file exists
    if not os.path.isfile(fullname):
        print('File %s do not exists!!!!' % fullname)
        ipdb.set_trace()
        return

    # initialize xr variables, coordinates and attributes
    xrcoords = {}
    xrvars = {}
    # xrcoords['xrattrs'] = {}

    # Read the file
    matvar = sio.loadmat(fullname)
    amt = matvar['amt%s' % amt_n]

    # Get all the first level keys
    amtkeys = list(amt.dtype.fields.keys())

    # Check if time is there where it should be
    if 'time' not in amtkeys:
        print('variable time not found!')
        return


    # Read time dimension
    dtime = amt['time'].item().squeeze()
    # Convert time to datetime
    dtime = pd.to_datetime(dtime-719529,unit='D')
    # Drop time from list of keys
    amtkeys.remove('time')
    # Add time to xrcoords
    xrcoords['time'] = dtime

    # Read wv dimension
    wv = amt['wv'].item().squeeze()
    # Drop time from list of keys
    amtkeys.remove('wv')
    # Add wv to xrcoords
    # xc = {'wavelength': {'value' : wv, 'attrs':{'units', 'nm'}} }
    xrcoords['wavelength'] = wv
    # xrcoords.attrs['units'] = 'nanometers'

    # Cycle each element of amtkeys
    for ivar in amtkeys:
        print("Processing %s" % ivar)
        _var = amt[ivar].item().squeeze()


        if len(_var.shape)>0:
            # Convert array to masked array
            _var = np.ma.array(_var,mask=np.isnan(_var))
            print('\t%s shape = ' % ivar,_var.shape)

            # Add it to the xrvars dictionary
            if len(_var.shape)==1:
                # xrvars['%s' % (ivar)] = ('time',_var)
                xrvars['%s' % (ivar)] = xr.DataArray( _var, dims=("time"), coords={"time": amt['time'].item().squeeze()} )

                if ivar=='chl':
                    xrvars['%s' % (ivar)].attrs['units'] = 'mg/m3'
                    xrvars['%s' % (ivar)].attrs['long name'] = 'Concentration of total chlorophyll-a estaimted from ACs measurements of particulate absorption coefficient (this has not been compared to HPLC data, because HPLC data were not available at the time of processing)'

                if ivar=='lat':
                    xrvars['%s' % (ivar)].attrs['units'] = 'degrees N'
                    xrvars['%s' % (ivar)].attrs['long name'] = 'Latitude'

                if ivar=='lon':
                    xrvars['%s' % (ivar)].attrs['units'] = 'degrees E'
                    xrvars['%s' % (ivar)].attrs['long name'] = 'Longitude'

                if ivar=='sst':
                    xrvars['%s' % (ivar)].attrs['units'] = 'degree Celsius'
                    xrvars['%s' % (ivar)].attrs['long name'] = 'Sea surface temperature'

                if ivar=='sal':
                    xrvars['%s' % (ivar)].attrs['units'] = '-'
                    xrvars['%s' % (ivar)].attrs['long name'] = 'Sea surface salinity'

            elif len(_var.shape)==2:
                xrvars['%s' % (ivar)] = xr.DataArray( _var, dims=("time", "wavelength"), coords={"time": amt['time'].item().squeeze(), 'wavelength': amt['wv'].item().squeeze()} )
                xrvars['%s' % (ivar)].attrs['units'] = '1/m'
                xrvars['%s' % (ivar)].attrs['long name'] = 'Absorption coefficient of coloured dissolved organic matter estimated following Dall\'Olmo et al. 2017 (https://doi.org/10.1364/OE.25.0A1079)'
                xrvars['%s' % (ivar)].coords['wavelength'].attrs['units'] = 'nm'
                # xrdata = xr.DataArray(amt['ay'].item().squeeze(), dims=("time", "wavelength"), coords={"time": amt['time'].item().squeeze(), 'wavelength': amt['wv'].item().squeeze()} )
                # xrdata.coords['wavelength'].attrs['units'] = 'nm'

    # Create xarray dataset
    ds = xr.Dataset(xrvars)

    pathout = pathin
    fnameout = 'amt%s_ay.nc' % amt_n
    ds.to_netcdf(os.path.join(pathout, fnameout))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--amt', default='29', help="Number of AMT cruise to process")
    args = parser.parse_args()
    amt_n = args.amt
    main(amt_n)
