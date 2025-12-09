#!/bin/bash
set -x

# No region or wfo input needed; detect automatically
cgnums="CG2 CG3 CG4 CG5"

PDY=$(date +%Y%m%d)
logfile=${workdir}/trans_cgn_${PDY}.log

# Create log if it doesn't exist
if [ ! -f ${logfile} ]; then
   touch ${logfile}
fi

# Detect WFO folders inside $workdir
# Example: workdir/are, workdir/sew, workdir/bro, workdir/crp ...
wfos=$(ls -d ${workdir}/*/ | xargs -n1 basename)

echo "Detected WFOs in workdir: $wfos"

for wfo in $wfos
do
  for cgnum in $cgnums
  do
    echo "Checking ${wfo} ${cgnum}..."

    # Expected plot tarball
    dset=${workdir}/${wfo}/${cgnum}/plots_${wfo}_${cgnum}.tar.gz

    # Must exist to transfer
    if [ -f ${dset} ]; then

      echo "Transferring ${dset}..."

      # Transfer to RZDM
      scp ${dset} waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/

      # Extract on RZDM
      ssh waves@emcrzdm "cd /home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/; tar -xf plots_${wfo}_${cgnum}.tar.gz"

      # Remove tarball on RZDM
      ssh waves@emcrzdm "cd /home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/; rm plots_${wfo}_${cgnum}.tar.gz"

      echo "Completed ${wfo} ${cgnum}"

      # Log transfer
      echo "${dset} at $(date -u "+%Y%m%d%H%M")" >> ${logfile}

    fi

  done # cgnum
done   # wfo

