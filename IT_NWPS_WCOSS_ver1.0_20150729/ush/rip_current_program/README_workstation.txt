Rip Current Program + NWPS
Author: donnie.king@noaa.gov && alex.gibbs@noaa.gov
created: 12/10/2013
version: 1.00

#_____________________________SECTION I______________________________________________________________
#
# Configure NWPS to output input file for Rip Current Program
#

1. Download the latest NWPS_Rip_Current_Program.tar.gz and do the following on your modeling box:

>>cd /usr/local/nwps/bin
>>tar xvzf NWPS_Rip_Current_Program.tar.gz
>>rm NWPS_Rip_Current_Program.tar.gz
>>cd rip_current_program

2. Configure your NWPS package to begin dropping wave data along the 5m bathy contour:

# Replace your domain setup script:
>>cp setup.sh $NWPSdir/domain_setup
>>cp inputCG# (domain you wish to extract contour data ONLY) $NWPSdir/domain_setup/templates
>>cat DOMAIN_FILE_ADDITION >> $NWPSdir/domain_setup/domains/SITEID
>>cd $NWPSdir/domain_setup/domains

>>vi SITEID

TO DO in your domain file:
a. Add a new nest (preferrably a very small domain set at ~100m resolution)
b. Ensure there is at least the CRM gridded bathymetry database setup for this domain
c. Edit the final section called: RIP CURRENT PROGRAM: 
   1. toggle RIPPROG="1" to turn it on
   2. set your RIPDOMAIN according to which nest you wish to output data on

NOTE: See the User Manual for a detailed description of how the RAY line is configured at:
   
      innovation.srh.noaa.gov/nwps/nwpsmanual.php/ripcurrent

3. Run the setup script and ensure your additional contour lines have been configured in your sites
   templates. 

>>cd $NWPSdir/domain_setup/
>>./setup.sh $NWPSdir/domain_setup/domains/SITEID Yes SWAN
>>cd ../templates/siteid
>>vi inputCG(your domain of interest: ie CG2 CG3 etc.)

NOTE: ensure your isolines and rays have been included in the specified inputCG file. If so, configure a test
      run and look in the /data/nwps/run/ directory for your 5m_contour_CG* file. If it is there and 
      contains data, NWPS has been successfully configured for the rip current program. 

#_____________________________SECTION 2______________________________________________________________
# Configure the Rip Current program for your site.
#

>>cd $NWPSdir/bin/rip_current_program
>>vi RipForecastShoreline.txt

NOTE: Add a critical point from your /data/nwps/run/5m_contour_CG* file. After yours has been added, remove
      the default option. To convert your longitude to spherical coordinates, simply add 360 to your longitude. 
      For the shoreline direction, change this to the direction this portion of the coast faces (0 to 360).
       
      save and exit vi

>>

      






