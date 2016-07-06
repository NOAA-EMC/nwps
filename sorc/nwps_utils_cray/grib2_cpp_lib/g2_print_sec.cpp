// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 05/27/2011
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

Util functions used to print GRIB2 message sections.

*/
// ----------------------------------------------------------- // 


// GNU C/C++ include files
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined (__USE_ANSI_CPP__) // Use the ANSI Standard C++ library
#include <iostream>
using namespace std; // Use unqualified names for Standard C++ library
#else // Use the old iostream library by default
#include <iostream.h>
#endif // __USE_ANSI_CPP__

// 3plibs include files

// Our API include files
#include "g2_cpp_headers.h"
#include "g2_meta_file.h"
#include "g2_utils.h"

int PrintSec0(g2Section0 *sec0)
{
  short ibuf = 0;
  std::cout << "\n";
  std::cout << "GRIB2 Section 0" << "\n";
  std::cout << "File ID: ";
  std::cout << sec0->grib_id[0] << sec0->grib_id[1] << sec0->grib_id[2] << sec0->grib_id[3] << "\n";
  std::cout << "Edition Number: " << (int)sec0->edition_number[0] << "\n";

  g2_reverse_byte_order((unsigned char *)sec0->reserved, 2);
  memmove(&ibuf, sec0->reserved,  2);
  std::cout << "Reserved: " << ibuf << "\n";
  std::cout << "Discipline: " << (int)sec0->discipline[0] << "\n";

  __g2ULLWORD__ message_len = 0;
  g2_reverse_byte_order((unsigned char *)sec0->message_length, 8);
  memmove(&message_len, sec0->message_length, 8);
  std::cout << "Message length: " << (long)message_len << "\n";

  // Reset byte ordering
  g2_reverse_byte_order((unsigned char *)sec0->reserved, 2);
  g2_reverse_byte_order((unsigned char *)sec0->message_length, 8);

  return 1;
}

int PrintSec1(g2Section1 *sec1)
{
  short ibuf = 0;
  int section_len = 0;
  g2_reverse_byte_order((unsigned char *)sec1->id.section_length, 4);
  memmove(&section_len, sec1->id.section_length, 4);
  std::cout << "Section " << (int)sec1->id.section[0] << " length: " << (int)section_len << "\n";
  g2_reverse_byte_order((unsigned char *)sec1->originating_center, 2);
  memmove(&ibuf, sec1->originating_center,  2);
  std::cout << "Center: " << ibuf << "\n";
  g2_reverse_byte_order((unsigned char *)sec1->originating_subcenter, 2);
  memmove(&ibuf, sec1->originating_subcenter,  2);
  std::cout << "Subcenter: " << ibuf << "\n";
  std::cout << "Master Table: " << (int)sec1->master_table_version[0] << "\n";
  std::cout << "Grib Local Table: " << (int)sec1->grib_local_table_ver[0] << "\n";
  std::cout << "Time Reference: " << (int)sec1->time_reference[0] << "\n";

  g2_reverse_byte_order((unsigned char *)sec1->year, 2);
  memmove(&ibuf, sec1->year,  2);
  std::cout << "Year: " << ibuf << "\n";
  std::cout << "Month: " << (int)sec1->month[0] << "\n";
  std::cout << "Day: " << (int)sec1->day[0] << "\n";
  std::cout << "Hour: " << (int)sec1->hour[0] << "\n";
  std::cout << "Minute: " << (int)sec1->minute[0] << "\n";
  std::cout << "Second: " << (int)sec1->second[0] << "\n";

  std::cout << "Production Status: " << (int)sec1->production_status[0] << "\n";
  std::cout << "Type Of Data: " << (int)sec1->type_of_data[0] << "\n";

  // Reset byte ordering
  g2_reverse_byte_order((unsigned char *)sec1->id.section_length, 4);
  g2_reverse_byte_order((unsigned char *)sec1->originating_center, 2);
  g2_reverse_byte_order((unsigned char *)sec1->originating_subcenter, 2);
  g2_reverse_byte_order((unsigned char *)sec1->year, 2);

  return 1;
}

int PrintSec2(g2Section2 *sec2)
{
  int section_len = 0;
  g2_reverse_byte_order((unsigned char *)sec2->id.section_length, 4);
  memmove(&section_len, sec2->id.section_length, 4);

  // Reset byte ordering
  g2_reverse_byte_order((unsigned char *)sec2->id.section_length, 4);
  return 1;
}

int PrintSec3(g2Section3 *sec3)
{
  int section_len = 0;
  g2_reverse_byte_order((unsigned char *)sec3->id.section_length, 4);
  memmove(&section_len, sec3->id.section_length, 4);
  std::cout << "Section " << (int)sec3->id.section[0] << " length: " << (int)section_len << "\n";

  short ibuf = 0;
  std::cout << "Source of grid definition: " 
	    << (int)sec3->source_of_grid_def[0] << "\n";

  unsigned num_points;
  g2_reverse_byte_order((unsigned char *)sec3->num_data_points, 4);
  memmove(&num_points, sec3->num_data_points,  4);
  std::cout << "Number of data points: " << num_points << "\n";

  std::cout << "Number of non-rectangular data points: " 
	    << (int)sec3->num_non_rect_points[0] << "\n";
    
  std::cout << "Appended list of data points: " 
	    << (int)sec3->appended_point_list[0] << "\n";

  g2_reverse_byte_order((unsigned char *)sec3->grid_def_template, 2);
  memmove(&ibuf, sec3->grid_def_template,  2);
  std::cout << "Grid Definition Template Number: " << ibuf << "\n";

  // Reset byte order
  g2_reverse_byte_order((unsigned char *)sec3->id.section_length, 4);
  g2_reverse_byte_order((unsigned char *)sec3->num_data_points, 4);
  g2_reverse_byte_order((unsigned char *)sec3->grid_def_template, 2);

  return 1;
}

int PrintSec4(g2Section4 *sec4)
{
  int section_len = 0;
  g2_reverse_byte_order((unsigned char *)sec4->id.section_length, 4);
  memmove(&section_len, sec4->id.section_length, 4);
  std::cout << "Section " << (int)sec4->id.section[0] << " length: " << (int)section_len << "\n";

  short ibuf = 0;

  g2_reverse_byte_order((unsigned char *)sec4->num_coords, 2);
  memmove(&ibuf, sec4->num_coords,  2);
  std::cout << "Number coords: " << ibuf << "\n";

  g2_reverse_byte_order((unsigned char *)sec4->product_def_number, 2);
  memmove(&ibuf, sec4->product_def_number,  2);
  std::cout << "Product definition number: " << ibuf << "\n";

  // Reset byte order
  g2_reverse_byte_order((unsigned char *)sec4->id.section_length, 4);
  g2_reverse_byte_order((unsigned char *)sec4->num_coords, 2);
  g2_reverse_byte_order((unsigned char *)sec4->product_def_number, 2);

  return 1;
}

int PrintSec5(g2Section5 *sec5)
{
  int section_len = 0;
  g2_reverse_byte_order((unsigned char *)sec5->id.section_length, 4);
  memmove(&section_len, sec5->id.section_length, 4);
  std::cout << "Section " << (int)sec5->id.section[0] << " length: " << (int)section_len << "\n";

  short ibuf = 0;
  int val = 0;

  g2_reverse_byte_order((unsigned char *)sec5->num_data_points, 4);
  memmove(&val, sec5->num_data_points,  4);
  std::cout << "Number data points: " << val << "\n";

  g2_reverse_byte_order((unsigned char *)sec5->data_rep_template_num, 2);
  memmove(&ibuf, sec5->data_rep_template_num,  2);
  std::cout << "Data Representation Template Number: " << ibuf << "\n";

  // Reset byte order
  g2_reverse_byte_order((unsigned char *)sec5->id.section_length, 4);
  g2_reverse_byte_order((unsigned char *)sec5->num_data_points, 4);
  g2_reverse_byte_order((unsigned char *)sec5->data_rep_template_num, 2);

  return 1;
}

int PrintSec6(g2Section6 *sec6)
{
  int section_len = 0;
  g2_reverse_byte_order((unsigned char *)sec6->id.section_length, 4);
  memmove(&section_len, sec6->id.section_length, 4);
  std::cout << "Section " << (int)sec6->id.section[0] << " length: " << (int)section_len << "\n";
  std::cout << "Bitmap indicator: " << (int)sec6->bit_map_indicator[0] << "\n";
  return 1;

  // Reset byte order
  g2_reverse_byte_order((unsigned char *)sec6->id.section_length, 4);
}

int PrintSec7(g2Section7 *sec7)
{
  int section_len = 0;
  g2_reverse_byte_order((unsigned char *)sec7->id.section_length, 4);
  memmove(&section_len, sec7->id.section_length, 4);
  std::cout << "Section " << (int)sec7->id.section[0] << " length: " << (int)section_len << "\n";

  // Reset byte order
  g2_reverse_byte_order((unsigned char *)sec7->id.section_length, 4);

  return 1;
}

int PrintGridDefTemplate30(GridDefTemplate30 *gt)
{
  unsigned val = 0;

  std::cout << "Shape of the earth: " << (int)gt->shape_of_earth[0] << "\n";
  std::cout << "Scale factor of radius of spherical earth: " << (int)gt->radius_scale_factor[0] << "\n";

  g2_reverse_byte_order((unsigned char *)gt->radius_scale_value, 4);
  memmove(&val, gt->radius_scale_value, 4);
  std::cout << "Scaled value of radius of spherical earth: " << val << "\n"; 
  std::cout << "Scale factor of major axis of oblate spheroid earth: " << (int)gt->major_axis_scale_factor[0] << "\n";

  g2_reverse_byte_order((unsigned char *)gt->major_axis_scale_value, 4); 
  memmove(&val, gt->major_axis_scale_value, 4); 
  std::cout << "Scaled value of major axis of oblate spheroid earth: " << val << "\n";
               
  std::cout << "Scale factor of minor axis of oblate spheroid earth: " << (int)gt->minor_axis_scale_factor[0] << "\n";

  g2_reverse_byte_order((unsigned char *)gt->minor_axis_scale_value, 4); 
  memmove(&val, gt->minor_axis_scale_value, 4);    
  std::cout << "Scaled value of minor axis of oblate spheroid earth: " << val << "\n";
  
  g2_reverse_byte_order((unsigned char *)gt->nx, 4);
  memmove(&val, gt->nx, 4);
  std::cout << "Nx – number of points along X-axis: " << val << "\n"; 

  g2_reverse_byte_order((unsigned char *)gt->ny, 4);
  memmove(&val, gt->ny, 4);                                                 
  std::cout << "Ny – number of points along Y-axis: " << val << "\n"; 

  g2_reverse_byte_order((unsigned char *)gt->basic_angle, 4);
  memmove(&val, gt->basic_angle, 4);                                                 
  std::cout << "Basic angle of the initial production domain: " << val << "\n"; 

  g2_reverse_byte_order((unsigned char *)gt->subdivisions_of_basic_angle, 4);
  memmove(&val, gt->subdivisions_of_basic_angle, 4);                                                 
  std::cout << "Subdivisions of basic angle: " << val << "\n"; 

  g2_reverse_byte_order((unsigned char *)gt->la1, 4);
  memmove(&val, gt->la1, 4);
  std::cout << "La1 – latitude of first grid point: " << val << "\n";

  g2_reverse_byte_order((unsigned char *)gt->lo1, 4); 
  memmove(&val, gt->lo1, 4); 
  std::cout << "Lo1 – longitude of first grid point: " << val << "\n";

  std::cout << "Resolution and component: " << (int)gt->res_and_comp_flag[0] << "\n";

  g2_reverse_byte_order((unsigned char *)gt->la2, 4);
  memmove(&val, gt->la2, 4);
  std::cout << "La2 – latitude of last grid point: " << val << "\n";

  g2_reverse_byte_order((unsigned char *)gt->lo2, 4); 
  memmove(&val, gt->lo2, 4); 
  std::cout << "Lo2 – longitude of last grid point: " << val << "\n";

  g2_reverse_byte_order((unsigned char *)gt->dx, 4);  
  memmove(&val, gt->dx, 4);
  std::cout << "Dx – X direction grid length: " << val << "\n";

  g2_reverse_byte_order((unsigned char *)gt->dy, 4);  
  memmove(&val, gt->dy, 4);
  std::cout << "Dy – Y direction grid length: " << val << "\n";

  std::cout << "Scanning mode: " << (int)gt->scanning_mode[0] << "\n";

  // Reset byte order
  g2_reverse_byte_order((unsigned char *)gt->radius_scale_value, 4);
  g2_reverse_byte_order((unsigned char *)gt->major_axis_scale_value, 4); 
  g2_reverse_byte_order((unsigned char *)gt->minor_axis_scale_value, 4); 
  g2_reverse_byte_order((unsigned char *)gt->nx, 4);
  g2_reverse_byte_order((unsigned char *)gt->ny, 4);
  g2_reverse_byte_order((unsigned char *)gt->basic_angle, 4);
  g2_reverse_byte_order((unsigned char *)gt->subdivisions_of_basic_angle, 4);
  g2_reverse_byte_order((unsigned char *)gt->la1, 4);
  g2_reverse_byte_order((unsigned char *)gt->lo1, 4); 
  g2_reverse_byte_order((unsigned char *)gt->la2, 4);
  g2_reverse_byte_order((unsigned char *)gt->lo2, 4); 
  g2_reverse_byte_order((unsigned char *)gt->dx, 4);  
  g2_reverse_byte_order((unsigned char *)gt->dy, 4);  

  return 1;
}

int PrintProductTemplate40(ProductTemplate40 *pt)
{
  std::cout << "Parameter category: " << (int)pt->parameter_category[0] << "\n";
  std::cout << "Parameter number: " << (int)pt->parameter_number[0] << "\n";
  std::cout << "Type of generating process: " << (int)pt->process_type[0] << "\n";
  std::cout << "Background generating process identifier: " << (int)pt->process_id[0] << "\n";
  std::cout << "Analysis or forecast generating process identified: " << (int)pt->forecast_process[0] << "\n";

  std::cout << "Hours of observational data cutoff after reference time: " 
	    << g2_get_int(pt->hours, sizeof(pt->hours), 1) << "\n";

  std::cout << "Minutes of observational data cutoff after reference time: " << (int)pt->minutes[0] << "\n";
  std::cout << "Indicator of unit of time range: " << (int)pt->time_range_unit[0] << "\n";
  std::cout << "Forecast time in units: " << g2_get_int(pt->forecast_time, sizeof(pt->forecast_time), 1) << "\n";

  std::cout << "Type of first fixed surface: " << (int)pt->surface_type[0] << "\n";
  std::cout << "Scale factor of first fixed surface: " << (int)pt->surface_scale_factor[0] << "\n";

  std::cout << "Scaled value of first fixed surface: " 
	    << g2_get_int(pt->surface_scale_value, sizeof(pt->surface_scale_value), 1) << "\n";

  std::cout << "Type of second fixed surfaced: " << (int)pt->surface_type2[0] << "\n";
  std::cout << "Scale factor of second fixed surface: " << (int)pt->surface_scale_factor2[0] << "\n";

  std::cout << "Scaled value of second fixed surfaces: " 
	    << g2_get_int(pt->surface_scale_value2, sizeof(pt->surface_scale_value2), 1) << "\n";

  return 1;
}

int PrintGridTemplate50(GridTemplate50 *pt)
{
  short ibuf = 0;
  int val = 0;

  g2_reverse_byte_order((unsigned char *)pt->ref_value, 4);
  memmove(&val, pt->ref_value, 4);
  std::cout << "Reference value (R) (IEEE 32-bit floating-point value): " << val << "\n";
  
  g2_reverse_byte_order((unsigned char *)pt->bin_scale_factor, 2);
  memmove(&ibuf, pt->bin_scale_factor, 2);
  std::cout << "Binary scale factor (E): " << ibuf << "\n";

  g2_reverse_byte_order((unsigned char *)pt->dec_scale_factor, 2);
  memmove(&ibuf, pt->dec_scale_factor, 2);
  std::cout << "Decimal scale factor (D): " << ibuf << "\n";
  
  std::cout << "Number of bits used for each packed value: " << (int)pt->num_bits[0] << "\n";
  std::cout << "Type of original field values: " << (int)pt->org_field_val[0] << "\n";
  
  // Reset byte order
  g2_reverse_byte_order((unsigned char *)pt->ref_value, 4);
  g2_reverse_byte_order((unsigned char *)pt->bin_scale_factor, 2);
  g2_reverse_byte_order((unsigned char *)pt->dec_scale_factor, 2);
  
  return 1;
}

// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //
