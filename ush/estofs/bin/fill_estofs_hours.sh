#!/bin/bash
# Script used to fill missing ESTOFS hours

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    export err=1; err_chk
fi
if [ ! -e ${USHnwps}/nwps_config.sh ]
then
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

source ${USHnwps}/nwps_config.sh &> /dev/null

myPWD=$(pwd)

# Set our data processing DIRS
LDMdir="${LDMdir}/estofs"
INPUTdir="${INPUTdir}/estofs"

HOURS="144"
if [ "${1}" != "" ]; then HOURS="${1}"; fi
TIMESTEP="1"
end=0

ingest_dir_start=$(cat ${LDMdir}/estofs_waterlevel_start_time.txt)

cd ${LDMdir}
ingest_filehours=$(ls -1rat --color=none *.dat)

for h in ${ingest_filehours} 
do 
    ingest_lasthour=$(echo "${h}" | awk -F_ '{ print $7 }' | sed s/.dat//g) 
    ingest_lastfilename="${h}"
done

end=$(echo "${ingest_lasthour}" | sed s/f00//g | sed s/f0//g | sed s/f//g)
until [ $end -ge $HOURS ]; do
    let end+=$TIMESTEP
    if [ $end -gt $HOURS ]; then break; fi
    FF=`echo $end`
    if [ $end -le 99 ]
	then
	FF=`echo 0$end`
    fi
    if [ $end -le 9 ]
	then
	FF=`echo 00$end`
    fi
    newname=$(echo "${ingest_lastfilename}" | sed s/${ingest_lasthour}/f${FF}/g)
    cp -fv ${ingest_lastfilename} ${newname}
done

cd ${myPWD}

exit 0
