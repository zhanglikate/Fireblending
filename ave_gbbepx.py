import datetime as dt
import netCDF4 as nc
import os, argparse
import numpy as np

'''
Command:
    python test_gbbepx.py -v INVARS.nml 
'''

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=(
            'Linear interpolation applied to real-time and climate GBBEPx emission for S2S'
        )
    )


    required = parser.add_argument_group(title='required arguments')

    required.add_argument(
        '-v', '--variable',
        help="Input file containing the  variables",
        type=str, required=True)

    parser.add_argument("iday")
    parser.add_argument("istart")
    parser.add_argument("iend")



    args = parser.parse_args()
    invarnml = args.variable

    iday = int(args.iday)
    istart = int(args.istart)
    iend = int(args.iend)

    #print("iday=", args.iday)
    #print("istart=", args.istart)
    #print("iend=", args.iend)

    infile1='input.nc'
    infile2='climate.nc'

    with open(invarnml, 'r') as fd:
	    invars=fd.read().strip().split(' ')
    print(invars)

#    import sys
#    sys.exit("stop")

    with nc.Dataset(infile1,'a') as infile1:
        with nc.Dataset(infile2,'a') as infile2:
            for vname in invars:
                print(vname)
                indata1 = infile1.variables[vname][:]
                indata2 = infile2.variables[vname][:]
                infile1.variables[vname][:] = (indata2[:]+indata1[:])/2.0
