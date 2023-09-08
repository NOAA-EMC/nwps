#!/bin/sh
################################################################3
#
#  This script will tar up all the data for a given forecast cycle for
#  the directory specified by the first
#  argument ($1) and place the tar files on the HPSS server,
#  under ${HPSSOUT}.  The tar file is put in the directory
#  appropriate for data valid for the day specified as the second 
#  command line argument ($2).
#
#  This script breaks up the nwps data directory into two separate
#  tar files per forecast region (that is, 10 tar files per cycle ).
#  The data files are broken up as proposed by EMC/GMB.
#
#  Usage: rhist_savenwps.sh Directory Date(YYYYMMDDHH format)
#
#  Where: Directory  = Directory to be tarred.
#         Date(YYYYMMDDHH format) = Day that the tar file should be saved under.
#
################################################################3
set -x


if [ $# -ne 2 ]
then
  echo "Usage: rhist_savenwps.sh Directory Date(YYYYMMDDHH format) "
  exit 1
fi 

${USHrhist}/rhist_check.sh $1 $2
if [ $? -eq 0 ] ; then
    echo "Log entry found in $LOGrhist, skipped processing for: $0 $1 $2"
    exit 0
fi

#
#   Get directory to be tarred from the first command line argument,
#   and check to make sure that the directory exists.
#

dir=$1
if [ ! -d $dir ]
then
  echo "rhist_savenwps.sh:  Directory $dir does not exist."
  exit 2
fi 

#
#   Determine the directory where the tar file will be stored
#   and make sure that it exists in HPSS.
#

year=`echo $2 | cut -c 1-4`
yearmo=`echo $2 | cut -c 1-6`
yrmoday=`echo $2 | cut -c 1-8`
rhcyc=`echo $2 | cut -c 9-10`
rhcycle=t${rhcyc}z

if [ $TSM_FLAG = 'NO' ]
then
  hpssdir0=${HPSSOUT}/5year/Ali.Salimi/rh${year}/${yearmo}/$yrmoday
  hpssdir1=${HPSSOUT}/1year/Ali.Salimi/rh${year}/${yearmo}/$yrmoday
  hpssdir2=${HPSSOUT}/2year/Ali.Salimi/rh${year}/${yearmo}/$yrmoday

elif [ $TSM_FLAG = 'YES' ]
then
  rhistdir0=${TSMOUT}/rh${year}/${yearmo}/$yrmoday
  rhistdir1=${TSMOUT}/1year/rh${year}/${yearmo}/$yrmoday
  rhistdir2=${TSMOUT}/2year/rh${year}/${yearmo}/$yrmoday
 
  ssh ibmtsm1.ncep.noaa.gov "mkdir -p -m 755 $rhistdir0; mkdir -p -m 755 $rhistdir1; mkdir -p -m 755 $rhistdir2"

fi

#
#   Get a listing of all files in the directory to be tarred
#   and break the file list up into groups of files.
#   Each list of files names the contents of its associated tar file.
# 

cd $dir

for region in sr er wr pr ar
do
   find ./${region}.${yrmoday}/ -maxdepth 4 \( -name "*input*" -o -name "*.inp" -o -name "${yrmoday}.*" -o -name "*.wnd" -o -name "*.wlev" \
                                            -o -name "*.cur" -o -name "*.tar" -o -name "NWPSWINDGRID*.tar.gz" -o -name "bc_*" -o -name "Warn*" \) > ${region}.keep
   find ./${region}.${yrmoday}/ -maxdepth 4 \( -name "*.grib2" -o -name "SPC2D.*" -o -name "Warn*" \) > ${region}.output
done

cd $dir

#  Now create a tar file for each group of files

for region in sr er wr pr ar
do
   for file in keep output
   do
      if [ ! -s ${dir}/$region.$file ]; then continue; fi

      #
      #   Pick 1year, 2year, or permanent archive.
      #
      case $file in
         keep)       hpssdir=$hpssdir0
                     rhistdir=$rhistdir0;;
         output)     hpssdir=$hpssdir2
                     rhistdir=$rhistdir2;;
         *)          hpssdir=$hpssdir0
                     rhistdir=$rhistdir0;;
      esac

      #
      #   Generate the name of the tarfile, which should be the same
      #   as the absolute path name of the directory being
      #   tarred, except that "/" are replaced with "_".
      #

      tarfile=`echo $PWD | cut -c 44- | tr "/" "_"`
      tarfile=${tarfile}_${region}.${yrmoday}.${file}.tar

      #
      #   Check if the tarfile index exists.  If it does, assume that
      #   the data for the corresponding directory has already been
      #   tarred and saved.
      #

      if [ $TSM_FLAG = 'NO' ]
      then
          if [[ $CHECK_HPSS_IDX == "YES" ]] ; then
           hsi "ls -l ${hpssdir}/${tarfile}.idx"
	      tar_file_exists=$?
           if [ $tar_file_exists -eq 0 ]
           then
	          echo "File  $tarfile already saved."
	          continue
	      fi
          fi
      elif [ $TSM_FLAG = 'YES' ]
      then
        size=`ssh ibmtsm1.ncep.noaa.gov ls -l ${rhistdir}/${tarfile} | awk '{print \$5}'`
        if [  -n "$size" ]
        then
          if [ $size -gt 0 ]
          then
             echo "File  $tarfile already saved."
             continue
          fi
        fi
      fi
   
      #   If on Stratus:
      #   htar is used to create the archive, -P creates
      #   the directory path if it does not already exist,
      #   and an index file is also made.
      #

      if [ $TSM_FLAG = 'NO' ]
      then
        date
        if [[ $DRY_RUN_ONLY == "YES" ]] ; then
            echo "DRY RUN, list of files that would be archived:"
            cat ${dir}/$region.$file | sort
            continue
        else
            htar -P -cvf ${hpssdir}/$tarfile -L ${dir}/$region.$file
            err=$?
        fi
        if [ $err -ne 0 ]
        then
          echo "rhist_savenwps.sh:  File $tarfile was not successfully created."
          exit 3
        fi
        date

      #
      #   Read the tarfile and save a list of files that are in the tar file.
      #
 
        htar -tvf $hpssdir/$tarfile
        err=$?
        if [ $err -ne 0 ]
        then
          echo "rhist_savenwps.sh:  Tar file $tarfile was not successfully read to"
          echo "             generate a list of the files."
          exit 4
        fi
 
      #
      #  Restrict tar file, if it contains restricted data.
      #
        ${USHrhist}/rhist_restrict.sh ${hpssdir}/$tarfile
 
      #
      #  send to HSM
      #
      elif [ $TSM_FLAG = 'YES' ]
      then

      #
      #   Tar up the directory and put the tarred file in the 
      #   appropriate directory in ${TSMOUT}.
      #  
   
        date
        gtar -cvf ${DATA}/$tarfile -T ${DATA}/$region.$file
        err=$?
        if [ $err -ne 0 ]
        then
          echo "rhist_savenwps.sh:  File $tarfile was not successfully created."
          exit 3
        fi 

        $SCP $SCP_CONFIG ${DATA}/${tarfile} ibmtsm1.ncep.noaa.gov:${rhistdir}/${tarfile}
        date
      fi
   
      rm ${dir}/$region.$file
   
   done
done

[[ $DRY_RUN_ONLY != "YES" ]] && ${USHrhist}/rhist_log.sh $1 $2
exit 0
