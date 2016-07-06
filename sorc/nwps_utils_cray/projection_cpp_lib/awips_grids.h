// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// Projection Algorithms By: Thomas.J.Lefebvre@noaa.gov Mike.Romberg@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 04/18/2013
// ---------------------------------------------------------------- // 
// ------------- Include File Description and Details ------------- // 
// ---------------------------------------------------------------- // 
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

On-line GRID reference:

http://www.nco.ncep.noaa.gov/pmb/docs/on388/tableb.html

*/
// ----------------------------------------------------------- // 
#ifndef __M_AWIPS_GRIDS_HPP__
#define __M_AWIPS_GRIDS_HPP__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "projection_cpp_lib.h"

enum AWIPSGridTypes {
  AWIPS_Unknown = 0,
  AWIPS_Grid201,
  AWIPS_Grid202,
  AWIPS_Grid203,
  AWIPS_Grid204,
  AWIPS_Grid205,
  AWIPS_Grid206,
  AWIPS_Grid207,
  AWIPS_Grid208,
  AWIPS_Grid209,
  AWIPS_Grid210,
  AWIPS_Grid211,
  AWIPS_Grid212,
  AWIPS_Grid213,
  AWIPS_Grid214,
  AWIPS_Grid214AK,
  AWIPS_Grid215,
  AWIPS_Grid216,
  AWIPS_Grid217,
  AWIPS_Grid218,
  AWIPS_Grid219,
  AWIPS_Grid221,
  AWIPS_Grid222,
  AWIPS_Grid225,
  AWIPS_Grid226,
  AWIPS_Grid227,
  AWIPS_Grid228,
  AWIPS_Grid229,
  AWIPS_Grid230,
  AWIPS_Grid231,
  AWIPS_Grid232,
  AWIPS_Grid233,
  AWIPS_Grid234,
  AWIPS_Grid235,
  AWIPS_HRAP,
  AWIPS_NCEP1, // 04/11/2013: Remove custom grids and added NCEP grid
  AWIPS_CustomLatLon // Grid to support other LATLON grids from GFE 
};

struct AWIPSGrid 
{
  AWIPSGrid() { }
  virtual ~AWIPSGrid();

  virtual void SetValues() = 0;
  virtual void Print() = 0;
  virtual void AWIPSDomainToLatLon(AWIPSdomain &domain) = 0;
  virtual PointData *GetPointData() = 0;
  virtual void latLonToXY(float lat, float lon, float &x, float &y) = 0;
  virtual void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) = 0; 
  virtual void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) = 0;
  virtual float GetGridSpacing() = 0;
  virtual void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) = 0;

  //  NOTE: Functions below are only used with custom grids                                                   
  virtual void SetCustomGrid(CoordPair latLonLL, CoordPair latLonUR,
                             CoordPair gridPointLL, CoordPair gridPointUR) { }
};

// Standalone functions used to process grid name strings
const char *GetAWIPSGridName(AWIPSGridTypes gt);
int HasAWIPSGrid(const char *gn);
int GridNameCompare(const char *a, const char *b);
AWIPSGridTypes FindGridType(CoordPair input_gridPointLL, CoordPair input_gridPointUR,
			    CoordPair input_latLonLL, CoordPair input_latLonUR);
AWIPSGrid *SetGrid(AWIPSGridTypes gt);

struct Grid201 : public AWIPSGrid 
{
  Grid201() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid201", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-150.00, -20.826);
    grid.latLonUR.Set(-20.90846, 30.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(65, 65);
    grid.lonOrigin = -105.0;
    grid.grid_spacing = 381.000;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid202 : public AWIPSGrid 
{
  Grid202() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid202", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-141.028, 7.838);
    grid.latLonUR.Set(-18.576, 35.617);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(65, 43);
    grid.lonOrigin = -105.0;
    grid.poleCoord.Set(33, 45);
    grid.grid_spacing = 190.5;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid203 : public AWIPSGrid 
{
  Grid203() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid203", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-185.837, 19.132);
    grid.latLonUR.Set(-53.660, 57.634);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(45, 39);
    grid.lonOrigin = -150.0;
    grid.poleCoord.Set(27, 37);
    grid.grid_spacing = 190.5;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid204 : public AWIPSGrid 
{
  Grid204() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid204", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-250.0, -25.0);
    grid.latLonUR.Set(-109.129, 60.644);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(93, 68);
    grid.lonCenter = -179.564;
    grid.grid_spacing = 160.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  Mercator grid;
};

struct Grid205 : public AWIPSGrid 
{
  Grid205() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid205", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-84.904, 0.616);
    grid.latLonUR.Set(-15.000, 45.620);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(45, 39);
    grid.lonOrigin = -60.0;
    grid.poleCoord.Set(27, 57);
    grid.grid_spacing = 190.5;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid206 : public AWIPSGrid 
{
  Grid206() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid206", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-117.991, 22.289);
    grid.latLonUR.Set(-73.182, 51.072);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(51, 41);
    grid.grid_spacing = 81.2705;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid207 : public AWIPSGrid 
{
  Grid207() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid207", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-175.641, 42.085);
    grid.latLonUR.Set(-93.689, 63.976);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(49, 35);
    grid.lonOrigin = -150.0;
    grid.poleCoord.Set(25, 51);
    grid.grid_spacing = 95.25;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid208 : public AWIPSGrid 
{
  Grid208() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid208", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-166.219, 10.656);
    grid.latLonUR.Set(-147.844, 27.917);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(25, 25);
    grid.lonCenter = -157.082;
    grid.grid_spacing = 80.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  Mercator grid;
};

struct Grid209 : public AWIPSGrid 
{
  Grid209() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid209", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-117.991, 22.289);
    grid.latLonUR.Set(-73.182, 51.072);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(101, 81);
    grid.grid_spacing = 44.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid210 : public AWIPSGrid 
{
  Grid210() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid210", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-77.000, 9.000);
    grid.latLonUR.Set(-58.625, 26.422);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(25, 25);
    grid.lonCenter = -67.812;
    grid.grid_spacing = 80.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  Mercator grid;
};

struct Grid211 : public AWIPSGrid 
{
  Grid211() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid211", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-133.459, 12.190);
    grid.latLonUR.Set(-49.385, 57.290);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(93, 65);
    grid.poleCoord.Set(53.000, 179.362);
    grid.grid_spacing = 80.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid212 : public AWIPSGrid 
{
  Grid212() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid212", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-133.459, 12.190);
    grid.latLonUR.Set(-49.385, 57.290);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(185, 129);
    grid.poleCoord.Set(105.000, 357.723);
    grid.grid_spacing = 40.63525;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid213 : public AWIPSGrid 
{
  Grid213() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid213", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-141.028, 7.838);
    grid.latLonUR.Set(-18.577, 35.617);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(129, 85);
    grid.lonOrigin = -105.0;
    grid.poleCoord.Set(65, 89);
    grid.grid_spacing = 95.25;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid214 : public AWIPSGrid 
{
  Grid214() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid214", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-175.641, 42.085);
    grid.latLonUR.Set(-93.689, 63.975);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(97, 69);
    grid.lonOrigin = -150.0;
    grid.poleCoord.Set(49, 101);
    grid.grid_spacing = 47.625;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid214AK : public AWIPSGrid 
{
  Grid214AK() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid214AK", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-178.571, 40.5301);
    grid.latLonUR.Set(-93.689, 63.975);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(104, 70);
    grid.lonOrigin = -150.0;
    grid.poleCoord.Set(49, 101);
    grid.grid_spacing = 47.625;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid215 : public AWIPSGrid 
{
  Grid215() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid215", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-133.459, 12.190);
    grid.latLonUR.Set(-49.385, 57.290);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(369, 257);
    grid.poleCoord.Set(209.0, 714.446);
    grid.grid_spacing = 20.317625;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid216 : public AWIPSGrid 
{
  Grid216() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid216", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-173.000, 30.000);
    grid.latLonUR.Set(-62.850, 70.111);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(139, 107);
    grid.lonOrigin = -135.0;
    grid.poleCoord.Set(94.909, 121.198);
    grid.grid_spacing = 45.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid217 : public AWIPSGrid 
{
  Grid217() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid217", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-173.000, 30.000);
    grid.latLonUR.Set(-62.850, 70.111);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(277, 213);
    grid.lonOrigin = -135.0;
    grid.poleCoord.Set(188.818, 241.397);
    grid.grid_spacing = 22.5;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid218 : public AWIPSGrid 
{
  Grid218() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid218", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-133.459, 12.190);
    grid.latLonUR.Set(-49.385, 57.290);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(614, 428);
    grid.poleCoord.Set(417.002, 1427.8923);
    grid.grid_spacing = 12.19058;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid219 : public AWIPSGrid 
{
  Grid219() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid219", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-119.559, 25.008);
    grid.latLonUR.Set(60.339, 24.028);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(385, 465);
    grid.lonOrigin = -80.0;
    grid.poleCoord.Set(190.988, 231.000);
    grid.grid_spacing = 25.4;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct Grid221 : public AWIPSGrid 
{
  Grid221() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid221", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-145.500, 1.000);
    grid.latLonUR.Set(-2.566, 46.352);
    grid.latLonOrigin.Set(-107.0, 50.0);
    grid.stdParallel_1 = 50.0;
    grid.stdParallel_2 = 50.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(349, 277);
    grid.poleCoord.Set(174.507, 307.764);
    grid.grid_spacing = 32.46341;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid222 : public AWIPSGrid 
{
  Grid222() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid222", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-145.500, 1.000);
    grid.latLonUR.Set(-2.566, 46.352);
    grid.latLonOrigin.Set(-107.0, 50.0);
    grid.stdParallel_1 = 50.0;
    grid.stdParallel_2 = 50.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(59, 47);
    grid.poleCoord.Set(29.918, 52.127);
    grid.grid_spacing = 88.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid225 : public AWIPSGrid 
{
  Grid225() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid225", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-250.0, -25.0);
    grid.latLonUR.Set(-109.129, 60.644);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(185, 135);
    grid.lonCenter = -179.564;
    grid.grid_spacing = 80.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  Mercator grid;
};

struct Grid226 : public AWIPSGrid 
{
  Grid226() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid226", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-133.459, 12.190);
    grid.latLonUR.Set(-49.385, 57.290);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(737, 513);
    grid.poleCoord.Set(579, 1422.960);
    grid.grid_spacing = 10.1588125;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid227 : public AWIPSGrid 
{
  Grid227() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid227", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-133.459, 12.190);
    grid.latLonUR.Set(-49.385, 57.290);
    grid.latLonOrigin.Set(-95.0, 25.0);
    grid.stdParallel_1 = 25.0;
    grid.stdParallel_2 = 25.0;
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(1473, 1025);
    grid.poleCoord.Set(1157.0, 2844.92);
    grid.grid_spacing = 5.079;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LambertConformal grid;
};

struct Grid228 : public AWIPSGrid 
{
  Grid228() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid228", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0.0, 90.0);
    grid.latLonUR.Set(359.0, -90.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(144, 73);
    grid.grid_spacing = 2.5;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct Grid229 : public AWIPSGrid 
{
  Grid229() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid229", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0.0, 90.0);
    grid.latLonUR.Set(359.0, -90.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(360, 181);
    grid.grid_spacing = 1.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct Grid230 : public AWIPSGrid 
{
  Grid230() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid230", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0.0, 90.0);
    grid.latLonUR.Set(359.5, -90.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(720, 361);
    grid.grid_spacing = .5;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct Grid231 : public AWIPSGrid 
{
  Grid231() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid231", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0.0, 0.0);
    grid.latLonUR.Set(359.5, 90.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(720, 181);
    grid.grid_spacing = .5;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct Grid232 : public AWIPSGrid 
{
  Grid232() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid232", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0.0, 0.0);
    grid.latLonUR.Set(359.5, 90.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(360, 91);
    grid.grid_spacing = 1.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct Grid233 : public AWIPSGrid 
{
  Grid233() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid233", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0.0, -78.0);
    grid.latLonUR.Set(358.750, 78.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(288, 157);
    grid.grid_spacing = 1.25; // 1.25 x 1.0
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct Grid234 : public AWIPSGrid 
{
  Grid234() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid234", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-98.000, 15.0);
    grid.latLonUR.Set(-65.000, -45.0);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(133, 121);
    grid.grid_spacing = .250;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct Grid235 : public AWIPSGrid 
{
  Grid235() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Grid235", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0.250, 89.750);
    grid.latLonUR.Set(359.750, -89.750);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(720, 360);
    grid.grid_spacing = 0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
  grid.AWIPSDomainToLatLon(domain);
}
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

struct HRAP : public AWIPSGrid 
{
  HRAP() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "HRAP", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-119.036, 23.097);
    grid.latLonUR.Set(-75.945396, 53.480095);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(801, 881);
    grid.lonOrigin = -105.0;
    grid.grid_spacing = 0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  PolarStereographic grid;
};

struct NCEP1 : public AWIPSGrid 
{
  NCEP1() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "NCEP1", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(-230.094, -30.4192);
    grid.latLonUR.Set(10.710, 80.01);
    grid.gridPointLL.Set(1, 1);
    grid.gridPointUR.Set(2517.0, 1793.0);
    grid.lonCenter = -109.962;
    grid.grid_spacing = 10.0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  Mercator grid;
};

struct CustomLatLon : public AWIPSGrid 
{
  CustomLatLon() { SetValues(); }

  void SetValues() {
    grid.Reset();
    strncpy(grid.grid_name, "Unknown", (sizeof(grid.grid_name)-1));
    grid.latLonLL.Set(0, 0);
    grid.latLonUR.Set(0, 0);
    grid.gridPointLL.Set(0, 0);
    grid.gridPointUR.Set(0, 0);
    grid.grid_spacing = 0;
    grid.SetValues();
  }
  void Print() { grid.Print(); }
  void AWIPSDomainToLatLon(AWIPSdomain &domain) {
    grid.AWIPSDomainToLatLon(domain);
  }

  void SetCustomGrid(CoordPair latLonLL, CoordPair latLonUR, 
		     CoordPair gridPointLL, CoordPair gridPointUR) {
    strncpy(grid.grid_name, "CustomLatLon", (sizeof(grid.grid_name)-1));
    grid.latLonLL = latLonLL; 
    grid.latLonUR = latLonUR; 
    grid.gridPointLL = gridPointLL; 
    grid.gridPointUR = gridPointUR;
    grid.SetValues();
  }
  PointData *GetPointData() { return grid.point_data; }
  void latLonToXY(float lat, float lon, float &x, float &y) {
    grid.latLonToXY(lat, lon, x, y);
  }
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) {
    grid.AWIPSToLatLon(xwc, ywc, lat, lon);
  }
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) {
    grid.latLonToAWIPS(lat, lon, xwc, ywc);
  }
  float GetGridSpacing() {
    return grid.grid_spacing;
  }
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y) {
    return grid.latLonToGrid(domain, lat, lon, x, y);
  }

  LatLon grid;
};

#endif // __M_AWIPS_GRIDS_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //



