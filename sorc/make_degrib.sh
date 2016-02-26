# Support Team:
#
# Contributors: 
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to build DEGRIB
#
# ----------------------------------------------------------- 

echo "Building source code DIRs"

# Setup our NWPS environment                                                    
export pwd=`pwd`
export NWPSdir=${pwd%/*}
if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi
echo "Building degrib" 
PWD=$(pwd)
cd degrib
rm -r degrib
gunzip -c degrib-src.tar.gz | tar -xf -
cd degrib/src
./config-linux.sh
cd degrib
sed -i 's/all: $(PRJ_NAME) $(CLOCK_NAME) $(DP_NAME) $(DRAWSHP_NAME) $(TCL_NAME) $(TK_NAME)/all: $(PRJ_NAME) $(CLOCK_NAME) $(DP_NAME) $(DRAWSHP_NAME) /g' Makefile
sed -i '/cp \$(/d' Makefile
cd ..
make
mv degrib/degrib $NWPSdir/exec/degrib


cd ${PWD}
echo "Done building DEGRIB"
