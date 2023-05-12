#!/bin/sh
set -xa
if [ "${envir}" != para ]; then
   ncyc="_$($NDATE)"
   dncyc=".$($NDATE)"
   ncycm1="_$($NDATE -1)"
   ncycm2="_$($NDATE -2)"
   ncycm3="_$($NDATE -3)"
   ncycm4="_$($NDATE -4)"
   ncycm5="_$($NDATE -5)"
else
   # for testing in para, set hour
   nhour=23
   ncyc="_$($NDATE 0 ${PDY}${nhour})"
   dncyc=".$($NDATE 0 ${PDY}${nhour})"
   ncycm1="_$($NDATE -1 ${PDY}${nhour})"
   ncycm2="_$($NDATE -2 ${PDY}${nhour})"
   ncycm3="_$($NDATE -3 ${PDY}${nhour})"
   ncycm4="_$($NDATE -4 ${PDY}${nhour})"
   ncycm5="_$($NDATE -5 ${PDY}${nhour})"
fi

export ECF_NAME_ORIG=${ECF_NAME}
export ECF_PASS_ORIG=${ECF_PASS}

if [ ! -e $dcom_hist ];then
    touch $dcom_hist
fi

function update_web {
if [ "${status}" == "RUNNING" ];then
    export status="ACTIVE"
    export color=green
elif [ "${status}" == "FINISHED" ];then
    export status="DONE"
    export color=black
elif [ "${status}" == "ABORTED" ];then
    export color=darkred
elif [ "${status}" == "OLD DATA" ];then
    export color=grey
elif [ "${status}" == "ERROR" ];then
    export status="N/A"
    export color=red
else
    export color=magenta
fi
if [ "a${step}" == "a" ]; then
    echo "{\"wfo\":\"${wfo^^}\",\"tstart\":\"<b><font color='darkslategray'>$tstart</font></b>\",\"tstop\":\"<b><font color='darkslategray'>$tstop</font></b>\",\"region\":\"$region\",\"stat\":\"<font color='$color'>$status</font>\",\"job\":\"<b><font color='$color'>${step^^}</font></b>\",\"options\":\"<a href='warnings/Warn_Forecaster_${wfo^^}${dncyc:0:9}.txt'>click</a>\"}," >> ${web_status_file}
else
    echo "{\"wfo\":\"${wfo^^}\",\"tstart\":\"<b><font color='darkslategray'>$tstart</font></b>\",\"tstop\":\"<b><font color='darkslategray'>$tstop</font></b>\",\"region\":\"$region\",\"stat\":\"<font color='$color'>${status}</font>\",\"job\":\"<b><font color='$color'>${step^^}</font></b>\",\"options\":\"<a href='warnings/Warn_Forecaster_${wfo^^}${dncyc:0:9}.txt'>click</a>\"}," >> ${web_status_file}
fi
}

function process_nwps_dcom {
    cat /dev/null > ${web_status_file}
    qorder=1
    nrunning=0
    nfinished=0
    nignored=0
#    DCOM_FILES=($( for i in $(cat ${FIXnwps}/wfolist.dat |grep -v -E "^$|#"|tr '[A-Z]' '[a-z]'); do
    DCOM_FILES=($( for i in $(cat ${PARMnwps}/wfo.tbl|grep -v "#"|awk -F"/" '{print $2}'); do
                        if ls -1rt ${FORECASTWINDdir}/*_${i}* &> /dev/null; then
                            ls -1rt ${FORECASTWINDdir}/*_${i}*|tail -n 1
                        fi
                    done| tr '\n' ' '))
    echo "================================================================================================"
    echo -ne "Processing ${#DCOM_FILES[@]} DCOM files:\t\t\t|\tSTATUS\t\t|\t(priority)\n"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    if [ "0${DCOM_FILES}" == "0" ];then
        echo "NO NEW DCOM FILES IN THE LAST 6 CYCLES."
    else
        echo "PROCESSING LASTEST WFO FILES FOR THE LAST 6 CYCLES ONLY."
        for dfile in ${DCOM_FILES[@]}; do
            dfileH=`basename $dfile`
            wfo=$(echo ${dfile} ${dcom}|awk -F_ '{print $2}')
            ecf_wfo=$(grep ${wfo} ${PARMnwps}/wfo.tbl)
            region=$(echo ${ecf_wfo} |awk -F"/" '{print $1}')
            dcom_name=$(ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}/jnwps_prep; show state"|grep label|awk '{print $NF}'|sed 's/\"//g')
            if grep -q "STARTED .*$dfileH" $dcom_hist && grep -q "FINISHED.*${dfileH}" $dcom_hist; then
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="FINISHED"
                export step=""
                export job=""
                export tstart=$(grep STARTED.*${dfileH} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstop=$(grep FINISHED.*${dfileH} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                ((nfinished++))
                echo -ne "$dfile\t\tFINISHED\n"
                update_web
            elif grep -q "STARTED .*$dfileH" $dcom_histm1 && grep -q "FINISHED.*${dfileH}" $dcom_hist; then
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="FINISHED"
                export step=""
                export tstart=$(grep STARTED.*${dfileH} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)
                export tstop=$(grep FINISHED.*${dfileH} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)
                ((nfinished++))
                echo -ne "$dfile\t\tFINISHED\n"
                update_web
            elif (grep -q "STARTED .*$dfileH" $dcom_histm1 || grep -q "STARTED .*$dfileH" $dcom_hist) && ! grep -q "FINISHED.*${dfileH}" $dcom_hist && \
                (ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:aborted) && \
                (! grep -q "ABORTED.*$dfileH" ${dcom_hist} || ! grep -q "ABORTED.*$dfileH" ${dcom_hist}); then
                echo -ne "$dfile\t\t${wfo}\t\t\ta ${ecf_wfo^^} aborted\n"
                export status="ABORTED"
                export step=""
                export tstart=$(grep STARTED.*${dfileH} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstart=${tstart:-$(grep STARTED.*${dfileH} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)}
                export tstop=""
                echo "ABORTED $dfile AT ${tstart}" >> ${dcom_hist}
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
                update_web
            elif grep -q "ABORTED .*${dfileH}" $dcom_hist && ! grep -q "FINISHED.*${dfileH}" $dcom_hist && \
                ! (ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:active); then
                echo -ne "$dfile\t\t${wfo}\t\t\ta ${ecf_wfo^^} aborted\n"
                export status="ABORTED"
                export step=""
                export tstart=$(grep STARTED.*${dfileH} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstart=${tstart:-$(grep STARTED.*${dfileH} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)}
                export tstop=""
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
                update_web
            elif (grep -q "STARTED .*$dfileH" $dcom_histm1 || grep -q "STARTED .*$dfileH" $dcom_hist) && \
                ! grep -q "FINISHED.*${dfileH}" $dcom_hist && (ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null|grep "family ${wfo}" |grep --quiet state:complete); then
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="FINISHED"
                export step=""
                export tstart=$(grep STARTED.*${dfileH} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstart=${tstart:-$(grep STARTED.*${dfileH} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)}
                export tstop=$(date -u "+%Y%m%d%H%M")
                ((nfinished++))
                echo "FINISHED $dfile AT ${tstop}" >> ${dcom_hist}
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                update_web
            elif (grep -q "STARTED .*$dfileH" $dcom_histm1 || grep -q "STARTED .*$dfileH" $dcom_hist) && \
                ! grep -q "FINISHED.*${dfileH}" $dcom_hist && ! (ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:aborted); then
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="RUNNING"
                export step=$(ecflow_client "--group=get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state"|grep "task.*state:active"|awk '{print $2}'|sed 's/jnwps_//g')
                export tstart=$(grep STARTED.*${dfileH} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstart=${tstart:-$(grep STARTED.*${dfileH} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)}
                export tstop=""
                ((nrunning++))
                echo -ne "$dfile\t\tACTIVE\n"
                update_web
            elif grep -q "FINISHED.*${dfileH}" $dcom_hist; then
                echo "$dfile\t\tFINISHED but not STARTED?, please investigate!!!!!!!"
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="FINISHED"
                export step=""
                export tstart=""
                export tstop=$(grep FINISHED.*${dfileH} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                ((nfinished++))
                update_web
            elif ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:active; then
                echo -ne "${dcom_name}\t\t${wfo}\t\t\ta ${ecf_wfo^^} running\n"
                export status="RUNNING"
                export step=$(ecflow_client "--group=get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state"|grep "task.*state:active"|awk '{print $2}'|sed 's/jnwps_//g')
                # JY !!!! should it be dfile other than ${dcom_name} in the following??? 
                export tstart=$(grep STARTED.*${dcom_name} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstop=""
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nrunning++))
                update_web
            elif grep -q "ERROR.*${dfileH}" $dcom_hist; then
                echo -ne "$dfile\t\t${wfo}\t\t\ta ${ecf_wfo^^} has_an_error.\n"
                export status="ERROR"
                export step=""
                export tstart=""
                export tstop=""
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
                update_web
            elif echo $dfile| grep -q -v -E "${ncyc}|${ncycm1}|${ncycm2}|${ncycm3}|${ncycm4}|${ncycm5}"; then
                echo -ne "$dfile\t\tSKIPPING\t\t(> 6 cycles old)\n"
                export status="OLD_DATA"
                export step=""
                export tstart=""
                export tstop=""
                update_web
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
            else
                echo -ne "$dfile\t\tadding to QUEUE\t\t(${qorder})\n"
                export step=""
                ((qorder++))
            fi
        done
        echo " "
        export DCOM_FILES=($(echo ${DCOM_FILES[@]} |grep -E "${ncyc}|${ncycm1}|${ncycm2}|${ncycm3}|${ncycm4}|${ncycm5}"))
        export DCOM_FILES=(${DCOM_FILES[@]})
    fi
    for rfile in $(echo ${DCOM_FILES[@]}|tr ' ' '\n'|grep -v -E "${ncyc}|${ncycm1}|${ncycm2}|${ncycm3}|${ncycm4}|${ncycm5}"); do
        echo $rfile
        DCOM_FILES=( "${DCOM_FILES[@]/${rfile}}" )
    done
    export DCOM_FILES=(${DCOM_FILES[@]})
    echo " "
    echo -ne "***COUNTING THE LATEST FILES FOR EACH WFO ONLY.***\n"
    echo "++++++++++++++++++++++++++++++++++++++++++"
    echo -ne "Number of dcomfiles processed:\t\t${nfinished}\n"
    echo -ne "Number of dcomfiles ignored:\t\t${nignored}\n"
    echo -ne "Number of jobs running:\t\t\t${nrunning}\n"
    echo -ne "Number of jobs in queue:\t\t${#DCOM_FILES[@]}\n"
    echo "=========================================="
}

echo " "
echo "\"STATUS WHEN DATACHK STARTS\":"
process_nwps_dcom
echo " "
export DCOM_FILES=(${DCOM_FILES[@]})

if [ "${#DCOM_FILES[@]}" -eq 0 ];then
    echo "========================"
    echo "NO DCOM FILES TO PROCESS"
    echo "========================"
            set -xa
    export ECF_NAME_INFO=${ECF_NAME}_info
    ecflow_client --alter change label queued "`echo -ne "\n***COUNTING THE LATEST FILES FOR EACH WFO ONLY.***\n++++++++++++++++++++++++++++++++++++++++++\n
    Number of dcomfiles processed: ${nfinished}\n
    Number of dcomfiles ignored: ${nignored}\n
    Number of jobs running: ${nrunning}\n
    Number of jobs in queue: ${#DCOM_FILES[@]}\n
    \n
    PUBLIC STATUS PAGE:\n
    http://www.nco.ncep.noaa.gov/pmb/spa/nwps/\n=========================================="`" ${ECF_NAME_INFO}
            set +xa
    sleep 5
else
    echo "============"
    for runit in ${DCOM_FILES[@]}; do
        # JY if [ "$nrunning" -lt 18 ]; then
        if [ "$nrunning" -lt $RUN_LIMIT ]; then
            wfo=$(echo ${runit}|awk -F_ '{print $2}')
            ecf_wfo=$(grep ${wfo} ${PARMnwps}/wfo.tbl)
            region=$(echo ${ecf_wfo} |awk -F"/" '{print $1}')
            if ! ( ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null| grep "family ${wfo}" |grep --quiet state:complete ); then
            # JY if ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:active; then
                echo "Not starting ${ecf_wfo} with ${runint}, ${ecf_wfo^^} is not complete."
                echo "The status of the ${ecf_wfo} is as following:"
                ecflow_client --group="get ${ECF_NAME%/*}/regions/${ecf_wfo}; show state" 2> /dev/null| grep "family ${wfo}" 
                DCOM_FILES=( "${DCOM_FILES[@]/${runit}}" )
            else
                echo -ne "QUEUEING:\t\t$wfo\n"
                ecflow_client --requeue force ${ECF_NAME%/*}/regions/${ecf_wfo} 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_prep 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_forecast_cg1 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_post_cg1 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_wavetrack_cg1 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_forecast_cgn 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_post_cgn 2> /dev/null
                export err=$?
                if [ "$err" -eq 0 ]; then
                    export tstart=$(date -u "+%Y%m%d%H%M")
                    echo "STARTED $runit AT ${tstart}" >> ${dcom_hist}
                    DCOM_FILES=( "${DCOM_FILES[@]/${runit}}" )
                    ((nrunning++))
                else 
                    echo -ne "ERROR:\t\tREQUEUEING $(echo ${runit}|awk -F_ '{print $2}') FAILED.\n"
                    export tstart=$(date -u "+%Y%m%d%H%M")
                    echo "ERROR $runit AT ${tstart}" >> ${dcom_hist}
                    DCOM_FILES=( "${DCOM_FILES[@]/${runit}}" )
                    #err_chk
                fi
                sleep 1
            fi
        else
            echo -ne "\nNWPS has reached its limit of running 18 jobs on 9 nodes, \nThe following DCOM files will not be processed at this time:\n$(echo $DCOM_FILES|tr ' ' '\n')\n\n"
            set -xa
            export ECF_NAME_INFO=${ECF_NAME}_info
            ecflow_client --alter change label queued "`echo -ne "\n***COUNTING THE LATEST FILES FOR EACH WFO ONLY.***\n++++++++++++++++++++++++++++++++++++++++++\n
            Number of dcomfiles processed: ${nfinished}\n
            Number of dcomfiles ignored: ${nignored}\n
            Number of jobs running: ${nrunning}\n
            Number of jobs in queue:\n 
            "$(echo "${FORECASTWINDdir} ${DCOM_FILES[@]}"|tr ' ' '\n'| awk -F'NWPSWINDGRID_' '{print $2}'|sed 's/\.tar\.gz//g'|tr '[a-z]' '[A-Z]')"\n
            PUBLIC STATUS PAGE:\n
            http://www.nco.ncep.noaa.gov/pmb/spa/nwps/\n=========================================="`" ${ECF_NAME_INFO}
            set +xa
            sleep 4
            break
        fi
    done
    echo "============"
fi

set -xa
echo " "
echo "\"STATUS WHEN DATACHK ENDS\":"
process_nwps_dcom

sort -t">" -k10 -o ${web_status_file} ${web_status_file}
sed -i '1s/^/[\n/g' ${web_status_file}
sed -i '$s/,$/\n]/g' ${web_status_file}

echo -ne "\n\n"
