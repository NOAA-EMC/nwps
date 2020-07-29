// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 04/11/2016
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

GRIB2 headers for CPP library.

This library was designed in compliance with WMO GRIB2 standards:

http://www.wmo.int/pages/prog/www/WMOCodes/Guides/GRIB/Introduction_GRIB1-GRIB2.doc
http://www.wmo.int/pages/prog/www/WMOCodes/Guides/GRIB/GRIB2_062006.doc

NCEP References used:

http://www.nco.ncep.noaa.gov/pmb/docs/grib2

NWS References used, LAMP and NDFD Encoding:

http://www.nws.noaa.gov/mdl/gfslamp/docs/lampgrib2.shtml
http://www.weather.gov/forecasts/graphical/docs/grib_design.html

Section 0: Indicator Section: "GRIB", Discipline, GRIB Edition number, 
                               Length of message

Section 1: Identification: Section Length of section, section number,
                           characteristics that apply to all processed data 
                           in the GRIB message

Section 2: Local Use Section: Length of section, section number, additional 
                              items for local use by originating centers

Section 3: Grid Definition Section: Length of section, section number, 
                                    definition of grid surface and geometry 
                                    of data values within the surface

Section 4: Product Definition Section: Length of Section, section number, 
                                       description of the nature of the data

Section 5:Data Representation Section: Length of section, section number, 
                                       description of how the data values 
                                       are represented. This will define if
				       data is compresses or not and what type
                                       of compression we are using.

Section 6:Bit-Map Section: Length of section, section number, indication 
                           of presence or absence of data at each grid 
                           point, as applicable

Section 7:Data Section: Length of section, section number, data values

Section 8:End Section: "7777"
*/
// ----------------------------------------------------------- // 
#ifndef __M_G2_CPP_HEADERS_HPP__
#define __M_G2_CPP_HEADERS_HPP__

// Default for all UNIX variants. NOTE: Place specific UNIX variants
// above this directive.
typedef long long __g2LLWORD__;
typedef unsigned long long __g2ULLWORD__;

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect0.shtml
struct g2Section0 
{
  g2Section0(int grib2_discipline = 0); 
  ~g2Section0() { };

  void Reset();
  void SetGRIB2MessageLen(__g2ULLWORD__ grib2_message_length);
  size_t GetSize();
  size_t SetSize();
  unsigned char *GetFileBuf(__g2ULLWORD__ grib2_message_length);

  unsigned char grib_id[4]; // Octets 1-4
  unsigned char reserved[2]; // Octets 5-6
  unsigned char discipline[1]; // Octet 7
  unsigned char edition_number[1]; // Octet 8
  unsigned char message_length[8]; // Octets 9-16
};

struct g2SectionID
{
  g2SectionID() { Reset(); }
  ~g2SectionID() { }
  g2SectionID(const g2SectionID &ob) { Copy(ob); }
  g2SectionID &operator=(const g2SectionID &ob);

  void Copy(const g2SectionID &ob);
  void Reset();

  unsigned char section_length[4];
  unsigned char section[1];
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect1.shtml
struct g2Section1 
{
  g2Section1();
  ~g2Section1() { }

  size_t GetSize();
  size_t SetSize();
  unsigned char *GetFileBuf();

  g2SectionID id;  // Octets 1-5
  unsigned char originating_center[2]; // Octets 6-7
  unsigned char originating_subcenter[2]; // Octets 8-9
  unsigned char master_table_version[1]; // Octet 10
  unsigned char grib_local_table_ver[1]; // Octet 11
  unsigned char time_reference[1]; // Octet 12: 0 = Analysis, 1 = Start of Forecast
  unsigned char year[2]; // Octets 13-14
  unsigned char month[1]; // Octet 16
  unsigned char day[1]; // Octet 16
  unsigned char hour[1]; // Octet 17
  unsigned char minute[1]; // Octet 18
  unsigned char second[1]; // Octet 19
  unsigned char production_status[1]; // Octet 20
  unsigned char type_of_data[1]; // Octet 21: 0 = Analysis Products, 1 = Forecast Products
  // NOTE: Octet 22 is a reserved field and does not need to be present
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect2.shtml
struct g2Section2 
{
  // NOTE: Section 2 is optional and only used in GRIB message if specified
  g2Section2();
  ~g2Section2();

  int AllocData(size_t len);
  size_t GetSize();
  size_t SetSize();
  unsigned char *GetFileBuf();

  g2SectionID id; // Octets 1-5
  size_t data_len; 
  unsigned char *local_use_data; // Octets 6-xx
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect3.shtml
struct g2Section3
{
  g2Section3();
  ~g2Section3();

  int AllocTemplate(size_t len);
  int AllocPoints(size_t len);
  size_t GetSize();
  size_t SetSize();
  unsigned char *GetFileBuf();

  g2SectionID id; // Octets 1-5
  unsigned char source_of_grid_def[1]; // Octet 6
  unsigned char num_data_points[4]; // Octets 7-10
  unsigned char num_non_rect_points[1]; // Octet 11
  unsigned char appended_point_list[1]; // Octet 12
  unsigned char grid_def_template[2]; // Octets 13-14: Grid Definition 
                                      // Template Number (see Code Table 3.1)

  size_t grid_def_len;
  unsigned char *grid_def; // Octets 15-xx

  // The appended points array is optional and used if specified
  size_t appended_points_len;
  unsigned char *appended_points; // Octets xx+1-nn
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect4.shtml
struct g2Section4
{
  g2Section4();
  ~g2Section4();

  int AllocTemplate(size_t len);
  int AllocPoints(size_t len);
  size_t GetSize();
  size_t SetSize();
  unsigned char *GetFileBuf();

  g2SectionID id; // Octets 1-5
  unsigned char num_coords[2]; // Octets 6-7
  // http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_table4-0.shtml
  unsigned char product_def_number[2]; // Octets 8-9
  size_t product_def_len;
  unsigned char *product_def; // Octets 10-xx
  size_t coord_list_len;
  unsigned char *coord_list; // Octets xx+1-nn
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect5.shtml
struct g2Section5
{
  g2Section5();
  ~g2Section5();

  int AllocTemplate(size_t len);
  size_t GetSize();
  size_t SetSize();
  unsigned char *GetFileBuf();

  g2SectionID id;  // Octets 1-5
  unsigned char num_data_points[4]; // Octets 6-9 
  unsigned char data_rep_template_num[2]; // Octets 10-11
  size_t data_rep_template_len; 
  unsigned char *data_rep_template; // Octet 12-nn
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect6.shtml
struct g2Section6
{
  g2Section6();
  ~g2Section6();

  int AllocBitmap(size_t len);
  size_t GetSize();
  size_t SetSize();
  unsigned char *GetFileBuf();

  g2SectionID id; // Octets 1-5
  unsigned char bit_map_indicator[1]; // Octet 6
  size_t bit_map_len;
  unsigned char *bit_map; // Octet 7-nn  
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_sect7.shtml
struct g2Section7
{
  g2Section7();
  ~g2Section7();

  // 04/11/2016: Fix for wgrib2 # define CHECK
  int AllocData(size_t len, int withdata = 0);
  size_t GetSize(int withdata = 0);
  size_t SetSize(int withdata = 0);
  unsigned char *GetFileBuf(int withdata = 0);

  g2SectionID id; // Octets 1-5
  size_t data_len;
  unsigned char *data; // Octets 6-nn
};

struct g2Section8
{
  g2Section8();
  unsigned char end_sequence[4];
};

// Template used with section 3 for LAT/LON grids
// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_table3-1.shtml
struct GridDefTemplate30
{
  GridDefTemplate30();
  ~GridDefTemplate30();

  void SetFileBuf();

  unsigned char shape_of_earth[1]; // Octets 15: Shape of the earth (see Code Table 3.2)
  unsigned char radius_scale_factor[1];// Octets 16: Scale factor of radius of spherical earth
  unsigned char radius_scale_value[4]; // Octets 17-20: Scaled value of radius of spherical earth
  unsigned char major_axis_scale_factor[1]; // Octets 21: Scale factor of major axis of oblate spheroid earth
  unsigned char major_axis_scale_value[4];  // Octets 22-25: Scaled value of major axis of oblate spheroid earth
  unsigned char minor_axis_scale_factor[1]; // Octets 26: Scale factor of minor axis of oblate spheroid earth
  unsigned char minor_axis_scale_value[4];  // Octets 27-30: Scaled value of minor axis of oblate spheroid earth
  unsigned char nx[4];  // Octets 31-34: Nx – number of points along X-axis
  unsigned char ny[4];  // Octets 35-38: Ny – number of points along Y-axis
  unsigned char basic_angle[4]; // 39-42 - Basic angle of the initial production domain
  unsigned char subdivisions_of_basic_angle[4]; // 43-46 Subdivisions of basic angle used to define extreme
                                                // longitudes and latitudes, and direction increments
  unsigned char la1[4]; // Octets 47-50: La1 – latitude of first grid point
  unsigned char lo1[4]; // Octets 51-54: Lo1 – longitude of first grid point
  unsigned char res_and_comp_flag[1]; // Octet 55: Resolution and component flag (see Flag Table 3.3)
  unsigned char la2[4]; // Octets 56-59: La2 – latitude of last grid point
  unsigned char lo2[4]; // Octets 60-63: Lo2 – longitude of last grid point
  unsigned char dx[4];  // Octets 64-67: Dx – X direction grid length
  unsigned char dy[4];  // Octets 68-71: Dy – Y direction grid length
  unsigned char scanning_mode[1]; // Octet 72: Scanning mode (see Flag Table 3.4)
};

// Template used with section 3 for Mercator grids
// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_temp3-10.shtml
struct GridDefTemplate310
{
  GridDefTemplate310();
  ~GridDefTemplate310();

  void SetFileBuf();

  unsigned char shape_of_earth[1]; // Octets 15: Shape of the earth (see Code Table 3.2)
  unsigned char radius_scale_factor[1];// Octets 16: Scale factor of radius of spherical earth
  unsigned char radius_scale_value[4]; // Octets 17-20: Scaled value of radius of spherical earth
  unsigned char major_axis_scale_factor[1]; // Octets 21: Scale factor of major axis of oblate spheroid earth
  unsigned char major_axis_scale_value[4];  // Octets 22-25: Scaled value of major axis of oblate spheroid earth
  unsigned char minor_axis_scale_factor[1]; // Octets 26: Scale factor of minor axis of oblate spheroid earth
  unsigned char minor_axis_scale_value[4];  // Octets 27-30: Scaled value of minor axis of oblate spheroid earth
  unsigned char nx[4];  // Octets 31-34: Nx - number of points along a parallel  
  unsigned char ny[4];  // Octets 35-38: Ny - number of points along  a meridian
  unsigned char la1[4]; // Octets: 39-42 La1 - latitude of first grid point
  unsigned char lo1[4]; // Octets: 43-46 Lo1 - longitude of first grid point
  unsigned char res_and_comp_flag[1]; // Octet 47: Resolution and component flag (see Flag Table 3.3)
  unsigned char lad[4]; // Octet 48-51: LaD - latitude(s) at which the Mercator projection intersects 
                        // the Earth (Latitude(s) where Di and Dj are specified)  
  unsigned char la2[4]; // Octet 52-55: La2 - latitude of last grid point
  unsigned char lo2[4]; // Octet 56-59: Lo2 - longitude of last grid point   
  unsigned char scanning_mode[1]; // Octet 60: Scanning mode (flags ― see Flag table 3.4)
  unsigned char grid_angle[4]; // Octet 61-64: Orientation of the grid, angle between i direction on the map and the Equator
  unsigned char dx[4]; // Octet 65-68: Dj - longitudinal direction grid length
  unsigned char dy[4]; // Octet 69-72: Dj - latitudinal direction grid length
  //
  // 73-nn List of number of points along each meridian or parallel 
  // (These octets are only present for quasi-regular grids as described in notes 2 and 3 of GDT 3.1)
};

// Template used with section 3 for Polar stereographic grids
// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_temp3-20.shtml
struct GridDefTemplate320
{
  GridDefTemplate320();
  ~GridDefTemplate320();

  void SetFileBuf();

  unsigned char shape_of_earth[1]; // Octets 15: Shape of the earth (see Code Table 3.2)
  unsigned char radius_scale_factor[1];// Octets 16: Scale factor of radius of spherical earth
  unsigned char radius_scale_value[4]; // Octets 17-20: Scaled value of radius of spherical earth
  unsigned char major_axis_scale_factor[1]; // Octets 21: Scale factor of major axis of oblate spheroid earth
  unsigned char major_axis_scale_value[4];  // Octets 22-25: Scaled value of major axis of oblate spheroid earth
  unsigned char minor_axis_scale_factor[1]; // Octets 26: Scale factor of minor axis of oblate spheroid earth
  unsigned char minor_axis_scale_value[4];  // Octets 27-30: Scaled value of minor axis of oblate spheroid earth
  unsigned char nx[4];  // Octets 31-34: Nx - number of points along X-axis
  unsigned char ny[4];  // Octets 35-38: Ny - number of points along Y-axis
  unsigned char la1[4]; // Octets 39-42: La1 - latitude of first grid point
  unsigned char lo1[4]; // Octets 43-46: Lo1 - longitude of first grid point
  unsigned char res_and_comp_flag[1]; // Octet 47: Resolution and component flag (see Flag Table 3.3)

  unsigned char la2[4]; // Octets 48-51: LaD - latitude where Dx and Dy are specified
  unsigned char lo2[4]; // Octets 52-55: LoV - orientation of the grid (see Note2)
  unsigned char dx[4];  // Octets 56-59: Dx - x-direction grid length (see Note 2)
  unsigned char dy[4];  // Octets 60-63: Dy - y-direction  grid length (see Note 3)
  unsigned char proj_flag[1];  // Octets 64: Projection centre flag (see Flag Table 3.5)
  unsigned char scanning_mode[1]; // Octet 65: Scanning mode (see Flag Table 3.4)
};

// Template used with section 3 for Lambert conformal grids
// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_temp3-30.shtml
struct GridDefTemplate330
{
  GridDefTemplate330();
  ~GridDefTemplate330();

  void SetFileBuf();

  unsigned char shape_of_earth[1]; // Octets 15: Shape of the earth (see Code Table 3.2)
  unsigned char radius_scale_factor[1];// Octets 16: Scale factor of radius of spherical earth
  unsigned char radius_scale_value[4]; // Octets 17-20: Scaled value of radius of spherical earth
  unsigned char major_axis_scale_factor[1]; // Octets 21: Scale factor of major axis of oblate spheroid earth
  unsigned char major_axis_scale_value[4];  // Octets 22-25: Scaled value of major axis of oblate spheroid earth
  unsigned char minor_axis_scale_factor[1]; // Octets 26: Scale factor of minor axis of oblate spheroid earth
  unsigned char minor_axis_scale_value[4];  // Octets 27-30: Scaled value of minor axis of oblate spheroid earth
  unsigned char nx[4];  // Octets 31-34: Nx - number of points along X-axis
  unsigned char ny[4];  // Octets 35-38: Ny - number of points along Y-axis
  unsigned char la1[4]; // Octets 39-42: La1― latitude of first grid point
  unsigned char lo1[4]; // Octets 43-46: Lo1― longitude of first grid point
  unsigned char res_and_comp_flag[1]; // Octets 47: Resolution and component flags (see Flag Table 3.3)
  unsigned char la2[4]; // Octets 48-51: LaD ― latitude where Dx and Dy are specified
  unsigned char lo2[4]; // Octets 52-55: LoV ― longitude of meridian parallel to y-axis along which 
                        // latitude increases as the y-coordinate increases
  unsigned char dx[4];  // Octets 56-59: Dx ― x-direction grid length (see Note1)
  unsigned char dy[4];  // Octets 60-63: Dy ― y-direction grid length (see Note 1)
  unsigned char proj_flag[1];  // Octets 64: Projection centre flag (see Flag Table 3.5)
  unsigned char scanning_mode[1]; // Octets 65: Scanning mode (see Flag Table 3.4)
  unsigned char latin1[4]; // Octets 66-69: Latin 1 ― first latitude from the pole at which the secant cone cuts the sphere
  unsigned char latin2[4]; // Octets 70-73: Latin 2 ― second latitude from the pole at which the secant cone cuts the sphere
  unsigned char la_south_pole[4]; // Octets 74-77: Latitude of the southern pole of projection
  unsigned char lo_south_pole[4]; // Octets 78-81: Longitude of the southern pole of projection
};

// Template used with section 4
struct ProductTemplate40
{
  ProductTemplate40();
  ~ProductTemplate40();

  void SetFileBuf();

  unsigned char parameter_category[1]; // Octets 10: Parameter category (see Code table 4.1)
  unsigned char parameter_number[1]; // Octets 11: Parameter number (see Code table 4.2)
  unsigned char process_type[1]; // Octets 12: Type of generating process (see Code table 4.3)
  unsigned char process_id[1]; // Octets 13: Background generating process identifier (defined by originating center)
  unsigned char forecast_process[1]; // Octets 14: Analysis or forecast generating process identified (see Code ON388 Table A)
  unsigned char hours[2]; // Octets 15-16: Hours of observational data cutoff after reference time (see Note)
  unsigned char minutes[1]; // Octets 17: Minutes of observational data cutoff after reference time (see Note)
  unsigned char time_range_unit[1]; // Octets 18: Indicator of unit of time range (see Code table 4.4)
  unsigned char forecast_time[4]; // Octets 19-22: Forecast time in units defined by octet 18
  unsigned char surface_type[1]; // Octets 23: Type of first fixed surface (see Code table 4.5)
  unsigned char surface_scale_factor[1]; // Octets 24: Scale factor of first fixed surface
  unsigned char surface_scale_value[4]; // Octets 25-28: Scaled value of first fixed surface
  unsigned char surface_type2[1]; // Octets 29: Type of second fixed surfaced (see Code table 4.5)
  unsigned char surface_scale_factor2[1]; // Octets 30: Scale factor of second fixed surface
  unsigned char surface_scale_value2[4]; // Octets 31-34: Scaled value of second fixed surfaces
};

// http://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_temp5-0.shtml
struct GridTemplate50
{
  GridTemplate50();
  ~GridTemplate50();

  void SetFileBuf();
  
  unsigned char ref_value[4]; // Octets 12-15: Reference value (R) (IEEE 32-bit floating-point value)
  unsigned char bin_scale_factor[2]; // Octets 16-17: Binary scale factor (E)
  unsigned char dec_scale_factor[2]; // Octets 18-19: Decimal scale factor (D)
  unsigned char num_bits[1]; // Octet 20: Number of bits used for each packed value for simple packing, 
                             // or for each group reference value for complex packing or spatial differencing
  unsigned char org_field_val[1]; // Octet 21: Type of original field values (see Code Table 5.1)
};

struct GRIB2Template
{
  GridDefTemplate30 gt30;
  ProductTemplate40 pt40;
  GridTemplate50 gt50;
};

struct GRIB2Message
{
  // Our GRIB2 message
  g2Section0 sec0;
  g2Section1 sec1;
  g2Section3 sec3;
  g2Section4 sec4;
  g2Section5 sec5;
  g2Section6 sec6;
  g2Section7 sec7;
  g2Section8 sec8;

  // Our GRIB2 templates
  GRIB2Template templates;
};


#endif // __M_G2_CPP_HEADERS_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //
