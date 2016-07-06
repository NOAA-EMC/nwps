// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// Projection Algorithms By: Thomas.J.Lefebvre@noaa.gov Mike.Romberg@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 04/18/2013
// ----------------------------------------------------------- // 
// ------------- Program Description and Details ------------- // 
// ----------------------------------------------------------- // 
/*
This software and documentation was produced within NOAA 
and is intended for internal agency use only. Please don't 
distribute any part of this software or documentation without 
first contacting the original author or NOAA agency that 
produced this software. All third party libraries used to 
build this application are subject to the licensing agreement 
stated within the source code and any documentation supplied 
with the third party library.

AWIPS grids data structures.

*/
// ----------------------------------------------------------- // 

// STD LIB includes
#include <ctype.h>

// 3PLIB includes
#include "gxstring.h"

// Project includes
#include "awips_grids.h"

// NOTE: This array must contain the same number of grids as the
// AWIPSGridTypes enumeration. 
const unsigned numAWIPSGridTypes = 37;
const char *AWIPSGridStrings[numAWIPSGridTypes] = {
  "Unknown",
  "Grid201",
  "Grid202",
  "Grid203",
  "Grid204",
  "Grid205",
  "Grid206",
  "Grid207",
  "Grid208",
  "Grid209",
  "Grid210",
  "Grid211",
  "Grid212",
  "Grid213",
  "Grid214",
  "Grid214AK",
  "Grid215",
  "Grid216",
  "Grid217",
  "Grid218",
  "Grid219",
  "Grid221",
  "Grid222",
  "Grid225",
  "Grid226",
  "Grid227",
  "Grid228",
  "Grid229",
  "Grid230",
  "Grid231",
  "Grid232",
  "Grid233",
  "Grid234",
  "Grid235",
  "HRAP",
  "NCEP1",
  "CustomLatLon"
};

AWIPSGrid *SetGrid(AWIPSGridTypes gt)
{
  AWIPSGrid *g;

  switch(gt) {
    case AWIPS_Unknown:
      return 0;

    case AWIPS_Grid201:
      g = (AWIPSGrid *)new Grid201;
      return g;

    case AWIPS_Grid202:
      g = (AWIPSGrid *)new Grid202;
      return g;

    case AWIPS_Grid203:
      g = (AWIPSGrid *)new Grid203;
      return g;

    case AWIPS_Grid204:
      g = (AWIPSGrid *)new Grid204;
      return g;

    case AWIPS_Grid205:
      g = (AWIPSGrid *)new Grid205;
      return g;

    case AWIPS_Grid206:
      g = (AWIPSGrid *)new Grid206;
      return g;

    case AWIPS_Grid207:
      g = (AWIPSGrid *)new Grid207;
      return g;

    case AWIPS_Grid208:
      g = (AWIPSGrid *)new Grid208;
      return g;

    case AWIPS_Grid209:
      g = (AWIPSGrid *)new Grid209;
      return g;

    case AWIPS_Grid210:
      g = (AWIPSGrid *)new Grid210;
      return g;

    case AWIPS_Grid211:
      g = (AWIPSGrid *)new Grid211;
      return g;

    case AWIPS_Grid212:
      g = (AWIPSGrid *)new Grid212;
      return g;

    case AWIPS_Grid213:
      g = (AWIPSGrid *)new Grid213;
      return g;

    case AWIPS_Grid214:
      g = (AWIPSGrid *)new Grid214;
      return g;

    case AWIPS_Grid214AK:
      g = (AWIPSGrid *)new Grid214AK;
      return g;

    case AWIPS_Grid215:
      g = (AWIPSGrid *)new Grid215;
      return g;

    case AWIPS_Grid216:
      g = (AWIPSGrid *)new Grid216;
      return g;

    case AWIPS_Grid217:
      g = (AWIPSGrid *)new Grid217;
      return g;

    case AWIPS_Grid218:
      g = (AWIPSGrid *)new Grid218;
      return g;

    case AWIPS_Grid219:
      g = (AWIPSGrid *)new Grid219;
      return g;

    case AWIPS_Grid221:
      g = (AWIPSGrid *)new Grid221;
      return g;

    case AWIPS_Grid222:
      g = (AWIPSGrid *)new Grid222;
      return g;

    case AWIPS_Grid225:
      g = (AWIPSGrid *)new Grid225;
      return g;

    case AWIPS_Grid226:
      g = (AWIPSGrid *)new Grid226;
      return g;

    case AWIPS_Grid227:
      g = (AWIPSGrid *)new Grid227;
      return g;

    case AWIPS_Grid228:
      g = (AWIPSGrid *)new Grid228;
      return g;

    case AWIPS_Grid229:
      g = (AWIPSGrid *)new Grid229;
      return g;

    case AWIPS_Grid230:
      g = (AWIPSGrid *)new Grid230;
      return g;

    case AWIPS_Grid231:
      g = (AWIPSGrid *)new Grid231;
      return g;

    case AWIPS_Grid232:
      g = (AWIPSGrid *)new Grid232;
      return g;

    case AWIPS_Grid233:
      g = (AWIPSGrid *)new Grid233;
      return g;

    case AWIPS_Grid234:
      g = (AWIPSGrid *)new Grid234;
      return g;

    case AWIPS_Grid235:
      g = (AWIPSGrid *)new Grid235;
      return g;

    case AWIPS_HRAP:
      g = (AWIPSGrid *)new HRAP;
      return g;

    case AWIPS_NCEP1:
      g = (AWIPSGrid *)new NCEP1;
      return g;

    case AWIPS_CustomLatLon:
      g = (AWIPSGrid *)new CustomLatLon;
      return g;

    default:
      break;
  }

  return 0;
}

AWIPSGrid::~AWIPSGrid()
{

}

const char *GetAWIPSGridName(AWIPSGridTypes gt)
{
  int type = (int)gt;
  if(type > ((int)numAWIPSGridTypes-1)) type = AWIPS_Unknown;

  // Find the corresponding grid type
  return AWIPSGridStrings[type];
}

int GridNameCompare(const char *a, const char *b)
// Returns -1 if a < b, 0 if a == b, and 1 if a > b without
// regard for the case of any ASCII letters.
{
  unsigned a_bytes = strlen(a);
  unsigned b_bytes = strlen(b);
  unsigned sn = (a_bytes < b_bytes) ? a_bytes : b_bytes;
  char *ap = (char *)a;
  char *bp = (char *)b;
  for(unsigned i = 0; i < sn; i++) {
    if(tolower(*ap) < tolower(*bp)) return -1;
    if(tolower(*ap++) > tolower(*bp++)) return 1;
  }
  if(a_bytes == b_bytes) return 0;
  if(a_bytes < b_bytes) return -1;
  return 1;
}

int HasAWIPSGrid(const char *gn)
{
  unsigned i;
  for(i = 0; i < numAWIPSGridTypes; i++) {
    if(GridNameCompare(AWIPSGridStrings[i], gn)) return 1;
  }
  return 0;
}

AWIPSGridTypes FindGridType(CoordPair input_gridPointLL, CoordPair input_gridPointUR,
			    CoordPair input_latLonLL, CoordPair input_latLonUR)
{
  CoordPair gridPointLL ,gridPointUR;
  CoordPair latLonLL, latLonUR;
  gxString input_lat_str, input_lon_str;
  gxString lat_str, lon_str;

  // Grid201
  latLonLL.Set(-150.00, -20.826);
  latLonUR.Set(-20.90846, 30.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(65, 65);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid201;
      }
    }
  }

  // Grid 202
  latLonLL.Set(-141.028, 7.838);
  latLonUR.Set(-18.576, 35.617);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(65, 43);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid202;
      }
    }
  }

  // Grid 203
  latLonLL.Set(-185.837, 19.132);
  latLonUR.Set(-53.660, 57.634);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(45, 39);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid203;
      }
    }
  }
  
  // Grid 204
  latLonLL.Set(-250.0, -25.0);
  latLonUR.Set(-109.129, 60.644);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(93, 68);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid204;
      }
    }
  }

  // Grid 205
  latLonLL.Set(-84.904, 0.616);
  latLonUR.Set(-15.000, 45.620);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(45, 39);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid205;
      }
    }
  }

  // Grid 206
  latLonLL.Set(-117.991, 22.289);
  latLonUR.Set(-73.182, 51.072);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(51, 41);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid206;
      }
    }
  }

  // Grid 207
  latLonLL.Set(-175.641, 42.085);
  latLonUR.Set(-93.689, 63.976);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(49, 35);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid207;
      }
    }
  }

  // Grid 208
  latLonLL.Set(-166.219, 10.656);
  latLonUR.Set(-147.844, 27.917);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(25, 25);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid208;
      }
    }
  }

  // Grid 209
  latLonLL.Set(-117.991, 22.289);
  latLonUR.Set(-73.182, 51.072);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(101, 81);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid209;
      }
    }
  }

  // Grid 210
  latLonLL.Set(-77.000, 9.000);
  latLonUR.Set(-58.625, 26.422);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(25, 25);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid210;
      }
    }
  }

  // Grid 211
  latLonLL.Set(-133.459, 12.190);
  latLonUR.Set(-49.385, 57.290);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(93, 65);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid211;
      }
    }
  }

  // Grid 212
  latLonLL.Set(-133.459, 12.190);
  latLonUR.Set(-49.385, 57.290);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(185, 129);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid212;
      }
    }
  }

  // Grid 213
  latLonLL.Set(-141.028, 7.838);
  latLonUR.Set(-18.577, 35.617);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(129, 85);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid213;
      }
    }
  }

  // Grid 214
  latLonLL.Set(-175.641, 42.085);
  latLonUR.Set(-93.689, 63.975);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(97, 69);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid214;
      }
    }
  }
  
  // Grid 214 AK
  latLonLL.Set(-178.571, 40.5301);
  latLonUR.Set(-93.689, 63.975);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(104, 70);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid214AK;
      }
    }
  }

  // Grid 215
  latLonLL.Set(-133.459, 12.190);
  latLonUR.Set(-49.385, 57.290);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(369, 257);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid215;
      }
    }
  }

  // Grid 216
  latLonLL.Set(-173.000, 30.000);
  latLonUR.Set(-62.850, 70.111);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(139, 107);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid216;
      }
    }
  }

  // Grid 217
  latLonLL.Set(-173.000, 30.000);
  latLonUR.Set(-62.850, 70.111);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(277, 213);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid217;
      }
    }
  }

  // Grid 218
  latLonLL.Set(-133.459, 12.190);
  latLonUR.Set(-49.385, 57.290);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(614, 428);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid218;
      }
    }
  }

  // Grid 219
  latLonLL.Set(-119.559, 25.008);
  latLonUR.Set(60.339, 24.028);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(385, 465);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid219;
      }
    }
  }

  // Grid 221
  latLonLL.Set(-145.500, 1.000);
  latLonUR.Set(-2.566, 46.352);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(349, 277);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid221;
      }
    }
  }

  // Grid 222
  latLonLL.Set(-145.500, 1.000);
  latLonUR.Set(-2.566, 46.352);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(59, 47);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid222;
      }
    }
  }

  // Grid 225
  latLonLL.Set(-250.0, -25.0);
  latLonUR.Set(-109.129, 60.644);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(185, 135);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid225;
      }
    }
  }

  // Grid 226
  latLonLL.Set(-133.459, 12.190);
  latLonUR.Set(-49.385, 57.290);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(737, 513);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid226;
      }
    }
  }

  // Grid 227
  latLonLL.Set(-133.459, 12.190);
  latLonUR.Set(-49.385, 57.290);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(1473, 1025);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid227;
      }
    }
  }

  // Grid 228
  latLonLL.Set(0.0, 90.0);
  latLonUR.Set(359.0, -90.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(144, 73);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid228;
      }
    }
  }

  // Grid 229
  latLonLL.Set(0.0, 90.0);
  latLonUR.Set(359.0, -90.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(360, 181);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid229;
      }
    }
  }

  // Grid 230
  latLonLL.Set(0.0, 90.0);
  latLonUR.Set(359.5, -90.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(720, 361);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid230;
      }
    }
  }

  // Grid 231
  latLonLL.Set(0.0, 0.0);
  latLonUR.Set(359.5, 90.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(720, 181);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid231;
      }
    }
  }

  // Grid 232
  latLonLL.Set(0.0, 0.0);
  latLonUR.Set(359.5, 90.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(360, 91);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid232;
      }
    }
  }

  // Grid 233
  latLonLL.Set(0.0, -78.0);
  latLonUR.Set(358.750, 78.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(288, 157);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid233;
      }
    }
  }

  // Grid 234
  latLonLL.Set(-98.000, 15.0);
  latLonUR.Set(-65.000, -45.0);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(133, 121);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid234;
      }
    }
  }
  
  // Grid 235
  latLonLL.Set(0.250, 89.750);
  latLonUR.Set(359.750, -89.750);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(720, 360);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_Grid235;
      }
    }
  }

  // HRAP
  latLonLL.Set(-119.036, 23.097);
  latLonUR.Set(-75.945396, 53.480095);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(801, 881);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_HRAP;
      }
    }
  }

  // Grid NCEP1
  latLonLL.Set(-230.094, -30.4192);
  latLonUR.Set(10.710, 80.01);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(2517.0, 1793.0);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_NCEP1;
      }
    }
  }

  // NCEP1 with normalized latLonLL value
  latLonLL.Set(129.906, -30.4192);
  latLonUR.Set(10.710, 80.01);
  gridPointLL.Set(1, 1);
  gridPointUR.Set(2517.0, 1793.0);
  if((gridPointLL == input_gridPointLL) && (gridPointUR == input_gridPointUR)) {
    input_lat_str << clear << input_latLonLL[0]; input_lat_str.DeleteAfterIncluding(".");
    input_lon_str << clear << input_latLonLL[1]; input_lon_str.DeleteAfterIncluding(".");
    lat_str << clear << latLonLL[0]; lat_str.DeleteAfterIncluding(".");
    lon_str << clear << latLonLL[1]; lon_str.DeleteAfterIncluding(".");
    if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
      input_lat_str << clear << input_latLonUR[0]; input_lat_str.DeleteAfterIncluding(".");
      input_lon_str << clear << input_latLonUR[1]; input_lon_str.DeleteAfterIncluding(".");
      lat_str << clear << latLonUR[0]; lat_str.DeleteAfterIncluding(".");
      lon_str << clear << latLonUR[1]; lon_str.DeleteAfterIncluding(".");
      if((input_lat_str == lat_str) && (input_lon_str == lon_str)) {
	return AWIPS_NCEP1;
      }
    }
  }


  return AWIPS_Unknown;
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //
