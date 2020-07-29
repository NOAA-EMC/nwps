# README file for direct file I/O library  

This is a C wrapper used to replace STDIO file functions with POSIX
file functions that can be used directly with the Cray IOBUF POSIX
file functions.

Compile option to enable Cray IOBUF calls: -DUSE_IOBUF_MACROS

Includes: direct_io.h
Src files: direct_io.c

