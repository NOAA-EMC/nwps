#!/bin/sh
#>ncyc="_$($NDATE)"                                      # This is set in the module prod_util
#>dncyc=".$($NDATE)"
#>ncycm1="_$($NDATE -1)"
#>ncycm2="_$($NDATE -2)"
#>ncycm3="_$($NDATE -3)"
#>ncycm4="_$($NDATE -4)"
#>ncycm5="_$($NDATE -5)"
echo "ncyc="$ncyc
echo "dncyc="$dncyc
echo "ncycm1="$ncycm1
echo "ncycm2="$ncycm2
echo "ncycm3="$ncycm3
echo "ncycm4="$ncycm4
echo "ncycm5="$ncycm5

#export ECF_NAME_ORIG=${ECF_NAME}
#export ECF_PASS_ORIG=${ECF_PASS}

#if [ ! -e $dcom_hist ];then
#    touch $dcom_hist
#fi

#function update_web {
#if [ "${status}" == "RUNNING" ];then
#    export status="ACTIVE"
#    export color=green
#elif [ "${status}" == "FINISHED" ];then
#    export status="DONE"
#    export color=black
#elif [ "${status}" == "ABORTED" ];then
#    export color=darkred
#elif [ "${status}" == "OLD DATA" ];then
#    export color=grey
#elif [ "${status}" == "ERROR" ];then
#    export status="N/A"
#    export color=red
#else
#    export color=magenta
#fi
#if [ "a${step}" == "a" ]; then
#    echo "{\"wfo\":\"${wfo^^}\",\"tstart\":\"<b><font color='darkslategray'>$tstart</font></b>\",\"tstop\":\"<b><font color='darkslategray'>$tstop</font></b>\",\"region\":\"$region\",\"stat\":\"<font color='$color'>$status</font>\",\"job\":\"<b><font color='$color'>${step^^}</font></b>\",\"options\":\"<a href='warnings/Warn_Forecaster_${wfo^^}${dncyc:0:9}.txt'>click</a>\"}," >> ${web_status_file}
#else
#    echo "{\"wfo\":\"${wfo^^}\",\"tstart\":\"<b><font color='darkslategray'>$tstart</font></b>\",\"tstop\":\"<b><font color='darkslategray'>$tstop</font></b>\",\"region\":\"$region\",\"stat\":\"<font color='$color'>${status}</font>\",\"job\":\"<b><font color='$color'>${step^^}</font></b>\",\"options\":\"<a href='warnings/Warn_Forecaster_${wfo^^}${dncyc:0:9}.txt'>click</a>\"}," >> ${web_status_file}
#fi
#}

function process_nwps_dcom {
    #cat /dev/null > ${web_status_file}
    qorder=1
    nrunning=0
    nfinished=0
    nignored=0
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
            wfo=$(echo ${dfile} ${dcom}|awk -F_ '{print $2}')
            ecf_wfo=$(grep ${wfo} ${PARMnwps}/wfo.tbl)
            region=$(echo ${ecf_wfo} |awk -F"/" '{print $1}')
            if grep -q "STARTED .*$dfile" $dcom_hist && grep -q "FINISHED.*${dfile}" $dcom_hist; then
                #--- Run started today has already completed. Remove wind file from execution list. ---
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="FINISHED"
                export step=""
                export job=""
                export tstart=$(grep STARTED.*${dfile} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstop=$(grep FINISHED.*${dfile} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                ((nfinished++))
                echo -ne "$dfile\t\tFINISHED\n"
                #update_web
            elif grep -q "STARTED .*$dfile" $dcom_histm1 && grep -q "FINISHED.*${dfile}" $dcom_hist; then
                #--- Run started yesterday has already completed. Remove wind file from execution list. ---
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="FINISHED"
                export step=""
                export tstart=$(grep STARTED.*${dfile} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)
                export tstop=$(grep FINISHED.*${dfile} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)
                ((nfinished++))
                echo -ne "$dfile\t\tFINISHED\n"
                #update_web
            #elif (grep -q "STARTED .*$dfile" $dcom_histm1 || grep -q "STARTED .*$dfile" $dcom_hist) && ! grep -q "FINISHED.*${dfile}" $dcom_hist && (ecflow_client --group="get ${ECF_NAME%/*}/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:aborted); then
            elif (grep -q "STARTED .*$dfile" $dcom_histm1 || grep -q "STARTED .*$dfile" $dcom_hist) && ! grep -q "FINISHED.*${dfile}" $dcom_hist && [ -z $(bjobs -u $USER | grep $(tail -1 ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log | awk -F"<" '{print $2}' | awk -F">" '{print $1}') | awk '{print $1}') ]; then
                #--- Run has been aborted. Remove wind file from execution list. ---
                echo -ne "$dfile\t\t${wfo}\t\t\ta ${ecf_wfo^^} aborted\n"
                export status="ABORTED"
                export step=""
                export tstart=$(grep STARTED.*${dfile} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstart=${tstart:-$(grep STARTED.*${dfile} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)}
                export tstop=""
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
                #update_web
            #elif (grep -q "STARTED .*$dfile" $dcom_histm1 || grep -q "STARTED .*$dfile" $dcom_hist) && ! grep -q "FINISHED.*${dfile}" $dcom_hist && ! (ecflow_client --group="get ${ECF_NAME%/*}/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:aborted); then
            elif (grep -q "STARTED .*$dfile" $dcom_histm1 || grep -q "STARTED .*$dfile" $dcom_hist) && ! grep -q "FINISHED.*${dfile}" $dcom_hist && [ ! -z $(bjobs -u $USER | grep $(tail -1 ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log | awk -F"<" '{print $2}' | awk -F">" '{print $1}') | awk '{print $1}') ]; then
                #--- Run is still being executed. Remove wind file from execution list. ---
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="RUNNING"
                #export step=$(ecflow_client "--group=get ${ECF_NAME%/*}/${ecf_wfo}; show state"|grep "task.*state:active"|awk '{print $2}'|sed 's/jnwps_//g')
                export tstart=$(grep STARTED.*${dfile} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                export tstart=${tstart:-$(grep STARTED.*${dfile} ${dcom_histm1}|awk '{print $NF}'|cut -c9-)}
                export tstop=""
                ((nrunning++))
                echo -ne "$dfile\t\tACTIVE\n"
                #update_web
            elif grep -q "FINISHED.*${dfile}" $dcom_hist; then
                #--- Something is wrong: run status is FINISHED, but it was never recorded as STARTED. Remove wind file from execution list. ---
                echo "$dfile\t\tFINISHED but not STARTED?, please investigate!!!!!!!"
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                export status="FINISHED"
                export step=""
                export tstart=""
                export tstop=$(grep FINISHED.*${dfile} ${dcom_hist}|awk '{print $NF}'|cut -c9-)
                ((nfinished++))
                #update_web
                err=254; err_chk
            #elif ecflow_client --group="get ${ECF_NAME%/*}/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:active; then
            elif [ ! -z $(bjobs -u $USER | grep $(tail -1 ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log | awk -F"<" '{print $2}' | awk -F">" '{print $1}') | awk '{print $1}') ]; then
                #--- WFO for this run cannot be traced. Remove wind file from execution list. ---
                echo -ne "$dfile\t\t${wfo}\t\t\ta ${ecf_wfo^^} running\n"
                export status="UNKN_RUN"
                export step=""
                export tstart=""
                export tstop=""
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
                #update_web
            elif grep -q "ERROR.*${dfile}" $dcom_hist; then
                #--- An error had been recorded at the time of run queueing. Remove wind file from execution list. ---
                echo -ne "$dfile\t\t${wfo}\t\t\ta ${ecf_wfo^^} has_an_error.\n"
                export status="ERROR"
                export step=""
                export tstart=""
                export tstop=""
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
                #update_web
            elif echo $dfile| grep -q -v -E "${ncyc}|${ncycm1}|${ncycm2}|${ncycm3}|${ncycm4}|${ncycm5}"; then
                #--- Wind file set for this WFO is older than 6 cycles. Remove wind file from execution list. ---
                echo -ne "$dfile\t\tSKIPPING\t\t(> 6 cycles old)\n"
                export status="OLD_DATA"
                export step=""
                export tstart=""
                export tstop=""
                #update_web
                DCOM_FILES=( "${DCOM_FILES[@]/${dfile}}" )
                ((nignored++))
            else
                #--- Wind file set has not been run yet, and is not older than 6 cycles. Keep in list for execution. ---
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

#echo " "
#echo "\"STATUS WHEN DATACHK STARTS\":"
#process_nwps_dcom
#echo " "
#export DCOM_FILES=(${DCOM_FILES[@]})

#echo "Number of DCOM_FILES ="${#DCOM_FILES[@]}
#if [ "${#DCOM_FILES[@]}" -eq 0 ];then
#    echo "========================"
#    echo "NO DCOM FILES TO PROCESS"
#    echo "========================"
#    #        set -xa
#    #export ECF_NAME=${ECF_NAME}_info ECF_PASS=FREE
#    #ecflow_client --label=queued "`echo -ne "\n***COUNTING THE LATEST FILES FOR EACH WFO ONLY.***\n++++++++++++++++++++++++++++++++++++++++++\n
#    #Number of dcomfiles processed: ${nfinished}\n
#    #Number of dcomfiles ignored: ${nignored}\n#
#    #Number of jobs running: ${nrunning}\n
#    #Number of jobs in queue: ${#DCOM_FILES[@]}\n
#    #\n
#    #PUBLIC STATUS PAGE:\n
#    #http://www.nco.ncep.noaa.gov/pmb/spa/nwps/\n=========================================="`"
#    #export ECF_NAME=${ECF_NAME_ORIG} ECF_PASS=${ECF_PASS_ORIG}
#    #        set +xa
#    #echo "Number of dcomfiles processed: "${nfinished}
#    #echo "Number of dcomfiles ignored: "${nignored}
#    #echo "Number of jobs running: "${nrunning}
#    #echo "Number of jobs in queue: "${#DCOM_FILES[@]}
#    sleep 5
#else
#    echo "============"


#AW111116    for runit in ${DCOM_FILES[@]}; do

regions="sr er wr ar pr"
cycles="00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23"

while read line
do                             #read line
  for region in $regions
  do                             #region
   if [ "${region}" == "sr" ]; then
      wfos="bro crp hgx lch lix mob tae tbw key mfl mlb jax sju"
   elif [ "${region}" == "er" ]; then
      wfos="chs ilm mhx akq lwx phi okx box gyx car"
   elif [ "${region}" == "wr" ]; then
      wfos="sew pqr mfr eka mtr lox sgx"
   elif [ "${region}" == "pr" ]; then
      wfos="hfo gua"
   elif [ "${region}" == "ar" ]; then
      wfos="ajk aer alu afg" 
   fi

   PDY=$line
   PDYm1=$(date +%Y%m%d -d "$PDY - 1 day")
   PDYm2=$(date +%Y%m%d -d "$PDY - 2 day")
   PDYm3=$(date +%Y%m%d -d "$PDY - 3 day")
   PDYp1=$(date +%Y%m%d -d "$PDY + 1 day")
   PDYp2=$(date +%Y%m%d -d "$PDY + 2 day")
   PDYp3=$(date +%Y%m%d -d "$PDY + 3 day")

   yy=`echo ${PDY} | cut -c1-4`
   yymm=`echo ${PDY} | cut -c1-6`

   export GESOUT=${COMROOT}/${NET}/$ver/${NET}.${PDY}/nwges
   export GESOUTm1=${COMROOT}/${NET}/$ver/${NET}.${PDYm1}/nwges

   #mkdir $HPSSARCHdir
   #cd $HPSSARCHdir
   #if [ ! -d ${HPSSARCHdir}/${region}.${PDY} ]; then
   #   hsi get /NCEPDEV/emc-marine/5year/Andre.VanderWesthuysen/rh${yy}/${yymm}/${PDY}/com_nwps_para_${region}.${PDY}.keep.tar
   #   if [ -f ${HPSSARCHdir}/com_nwps_para_${region}.${PDY}.keep.tar ]; then
   #      tar -xvf com_nwps_para_${region}.${PDY}.keep.tar
   #      rm com_nwps_para_${region}.${PDY}.keep.tar
   #   fi
   #   #--- For period on 2017/08-2017/09 where tarfile was misnamed ---
   #   hsi get /NCEPDEV/emc-marine/5year/Andre.VanderWesthuysen/rh${yy}/${yymm}/${PDY}/_com_nwps_para_${region}.${PDY}.keep.tar
   #   if [ -f ${HPSSARCHdir}/_com_nwps_para_${region}.${PDY}.keep.tar ]; then
   #      tar -xvf _com_nwps_para_${region}.${PDY}.keep.tar
   #      rm _com_nwps_para_${region}.${PDY}.keep.tar
   #   fi
   #   #----------------------------------------------------------------
   #fi

   for wfo in $wfos
   do                    #wfo
    datafound='false'
    for CYCLE in $cycles
    do                    #CYCLE
      #if [ ${datafound} == 'false' ]      #datafound
      #then
        workdir=$HPSSARCHdir/${region}.${PDY}/${wfo}/${CYCLE}
        echo 'Searching '${workdir}'...'
        windfile=`ls ${workdir}/CG1/NWPSWINDGRID* | tail -1`
        if [ "${windfile}" != "" ]        #NWPSWINDGRID found
        then
          runcomplete='false'
          runSTARTED=$(grep ${wfo} $GESOUT/dcom_hist.txt | grep ${PDY} | grep /${CYCLE}/ | grep STARTED | tail -1)
          runFINISHED=$(grep ${wfo} $GESOUT/dcom_hist.txt | grep ${PDY} | grep /${CYCLE}/ | grep FINISHED | tail -1)
          echo $runSTARTED
          echo $runFINISHED
          if [ "${runSTARTED}" != "" ] && [ "${runFINISHED}" != "" ]; then
             echo 'Archive found. This '${wfo}' job already completed.'
             runcomplete='true'
          elif [ "${runSTARTED}" != "" ] && [ "${runFINISHED}" == "" ]; then
             echo 'Archive found. This '${wfo}' job already running.'
             continue 2
          fi

          if [ ${runcomplete} == 'false' ]
          then           #runcomplete
            echo 'Archive found. Executing retrospective run.'
            nrunning=0

    runit=${windfile}

    # make sure NWPS COM directory exists
    if [ "${SENDCOM}" = YES ]; then
       mkdir -p $GESOUT
    fi

    export dcom_hist=$GESOUT/dcom_hist.txt
    export dcom_histm1=$GESOUTm1/dcom_hist.txt

    if [ ! -e $dcom_hist ];then
       touch $dcom_hist
    fi

        if [ "$nrunning" -lt 18 ]; then
            #wfo=$(echo ${runit}|awk -F_ '{print $2}')
            ecf_wfo=$(grep ${wfo} ${PARMnwps}/wfo.tbl)
            #region=$(echo ${ecf_wfo} |awk -F"/" '{print $1}')
            #if ecflow_client --group="get ${ECF_NAME%/*}/${ecf_wfo}; show state" 2> /dev/null|grep --quiet state:active; then
	    if [ ! -z $( qstat -u $USER | grep $(tail -1 ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log) | awk '{print $1}' ) ]; then
                echo "Not starting ${ecf_wfo} with ${runit}, ${ecf_wfo^^} is active."
		#DCOM_FILES=( "${DCOM_FILES[@]/${runit}}" )
            else
                echo -ne "QUEUEING:\t\t$wfo\n"

                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_prep_ret.o 
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_forecast_cg1_ret.o
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_post_cg1_ret.o
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_prdgen_cg1_ret.o
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_wavetrack_cg1_ret.o
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_prdgen_cg0_ret.o
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_forecast_cgn_ret.o
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_post_cgn_ret.o
                rm ${COMROOT}/${NET}/${ver}/NWPS_${wfo}_prdgen_cgn_ret.o

                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_prep_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_fc_cg1_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_po_cg1_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_pd_cg1_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_wt_cg1_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_pd_cg0_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_fc_cgn_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_po_cgn_ret
                rm ${DATA}/logs/jlogfiles/jlogfile.pnwps_${wfo}_pd_cgn_ret

                echo "Setting PDY and CYC for "${wfo}"..."
                echo "export PDYm3=$PDYm3" > ${DATA}/PDY.${wfo^^}
                echo "export PDYm2=$PDYm2" >> ${DATA}/PDY.${wfo^^}
                echo "export PDYm1=$PDYm1" >> ${DATA}/PDY.${wfo^^}
                echo "export PDY=$PDY"     >> ${DATA}/PDY.${wfo^^}
                echo "export PDYp1=$PDYp1" >> ${DATA}/PDY.${wfo^^}
                echo "export PDYp2=$PDYp2" >> ${DATA}/PDY.${wfo^^}
                echo "export PDYp3=$PDYp3" >> ${DATA}/PDY.${wfo^^}
                echo "$CYCLE" > ${DATA}/CYC.${wfo^^}

                echo "Populating jobcards for "${wfo}"..."
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_prep_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_prep_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_forecast_cg1_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_forecast_cg1_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_post_cg1_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_post_cg1_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_prdgen_cg1_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_prdgen_cg1_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_wavetrack_cg1_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_wavetrack_cg1_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_prdgen_cg0_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_prdgen_cg0_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_forecast_cgn_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_forecast_cgn_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_post_cgn_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_post_cgn_ret.ecf.${wfo}
                sed "s/%WFO%/$wfo/g" ${NWPSdir}/dev/ecf/jnwps_prdgen_cgn_ret.ecf.tmpl > ${NWPSdir}/dev/ecf/jnwps_prdgen_cgn_ret.ecf.${wfo}

                echo $runit                                                  > ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_prep_ret.ecf.${wfo}          >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_forecast_cg1_ret.ecf.${wfo}  >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_post_cg1_ret.ecf.${wfo}      >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_prdgen_cg1_ret.ecf.${wfo}    >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_wavetrack_cg1_ret.ecf.${wfo} >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_prdgen_cg0_ret.ecf.${wfo}    >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_forecast_cgn_ret.ecf.${wfo}  >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_post_cgn_ret.ecf.${wfo}      >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log; 
                qsub ${NWPSdir}/dev/ecf/jnwps_prdgen_cgn_ret.ecf.${wfo}    >> ${NWPSdir}/dev/ecf/jobids_${wfo}_ret.log

                echo 'Submitted run for '${wfo}': '${runit}

                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo} 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_prep 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_forecast_cg1 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_post_cg1 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_wavetrack_cg1 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_forecast_cgn 2> /dev/null
                #ecflow_client --requeue force ${ECF_NAME%/*}/${ecf_wfo}/jnwps_post_cgn 2> /dev/null
                #>export err=$?
                #>if [ "$err" -eq 0 ]; then
                    export tstart=$(date -u "+%Y%m%d%H%M")
                    echo "STARTED $runit AT ${tstart}" >> ${dcom_hist}
                    DCOM_FILES=( "${DCOM_FILES[@]/${runit}}" )
                    ((nrunning++))
                #>else 
                #>    echo -ne "ERROR:\t\tREQUEUEING $(echo ${runit}|awk -F_ '{print $2}') FAILED.\n"
                #>    export tstart=$(date -u "+%Y%m%d%H%M")
                #>    echo "ERROR $runit AT ${tstart}" >> ${dcom_hist}
                #>    DCOM_FILES=( "${DCOM_FILES[@]/${runit}}" )
                #>    #err_chk
                #>fi
                sleep 5
            fi
        else
            echo -ne "\nNWPS has reached its limit of running 18 jobs on 9 nodes, \nThe following DCOM files will not be processed at this time:\n$(echo $DCOM_FILES|tr ' ' '\n')\n\n"
            #export ECF_NAME="${ECF_NAME}_info" ECF_PASS=FREE
            #ecflow_client --label=queued "`echo "${FORECASTWINDdir} ${DCOM_FILES[@]}"|tr ' ' '\n'| \
            #    awk -F'NWPSWINDGRID_' '{print $2}'|sed 's/\.tar\.gz//g'|tr '[a-z]' '[A-Z]'`"
            #export ECF_NAME=${ECF_NAME_ORIG} ECF_PASS=${ECF_PASS_ORIG}
            sleep 4
            break
        fi
#AW11116    done
    echo "============"
#fi

echo " "
echo "\"STATUS WHEN DATACHK ENDS\":"
#AW111116process_nwps_dcom

            continue 2
          fi           #runcomplete
         fi        #NWPSWINDGRID found
      #fi       #datafound
    done     #CYCLE
   done     #wfo
  done     #region
done < ${NWPSdir}/dev/scripts/retro_list.dat

#sort -t">" -k10 -o ${web_status_file} ${web_status_file}
#sed -i '1s/^/[\n/g' ${web_status_file}
#sed -i '$s/,$/\n]/g' ${web_status_file}

echo -ne "\n\n"
exit 0
