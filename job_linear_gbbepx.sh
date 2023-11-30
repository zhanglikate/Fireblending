#!/bin/bash

module use -a /contrib/anaconda/modulefiles
module load anaconda/latest
module load nco

gbbdir=/scratch1/NCEPDEV/rstprod/nexus_emissions/GBBEPx
#outdir=/scratch1/NCEPDEV/rstprod/nexus_emissions/GBBEPx/blending
outdir=/scratch1/BMC/gsd-fv3-dev/lzhang/blend/test1
vars="BC CH4 CO CO2 MeanFRP NH3 NOx OC PM2.5 SO2"
echo ${vars} > invar.nml

yy=2016
mm=08
dd=01

emidate=$yy$mm$dd


istart=1 # istart can be flexible ajdusted to any day (such as 6 to keep the first 6 the same)
iday=1 #iday starts from istart to iend
iend=35

        j_day=$(date -d "$emidate" "+%j")
        echo "Julian day: $j_day"
        end_day=$((j_day+iend-1))
        echo "end_day: $end_day"

         end_day_of_year=$end_day
         end_date=$(date -d "$yy-01-01 +$(( $end_day_of_year - 1 )) days" +"%Y-%m-%d")
         echo "Date: $end_date"
         end_mm=$(echo $end_date | awk -F'-' '{print $2}')
         end_dd=$(echo $end_date | awk -F'-' '{print $3}')

cp  ${gbbdir}/climMean/GBBEPx-all01GRID_v4r0_climMean_${end_mm}${end_dd}.nc climate.nc
      echo "cp climMean/GBBEPx-all01GRID_v4r0_climMean_${end_mm}${end_dd}.nc climate.nc"
       for (( i=${j_day}; i<=${end_day}; i++ ))
       do
         jd=$((i-j_day+1))
           iday=${jd}
         day_of_year=$i
         date=$(date -d "$yy-01-01 +$(( $day_of_year - 1 )) days" +"%Y-%m-%d")
         echo "Date: $date"
         nmonth=$(echo $date | awk -F'-' '{print $2}')
         nday=$(echo $date | awk -F'-' '{print $3}')

#cp  ${gbbdir}/climMean/GBBEPx-all01GRID_v4r0_climMean_${nmonth}${nday}.nc climate.nc
#      echo "cp climMean/GBBEPx-all01GRID_v4r0_climMean_${nmonth}${nday}.nc climate.nc"

cp ${gbbdir}/GBBEPx_all01GRID.emissions_v004_${yy}${mm}${dd}.nc input.nc

   echo "cp GBBEPx_all01GRID.emissions_v004_${yy}${mm}${dd}.nc input.nc "
   echo "iday: ${iday}" 

if [ ${iday} -ge  ${istart} ]; then
      iday_new=$((iday-istart+1))
      istart_new=1
      iend_new=$((iend -istart+1))
      
python linear_gbbepx.py  -v invar.nml $iday_new $istart_new $iend_new 
#python linear_gbbepx.py  -v invar.nml $iday $istart $iend
fi

#python ave_test_gbbepx.py  -v invar.nml $iday $istart $iend

ncatted -O -a units,time,o,c,"hours since ${yy}-${nmonth}-${nday} 12:00:00" input.nc

mv input.nc $outdir/GBBEPx_all01GRID.emissions_v004_${yy}${nmonth}${nday}.nc

       done
       
