# Creates a netcdf file from the final mat file of an AMT cruise
import numpy as np
import xarray as xr
import scipy.io as sio
import pandas as pd
import os
import argparse
import datetime as dt
# debug
import ipdb


def main(amt_n, amt_y):
    pathin = '../../Processed/Underway/Step3/'
    # pathin = '../../../AMT%s/Processed/Underway/Step3/' % amt_n
    # pathin = '/data/datasets/cruise_data/active/AMT%s/OSU/Optics/AMT%s_source/m/' % (amt_n,amt_n)
    # pathin = '../../Processed/Underway/Step3/'
    fname = 'amt%s_optics.mat' % amt_n
    fullname = os.path.join(pathin,fname)

    # Check if file exists
    if not os.path.isfile(fullname):
        print('File %s do not exists!!!!' % fullname)
        ipdb.set_trace()
        return

    # initialize xr variables and coordinates
    xrcoords = {}
    xrvars = {}
    xrcoords_attrs = {}
    xrvars_attrs = {}
    ds = xr.Dataset()

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
    if dtime[0] < 367:
        dtime = np.array([dt.datetime(int(amt_y),1,1)+dt.timedelta(days=idtime) for idtime in dtime])
    else:
        dtime = pd.to_datetime(dtime-719529,unit='D')

    # Drop time from list of keys
    amtkeys.remove('time')

    # Add time to xrcoords
    ds.assign_coords(time = dtime)
    ds['time'] = dtime
    ds['time'].attrs = {'time zone' : 'UTC'}
    ds.time.encoding['units'] = "seconds since 1970-01-01 00:00:00"
    ds.time.encoding['calendar'] = "proleptic_gregorian"
    
    ds.assign_coords(wv =  amt['acs'].item()['wv'].item().squeeze() )
    ds['acs_wv'] = amt['acs'].item()['wv'].item().squeeze()
    ds['acs_wv'].attrs = {'units' : 'nanometers'}
    
    if 'ac9' in amtkeys:
        ds.assign_coords(wv =  amt['ac9'].item()['wv'].item().squeeze() )
        ds['ac9_wv'] = amt['ac9'].item()['wv'].item().squeeze()
        ds['ac9_wv'].attrs = {'units' : 'nanometers'}
    
    ds.assign_coords(bb9wv =  np.array([470., 532., 700.]) )
    ds['bb3_wv'] = np.array([470., 532., 700.]) 
    ds['bb3_wv'].attrs = {'units' : 'nanometers'}

    #xrcoords['time'] = dtime
    #xrcoords_attrs['time_units'] = "UTC"

    # Again flow is assumed to be there
    if 'flow' not in amtkeys:
        print('variable flow not found')
        return

    # Read the dimension
    flow = amt['flow'].item().squeeze()

    # Drop it from the list of keys
    amtkeys.remove('flow')

    # Add it to xrvars
    xrvars['flow'] = (['time'],flow)
    xrvars_attrs['flow_units'] = "relative units"
    

    # Cycle each element of amtkeys
    for ivar in amtkeys:
        print("Processing %s" % ivar)
        _var = amt[ivar].item()
        _varkeys = list(_var.dtype.fields.keys())

        # Remove time if it is in the list
        if 'time' in _varkeys:
            _varkeys.remove('time')

        # If ivar is acs need to pull out the wavelengths vector
        if ivar == 'acs':
            acswv = _var['wv'].item().squeeze()
            ## Add them to xarray coordinates
            #xrcoords['wv'] = acswv
            #xrcoords_attrs['wv_units'] = 'nanometers'
            # drop wv from list
            _varkeys.remove('wv')

        # If ivar is ac9 need to pull out the wavelengths vector
        if ivar == 'ac9':
            ac9wv = _var['wv'].item().squeeze()
            ## Add them to xarray coordinates
            #xrcoords['wv'] = acswv
            #xrcoords_attrs['wv_units'] = 'nanometers'
            # drop wv from list
            _varkeys.remove('wv')

        if ivar == 'bb3':
            # need to read bb3 wavelengths from configuration file
            bb3_wv = np.array([1.,2.,3.])
            ## Add them to xarray coordinates
            #xrcoords['bb3_wv'] = bb3_wv
            #xrcoords_attrs[ivar+'wv_units'] = 'nanometers'

        # Get the various variables
        for iivar in _varkeys:
            _tmp = _var[iivar].item().squeeze()

            if len(_tmp.shape)>0:
                # Convert array to masked array
                if ivar == 'hplc':
                    ipdb.set_trace()

                inan = np.isnan(_tmp)
                _tmp = np.ma.array(_tmp,mask=np.isnan(_tmp))
                print('\t%s shape = ' % iivar,_tmp.shape)

                # Add it to the xrvars dictionary
                if len(_tmp.shape)==1:
                    xrvars['%s_%s' % (ivar,iivar)] = (['time'],_tmp)

                    if (ivar == "acs"):
                        if (iivar == "N"):
                            xrvars_attrs[ivar+'_'+iivar+"_units"] = 'number of binned measurements'

                        elif (iivar == "chl"):
                            chlattrs = {ivar+'_'+iivar+'_units' : 'mg/m3',
                                        ivar+'_'+iivar+'_equation' : 'chla = (acs.ap(:,wv676)-39/65.*acs.ap(:,wv650)-26/65*acs.ap(:,wv714))./0.014;',
                                        ivar+'_'+iivar+'_comment' : 'uncalibrated, not-debiased chl estimated from ACS ap'}

                    elif (ivar == "ac9"):
                        if (iivar == "N"):
                            xrvars_attrs[ivar+'_'+iivar+"_units"] = 'number of binned measurements'

                        elif (iivar == "chl"):
                            ac9chlattrs = {ivar+'_'+iivar+'_units' : 'mg/m3',
                                        ivar+'_'+iivar+'_equation' : 'chla = (acs.ap(:,wv676)-39/65.*acs.ap(:,wv650)-26/65*acs.ap(:,wv714))./0.014;',
                                        ivar+'_'+iivar+'_comment' : 'uncalibrated, not-debiased chl estimated from ACS ap'}

                        elif (iivar == "chl_adj"):
                            ac9chlattrs = {ivar+'_'+iivar+'_units' : 'mg/m3',
                                        ivar+'_'+iivar+'_equation' : 'chla_adj = chlAC9*median(chlACs/chlAC9)',
                                        ivar+'_'+iivar+'_comment' : 'uncalibrated, not-debiased chl estimated from ACS ap'}

                    elif (ivar+'_'+iivar == 'uway_lat'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = 'degrees_N'

                    elif (ivar+'_'+iivar == 'uway_long'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = 'degrees_E'
                    
                    elif (ivar+'_'+iivar == 'ctd_sst'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = 'degC'

                    elif (ivar+'_'+iivar == 'cdt_sal'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = '-'

                    elif (ivar+'_'+iivar == 'uway_sal'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = '-'

                    elif (ivar+'_'+iivar == 'uway_sst'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = 'degC'

                    elif (ivar+'_'+iivar == 'cstar_cp'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = '1/m'

                    elif (ivar+'_'+iivar == 'cstar_cp_err'):
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = '1/m'

                    else:
                        xrvars_attrs[ivar+'_'+iivar+'_units'] = ' '

                elif len(_tmp.shape)==2:
                    if ivar == 'acs':
                        xrvars['%s_%s' % (ivar,iivar)] = (['time','acs_wv'],_tmp)
                        xrvars_attrs['%s_%s_units' % (ivar,iivar)] = '1/m'

                    elif ivar == 'bb3':
                        xrvars['%s_%s' % (ivar,iivar)] = (['time','bb3_wv'],_tmp)
                        xrvars_attrs['%s_%s_units' % (ivar,iivar)] = '1/m'

    # Create xarray dataset
    #ds = xr.Dataset(xrvars)

    # add attributes
    for i in xrvars.keys():
        print('xrvars: '+i)
        ds[i] = xrvars[i]
        
        if 'acs_chl' in i:
            ds[i].attrs = chlattrs 

        elif 'ac9_chl' in i:
            ds[i].attrs = ac9chlattrs 

        else:
#            ipdb.set_trace()
            ds[i].attrs = {'units' : xrvars_attrs[i+'_units']}


#    for i in xrcoords.keys():
#        print('xrcoords: '+i)
#        ds.coords[i].attrs = {'units' : xrcoords_attrs[i+'_units']}

    pathout = pathin
    fnameout = 'amt%s_final.nc' % amt_n
    ds.to_netcdf(os.path.join(pathout,fnameout))



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--amt', default='29', help="Number of AMT cruise to process")
    parser.add_argument('--year', default='2019', help="Year of AMT cruise to process")
    args = parser.parse_args()
    amt_n = args.amt
    amt_y = args.year
    main(amt_n,amt_y)
