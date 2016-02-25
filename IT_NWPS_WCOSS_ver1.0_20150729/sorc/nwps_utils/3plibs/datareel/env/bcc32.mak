#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile Contents: Makefile for command line builds
# C/C++ Compiler Used: Borland C++ 5.5 for WIN32
# Produced By: DataReel Software Development Team
# File Creation Date: 05/25/2001 
# Date Last Modified: 10/19/2005
# --------------------------------------------------------------- 
# Setup my path to the gxcode library
GCODE_LIB_DIR = # Set absoulte path to the DataReel library here

!include $(GCODE_LIB_DIR)/winslib/bcc32.env

# Define a name for the executable
# PROJECT = 

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT)$(EXE_EXT)

!include project.mak

# Setup the path to the gxcode library
#GXCODE_LIB_PATH = $(GCODE_LIB_DIR)$(PATHSEP)winslib
#LIB_GXCODE = $(GXCODE_LIB_PATH)$(PATHSEP)gxcode32.lib
# LIB_GXCODE = $(GXCODE_LIB_PATH)$(PATHSEP)gxcode64.lib

LIB_GXCODE = gxcode32.lib

# BCC 32 libs defined in the BCC32 env file
ALLOBJ = $(ALLOBJ) $(OBJECTS) # wildargs.obj # Expand command line wildcards
ALLRES = $(ALLRES)
ALLLIB = $(ALLLIB) $(LIBRARIES) $(LIB_GXCODE)

$(PROJECT).exe:	$(OBJECTS)
	$(LINKER) @&&!
	$(LINKER_FLAGS) +
	$(ALLOBJ), +
	$(PROJECT),, +
	$(ALLLIB), +
	$(DEFFILE), +
	$(ALLRES)
!
# ===============================================================

# Remove OBJS, debug files, and executable after running nmake 
# ===============================================================
clean:
	@echo Removing all .tds files from working directory...
	if exist *.tds del *.tds 

	@echo Removing all .ils files from working directory...
	if exist *.ils del *.ils 

	@echo Removing all .ilf files from working directory...
	if exist *.ilf del *.ilf 

	@echo Removing all .ilc files from working directory...
	if exist *.ilc del *.ilc 

	@echo Removing all .ild files from working directory...
	if exist *.ild del *.ild 

	@echo Removing all .map files from working directory...
	if exist *.map del *.map 

	@echo Removing all .OBJ files from working directory...
	if exist *.obj del *.obj 

	@echo Removing the EXECUTABLE file from working directory
	if exist $(PROJECT).exe del $(PROJECT).exe 

	@echo Removing all test LOG files from working directory...
	if exist *.log del *.log 

	@echo Removing all test OUT files from working directory...
	if exist *.out del *.out 

	@echo Removing all temporary ARP cache files from working directory...
	if exist arpcache.txt del arpcache.txt

	@echo Removing all test EDS files from working directory...
	if exist *.eds del *.eds 

	@echo Removing all test DATABASE files from working directory...
	if exist *.gxd del *.gxd 

	@echo Removing all test INDEX files from working directory...
	if exist *.btx del *.btx 
	if exist *.gix del *.gix 

	@echo Removing all test InfoHog files from working directory...
	if exist *.ihd del *.ihd 
	if exist *.ihx del *.ihx
# --------------------------------------------------------------- 
#####################
#### End of File ####
#####################


