#! /bin/bash
#------------------------------------------------------------------
#
# Transform Ozone output from kg to mol/mol 
# (monthly average output in OsloCTM3)
#
# Activate shell script by typing: chmod +x cdo_vmr.sh
#------------------------------------------------------------------

usage=$"Transform ozone monthly average output from kg to mol/mol. 
              ./cdo_vmr <path_to_ozone_files> --surface" 

srcdir=${1}
opttype=${2}

tmp_outfile=tmp_output.nc
basedir=`dirname $srcdir`

case $opttype in
    --surface)
        echo "Selecting surface level."
        select_level=1
        ;;
    *)
        echo "Selecting whole field."
        select_level=0
esac

# Change to working directory
cd $basedir

# Make directory
if [ ! -d  "VMR" ]; then
    mkdir "VMR"
fi
cd VMR
echo `pwd`

Mair=28.9644
MO3=47.9982
MCH4=16.042

# Loop all files
for infile1 in `ls ${srcdir}*.nc` ; do
    #outfile=${infile1/"avgsav"/"avg_ozone"}
    outfile=${infile1/"avgsav"/"avg_methane"}
    outfile=`basename ${outfile}`
    echo `pwd`
    ls .
    #echo $outfile
    if [[ ! -e ${outfile} ]]; then
        # Convert from kg to mol/mol
        if [[ $select_level -eq 1 ]]; then
            echo $infile1 $outfile
	    #cdo -L mulc,$Mair -divc,$MO3 -div -sellevidx,1 -selname,O3 ${infile1} -selname,AIR ${infile1} ${outfile
            cdo -L mulc,$Mair -divc,$MCH4 -div -sellevidx,1 -selname,CH4 ${infile1} -selname,AIR ${infile1} ${outfile}
        else
            echo $infile1 $outfile
	    #cdo -L mulc,$Mair -divc,$MO3 -div -selname,O3 ${infile1} -selname,AIR ${infile1} ${outfile}
            cdo -L mulc,$Mair -divc,$MCH4 -div -selname,CH4 ${infile1} -selname,AIR ${infile1} ${outfile}
        fi
        # Rename variable
        #ncrename -v .AIR,"O3" ${outfile}
	ncrename -v .AIR,"CH4" ${outfile}
        # Change netcdf units attribute
        #ncatted -a units,"O3",m,c,"mol/mol" ${outfile}
        ncatted -a units,"CH4",m,c,"mol/mol" ${outfile}
    else
        echo "Files already exist!"
    fi
    
done
