# Script to initialize an AMT directory structure as Giorgio likes
import os
import argparse
# Debug
import ipdb


def make_dir(path):
    # See if directory already exists, and if not create it
    if os.path.isdir(path):
        print('Directory %s already exists!' % path)
    else:
        print('Create %s' % path)
        os.mkdir(os.path.join(path))


def main(amt):
    # DEfine main path
    # (this should change only if laptop changes)
    main_path = '/users/rsg/tjor/scratch_network/AMT_underway/'
    # Update main_apth based on amt
    if not os.path.isdir(main_path):
        print('Make sure to mount the amt_laptop_data partition as user "amt"')
    else:
        main_path = os.path.join(main_path,'AMT%02d' % (amt))
    # Create amt directory
    make_dir(main_path)

    # List with subdirectories
    main_subs = ['Data','Figures','Processed','Source']
    # Dictionary with sublevel directories
    # Entries must be in main_subs
    second_subs = {'Data' : ['allcals4extraction','Optics_rig','Ship_CTD','Ship_uway','Underway']} 
    # Dictionary with sub-sublevel directories
    # Entries must be in second_subs
    third_subs = {'Optics_rig' : ['renamed','WAP_extracted','WAP_setup','Wet_host_setup'],
            'Underway': ['Calibration_files','Flow','Raw_underway','WAP_extracted','WAP_setup','Wet_host_setup']} 
    for isub in main_subs:
        # Create first subdir
        _path = os.path.join(main_path,isub)
        make_dir(_path)
        # Check for second level subdirectories
        if isub in second_subs.keys():
            for iisub in second_subs[isub]:
                _sub_path = os.path.join(_path,iisub)
                make_dir(_sub_path)
                # Check for third level subdirectories
                if iisub in third_subs.keys():
                    for iiisub in third_subs[iisub]:
                        _sub_sub_path = os.path.join(_sub_path,iiisub)
                        make_dir(_sub_sub_path)
    ipdb.set_trace()


if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--AMT',help="AMT number for which to create the folder structure")
    args = parser.parse_args()
    amt = int(args.AMT)
    main(amt)
