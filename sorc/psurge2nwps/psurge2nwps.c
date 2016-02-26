#define PROGRAM_VERSION "1.0"
#define PROGRAM_DATE "09/24/2013"

/*****************************************************************************
 * psurge2nwps.c
 *
 * DESCRIPTION
 *    This program converts from a P-Surge file that has been stored as a
 * set of .flt files (by degrib) to the output format that the National Wave
 * Prediction System can use.
 *
 * HISTORY
 *   9/2013 Arthur Taylor (MDL): Created.
 *
 * NOTES
 *
 * Flow of the program is as follows:
 *   a) Get the WFO grid definitions
 *   b) Read the "degrib .txt" file to get the P-Surge map projection
 *   c) Get various meta data from the "degrib .flt" filename
 *   d) Open the .flt file and loop over the WFO grids
 *      For each WFO grid, loop over the lat/lons
 *        For each lat/lon,
 *          map to grid coordinate
 *          fseek data from .flt file
 *          use either bi-linear or nearest neighbor to get value
 *          output result
 *
 * Assumes that ("degrib -V" = "2.02") was used as follows:
 *   ${DEGRIB} <grib file> -C -Flt -msg all -Unit none
 *                         -nameStyle "%e_%lv_%p_e${EXCEED}.txt"
 *
 *  1) Assumes the .flt file was created in "big endian".
 *  2) Assumes the .flt file was created in meters.
 *  3) Assumes the binary .dat file should be in "little endian".
 *  4) Assumes the .flt file missing value is '9999'.  Could determine by
 *  reading the .txt file.
 *  5) Assumes the wfo grids missing value is '-9999'.  Could be a command
 *  line option.
 *
 * Output file name is defined as follows:
 *    psurge_AsOf_WFO_X_Y_S_T_E.dat
 *      AsOf (YYYYMMDDHH) = {2012102906}
 *      WFO = {phi}
 *      X = (NX)-(lon1 * -100) {779-7625}
 *      Y = (NY)-(lat1 * 100)  {779-3760}
 *          NX = (-72.7500 - -76.2500) / .0045 + 1 = {778.777 = 779}
 *          NY = (41.1000 - 37.6000) / .0045 + 1 =   {778.777 = 779}
 *      S (spacing * 10,000) = {45}
 *      T = {f006}
 *      E (exceedance) = {e10}
 *    e.g: psurge_2012102906_phi_779-7625_779-3760_45_f006_e10.dat
 ****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "libaat.h"
#include "mymapf.h"
#ifdef MEMWATCH
#include "memwatch.h"
#endif

/*****************************************************************************
 * Get_WFOGrids() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Define the WFO grid by reading in the RTOFLON and RTOFLAT data from the
 * WFO [wfo]_ncep_config.sh files located in the 'wfoDir'.  Uses that
 * information combined with the spacing variable to compute the number of X
 * cells (NX) and number of Y cells (NY).
 *
 * ARGUMENTS
 *  wfoList = Comma separeated list of WFO's to define (Input)
 *   wfoDir = Location of the WFO .sh files (Input)
 *  spacing = # degrees to separate WFO points by (both X and Y) (Input)
 * numGrids = Number of WFO grids (Output)
 *   WfoMap = Set of Wfo grids.
 *
 * RETURNS: 1 on error, 0 on ok.
 *
 * HISTORY
 *  9/2013 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
/* Structure used to hold a WFO grid. */
typedef struct {
   char WFO[4];         /* WFO. */
   double lat1, lon1;   /* Lower left corner of WFO grid. */
   double lat2, lon2;   /* Upper right corner of WFO grid. */
   sInt4 NX, NY;        /* Number of points in X and Y direction. */
} wfoGridType;

static int Get_WFOGrids (const char *wfoList, const char *wfoDir,
                         double spacing, size_t *numGrids,
                         wfoGridType ** WfoGrid)
{
   int f_error = 0;     /* Return value */
   char *spBuff = NULL; /* Copy of wfoList with ',' => \0 and trimmed */
   size_t spBuffLen = 0; /* Allocated length of spBuff */
   size_t numCol = 0;   /* Number of columns in wfoList */
   char **col = NULL;   /* Pointers to beginning of columns in spBuff */
   size_t i;            /* Loop counter over number of columns */
   wfoGridType *wfoGrid; /* Local copy of wfoGrid for constructing */
   char *configName = NULL; /* Name of WFO config file */
   FILE *fp;            /* Open'ed WFO config file */
   char *line = NULL;   /* Current line in WFO config file */
   size_t lineLen = 0;  /* Allocated length of line */
   char *ptr;           /* Pointer to begininng of RTOF.. in line */
   char *ptr2;          /* Pointer to '=' in line */

   /* Split the wfoList by the ',' */
   if (mySplit (wfoList, ',', &spBuffLen, &spBuff, &numCol, &col, 1) != 0) {
      fprintf (stderr, "Problems working with wfoList: %s\n", wfoList);
      f_error = 1;
      goto error;
   }

   /* Allocate the wfoGrids. */
   *numGrids = numCol;
   wfoGrid = (wfoGridType *) malloc (numCol * sizeof (wfoGridType));

   /* Loop over the wfoGrids. */
   for (i = 0; i < numCol; i++) {
      /* Determine the WFO config file name */
      strToLower (col[i]);
      strncpy (wfoGrid[i].WFO, col[i], 3);
      wfoGrid[i].WFO[3] = '\0';
      mallocSprintf (&configName, "%s/%s_ncep_config.sh", wfoDir, col[i]);

      /* Open the WFO config file and look for the 'right' lines. */
      if ((fp = fopen (configName, "rt")) == NULL) {
         fprintf (stderr, "Problems opening Config file %s\n", configName);
         f_error = 1;
         goto error;
      }
      while (reallocFGets (&line, &lineLen, fp) > 0) {
         strTrim (line);
         if ((line[0] != '#') && (strlen (line) > 0)) {
            /* Look for RTOFSLON= or RTOFSLAT= */
            if ((ptr = strchr (line, 'R')) != NULL) {
               if ((ptr[1] == 'T') && ((ptr2 = strchr (ptr, '=')) != NULL)) {
                  *ptr2 = '\0';
                  if (strcmp (ptr, "RTOFSLON") == 0) {
                     /* The + 2 below avoids the = and the first " char */
                     sscanf (ptr2 + 2, "%lf %lf", &wfoGrid[i].lon1,
                             &wfoGrid[i].lon2);
                     wfoGrid[i].NX = ceil ((wfoGrid[i].lon2 - wfoGrid[i].lon1) /
                                           spacing + 1);
                     /* Get longitudes in range of -180 to 180 */
                     wfoGrid[i].lon1 = wfoGrid[i].lon1 - 360;
                     wfoGrid[i].lon2 = wfoGrid[i].lon2 - 360;
                  } else if (strcmp (ptr, "RTOFSLAT") == 0) {
                     /* The + 2 below avoids the = and the first " char */
                     sscanf (ptr2 + 2, "%lf %lf", &wfoGrid[i].lat1,
                             &wfoGrid[i].lat2);
                     wfoGrid[i].NY = ceil ((wfoGrid[i].lat2 - wfoGrid[i].lat1) /
                                           spacing + 1);
                  } else {
                     fprintf (stderr, "Unexpected line '%s' in '%s'\n", line,
                              configName);
                     f_error = 1;
                     free (wfoGrid);
                     goto error;
                  }
               }
            }
         }
      }
      free (configName);
      configName = NULL;
      fclose (fp);
   }

   /* Set the answer pointer to the local pointer. */
   *WfoGrid = wfoGrid;

 error:
   free (line);
   if (configName != NULL) {
      free (configName);
   }
   if (spBuff != NULL) {
      free (spBuff);
   }
   if (col != NULL) {
      free (col);
   }
   return f_error;
}

/*****************************************************************************
 * Read_DegribTxtGDS() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Read the Grid Definition Section (GDS) from a degrib formated .txt file.
 * This creates a gdsType which can then be used to define a map projection
 * via a call to mapMapf.c::SetMapParamGDS().
 *
 * ARGUMENTS
 * filename = Filename to read the degrib formated .txt file from (Input)
 *      gds = Resulting Grid Definition Section (GDS) (Output)
 *
 * RETURNS: 1 on error, 0 on ok.
 *
 * HISTORY
 *  9/2013 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
static int Read_DegribTxtGDS (const char *filename, gdsType *gds)
{
   int f_error = 0;     /* Return value */
   FILE *fp;            /* Open'ed 'degrib .txt' file */
   char *line = NULL;   /* Current line in degrib .txt file */
   size_t lineLen = 0;  /* Allocated length of line */
   char *spBuff = NULL; /* Copy of line with '|' => \0 and trimmed */
   size_t spBuffLen = 0; /* Allocated length of spBuff */
   size_t numCol = 0;   /* Number of columns in line */
   char **col = NULL;   /* Pointers to beginning of columns in spBuff */

   /* Open the 'degrib .txt' file. */
   if ((fp = fopen (filename, "rt")) == NULL) {
      fprintf (stderr, "Problems opening Map file %s\n", filename);
      return 1;
   }

   /* Set gds elements we don't care about. */
   gds->resFlag = 0;
   gds->center = 0;
   gds->lat2 = 0;
   gds->lon2 = 0;
   /* Really obscure gds entries. */
   gds->poleLat = 0;
   gds->poleLon = 0;
   gds->stretchFactor = 0;
   gds->f_typeLatLon = 0;
   gds->angleRotate = 0;
   gds->hdatum = 0;

   /* Loop over the lines in the 'degrib .txt' file. */
   while (reallocFGets (&line, &lineLen, fp) > 0) {
      if (strncmp (line, "GDS", 3) == 0) {
         /* Split on the '|' and make sure the line is well formed. */
         if (mySplit (line, '|', &spBuffLen, &spBuff, &numCol, &col, 1) != 0) {
            fprintf (stderr, "%s is not well formed\n", line);
            f_error = 1;
            goto error;
         }
         if (numCol != 3) {
            fprintf (stderr, "%s is not well formed\n", line);
            f_error = 1;
            goto error;
         }

         /* Parse the GDS entries that we care about. */
         if (strcmp (col[1], "Number of Points") == 0) {
            gds->numPts = atoi (col[2]);
         } else if (strcmp (col[1], "Projection Type") == 0) {
            gds->projType = atoi (col[2]);
            if (gds->projType != 30) {
               fprintf (stderr, "Have only tested this procedure with lambert "
                        "conformal projections\nIf '%s' is Mercator, we need "
                        "to parse lat2, lon2\n", line);
               f_error = 1;
               goto error;
            }
         } else if (strcmp (col[1], "Shape of Earth") == 0) {
            gds->f_sphere = 1;
            if (strcmp (col[2], "sphere") != 0) {
               fprintf (stderr, "Currently can only handle spheres\n");
               f_error = 1;
               goto error;
            }
         } else if (strcmp (col[1], "Radius") == 0) {
            gds->majEarth = atof (col[2]);
            gds->minEarth = gds->majEarth;
         } else if (strcmp (col[1], "Nx (Number of points on parallel)") == 0) {
            gds->Nx = atoi (col[2]);
         } else if (strcmp (col[1], "Ny (Number of points on meridian)") == 0) {
            gds->Ny = atoi (col[2]);
         } else if (strcmp (col[1], "Lat1") == 0) {
            gds->lat1 = atof (col[2]);
         } else if (strcmp (col[1], "Lon1") == 0) {
            gds->lon1 = atof (col[2]);
         } else if (strcmp (col[1], "OrientLon") == 0) {
            gds->orientLon = atof (col[2]);
         } else if (strcmp (col[1], "Dx") == 0) {
            gds->Dx = atof (col[2]);
         } else if (strcmp (col[1], "Dy") == 0) {
            gds->Dy = atof (col[2]);
         } else if (strcmp (col[1], "MeshLat") == 0) {
            gds->meshLat = atof (col[2]);
         } else if (strcmp (col[1], "(.flt file grid), scan mode") == 0) {
            gds->scan = atof (col[2]);
         } else if (strcmp (col[1], "Tangent Lat1") == 0) {
            gds->scaleLat1 = atof (col[2]);
         } else if (strcmp (col[1], "Tangent Lat2") == 0) {
            gds->scaleLat2 = atof (col[2]);
         } else if (strcmp (col[1], "Southern Lat") == 0) {
            gds->southLat = atof (col[2]);
         } else if (strcmp (col[1], "Southern Lon") == 0) {
            gds->southLon = atof (col[2]);
         }
      }
   }

   /* Check that 'mapMapf.c' considers the gds to be valid. */
   if (GDSValid (gds) != 0) {
      fprintf (stderr, "Something wrong with the gds\n");
      f_error = 1;
      goto error;
   }

 error:
   fclose (fp);
   free (line);
   if (spBuff != NULL) {
      free (spBuff);
   }
   if (col != NULL) {
      free (col);
   }
   return f_error;
}

/*****************************************************************************
 * Get_MetaInfo() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Parse the fltFile name for (a) the asof time (when the forecast was made)
 * (b) the valid time (remember that this is the end of the forecast time)
 * (c) the P-Surge exceedance level.
 *    This assumes that the file name was constructed using "degrib's" nameStyle
 * "%e_%lv_%p_e${EXCEED}.txt" where ${EXCEED} is the P-Surge Exceedance level.
 *
 * ARGUMENTS
 * fltFile = The .flt filename to parse (Input)
 *    Asof = When the forecast was made (aka reference time) (Output)
 *    Time = The number of hours between the Asof time and the end of the valid
 *           period.  For P-Surge that is currently 6-hours later. (Output)
 *  Exceed = What P-Surge exceedance level (e10, e20, e30, e40, e50) (Output)
 *
 * RETURNS: 1 on error, 0 on ok.
 *
 * HISTORY
 *  9/2013 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
static int Get_MetaInfo (const char *fltFile, char **Asof, char **Time,
                         char **Exceed)
{
   int f_error = 0;     /* Return value */
   char *spBuff = NULL; /* Copy of fltFile with '_' => \0 and trimmed */
   size_t spBuffLen = 0; /* Allocated length of spBuff */
   size_t numCol = 0;   /* Number of columns in fltFile */
   char **col = NULL;   /* Pointers to beginning of columns in spBuff */
   char *ptr;           /* Points to first '.' in 4th column of fltFile */

   /* Split on the '_' and make sure the fltFile is well formed. */
   if (mySplit (fltFile, '_', &spBuffLen, &spBuff, &numCol, &col, 1) != 0) {
      fprintf (stderr, "Problems working with fltFileName: %s\n", fltFile);
      f_error = 1;
      goto error;
   }
   if (numCol != 4) {
      fprintf (stderr, "fltFile: %s is not of the form "
               "*_[asof]_[projection time]_[exceed].*\n", fltFile);
      f_error = 1;
      goto error;
   }

   /* Get the columns that we care about. */
   *Asof = malloc (strlen (col[1]) + 1);
   strcpy (*Asof, col[1]);
   *Time = malloc (strlen (col[2]) + 1);
   strcpy (*Time, col[2]);
   ptr = strchr (col[3], '.');
   *ptr = '\0';
   *Exceed = malloc (strlen (col[3]) + 1);
   strcpy (*Exceed, col[3]);

 error:
   if (spBuff != NULL) {
      free (spBuff);
   }
   if (col != NULL) {
      free (col);
   }
   return f_error;
}

/*****************************************************************************
 * OutputWFO() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    For a given WFO grid, loop over the lat/lons mapping the lat/lon to the
 * the P-Surge grid.  Use fseek() and FREAD_BIG() to get the data from the .flt
 * file.  Depending on the user's choice of f_interp, either use nearest neighbor
 * or bi-linear interpolation to determine the resulting value.  Write the value
 * to outFile based on the user's choice of output style.
 *
 * ARGUMENTS
 *        flt = Opened .flt file (Input)
 *        map = Map projection associated with the .flt file (Input)
 *      fltNx = NX of the .flt file (Input)
 *      fltNy = NY of the .flt file (Input)
 *    fltMiss = Missing value for the .flt file (Input)
 *    wfoGrid = WFO Grid to output (Input)
 *    spacing = Delta X and Delta Y spacing (in degrees) for WFO grids (Input)
 *    wfoMiss = Missing value for the wfoGrid (Input)
 *   f_interp = 1 => use bi-linear, 0 => use nearest-neighbor (Input)
 *     f_feet = 1 => output in feet, 0 => output in meters (Input)
 * f_outStyle = Which output style to use. (Input) Choices are:
 *              1 => Binary 4 byte float file (.dat) with z values
 *              2 => ASCII file (.dat) with z values
 *              3 => ASCII file (.csv) with lon, lat, z values
 *              4 => ASCII file (.csv) with lon, lat, x, y, z values
 *    outFile = Name of file to write output to (Output)
 *
 * RETURNS: 1 on error, 0 on ok.
 *
 * HISTORY
 *  9/2013 Arthur Taylor (MDL): Created.
 *
 * NOTES
 *  1) Assumes the .flt file was created in "big endian".
 *  2) Assumes the .flt file was created in meters.
 *  3) Assumes the binary .dat file should be in "little endian".
 ****************************************************************************/
#define M2FT 3.28084

static int OutputWFO (FILE *flt, myMaparam *map, sInt4 fltNx, sInt4 fltNy,
                      double fltMiss, wfoGridType * wfoGrid, double spacing,
                      sInt4 wfoMiss, char f_interp, char f_feet,
                      char f_outStyle, char *outFile)
{
   sInt4 i, j;          /* Loop Counters over the WFO lat/lon's */
   double lat, lon;     /* Current lat/lon in the grid */
   double x, y;         /* Current x/y in the grid */
   sInt4 iX, iY;        /* integer value of lower left corner of x/y or the
                         * nearest neighbor to x/y depending on f_interp */
   sInt4 offset;        /* Current offset into the flt file */
   float d11, d12, d21, d22; /* Corner values during bi-linear interpolation */
   float d1, d2;        /* Edge values during bi-linear interpolation */
   float d;             /* Resulting P-Surge value */
   FILE *fp;            /* The opened output file */

   /* Open the output file. */
   if (f_outStyle == 1) {
      if ((fp = fopen (outFile, "wb")) == NULL) {
         fprintf (stderr, "Problems opening output file %s\n", outFile);
         return 1;
      }
   } else {
      if ((fp = fopen (outFile, "wt")) == NULL) {
         fprintf (stderr, "Problems opening output file %s\n", outFile);
         return 1;
      }
      if (f_outStyle == 3) {
         fprintf (fp, "Lon, Lat, Z\n");
      } else if (f_outStyle == 4) {
         fprintf (fp, "Lon, Lat, X, Y, Z\n");
      }
   }

   if (f_interp) {
      /* Bi-linear interpolation */
      for (i = 0; i < wfoGrid->NX; i++) {
         for (j = 0; j < wfoGrid->NY; j++) {
            lon = wfoGrid->lon1 + i * spacing;
            lat = wfoGrid->lat1 + j * spacing;
            myCll2xy (map, lat, lon, &x, &y);
            iX = floor (x);
            iY = floor (y);

            /* Get the data value 'd' */
            offset = ((iX - 1) + ((fltNy - 1) - (iY - 1)) * fltNx) *
                  sizeof (float);
            fseek (flt, offset, SEEK_SET);
            FREAD_BIG (&(d11), sizeof (float), 1, flt);
            offset = ((iX - 1) + ((fltNy - 1) - (iY)) * fltNx) * sizeof (float);
            fseek (flt, offset, SEEK_SET);
            FREAD_BIG (&(d12), sizeof (float), 1, flt);
            offset = ((iX) + ((fltNy - 1) - (iY - 1)) * fltNx) * sizeof (float);
            fseek (flt, offset, SEEK_SET);
            FREAD_BIG (&(d21), sizeof (float), 1, flt);
            offset = ((iX) + ((fltNy - 1) - (iY)) * fltNx) * sizeof (float);
            fseek (flt, offset, SEEK_SET);
            FREAD_BIG (&(d22), sizeof (float), 1, flt);
            if ((d11 == fltMiss) || (d12 == fltMiss) ||
                (d21 == fltMiss) || (d22 == fltMiss)) {
               d = wfoMiss;
            } else {
               /* *INDENT-OFF* */
               /* d1 = d11 + (y - y1) / (y2 - y1) * (d12 - d11);
                * d2 = d21 + (y - y1) / (y2 - y1) * (d22 - d21);
                * y2 - y1 = 1 ; y - y1 = y - iY */
               /* *INDENT-ON* */
               d1 = d11 + (y - iY) * (d12 - d11);
               d2 = d21 + (y - iY) * (d22 - d21);
               /* *INDENT-OFF* */
               /* d = d1 + (x - x1) / (x2 - x1) * (d2 - d1);
                * x2 - x1 = 1 ; x - x1 = x - iX */
               /* *INDENT-ON* */
               d = d1 + (x - iX) * (d2 - d1);
               if (f_feet) {
                  d = d * M2FT;
               }
            }

            /* Output the result: .flt file is in meters to 3 decimals (i.e we
             * have either +/- 0.001 meter or 0.00328 feet).  In text output,
             * round to 3 decimals. */
            if (f_outStyle == 1) {
               FWRITE_LIT (&(d), sizeof (float), 1, fp);
            } else if (f_outStyle == 2) {
               fprintf (fp, "%.3f\n", d);
            } else if (f_outStyle == 3) {
               fprintf (fp, "%f, %f, %.3f\n", lon, lat, d);
            } else if (f_outStyle == 4) {
               fprintf (fp, "%f, %f, %f, %f, %.3f\n", lon, lat, x, y, d);
            }
         }
      }

   } else {
      /* Nearest neighbor interpolation */
      for (i = 0; i < wfoGrid->NX; i++) {
         for (j = 0; j < wfoGrid->NY; j++) {
            lon = wfoGrid->lon1 + i * spacing;
            lat = wfoGrid->lat1 + j * spacing;
            myCll2xy (map, lat, lon, &x, &y);
            iX = floor (x + 0.5);
            iY = floor (y + 0.5);

            /* Get the data value 'd' */
            offset = ((iX - 1) + ((fltNy - 1) - (iY - 1)) * fltNx) *
                  sizeof (float);
            fseek (flt, offset, SEEK_SET);
            FREAD_BIG (&(d), sizeof (float), 1, flt);
            if (d == fltMiss) {
               d = wfoMiss;
            } else {
               if (f_feet) {
                  d = d * M2FT;
               }
            }

            /* Output the result: .flt file is in meters to 3 decimals (i.e we
             * have either +/- 0.001 meter or 0.00328 feet).  In text output,
             * round to 3 decimals. */
            if (f_outStyle == 1) {
               FWRITE_LIT (&(d), sizeof (float), 1, fp);
            } else if (f_outStyle == 2) {
               fprintf (fp, "%.3f\n", d);
            } else if (f_outStyle == 3) {
               fprintf (fp, "%f, %f, %.3f\n", lon, lat, d);
            } else if (f_outStyle == 4) {
               fprintf (fp, "%f, %f, %f, %f, %.3f\n", lon, lat, x, y, d);
            }
         }
      }
   }
   fclose (fp);
   return 0;
}

/*****************************************************************************
 * ParseCmdLine() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Parse the user's options from the command line.  Also provides the
 * Usage() and About() functions via the flag=1, and flag=2 options.
 *
 * ARGUMENTS
 * flag = 0 => Parse the command line, 1 = Print usage, 2 = Print version (In)
 * argc = The number of arguments on the command line. (Input)
 * argv = The arguments on the command line. (Input)
 *  usr = The parsed user parameters (Output)
 *
 * RETURNS: -1 on error, 0 on ok and continue, 1 on ok, but quit.
 *
 * HISTORY
 *  9/2013 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
typedef struct {
   char *fltFile;       /* Name of the .flt file */
   char *wfoList;       /* Comma separated list of WFO's */
   char *wfoDir;        /* Where to find the '[wfo]_ncep_config.sh' files */
   double spacing;      /* Spacing (in degrees) for the WFO grid */
   char f_interp;       /* 1=bi-linear, 0=nearest neighbor interpolation */
   char f_feet;         /* Output in 1=feet, 0=meter */
   char f_outStyle;     /* Output style (see usage) */
} usrType;

static int ParseCmdLine (int flag, int argc, char **argv, usrType * usr)
{
   int c;               /* Returned command line option */
   struct getOptRet getOp; /* Command line option structure */

   if (flag == 2) {
      /* Print version info and return */
      printf ("%s\nVersion: %s\nDate: %s\nAuthors: Arthur Taylor\n", argv[0],
              PROGRAM_VERSION, PROGRAM_DATE);
      printf ("Compiled by %s\n", CC_VER);
      printf ("Compiled date %s\n", __DATE__);
      printf ("sizeof(long int)=%d, sizeof(sInt4)=%d\n",
              (int) sizeof (long int), (int) sizeof (sInt4));
      return 0;

   } else if (flag == 1) {
      /* Print usage info and return */
      printf ("usage: %s <flt file> [options]\n\n", argv[0]);
      printf (" -H       = Prints this help\n");
      printf (" -V       = Version of the program\n\n");
      printf (" -d [arg] = Directory containing [wfo]_ncep_config.sh files\n");
      printf (" -i       = [Optional] Use bi-linear interpolation (vs nearest "
              "neighbor)\n");
      printf (" -m       = [Optional] Output meters (vs feet)\n");
      printf (" -o [arg] = [Optional] Output format (default 1)\n");
      printf ("           [1] = Binary 4 byte float file (.dat) with z values"
              ".\n");
      printf ("            2 = ASCII file (.dat) with z values.\n");
      printf ("            3 = ASCII file (.csv) with lon, lat, z values.\n");
      printf ("            4 = ASCII file (.csv) with lon, lat, x, y, z values"
              ".\n");
      printf (" -s [arg] = [Optional] spacing for the wfo grid (default = 0.00"
              "45 degree)\n");
      printf (" -w [arg] = WFO(s) to convert.sh file(s) containing the NWPS ex"
              "tents\n\n");
      printf ("Assumptions:\n");
      printf ("  1) mapfile is same as .flt except with a .txt extension.\n");
      printf ("  2) Name of .flt file is of form *_[asof]_[proj. time]_[exceed"
              "].*\n");
      printf ("     e.g. SURGE10_asof_006_e10.flt\n\n");
      printf ("Example: %s foo.flt -w mfl,mlb -d ./wfoFiles\n", argv[0]);
      return 0;
   }

   /* Init the usr options. */
   usr->fltFile = NULL;
   usr->wfoList = NULL;
   usr->wfoDir = NULL;
   usr->spacing = 0.0045;
   usr->f_interp = 0;
   usr->f_feet = 1;
   usr->f_outStyle = 1;

   /* Parse the command line. */
   getOp.opterr = 0;
   while ((c = myGetOpt (argc, argv, "HVd:imo:s:w:", NULL, &getOp)) != -1) {
      switch (c) {
         case 'H':
            ParseCmdLine (1, argc, argv, usr);
            return 1;
         case 'V':
            ParseCmdLine (2, argc, argv, usr);
            return 1;
         case 'd':
            usr->wfoDir = getOp.optarg;
            break;
         case 'i':
            usr->f_interp = 1;
            break;
         case 'm':
            usr->f_feet = 0;
            break;
         case 'o':
            usr->f_outStyle = atoi (getOp.optarg);
            break;
         case 's':
            usr->spacing = atof (getOp.optarg);
            break;
         case 'w':
            usr->wfoList = getOp.optarg;
            break;
         case '?':
            if ((getOp.optopt == 'd') || (getOp.optopt == 'o') ||
                (getOp.optopt == 's') || (getOp.optopt == 'w')) {
               fprintf (stderr, "Option -%c requires an argument.\n",
                        getOp.optopt);
            } else {
               fprintf (stderr, "Unknown option character `\\x%x'.\n",
                        getOp.optopt);
            }
            return -1;
         default:
            ParseCmdLine (1, argc, argv, usr);
            return -1;
      }
   }
   if ((usr->wfoDir == NULL) || (usr->wfoList == NULL)) {
      fprintf (stderr, "Please provide a list of wfo's and/or the wfo"
               " directory\n");
      ParseCmdLine (1, argc, argv, usr);
      return -1;
   }
   if (getOp.optind + 1 != argc) {
      fprintf (stderr, "Please provide a .flt file\n");
      ParseCmdLine (1, argc, argv, usr);
      return -1;
   }
   usr->fltFile = argv[getOp.optind];
   return 0;
}

/*****************************************************************************
 * main() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *   The main entry point for the psurge2nwps program.
 *
 * ARGUMENTS
 * argc = The number of arguments on the command line. (Input)
 * argv = The arguments on the command line. (Input)
 *
 * RETURNS: 1 on error, 0 on ok.
 *
 * HISTORY
 *  9/2013 Arthur Taylor (MDL): Created.
 *
 * NOTES
 *  4) Assumes the .flt file missing value is '9999'.  Could determine by
 *  reading the .txt file.
 *  5) Assumes the wfo grids missing value is '-9999'.  Could be a command
 *  line option.
 ****************************************************************************/
int main (int argc, char **argv)
{
   int f_error = 0;     /* Return value */
   usrType usr;         /* User's command line options */
   size_t numWFO = 0;   /* Number of WFO's */
   wfoGridType *wfoGrid = NULL; /* WFO Grid definitions */
   char *ptr;           /* Points to '.' in flt file to create .txt name */
   gdsType gds;         /* Grid Definition Section associated with .flt file */
   myMaparam map;       /* map projection associated with .flt file */
   char *asof = NULL;   /* Reference time */
   char *time = NULL;   /* Valid Time - Reference Time */
   char *exceed = NULL; /* Exceedance level */
   FILE *fp;            /* Open pointer to the flt file */
   size_t i;            /* Loop counter over number of WFO grids */
   char *outFile = NULL; /* Name of the output file */
   double fltMiss = 9999; /* Missing value in the .flt file */
   sInt4 wfoMiss = -9999; /* Missing value in the wfo output file */

   /* Parse the command line for the user's choices. */
   if ((f_error = ParseCmdLine (0, argc, argv, &usr)) != 0) {
      if (f_error == -1) { /* Error occured. */
         return 1;
      } else {          /* Exited safely. */
         return 0;
      }
   }

   /* Open the WFO List. */
   if (Get_WFOGrids (usr.wfoList, usr.wfoDir, usr.spacing, &numWFO,
                     &wfoGrid) != 0) {
      return 1;
   }

   /* Open the .txt file to read the GDS. */
   if ((ptr = strchr (usr.fltFile, '.')) == NULL) {
      fprintf (stderr, "Can't find the . in %s\n", usr.fltFile);
      ParseCmdLine (1, argc, argv, &usr);
      free (wfoGrid);
      return 1;
   }
   strcpy (ptr + 1, "txt");
   if (Read_DegribTxtGDS (usr.fltFile, &gds) != 0) {
      free (wfoGrid);
      return 1;
   }
   strcpy (ptr + 1, "flt");

   /* Set up the map projection. */
   SetMapParamGDS (&map, &gds);

   /* Get the meta data from the .flt filename */
   if (Get_MetaInfo (usr.fltFile, &asof, &time, &exceed) != 0) {
      fprintf (stderr, "%s is not of for *_[asof]_[time]_[exceed].*\n",
               usr.fltFile);
      ParseCmdLine (1, argc, argv, &usr);
      free (wfoGrid);
      return 1;
   }

   /* Open the flt file. */
   if ((fp = fopen (usr.fltFile, "rb")) == NULL) {
      fprintf (stderr, "Problems opening fltFile %s\n", usr.fltFile);
      free (wfoGrid);
      free (asof);
      free (time);
      free (exceed);
      return 1;
   }

   /* Loop over the WFO grids output'ing the results. */
   for (i = 0; i < numWFO; i++) {
      /* Create the output file name. */
      mallocSprintf (&outFile, "psurge_%s_%s_%d-%d_%d-%d_%d_f%s_%s.", asof,
                     wfoGrid[i].WFO, wfoGrid[i].NX,
                     (int) (-1 * wfoGrid[i].lon1 * 100), wfoGrid[i].NY,
                     (int) (wfoGrid[i].lat1 * 100),
                     (int) (ceil (usr.spacing * 10000)), time, exceed);
      if ((usr.f_outStyle == 1) || (usr.f_outStyle == 2)) {
         reallocSprintf (&outFile, "dat");
      } else {
         reallocSprintf (&outFile, "csv");
      }

      /* Output to the WFO file by probing the .flt file */
      if (OutputWFO (fp, &map, gds.Nx, gds.Ny, fltMiss, &(wfoGrid[i]),
                     usr.spacing, wfoMiss, usr.f_interp, usr.f_feet,
                     usr.f_outStyle, outFile) != 0) {
         fprintf (stderr, "Problems with looping over the wfo grid\n");
         free (wfoGrid);
         free (asof);
         free (time);
         free (exceed);
         return 1;
      }
      free (outFile);
      outFile = NULL;
   }
   fclose (fp);
   free (asof);
   free (time);
   free (exceed);
   free (wfoGrid);
   return 0;
}
