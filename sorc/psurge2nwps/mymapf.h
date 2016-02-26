#ifndef MYMAPF_H
#define MYMAPF_H

#include "cmapf.h"
#include "libaat.h"

/* #include "meta.h" */
/* ------------------------ This was in meta.h ----------------*/
enum { GS3_LATLON = 0, GS3_MERCATOR = 10, GS3_POLAR = 20,
       GS3_LAMBERT = 30, GS3_ORTHOGRAPHIC = 90,
       GS3_EQUATOR_EQUIDIST = 110, GS3_AZIMUTH_RANGE = 120};

typedef struct {
   uInt4 numPts;             /* Number of data points. Typically Nx * Ny, but
                                for some exotic grids they don't have Nx,Ny */
   uChar projType;           /* Projection type / template type. Valid choices
                                0(lat/lon), 10(mercator), 20(Polar Stereo),
                                30(Lambert Conformal),
                                in future maybe 90, 110, 120. */
/* Shape of Earth */
   uChar f_sphere;           /* 1 is a sphere, => majEarth == minEarth */
   double majEarth, minEarth; /* semi major and minor axis of earth in km. */
/* Projection info. */
   uInt4 Nx, Ny;             /* Dimensions of grid. */
   double lat1, lon1;        /* lat,lon position of first grid point. */
   /* resFlag: moved to save memory. */
   double orientLon;         /* Where up is North. (0 for lat/lon grids) */
   double Dx, Dy;            /* Mesh delta x,y in degrees or meters. */
   double meshLat;           /* Where the mesh size is defined
                                (0 for lat/lon grids.) */
   uChar resFlag;            /* Table 7 GRIB1 : Section 2 */
   uChar center;             /* For lambert and polar stereographic, answers:
                                (south/north?) and (bi-polar?) */
   uChar scan;               /* describes how the grid was traversed when it
                                was stored. (ie top/down left/right etc.)
                                Internally we use 0100. (start lower left) */
   double lat2, lon2;        /* lat,lon position of last grid point.
                                (0 if unused) */
/* Specific to Lambert Conformal grids. */
   double scaleLat1, scaleLat2; /* The tangent latitude.  If different:
                                then the latitude where the scale should be
                                equal, which allows one to compute the correct
                                tangent latitude.  (0 for lat/lon and mercator,
                                90 for north polar stereographic). */
   double southLat, southLon; /* Not needed. 0 except lambert.
                                 (and rotated lat/lon) */
   /* Following is for stretched Lat/Lon grids. */
   double poleLat, poleLon;   /* Pole of stretching. */
   double stretchFactor;      /* Factor of stretching. */
   int f_typeLatLon;          /* 0 regular, 1 stretch, 2 stretch / rotate. */
   double angleRotate;        /* Rotation angle. */
/* following is just to track the datum. */
   uChar hdatum;              /* horizontal datum to use.  0=undefined (use
                               * grid dataum) 1=WGS84 */
} gdsType;
/* ------------------------ This was in meta.h ----------------*/

typedef struct {
  maparam stcprm;
  char f_latlon;
  double lat1;
  double latN;
  double lon1;           /* lon of west corner of grid. */
  double lonN;           /* lon of east corner of grid. */
                         /* lonN and lon1 are set so that:
                          * A) lon1 < lonN,
                          * B) lonN - lon1 <= 360
                          * C) lonN in [0,360), lon1 in [-360,360) */
  double Nx, Ny;
  double Dx, Dy;
  double ratio;         /*  Ratio of Dy / Dx. */
} myMaparam;

void myCxy2ll (myMaparam * map, double x, double y, double *lat, double *lon);

void myCll2xy (myMaparam * map, double lat, double lon, double *x, double *y);

int GDSValid (const gdsType * gds);

void SetMapParamGDS (myMaparam * map, const gdsType *gds);

int computeSubGrid (LatLon *lwlf, int *x1, int *y1, LatLon *uprt, int *x2,
                    int *y2, gdsType *gds, gdsType *newGds);

int DateLineLat (double lon1, double lat1, double lon2, double lat2,
                 double *ans);

#endif
