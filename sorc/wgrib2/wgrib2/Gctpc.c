#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "proj.h"
#include "grb2.h"
#include "wgrib2.h"
#include "fnlist.h"

/* Gctpc.c  interface routines to the gctpc library
   2/2012 Public Domain Wesley Ebisuzaki

  gctpc_get_latlon: fill grid with lat/lon values

  mercator
  polar stereographic
  lambert conformal
  Albers equal area
*/

/* M_PI, M_PI_2, M_PI_4, and M_SQRT2 are not ANSI C but are commonly defined */
/* values from GNU C library version of math.h copyright Free Software Foundation, Inc. */

#ifndef M_PI
#define M_PI           3.14159265358979323846  /* pi */
#endif
#ifndef M_PI_2
#define M_PI_2         1.57079632679489661923  /* pi/2 */
#endif
#ifndef M_PI_4
#define M_PI_4         0.78539816339744830962  /* pi/4 */
#endif
#ifndef M_SQRT2
#define M_SQRT2        1.41421356237309504880  /* sqrt(2) */
#endif

extern int use_gctpc;
extern int latlon;
extern double *lon, *lat;
extern enum output_order_type output_order;


/*
 * HEADER:100:gctpc:inv:1: X=0,1 use gctpc library (testing)
 */

int f_gctpc(ARG1) {
   use_gctpc = (strcmp(arg1,"1") == 0);
   return 0;
}


/* get lat-lon for grid
 *
 * step 1: initialize to center point
 * step 2: find (x,y) of lon1/lat1 (1st grid point)  (x0,y0)
 * step 3  find (x,y) of grid
 * step 4  find lat-lon of (x,y)
 */

int gctpc_get_latlon(unsigned char **sec, double **lon, double **lat) {

    int gdt;
    unsigned char *gds;

    double r_maj;                           /* major axis                   */
    double r_min;                           /* minor axis                   */
    double lat1;                            /* first standard parallel      */
    double lat2;                            /* second standard parallel     */
    double c_lon;                           /* center longitude             */
    double c_lat;                           /* center latitude              */
    double false_east;                      /* x offset in meters           */
    double false_north;
    double dx, dy;
    double x0, y0;
    long int (*inv_fn)();
    double *llat, *llon, rlon, rlat, x, y;

    int i,j, k, nnx, nny, nres, nscan;
    unsigned int nnpnts;
    long long_i;

    gdt = code_table_3_1(sec);
    gds = sec[3];

    /* only process certain grids */

    if (gdt != 10 && gdt != 20 && gdt != 30) return 1;
    get_nxny(sec, &nnx, &nny, &nnpnts, &nres, &nscan);
    if (nnx == -1 || nny == -1 || nnx*nny != nnpnts)   return 1;

    llat = *lat;
    llon = *lon;

    if (llat != NULL) {
	free(llat);
	free(llon);
        *lat = *lon = llat = llon = NULL;
    }

    inv_fn = NULL;
    dx = dy = 0.0;

    if (gdt == 10) {            // mercator

       /* get earth axis */
       axes_earth(sec, &r_maj, &r_min);
       dy      = GDS_Mercator_dy(gds);
       dx      = GDS_Mercator_dx(gds);

       /* central point */
       c_lon = GDS_Mercator_ori_angle(gds) * (M_PI/180.0);
       c_lat = GDS_Mercator_latD(gds) * (M_PI/180.0);

       /* find the eastling and northing of of the 1st grid point */

       false_east = false_north = 0.0;
       long_i = merforint(r_maj,r_min,c_lon,c_lat,false_east,false_north);

       rlon   = GDS_Mercator_lon1(gds) * (M_PI/180.0);
       rlat   = GDS_Mercator_lat1(gds) * (M_PI/180.0);

       long_i = merfor(rlon, rlat, &x0, &y0);

       if (GDS_Scan_x(nscan) == 0) x0 = x0 - (nnx-1)*dx;
       if (GDS_Scan_y(nscan) == 0) y0 = y0 - (nny-1)*dy;

       /* initialize for 1st grid point */
       x0 = -x0;
       y0 = -y0;
       long_i = merinvint(r_maj,r_min,c_lon,c_lat,x0,y0);
       inv_fn = &merinv;
    }

    else if (gdt == 20) {            // polar stereographic

       /* get earth axis */
       axes_earth(sec, &r_maj, &r_min);
       dy      = GDS_Polar_dy(gds);
       dx      = GDS_Polar_dx(gds);

       /* central point */
       c_lon = GDS_Polar_lov(gds) * (M_PI/180.0);
       c_lat = GDS_Polar_lad(gds) * (M_PI/180.0);

       /* find the eastling and northing of of the 1st grid point */

       false_east = false_north = 0.0;
       long_i = psforint(r_maj,r_min,c_lon,c_lat,false_east,false_north);

       rlon   = GDS_Polar_lon1(gds) * (M_PI/180.0);
       rlat   = GDS_Polar_lat1(gds) * (M_PI/180.0);

       long_i = psfor(rlon, rlat, &x0, &y0);

       if (GDS_Scan_x(nscan) == 0) x0 = x0 - (nnx-1)*dx;
       if (GDS_Scan_y(nscan) == 0) y0 = y0 - (nny-1)*dy;

       /* initialize for 1st grid point */
       x0 = -x0;
       y0 = -y0;
       long_i = psinvint(r_maj,r_min,c_lon,c_lat,x0,y0);
       inv_fn = &psinv;
    }

    else if (gdt == 30) {            // lambert conformal conic

       /* get earth axis */
       axes_earth(sec, &r_maj, &r_min);
       dy      = GDS_Lambert_dy(gds);
       dx      = GDS_Lambert_dx(gds);
//printf(">>> gctpc dx %lf, dy %lf\n", dx, dy);
       /* latitudes of tangent/intersection */
       lat1 = GDS_Lambert_Latin1(gds) * (M_PI/180.0);
       lat2 = GDS_Lambert_Latin2(gds) * (M_PI/180.0);

       /* central point */
       c_lon = GDS_Lambert_Lov(gds) * (M_PI/180.0);
       c_lat = GDS_Lambert_LatD(gds) * (M_PI/180.0);

       /* find the eastling and northing of of the 1st grid point */

       false_east = false_north = 0.0;
//printf(">>> lamccforint\n");
       long_i = lamccforint(r_maj,r_min,lat1,lat2,c_lon,c_lat,false_east,false_north);
//printf("<< lamccforint\n");

       rlon   = GDS_Lambert_Lo1(gds) * (M_PI/180.0);
       rlat   = GDS_Lambert_La1(gds) * (M_PI/180.0);

       long_i = lamccfor(rlon, rlat, &x0, &y0);

       if (GDS_Scan_x(nscan) == 0) x0 = x0 - (nnx-1)*dx;
       if (GDS_Scan_y(nscan) == 0) y0 = y0 - (nny-1)*dy;

       /* initialize for 1st grid point */
       x0 = -x0;
       y0 = -y0;
       long_i = lamccinvint(r_maj,r_min,lat1,lat2,c_lon,c_lat,x0,y0);
       inv_fn = &lamccinv;
    }
    else if (gdt == 31) {			// albers equal area
       /* get earth axis */
       axes_earth(sec, &r_maj, &r_min);
       dy      = GDS_Albers_dy(gds);
       dx      = GDS_Albers_dx(gds);

       /* latitudes of tangent/intersection */
       lat1 = GDS_Albers_Latin1(gds) * (M_PI/180.0);
       lat2 = GDS_Albers_Latin2(gds) * (M_PI/180.0);

       /* central point */
       c_lon = GDS_Albers_Lov(gds) * (M_PI/180.0);
       c_lat = GDS_Albers_LatD(gds) * (M_PI/180.0);

       /* find the eastling and northing of of the 1st grid point */

       false_east = false_north = 0.0;
       long_i = alberforint(r_maj,r_min,lat1,lat2,c_lon,c_lat,false_east,false_north);

       rlon   = GDS_Albers_Lo1(gds) * (M_PI/180.0);
       rlat   = GDS_Albers_La1(gds) * (M_PI/180.0);

       long_i = alberfor(rlon, rlat, &x0, &y0);

       if (GDS_Scan_x(nscan) == 0) x0 = x0 - (nnx-1)*dx;
       if (GDS_Scan_y(nscan) == 0) y0 = y0 - (nny-1)*dy;

       /* initialize for 1st grid point */
       x0 = -x0;
       y0 = -y0;
       long_i = alberinvint(r_maj,r_min,lat1,lat2,c_lon,c_lat,x0,y0);
       inv_fn = &alberinv;
    }
    

    if (inv_fn == NULL)  return 1;

    if ((*lat = llat = (double *) malloc(nnpnts * sizeof(double))) == NULL) {
        fatal_error("gctpc_get_latlon memory allocation failed","");
    }
    if ((*lon = llon = (double *) malloc(nnpnts * sizeof(double))) == NULL) {
        fatal_error("gctpc_get_latlon memory allocation failed","");
    }


#pragma omp parallel for schedule(static) private(i,j,k,x,y)
    for (j = 0; j < nny; j++) {
        y = j*dy;
        for (i = 0; i < nnx; i++) {
            x = i*dx;
            k = i+j*nnx;
            inv_fn(x , y, llon+k, llat+k);
	    llat[k] *= (180.0 / M_PI);
	    llon[k] *= (180.0 / M_PI);
	    if (llon[k] < 0.0) llon[k] += 360.0;
        }
    }

    return 0;
}


/*
 * HEADER:100:ll2ij:inv:2:x=lon y=lat, converts lon-lat (i,j) 
 */
int f_ll2ij(ARG2) {

    double x[1], y[1], to_lat[1], to_lon[1];
    int i;

    if (mode == -1) {
	latlon = 1;
    }
    if (mode >= 0) {
	if (output_order != wesn)  return 1;
	to_lon[0] = atof(arg1);
	to_lat[0] = atof(arg2);
        i = gctpc_ll2xy_init(sec, lon, lat);
	if (i == 0)  {
            i = gctpc_ll2xy(1, to_lon, to_lat, x , y);
	    sprintf(inv_out,"%lf %lf -> (%lf,%lf)",to_lon[0], to_lat[0], x[0]+1.0, y[0]+1.0);
	}
    }
    return 0;
}

/*
 * HEADER:100:ll2i:inv:2:x=lon y=lat, converts to (i)
 */
int f_ll2i(ARG2) {

    double to_lat[1], to_lon[1];
    int i, iptr;

    if (mode == -1) {
        latlon = 1;
    }
    if (mode >= 0) {
        if (output_order != wesn) return 1;
        to_lon[0] = atof(arg1);
        to_lat[0] = atof(arg2);
        i = gctpc_ll2xy_init(sec, lon, lat);
        if (i == 0)  {
            i = gctpc_ll2i(1, to_lon, to_lat, &iptr);
            sprintf(inv_out,"%lf %lf -> (%d)",to_lon[0], to_lat[0], iptr);
        }
    }
    return 0;
}



