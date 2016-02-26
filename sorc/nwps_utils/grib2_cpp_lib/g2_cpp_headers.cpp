// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 11/30/2012
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

GRIB2 headers for CPP library.

*/
// ----------------------------------------------------------- // 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "g2_cpp_headers.h"
#include "g2_utils.h"

g2Section0::g2Section0(int grib2_discipline) 
{
  grib_id[0] = 'G';
  grib_id[1] = 'R';
  grib_id[2] = 'I';
  grib_id[3] = 'B';
  edition_number[0] = 2;
  memset(reserved, 0, sizeof(reserved));
  discipline[0] = (unsigned char)grib2_discipline;
  memset(message_length, 0, sizeof(message_length));
}

void g2Section0::Reset()
{
  memset(grib_id, 0, sizeof(grib_id));
  edition_number[0] = 0;
  memset(reserved, 0, sizeof(reserved));
  discipline[0] = 0;
  memset(message_length, 0, sizeof(message_length));
}

void g2Section0::SetGRIB2MessageLen(__g2ULLWORD__ grib2_message_length)
{
  memmove(message_length, (unsigned char *)&grib2_message_length, 8);
}

unsigned char *g2Section0::GetFileBuf(__g2ULLWORD__ grib2_message_length)
{
  SetGRIB2MessageLen(grib2_message_length);
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(reserved, 2);
  g2_reverse_byte_order(message_length, 8);
  memcpy(buf, (unsigned char *)this, len);
  return buf;
}

size_t g2Section0::SetSize()
{
  return GetSize();
}

size_t g2Section0::GetSize()
{
  size_t sz = sizeof(grib_id);
  sz += sizeof(reserved);
  sz += sizeof(discipline);
  sz += sizeof(edition_number);
  sz += sizeof(message_length);
  return sz;
}

g2Section1::g2Section1() 
{
  int len = (int)GetSize();
  memmove(id.section_length, &len, 4);
  id.section[0] = 1;
  short center = 255;
  memmove(originating_center, &center, 2);
  center = 0;
  memmove(originating_subcenter, &center, 2);
  master_table_version[0] = 2;
  grib_local_table_ver[0] = 1;
  time_reference[0] = 1;
  
  time_t elapsed_seconds = 0;
  struct tm tm_local;
  struct tm *tm_ptr;
  char str_year[25], str_month[25], str_day[25], str_hour[25], str_minute[25], str_second[25];
  memset(str_year, 0, sizeof(str_year));
  memset(str_month, 0, sizeof(str_month));
  memset(str_day, 0, sizeof(str_day));
  memset(str_hour, 0, sizeof(str_hour));
  memset(str_minute, 0, sizeof(str_minute));
  memset(str_second, 0, sizeof(str_second));
  memset(&tm_local, 0, sizeof(tm_local));
  
  time(&elapsed_seconds); 
  tm_ptr = gmtime(&elapsed_seconds);
  memmove(&tm_local, tm_ptr, sizeof(tm_local));
  
  strftime(str_year, (sizeof(str_year)-1), "%Y", &tm_local);
  strftime(str_month, (sizeof(str_month)-1), "%m", &tm_local);
  strftime(str_day, (sizeof(str_day)-1), "%d", &tm_local);
  strftime(str_hour, (sizeof(str_hour)-1), "%H", &tm_local);
  strftime(str_minute, (sizeof(str_minute)-1), "%M", &tm_local);
  strftime(str_second, (sizeof(str_second)-1), "%S", &tm_local);
  
  short int_year = (short)atoi(str_year);
  memmove(year, &int_year, 2);
  month[0] = (char)atoi(str_month);
  day[0] = (char)atoi(str_day);
  hour[0] = (char)atoi(str_hour);
  minute[0] = (char)atoi(str_minute);
  second[0] = (char) atoi(str_second);
  production_status[0] = 0;
  type_of_data[0] = 1;
}

unsigned char *g2Section1::GetFileBuf()
{
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(id.section_length, 4);
  g2_reverse_byte_order(originating_center, 2);
  g2_reverse_byte_order(originating_subcenter, 2);
  g2_reverse_byte_order(year, 2);
  memcpy(buf, (unsigned char *)this, len);
  return buf;
}

size_t g2Section1::SetSize()
{
  return GetSize();
}

size_t g2Section1::GetSize()
{
  size_t sz = sizeof(id);
  sz += sizeof(originating_center);
  sz += sizeof(originating_subcenter);
  sz += sizeof(master_table_version);
  sz += sizeof(grib_local_table_ver);
  sz += sizeof(time_reference);
  sz += sizeof(year);
  sz += sizeof(month);
  sz += sizeof(day);
  sz += sizeof(hour);
  sz += sizeof(minute);
  sz += sizeof(second);
  sz += sizeof(production_status);
  sz += sizeof(type_of_data);
  unsigned int len = (unsigned int)sz;
  memmove(id.section_length, &len, 4);
  return sz;
}

g2SectionID &g2SectionID::operator=(const g2SectionID &ob)
{
  if(this != &ob) Copy(ob);
  return *this;
}

void g2SectionID::Reset()
{
  memset(section_length, 0, 4);
  section[0] = 0;
}

void g2SectionID::Copy(const g2SectionID &ob) 
{
  memcpy(section_length, ob.section_length, 4);
  section[0] = ob.section[0];
}

g2Section2::g2Section2()
{
  memset(id.section_length, 0, 4);
  id.section[0] = 2;
  data_len = 0;
  local_use_data = 0;
}

g2Section2::~g2Section2()
{
  if((data_len > 0) && (local_use_data != 0)) {
    delete local_use_data;
  }
}

unsigned char *g2Section2::GetFileBuf()
{
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(id.section_length, 4); 
  memcpy(buf, (unsigned char *)this, 5);
  if((data_len > 0) && (local_use_data != 0)) {
    memcpy(buf+5, local_use_data, data_len);
  }
  return buf;
}

size_t g2Section2::GetSize()
{
  size_t sz = sizeof(id);
  sz += data_len;
  unsigned int len = (unsigned int)sz;
  memmove(id.section_length, &len, 4);
  return sz;
}

size_t g2Section2::SetSize()
{
  return GetSize();
}

int g2Section2::AllocData(size_t len)
{
  if((data_len > 0) && (local_use_data != 0)) delete local_use_data;
  local_use_data = new unsigned char[len];
  data_len = len;
  memset(local_use_data, 0 , len);
  SetSize();
  return 1;
}

g2Section3::g2Section3() 
{
  memset(id.section_length, 0, 4);
  id.section[0] = 3;
  source_of_grid_def[0] = 0;
  memset(num_data_points, 0, 4);
  
  // Set default number of points to 4
  g2_set_int(4, num_data_points, sizeof(num_data_points));

  num_non_rect_points[0] = 0;
  appended_point_list[0] = 0;
  memset(grid_def_template, 0, 2);
  grid_def_len = 0;
  grid_def = 0;
  appended_points_len = 0;
  appended_points = 0;
}

g2Section3::~g2Section3()
{
  if((grid_def_len > 0) && (grid_def != 0)) {
    delete grid_def;
  }
  if((appended_points_len > 0) && (appended_points != 0)) {
    delete appended_points;
  } 
}

int g2Section3::AllocTemplate(size_t len)
{
  if((grid_def_len > 0) && (grid_def != 0)) delete grid_def;
  grid_def = new unsigned char[len];
  memset(grid_def, 0, len);
  grid_def_len = len;
  SetSize();
  return 1;
}

int g2Section3::AllocPoints(size_t len)
{
  if((appended_points_len > 0) && (appended_points != 0)) delete appended_points;
  appended_points = new unsigned char[len];
  memset(appended_points, 0, len);
  appended_points_len = len;
  SetSize();
  return 1;
}

unsigned char *g2Section3::GetFileBuf()
{
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(id.section_length, 4); 
  g2_reverse_byte_order(num_data_points, 4);
  g2_reverse_byte_order(grid_def_template, 2);
  memcpy(buf, (unsigned char *)this, 14);
  if((grid_def_len > 0) && (grid_def != 0) &&
     (appended_points_len > 0) && (appended_points != 0)) {
    memcpy(buf+14, grid_def, grid_def_len);
    memcpy(buf+(14+grid_def_len), appended_points, appended_points_len);
  }
  else if((grid_def_len > 0) && (grid_def != 0)) {
    memcpy(buf+14, grid_def, grid_def_len);
  }
  else if((appended_points_len > 0) && (appended_points != 0)) {
    memcpy(buf+14, appended_points, appended_points_len);
  }
  else {
    ;
  }
  return buf;
}

size_t g2Section3::GetSize()
{
  size_t sz = sizeof(id);
  sz += sizeof(source_of_grid_def);
  sz += sizeof(num_data_points);
  sz += sizeof(num_non_rect_points);
  sz += sizeof(appended_point_list);
  sz += sizeof(grid_def_template);
  sz += grid_def_len;
  sz += appended_points_len;
  unsigned int len = (unsigned int)sz;
  memmove(id.section_length, &len, 4);
  return sz;
}

size_t g2Section3::SetSize()
{
  return GetSize();
}

g2Section4::g2Section4()
{
  memset(id.section_length, 0, 4);
  id.section[0] = 4;
  memset(num_coords, 0, 2);
  memset(product_def_number, 0, 2);
  product_def_len = 0;
  product_def = 0;
  coord_list_len = 0;
  coord_list = 0;
}

g2Section4::~g2Section4()
{
  if((product_def_len > 0) && (product_def != 0)) {
    delete product_def;
  }
  if((coord_list_len > 0) && (coord_list != 0)) {
    delete coord_list;
  } 
}

unsigned char *g2Section4::GetFileBuf()
{
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(id.section_length, 4); 
  g2_reverse_byte_order(num_coords, 2);
  g2_reverse_byte_order(product_def_number, 2);
  memcpy(buf, (unsigned char *)this, 9);
  if((product_def_len > 0) && (product_def != 0) &&
     (coord_list_len > 0) && (coord_list != 0)) {
    memcpy(buf+9, product_def, product_def_len);
    memcpy(buf+(9+coord_list_len), coord_list, coord_list_len);
  }
  else if((product_def_len > 0) && (product_def != 0)) {
    memcpy(buf+9, product_def, product_def_len);
  }
  else if((coord_list_len > 0) && (coord_list != 0)) {
    memcpy(buf+9, coord_list, coord_list_len);
  }
  else {
    ;
  }
  return buf;
}

int g2Section4::AllocTemplate(size_t len)
{
  if((product_def_len > 0) && (product_def != 0)) delete product_def;
  product_def = new unsigned char[len];
  memset(product_def, 0,  len);
  product_def_len = len;
  SetSize();
  return 1;
}

int g2Section4::AllocPoints(size_t len)
{
  if((coord_list_len > 0) && (coord_list != 0)) delete coord_list;
  coord_list = new unsigned char[len];
  memset(coord_list, 0, len);
  coord_list_len = len;
  SetSize();
  return 1;
}

size_t g2Section4::GetSize()
{
  size_t sz = sizeof(id);
  sz += sizeof(num_coords);
  sz += sizeof(product_def_number);
  sz += product_def_len;
  sz += coord_list_len;
  unsigned int len = (unsigned int)sz;
  memmove(id.section_length, &len, 4);
  return sz;
}

size_t g2Section4::SetSize()
{
  return GetSize();
}

g2Section5::g2Section5()
{
  memset(id.section_length, 0, 4);
  id.section[0] = 5;

  // Setup a default grid for template files
  g2_set_int(4, num_data_points, sizeof(num_data_points));

  memset(data_rep_template_num, 0 , 2);
  data_rep_template_len = 0;
  data_rep_template = 0;
}

g2Section5::~g2Section5()
{
  if((data_rep_template_len > 0) && (data_rep_template != 0)) {
    delete data_rep_template;
  }
}

unsigned char *g2Section5::GetFileBuf()
{
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(id.section_length, 4); 
  g2_reverse_byte_order(num_data_points, 4);
  g2_reverse_byte_order(data_rep_template_num, 2);
  memcpy(buf, (unsigned char *)this, 11);
  if((data_rep_template_len > 0) && (data_rep_template != 0)) {
    memcpy(buf+11, data_rep_template, data_rep_template_len);
  }
  return buf;
}

int g2Section5::AllocTemplate(size_t len)
{
  if((data_rep_template_len > 0) && (data_rep_template != 0)) delete data_rep_template;
  data_rep_template = new unsigned char[len];
  memset(data_rep_template, 0, len);
  data_rep_template_len = len;
  SetSize();
  return 1;
}

size_t g2Section5::GetSize()
{
  size_t sz = sizeof(id);
  sz += sizeof(num_data_points);
  sz += sizeof(data_rep_template_num);
  sz += data_rep_template_len;
  unsigned int len = (unsigned int)sz;
  memmove(id.section_length, &len, 4);
  return sz;
}

size_t g2Section5::SetSize()
{
  return GetSize();
}

g2Section6::g2Section6()
{
  memset(id.section_length, 0, 4);
  id.section[0] = 6;
  bit_map_indicator[0] = 255;
  bit_map_len = 0;
  bit_map = 0; 
}

g2Section6::~g2Section6()
{
  if((bit_map_len > 0) && (bit_map != 0)) {
    delete bit_map;
  }
}

unsigned char *g2Section6::GetFileBuf()
{
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(id.section_length, 4); 
  memcpy(buf, (unsigned char *)this, 6);
  if((bit_map_len > 0) && (bit_map != 0)) {
    memcpy(buf+6, bit_map, bit_map_len);
  }
  return buf;
}

int g2Section6::AllocBitmap(size_t len)
{
  if((bit_map_len > 0) && (bit_map != 0)) delete bit_map;
  bit_map = new unsigned char[len];
  memset(bit_map, 0, len);
  bit_map_len = len;
  SetSize();
  return 0;
}

size_t g2Section6::GetSize()
{
  size_t sz = sizeof(id);
  sz += sizeof(bit_map_indicator);
  sz += bit_map_len;
  unsigned int len = (unsigned int)sz;
  memmove(id.section_length, &len, 4);
  return sz;
}

size_t g2Section6::SetSize()
{
  return GetSize();
}

g2Section7::g2Section7()
{
  memset(id.section_length, 0, 4);
  id.section[0] = 7;
  data_len = 0;
  data = 0;
}

g2Section7::~g2Section7()
{
  if((data_len > 0) && (data != 0)) {
    delete data;
  }
}

unsigned char *g2Section7::GetFileBuf()
{
  size_t len = GetSize();
  unsigned char *buf = new unsigned char[len];
  memset(buf, 0, len);
  g2_reverse_byte_order(id.section_length, 4); 
  memcpy(buf, (unsigned char *)this, 5);
  if((data_len > 0) && (data != 0)) {
    memcpy(buf+5, data, data_len);
  }
  return buf;
}

int g2Section7::AllocData(size_t len)
{
  if((data_len > 0) && (data != 0)) delete data;
  data = new unsigned char[len];
  memset(data, 0, len);
  data_len = len;
  SetSize();
  return 1;
}

size_t g2Section7::GetSize()
{
  size_t sz = sizeof(id);
  sz += data_len;
  unsigned int len = (unsigned int)sz;
  memmove(id.section_length, &len, 4);
  return sz;
}

size_t g2Section7::SetSize()
{
  return GetSize();
}

g2Section8::g2Section8() 
{
  end_sequence[0] = '7';
  end_sequence[1] = '7';
  end_sequence[2] = '7';
  end_sequence[3] = '7';
}

GridDefTemplate30::GridDefTemplate30()
{
  memset(shape_of_earth, 0, 1);
  memset(radius_scale_factor, 0, 1);
  memset(radius_scale_value, 0, 4);
  memset(major_axis_scale_factor, 0, 1);
  memset(major_axis_scale_value, 0, 4);
  memset(minor_axis_scale_factor, 0, 1);
  memset(minor_axis_scale_value, 0, 4);
  memset(nx, 0, 4);
  memset(ny, 0, 4);
  memset(basic_angle, 0, 4);
  memset(subdivisions_of_basic_angle, 0, 4);
  memset(la1, 0, 4);
  memset(lo1, 0, 4);
  memset(res_and_comp_flag, 0, 1);
  memset(la2, 0, 4);
  memset(lo2, 0, 4);
  memset(dx, 0, 4);
  memset(dy, 0, 4);
  memset(scanning_mode, 0, 1);

  // Set some default values for template files
  g2_set_int(6, shape_of_earth, sizeof(shape_of_earth));
  g2_set_int(6371229, radius_scale_value, sizeof(radius_scale_value));
  g2_set_int(2, nx, sizeof(nx));
  g2_set_int(2, ny, sizeof(ny)); 
  g2_set_int(-1, subdivisions_of_basic_angle, sizeof(subdivisions_of_basic_angle));
  g2_set_int(1000000, la2, sizeof(la2));
  g2_set_int(1000000, lo2, sizeof(lo2)); 
  g2_set_int(10000, dx, sizeof(dx));
  g2_set_int(10000, dy, sizeof(dy));
  res_and_comp_flag[0] = 48;
  g2_set_int(64, scanning_mode, sizeof(scanning_mode));
}

void GridDefTemplate30::SetFileBuf()
{
  g2_reverse_byte_order(radius_scale_value, 4);
  g2_reverse_byte_order(major_axis_scale_value, 4);
  g2_reverse_byte_order(minor_axis_scale_value, 4);
  g2_reverse_byte_order(nx, 4);
  g2_reverse_byte_order(ny, 4);
  g2_reverse_byte_order(basic_angle, 4);
  g2_reverse_byte_order(subdivisions_of_basic_angle, 4);
  g2_reverse_byte_order(la1, 4);
  g2_reverse_byte_order(lo1, 4);
  g2_reverse_byte_order(la2, 4);
  g2_reverse_byte_order(lo2, 4);
  g2_reverse_byte_order(dx, 4);
  g2_reverse_byte_order(dy, 4);
}

GridDefTemplate30::~GridDefTemplate30()
{

}

// http://www.weather.gov/forecasts/graphical/docs/grib_design.html
GridDefTemplate310::GridDefTemplate310()
{
  memset(shape_of_earth, 0, 1);
  memset(radius_scale_factor, 0, 1);
  memset(radius_scale_value, 0, 4);
  memset(major_axis_scale_factor, 0, 1);
  memset(major_axis_scale_value, 0, 4);
  memset(minor_axis_scale_factor, 0, 1);
  memset(minor_axis_scale_value, 0, 4);
  memset(nx, 0, 4);
  memset(ny, 0, 4);
  memset(la1, 0, 4);
  memset(lo1, 0, 4);
  memset(res_and_comp_flag, 0, 1);
  memset(lad, 0, 4);
  memset(la2, 0, 4);
  memset(lo2, 0, 4);
  memset(scanning_mode, 0, 1);
  memset(grid_angle, 0, 4);
  memset(dx, 0, 4);
  memset(dy, 0, 4);
}

GridDefTemplate310::~GridDefTemplate310() 
{

}

void GridDefTemplate310::SetFileBuf()
{
  g2_reverse_byte_order(radius_scale_value, sizeof(radius_scale_value));
  g2_reverse_byte_order(major_axis_scale_value, sizeof(major_axis_scale_value));
  g2_reverse_byte_order(minor_axis_scale_value, sizeof(minor_axis_scale_value));
  g2_reverse_byte_order(nx, sizeof(nx));
  g2_reverse_byte_order(ny, sizeof(ny));
  g2_reverse_byte_order(la1, sizeof(la1));
  g2_reverse_byte_order(lo1, sizeof(lo1));
  g2_reverse_byte_order(lad, sizeof(lad));
  g2_reverse_byte_order(la2, sizeof(la2));
  g2_reverse_byte_order(lo2, sizeof(lo2));
  g2_reverse_byte_order(grid_angle, sizeof(grid_angle));
  g2_reverse_byte_order(dx, sizeof(dx));
  g2_reverse_byte_order(dy, sizeof(dy));
}

GridDefTemplate320::GridDefTemplate320()
{
  memset(shape_of_earth, 0, 1);
  memset(radius_scale_factor, 0, 1);
  memset(radius_scale_value, 0, 4);
  memset(major_axis_scale_factor, 0, 1);
  memset(major_axis_scale_value, 0, 4);
  memset(minor_axis_scale_factor, 0, 1);
  memset(minor_axis_scale_value, 0, 4);
  memset(nx, 0, 4);
  memset(ny, 0, 4);
  memset(la1, 0, 4);
  memset(lo1, 0, 4);
  memset(res_and_comp_flag, 0, 1);
  memset(la2, 0, 4);
  memset(lo2, 0, 4);
  memset(dx, 0, 4);
  memset(dy, 0, 4);
  memset(proj_flag, 0, 1);
  memset(scanning_mode, 0, 1);
}

GridDefTemplate320::~GridDefTemplate320() 
{

}

void GridDefTemplate320::SetFileBuf()
{
  g2_reverse_byte_order(radius_scale_value, sizeof(radius_scale_value));
  g2_reverse_byte_order(major_axis_scale_value, sizeof(major_axis_scale_value));
  g2_reverse_byte_order(minor_axis_scale_value, sizeof(minor_axis_scale_value));
  g2_reverse_byte_order(nx, sizeof(nx));
  g2_reverse_byte_order(ny, sizeof(ny));
  g2_reverse_byte_order(la1, sizeof(la1));
  g2_reverse_byte_order(lo1, sizeof(lo1));
  g2_reverse_byte_order(la2, sizeof(la2));
  g2_reverse_byte_order(lo2, sizeof(lo2));
  g2_reverse_byte_order(dx, sizeof(dx));
  g2_reverse_byte_order(dy, sizeof(dy));
}

GridDefTemplate330::GridDefTemplate330()
{
  shape_of_earth[0] = 1;
  radius_scale_factor[0] = 0;
  g2_set_int(6371200, radius_scale_value, sizeof(radius_scale_value)); 
  major_axis_scale_factor[0] = 0;
  memset(major_axis_scale_value, 0, 4);
  memset(minor_axis_scale_factor, 0, 1);
  memset(minor_axis_scale_value, 0, 4);
  g2_set_int(1073, nx, 4);
  g2_set_int(689, ny, 4);
  g2_set_int(2019199, la1, 4);
  g2_set_int(2384459, lo1, 4);
  memset(res_and_comp_flag, 0, 1);
  g2_set_int(25000000, la2, 4);
  g2_set_int(265000000, lo2, 4);
  g2_set_int(5079406, dx, 4);
  g2_set_int(5079406, dy, 4);
  memset(proj_flag, 0, 1);
  scanning_mode[0] = 80;
  g2_set_int(25000000, latin1, 4);
  g2_set_int(25000000, latin2, 4);
  // TOOD: Set to neg
  //  -90000000  unsigned char la_south_pole[4]; // Octets 74-77: Latitude of the southern pole of projection
  lo_south_pole[0] = 0;
}

GridDefTemplate330::~GridDefTemplate330() 
{

}

void GridDefTemplate330::SetFileBuf()
{
  g2_reverse_byte_order(radius_scale_value, sizeof(radius_scale_value));
  g2_reverse_byte_order(major_axis_scale_value, sizeof(major_axis_scale_value));
  g2_reverse_byte_order(minor_axis_scale_value, sizeof(minor_axis_scale_value));
  g2_reverse_byte_order(nx, sizeof(nx));
  g2_reverse_byte_order(ny, sizeof(ny));
  g2_reverse_byte_order(la1, sizeof(la1));
  g2_reverse_byte_order(lo1, sizeof(lo1));
  g2_reverse_byte_order(la2, sizeof(la2));
  g2_reverse_byte_order(lo2, sizeof(lo2));
  g2_reverse_byte_order(dx, sizeof(dx));
  g2_reverse_byte_order(dy, sizeof(dy));
  g2_reverse_byte_order(latin1, sizeof(latin1));
  g2_reverse_byte_order(latin2, sizeof(latin2));
  g2_reverse_byte_order(la_south_pole, sizeof(la_south_pole));
  g2_reverse_byte_order(lo_south_pole, sizeof(lo_south_pole));
}

ProductTemplate40::ProductTemplate40()
{
  parameter_category[0] = 255;
  parameter_number[0] = 255;
  process_type[0] = 255;
  process_id[0] = 255;
  forecast_process[0] = 255;

  g2_set_int(-1, hours, sizeof(hours));

  minutes[0] = 255;
  time_range_unit[0] = 255;

  g2_set_int(-1, forecast_time, sizeof(forecast_time));

  surface_type[0] = 255;
  surface_scale_factor[0] = 255;
  g2_set_int(-1, surface_scale_value, sizeof(surface_scale_value));

  memset(surface_type2, 0, 1);
  memset(surface_scale_factor2, 0, 1);
  memset(surface_scale_value2, 0, 4);
}

void ProductTemplate40::SetFileBuf()
{
  g2_reverse_byte_order(hours, 2);
  g2_reverse_byte_order(forecast_time, 4);
  g2_reverse_byte_order(surface_scale_value, 4);
  g2_reverse_byte_order(surface_scale_value2, 4);
}

ProductTemplate40::~ProductTemplate40()
{

}

GridTemplate50::GridTemplate50()
{
  memset(ref_value, 0, 4);
  memset(bin_scale_factor, 0, 2);
  memset(dec_scale_factor, 0, 2);
  memset(num_bits, 0, 1);
  memset(org_field_val, 0, 1);
}

void GridTemplate50::SetFileBuf()
{
  g2_reverse_byte_order(ref_value, 4);
  g2_reverse_byte_order(bin_scale_factor, 2);
  g2_reverse_byte_order(dec_scale_factor, 2);
}

GridTemplate50::~GridTemplate50()
{


}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //
