#!/bin/bash

#####################################################################
echo "------------------------------------------------"
echo "JNWPS_PREP_OFS - NWPS ${job^^} processing"
echo "------------------------------------------------"
echo "History:  Sept 2014 - NWPS OFS extraction script setup.   "
#####################################################################

cd $DATA

set -x

if [ -e ${jlogfile} ] ; then rm ${jlogfile} ; fi
startmsg

# Add all NWPS default overrides here
# This config is maintained by NCEP team and is our baseline config for NCEP workstations

# Set database DIRs here
export BATHYdb=${HOMEnwps}/fix/bathy_db
export SHAPEFILEdb=${HOMEnwps}/fix/shapefile_db

# Set our regional baseline here
export DEBUGGING="FALSE"
export ISPRODUCTION="TRUE"
export SITETYPE="EMC"
export ESTOFSTIMESTEP="1"
export ESTOFSHOURS="180"
export ESTOFSDOMAIN="262.00 23.0 0. 682 370 0.029326 0.027027"
export ESTOFSNX="683"
export ESTOFSNY="371"
export RTOFSLON="262.00 282.00"
export RTOFSLAT="23.0 33.00"
export RTOFSDATFILE="pdef_ncep_global"
export RTOFSHOURS="180"
export RTOFSTIMESTEP="3"
export PSURGEHOURS="102"
export PSURGETIMESTEP="1"

# NOTE: This should only be set once your verify your IFPS account
# NOTE: can SSH to LDAD using keyed authentication. Move this export
# NOTE: to your site config: ${HOMEnwps}/etc/${siteid}_config.sh
export SENDLDADALERTS="FALSE"

##Execute OFS script
case ${OFSTYPE} in 
    estofs)
        export CYCLE="${CYC}"
        ${USHnwps}/make_estofs.sh
        export err=$?; err_chk
        rm -rf ${RUNdir}/{*hourly,*hourly.spool}
    ;;
    rtofs)
        export CYCLE="00"
        ${USHnwps}/make_rtofs.sh
        export err=$?; err_chk
        rm -rf ${RUNdir}/{*hourly,*hourly.spool}
    ;;
    psurge)
        export CYCLE="00"
        ${USHnwps}/make_psurge.sh
        export err=$?; err_chk
        rm -rf ${COMOUT}/${OFSTYPE}/{*hourly,*hourly.spool}
    ;;
    *)
        echo "\$OFS type not found"
        export err=293; err_chk
    ;;
esac

if [ $SENDDBN = YES ]; then
    rm -rf ${DATA}/tars
    mkdir ${DATA}/tars
    for i in ${COMOUT}/${OFSTYPE}/*_output; do
        if [ "${OFSTYPE}" == "psurge" ]; then
            find ${i}/ -name *txt -exec basename '{}' ';' >> ${DATA}/tars/${i##*/}.list
            find ${i}/ -name *gz -exec basename '{}' ';' >> ${DATA}/tars/${i##*/}.list
        else
            find ${i}/ -name wave_${OFSTYPE}*_${CYCLE}_*dat -exec basename '{}' ';' > ${DATA}/tars/${i##*/}.list
            find ${i}/ -name *txt -exec basename '{}' ';' >> ${DATA}/tars/${i##*/}.list
        fi

        echo "tar cvf ${DATA}/tars/${i##*/}.tar -C ${i} -T ${DATA}/tars/${i##*/}.list; if [ "$?" = "0" ]; then mv ${DATA}/tars/${i##*/}.tar ${COMOUT}/${OFSTYPE}/; $DBNROOT/bin/dbn_alert MODEL NWPS_ASCII_TAR $job ${COMOUT}/${OFSTYPE}/${i##*/}.tar; fi" >> ${DATA}/tars/tar_cmdfile
    done
    aprun -n24 -N24 -j1 -d1 cfp ${DATA}/tars/tar_cmdfile
fi

#####################################################################
# GOOD RUN
set +x
echo "**************job ${job^^} COMPLETED NORMALLY ON THE IBM"
echo "**************job ${job^^} COMPLETED NORMALLY ON THE IBM"
echo "**************job ${job^^} COMPLETED NORMALLY ON THE IBM"
set -x
#####################################################################

msg="HAS COMPLETED NORMALLY!"
echo $msg
postmsg "$jlogfile" "$msg"

exit 0
############## END OF SCRIPT #######################
