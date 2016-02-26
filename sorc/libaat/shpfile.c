/*****************************************************************************
 * shpfile.c
 *
 * DESCRIPTION
 *    This file contains some functions to save various types of ESRI
 * shapefiles
 *
 * HISTORY
 *  3/2007 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "libaat.h"

#ifdef MEMWATCH
#include "memwatch.h"
#endif

enum { SHPT_NULL, SHPT_POINT, SHPT_ARC = 3, SHPT_POLYGON = 5,
   SHPT_MULTIPOINT = 8, SHPT_POINTZ = 11, SHPT_ARCZ = 13,
   SHPT_POLYGONZ = 15, SHPT_MULTIPOINTZ = 18, SHPT_POINTM = 21,
   SHPT_ARCM = 23, SHPT_POLYGONM = 25, SHPT_MULTIPOINTM = 28,
   SHPT_MULTIPATCH = 31
};

/*****************************************************************************
 * shpCreatePolyGrid() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *   This creates a .shp / .shx file.  The .shp / .shx file contains the
 * lat/lon values of the grid as polygons instead of as points.  These formats
 * are specific to Esri ArcView.
 *   The points are assumed to be the corner points of the grid, so there
 * should be 1 more row/column in the dp than given to the shpPnt command,
 * but Nx and Ny are the same as with shpPnt.
 *
 * ARGUMENTS
 *    filename = Name of file to save to. (Output)
 *          dp = Array of lat/lon pairs for the grid cells. (Input)
 *               dp is expected to have 1 extra set of x than Nx and 1
 *               extra set of y than Ny.
 *        mask = 1 if we want to hide the cell, 0 if we want to save it. (In)
 *          Nx = Number of x values in the grid. (Input)
 *          Ny = Number of y values in the grid. (Input)
 * LatLon_Prec = Precision to use with new lat/lon points (Input)
 *   f_reverse = true => traverse the polygons in opposite direction (Input)
 *
 * RETURNS: int (could use errSprintf())
 *  0 = OK
 * -1 = Memory allocation error.
 * -2 = Opening either .shp or .shx file
 * -3 = Problems writing entire .shp or .shx file
 *
 * HISTORY
 *   4/2003 Arthur Taylor (MDL/RSIS): Created.
 *   5/2003 AAT: Modified to allow for f_nMissing.
 *   5/2003 AAT: Fixed orientation to polygon issue.
 *   5/2003 AAT: For poly spanning date line, allow outside of -180..180
 *   5/2003 AAT: Decided to have 1,1 be lower left corner in .shp files.
 *   5/2003 AAT: Removed reliance on errno (since Tcl/Tk confuses the issue).
 *   7/2003 AAT: 1,1 lower left affected orientation of polygons.
 *   3/2004 AAT: Updated to handle Alaska polygons.
 *  12/2007 AAT: Added to libaat
 *               Rename from CreateShpPoly -> shpCreatePolyGrid.
 *
 * NOTES
 * 1) Doesn't inter-twine the write to files, as that could cause the hard
 *   drive to slow down.
 * 2) Assumes data goes from left to right before going up and down.
 *****************************************************************************
 */
int shpCreatePolyGrid(const char *Filename, const LatLon *dp, const char *mask,
                      int Nx, int Ny, int LatLon_Prec, int f_reverse)
{
   char *filename;      /* Local copy of the name of the file. */
   const char *curMask; /* pointer to the current entry in mask. */
   int ierr;            /* Return value. */
   FILE *sfp;           /* The open file pointer for .shp */
   FILE *xfp;           /* The open file pointer for .shx. */
   int i;               /* A counter used for the shx values. */
   sInt4 Head1[7];      /* The Big endian part of the Header. */
   sInt4 Head2[2];      /* The Little endian part of the Header. */
   double Bounds[] = {
      0., 0., 0., 0., 0., 0., 0., 0.
   };                   /* Spatial bounds of the data. minLon, minLat,
                         * maxLon, maxLat, ... */
   sInt4 dataType = 5;  /* Polygon shp type. */
   sInt4 curRec[2];     /* rec number, and content length. */
   const LatLon *curDp; /* current data point. */
   int recLen;          /* Length in bytes of a record in the .shp file. */
   int recLen2;         /* Length in bytes of a 2 poly record. */
   sInt4 dpLen;         /* Number of data polygons in output file. */
   sInt4 numRec;        /* The total number of records actually stored. */
   int x, y;            /* Counters used for traversing the grid. */
   double pts[10];      /* Holds the lon/lat points for the cur polygon. */
   double pts1[20];     /* The points for cur poly if split on dateline. */
   double pts2[20];     /* The points for cur poly if split on dateline. */
   int k;               /* Used for traversing the polygon record. */
   double *cur;         /* Used for traversing the polygon record. */
   double PolyBound[4]; /* Used for holding the polygon bounds. */
   sInt4 PolygonSpecs[] = {
      1, 5, 0
   };                   /* NumParts, NumPnts, Index of Ring are constant for
                         * This type of .shp polygon. */
   sChar *f_dateline;   /* array of flags if the poly crosses the dateline. */
   int indexLf = 0;     /* Where to add data to the left polygon chain. */
   int indexRt = 0;     /* Where to add data to the right polygon chain. */
   sChar f_left;        /* Flag to add to the left or right polygon */
   double delt;         /* change in lon of a given line segment. */
   double newLat;       /* latitude where line segment crosses the dateline */
   sInt4 secChain;      /* first index to the second chain. */
   int dateLineCnt;     /* A count of number of polys that cross dateline. */

   /* Open the files. */
   if (fileAllocNewExten(Filename, ".shp", &filename) != 0) {
      return -1;
   }
   if ((sfp = fopen(filename, "wb")) == NULL) {
      myWarn_Err2Arg("Problems opening %s for write.\n", filename);
      free(filename);
      return -2;
   }
   filename[strlen(filename) - 1] = 'x';
   if ((xfp = fopen(filename, "wb")) == NULL) {
      myWarn_Err2Arg("Problems opening %s for write.\n", filename);
      free(filename);
      fclose(sfp);
      return -2;
   }

   dpLen = Nx * Ny;
   /* Start Writing header in first 100 bytes. */
   Head1[0] = 9994;     /* ArcView identifier. */
   memset ((Head1 + 1), 0, 5 * sizeof (sInt4)); /* set 5 unused to 0 */
   recLen = sizeof (sInt4) + 4 * sizeof (double) + 3 * sizeof (sInt4) +
         10 * sizeof (double);
   recLen2 = sizeof (sInt4) + 4 * sizeof (double) +
         2 * sizeof (sInt4) + 2 * sizeof (sInt4) + 10 * sizeof (double) +
         10 * sizeof (double);
   /* .shp file size (in 2 byte words). */
   Head1[6] = (100 + (2 * sizeof (sInt4) + recLen) * dpLen) / 2;
   FWRITE_BIG (Head1, sizeof (sInt4), 7, sfp);
   Head2[0] = 1000;     /* ArcView version identifier. */
   Head2[1] = dataType; /* Signal that these are polygon data. */
   FWRITE_LIT (Head2, sizeof (sInt4), 2, sfp);
   /* Write out initial guess for bounds... Need to revisit. */
   FWRITE_LIT (Bounds, sizeof (double), 8, sfp);

   /* Start Writing data. */
   curRec[1] = recLen / 2; /* Content length in (2 byte words) */
   curRec[0] = 1;
   dateLineCnt = 0;
   f_dateline = (sChar *) malloc (dpLen * sizeof (sChar));

   /* If the simple case where we don't have to worry about removing the
    * missing values.  */
   for (y = 0; y < Ny; y++) {
      curMask = mask + y * Nx;
      curDp = dp + y * (Nx + 1);
      for (x = 0; x < Nx; x++) {
         if (*curMask == 0) {
            /* Get the current polygon. */
            cur = pts;
            /* Order matters here.  Must be clockwise !!! */
            *(cur++) = curDp->lon;
            *(cur++) = curDp->lat;
            if (f_reverse) {
               *(cur++) = curDp[1].lon;
               *(cur++) = curDp[1].lat;
               *(cur++) = curDp[Nx + 2].lon; /* 1 row up + 1 accross. */
               *(cur++) = curDp[Nx + 2].lat; /* 1 row up + 1 accross. */
               *(cur++) = curDp[Nx + 1].lon; /* 1 row up. */
               *(cur++) = curDp[Nx + 1].lat; /* 1 row up. */
            } else {
               *(cur++) = curDp[Nx + 1].lon; /* 1 row up. */
               *(cur++) = curDp[Nx + 1].lat; /* 1 row up. */
               *(cur++) = curDp[Nx + 2].lon; /* 1 row up + 1 accross. */
               *(cur++) = curDp[Nx + 2].lat; /* 1 row up + 1 accross. */
               *(cur++) = curDp[1].lon;
               *(cur++) = curDp[1].lat;
            }
            *(cur++) = curDp->lon;
            *cur = curDp->lat;

            /* Compute the bounds of this polygon. */
            cur = pts;
            PolyBound[0] = *cur; /* min x */
            PolyBound[2] = *cur; /* max x */
            cur++;
            PolyBound[1] = *cur; /* min y */
            PolyBound[3] = *cur; /* max y */
            cur++;
            for (k = 1; k <= 3; k++) {
               if (PolyBound[0] > *cur)
                  PolyBound[0] = *cur;
               else if (PolyBound[2] < *cur)
                  PolyBound[2] = *cur;
               cur++;
               if (PolyBound[1] > *cur)
                  PolyBound[1] = *cur;
               else if (PolyBound[3] < *cur)
                  PolyBound[3] = *cur;
               cur++;
            }
            f_dateline[curRec[0] - 1] = 0;
            if ((PolyBound[2] - PolyBound[0]) > 180) {
               f_dateline[curRec[0] - 1] = 1;
               dateLineCnt++;
               PolyBound[2] = 180;
               PolyBound[0] = -180;
               f_left = 1;
               indexLf = 0;
               indexRt = 0;
               pts1[indexLf++] = pts[0];
               pts1[indexLf++] = pts[1];
               for (k = 1; k <= 4; k++) {
                  delt = pts[k * 2] - pts[(k - 1) * 2];
                  if ((delt > 180) || (delt < -180)) {
                     DateLineLat (pts[k * 2], pts[k * 2 + 1],
                                  pts[(k - 1) * 2], pts[(k - 1) * 2 + 1],
                                  &newLat);
                     newLat = myRound (newLat, LatLon_Prec);
                     if (f_left) {
                        if (pts1[0] < 0) {
                           pts1[indexLf++] = -180;
                           pts2[indexRt++] = 180;
                        } else {
                           pts1[indexLf++] = 180;
                           pts2[indexRt++] = -180;
                        }
                        pts1[indexLf++] = newLat;
                        pts2[indexRt++] = newLat;
                        pts2[indexRt++] = pts[k * 2];
                        pts2[indexRt++] = pts[k * 2 + 1];
                        f_left = 0;
                     } else {
                        if (pts1[0] < 0) {
                           pts1[indexLf++] = -180;
                           pts2[indexRt++] = 180;
                        } else {
                           pts1[indexLf++] = 180;
                           pts2[indexRt++] = -180;
                        }
                        pts2[indexRt++] = newLat;
                        pts1[indexLf++] = newLat;
                        pts1[indexLf++] = pts[k * 2];
                        pts1[indexLf++] = pts[k * 2 + 1];
                        f_left = 1;
                     }
                  } else {
                     if (f_left) {
                        pts1[indexLf++] = pts[k * 2];
                        pts1[indexLf++] = pts[k * 2 + 1];
                     } else {
                        pts2[indexRt++] = pts[k * 2];
                        pts2[indexRt++] = pts[k * 2 + 1];
                     }
                  }
               }
               pts2[indexRt++] = pts2[0];
               pts2[indexRt++] = pts2[1];
            }

            /* Update Bounds of all data. */
            if (curRec[0] == 1) {
               Bounds[0] = PolyBound[0];
               Bounds[1] = PolyBound[1];
               Bounds[2] = PolyBound[2];
               Bounds[3] = PolyBound[3];
            } else {
               if (Bounds[0] > PolyBound[0])
                  Bounds[0] = PolyBound[0];
               if (Bounds[1] > PolyBound[1])
                  Bounds[1] = PolyBound[1];
               if (Bounds[2] < PolyBound[2])
                  Bounds[2] = PolyBound[2];
               if (Bounds[3] < PolyBound[3])
                  Bounds[3] = PolyBound[3];
            }
            if (f_dateline[curRec[0] - 1]) {
               /* Write record header. */
               curRec[1] = recLen2 / 2; /* Content length in (2 byte words) */
               FWRITE_BIG (curRec, sizeof (sInt4), 2, sfp);
               curRec[1] = recLen / 2; /* Content length in (2 byte words) */
               /* Write the data type. */
               FWRITE_LIT (&dataType, sizeof (sInt4), 1, sfp);
               /* Write polygons bounds */
               FWRITE_LIT (PolyBound, sizeof (double), 4, sfp);
               /* Write out the Polygon Specs. */
               PolygonSpecs[0] = 2;
               PolygonSpecs[1] = 10;
               FWRITE_LIT (PolygonSpecs, sizeof (sInt4), 3, sfp);
               PolygonSpecs[0] = 1;
               PolygonSpecs[1] = 5;
               /* Write out index of second chain. */
               secChain = indexLf / 2;
               FWRITE_LIT (&secChain, sizeof (sInt4), 1, sfp);
               /* Points ... 10 of them indexLf + indexRt = 20 (10 points) */
               FWRITE_LIT (pts1, sizeof (double), indexLf, sfp);
               FWRITE_LIT (pts2, sizeof (double), indexRt, sfp);
            } else {
               /* Write record header. */
               FWRITE_BIG (curRec, sizeof (sInt4), 2, sfp);
               /* Write the data type. */
               FWRITE_LIT (&dataType, sizeof (sInt4), 1, sfp);
               /* Write polygons bounds */
               FWRITE_LIT (PolyBound, sizeof (double), 4, sfp);
               /* Write out the Polygon Specs. */
               FWRITE_LIT (PolygonSpecs, sizeof (sInt4), 3, sfp);
               /* Points ... 5 of them */
               FWRITE_LIT (pts, sizeof (double), 10, sfp);
            }
            curRec[0]++;
            /* Assuming no dateline issues, the size of the .shp file is:
             * 100 + dpLen * (8 +4 +4*8 +3*4 +10*8= 180bytes)
             * So the max number of records allowed is <=
             * (2^31-1) * 2 - 100 / 180 = 23,860,928.8 */
            if (curRec[0] > 23860928) {
               myWarn_Err2Arg("Trying to create a small poly shp file with %d"
                              " cells.  This is > small polygon maximum of"
                              " 23,860,928\n", curRec[0]);
               ierr = -1;
               goto done;
            }
         }
         curDp++;
         curMask++;
      }
   }
   numRec = curRec[0] - 1;

   /* Store the updated file length. */
   /* .shp file size (in 2 byte words). */
   Head1[6] = (100 + (2 * sizeof (sInt4) + recLen) * numRec) / 2;

   /* The dateline polys are bigger than the normal poly's by: 10 * sizeof
    * (double) + 1 * sizeof (sInt4); so we have to add that. */
   Head1[6] += (recLen2 - recLen) * dateLineCnt / 2;

   fseek (sfp, 24, SEEK_SET);
   FWRITE_BIG (&(Head1[6]), sizeof (sInt4), 1, sfp);

   /* Store the updated Bounds. */
   fseek (sfp, 36, SEEK_SET);
   /* FWRITE use 4 since we are only updating 4 bounds (not 8). */
   FWRITE_LIT (Bounds, sizeof (double), 4, sfp);
   fflush (sfp);

   /* Check that .shp is now the correct file size. */
   fseek(sfp, 0L, SEEK_END);
   if (ftell(sfp) != Head1[6] * 2) {
      filename[strlen(filename) - 1] = 'p';
      myWarn_Err3Arg("shp file %s is not %ld bytes long.\n", filename,
                     Head1[6] * 2);
      ierr = -3;
      goto done;
   }
   fclose(sfp);

   /* Write ArcView header. */
   Head1[6] = (100 + 8 * numRec) / 2; /* shx file size (in words). */
   FWRITE_BIG (Head1, sizeof (sInt4), 7, xfp);
   FWRITE_LIT (Head2, sizeof (sInt4), 2, xfp);
   FWRITE_LIT (Bounds, sizeof (double), 8, xfp);
   curRec[0] = 50;      /* 100 bytes / 2 = 50 words */
   for (i = 0; i < numRec; i++) {
      if (f_dateline[i]) {
         curRec[1] = recLen2 / 2; /* Content length in words (2 bytes) */
      } else {
         curRec[1] = recLen / 2; /* Content length in words (2 bytes) */
      }
      FWRITE_BIG (curRec, sizeof (sInt4), 2, xfp);
      if (f_dateline[i]) {
         /* X / 2 because of (2 byte words) */
         curRec[0] += (recLen2 + 2 * sizeof (sInt4)) / 2;
      } else {
         /* X / 2 because of (2 byte words) */
         curRec[0] += (recLen + 2 * sizeof (sInt4)) / 2;
      }
   }
   fflush (xfp);

   /* Check that .shx is now the correct file size. */
   fseek(xfp, 0L, SEEK_END);
   if (ftell(xfp) != 100 + 8 * numRec) {
      myWarn_Err3Arg("shx file '%s' is not %ld bytes long.\n", filename,
                     100 + 8 * numRec);
      ierr = -3;
      goto done;
   }

   ierr = 0;
 done:
   free (f_dateline);
   free(filename);
   fclose(xfp);
   fclose(sfp);

   return ierr;
}

/*****************************************************************************
 * shpCreatePnt() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    This creates a POINT .shp/.shx file.  The .shp/.shx file contains the
 * lat/lon values of a given vector as points.
 *    If one wants to skip points then create a new vector which points to
 * just the desired points.  This is more memory efficient than passing in a
 * mask vector.
 *    Does NOT check that the lat/lon are in correct range.  User may want to
 * call "myCyclicBounds()"
 *
 * ARGUMENTS
 * Filename = Name of file to save to. (Output)
 *       dp = Vector of lat/lon pairs. (Input)
 *    numDP = number of pairs in dp. (Input)
 *
 * RETURNS: int
 *  0 = OK
 * -1 = Memory allocation error.
 * -2 = Opening either .shp or .shx file
 * -3 = Problems writing entire .shp or .shx file
 *
 * HISTORY
 *  3/2007 Arthur Taylor (MDL): Created.
 *
 * NOTES
 *    Doesn't inter-twine the write to files, as that could cause the hard
 * drive to slow down.
 ****************************************************************************/
int shpCreatePnt(const char *Filename, const LatLon *dp, size_t numDP)
{
   char *filename;      /* Local copy of the name of the file. */
   FILE *sfp;           /* The open file pointer for .shp */
   FILE *xfp;           /* The open file pointer for .shx */
   sInt4 Head1[7];      /* The Big endian part of the Header. */
   size_t recLen;       /* Length in bytes of a record in the .shp file. */
   sInt4 Head2[2];      /* The Little endian part of the Header. */
   /* Spatial bounds of the data. minLon, minLat, maxLon, maxLat, ... */
   double Bounds[] = { 0., 0., 0., 0., 0., 0., 0., 0. };
   sInt4 curRec[2];     /* rec number, and content length. */
   size_t i;            /* Loop counter over number of points. */

   /* Open the files. */
   if (fileAllocNewExten(Filename, ".shp", &filename) != 0) {
      return -1;
   }
   if ((sfp = fopen(filename, "wb")) == NULL) {
      myWarn_Err2Arg("Problems opening %s for write.\n", filename);
      free(filename);
      return -2;
   }
   filename[strlen(filename) - 1] = 'x';
   if ((xfp = fopen(filename, "wb")) == NULL) {
      myWarn_Err2Arg("Problems opening %s for write.\n", filename);
      free(filename);
      fclose(sfp);
      return -2;
   }

   /* Start Writing header in first 100 bytes. */
   Head1[0] = 9994;     /* ArcView identifier. */
   /* set 5 unused to 0 */
   memset((Head1 + 1), 0, 5 * sizeof(sInt4));
   recLen = sizeof(sInt4) + 2 * sizeof(double);
   /* .shp file size (in 2 byte words) */
   Head1[6] = (100 + (2 * sizeof(sInt4) + recLen) * numDP) / 2;
   FWRITE_BIG(Head1, sizeof(sInt4), 7, sfp);
   Head2[0] = 1000;     /* ArcView version identifier. */
   Head2[1] = SHPT_POINT; /* Signal that these are point data. */
   FWRITE_LIT(Head2, sizeof(sInt4), 2, sfp);
   /* Write out initial guess for bounds... Need to revisit. */
   FWRITE_LIT(Bounds, sizeof(double), 8, sfp);

   /* Start Writing data. */
   curRec[0] = 1;
   curRec[1] = recLen / 2; /* Content length in (2 byte words) */
   Bounds[0] = Bounds[2] = dp->lon;
   Bounds[1] = Bounds[3] = dp->lat;
   for (i = 0; i < numDP; ++i) {
      FWRITE_BIG(curRec, sizeof(sInt4), 2, sfp);
      FWRITE_LIT(&(Head2[1]), sizeof(sInt4), 1, sfp);
      FWRITE_LIT(&(dp->lon), sizeof(double), 1, sfp);
      FWRITE_LIT(&(dp->lat), sizeof(double), 1, sfp);
      /* Update Bounds. */
      if (dp->lon < Bounds[0]) {
         Bounds[0] = dp->lon;
      } else if (dp->lon > Bounds[2]) {
         Bounds[2] = dp->lon;
      }
      if (dp->lat < Bounds[1]) {
         Bounds[1] = dp->lat;
      } else if (dp->lat > Bounds[3]) {
         Bounds[3] = dp->lat;
      }
      ++curRec[0];
      ++dp;
   }
   /* Store the updated Bounds (only 4 (not 8) of them). */
   fseek(sfp, 36, SEEK_SET);
   FWRITE_LIT(Bounds, sizeof(double), 4, sfp);
   fflush(sfp);

   /* Check that .shp is now the correct file size. */
   fseek(sfp, 0L, SEEK_END);
   if (ftell(sfp) != Head1[6] * 2) {
      filename[strlen(filename) - 1] = 'p';
      myWarn_Err3Arg("shp file %s is not %ld bytes long.\n", filename,
                     Head1[6] * 2);
      free(filename);
      fclose(sfp);
      fclose(xfp);
      return -3;
   }
   fclose(sfp);

   /* Write ArcView header (.shx file). */
   Head1[6] = (100 + 8 * numDP) / 2; /* shx file size (in words). */
   FWRITE_BIG(Head1, sizeof(sInt4), 7, xfp);
   FWRITE_LIT(Head2, sizeof(sInt4), 2, xfp);
   FWRITE_LIT(Bounds, sizeof(double), 8, xfp);
   curRec[0] = 50;      /* 100 bytes / 2 = 50 words */
   curRec[1] = recLen / 2; /* Content length in words (2 bytes) */
   for (i = 0; i < numDP; ++i) {
      FWRITE_BIG(curRec, sizeof(sInt4), 2, xfp);
      curRec[0] += (recLen + 2 * sizeof(sInt4)) / 2; /* (2 byte words) */
   }
   fflush(xfp);

   /* Check that .shx is now the correct file size. */
   fseek(xfp, 0L, SEEK_END);
   if (ftell(xfp) != 100 + 8 * numDP) {
      myWarn_Err3Arg("shx file '%s' is not %ld bytes long.\n", filename,
                     100 + 8 * numDP);
      free(filename);
      fclose(xfp);
      return -3;
   }
   free(filename);
   fclose(xfp);
   return 0;
}

/* Following should take function for xy2ll */
/* int shpCreateGridLatice();*/
/* Following needs to handle the dateline */
/* int shpCreateGridPoly();*/

int shpCreatePrj(const char *Filename, const char *gcs, const char *datum,
                 const char *spheroid, double A, double B)
{
   char *filename;
   FILE *fp;
   double invFlat;

   /* Open the files. */
   if (fileAllocNewExten(Filename, ".prj", &filename) != 0) {
      return -1;
   }
   if ((fp = fopen(filename, "wb")) == NULL) {
      myWarn_Err2Arg("Problems opening %s for write.\n", filename);
      free(filename);
      return -2;
   }
   invFlat = A / (A - B);
   fprintf(fp, "GEOGCS[\"%s\",DATUM[\"%s\",SPHEROID[\"%s\",%.1f,%.13f]],"
           "PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199433]]",
           gcs, datum, spheroid, A, invFlat);
   fclose(fp);
   free(filename);
   return 0;
}
