/*
 * Copyright (c) 1999-2000 Image Power, Inc. and the University of
 *   British Columbia.
 * Copyright (c) 2001-2003 Michael David Adams.
 * All rights reserved.
 */

/* __START_OF_JASPER_LICENSE__
 * 
 * JasPer Software License
 * 
 * IMAGE POWER JPEG-2000 PUBLIC LICENSE
 * ************************************
 * 
 * GRANT:
 * 
 * Permission is hereby granted, free of charge, to any person (the "User")
 * obtaining a copy of this software and associated documentation, to deal
 * in the JasPer Software without restriction, including without limitation
 * the right to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the JasPer Software (in source and binary forms),
 * and to permit persons to whom the JasPer Software is furnished to do so,
 * provided further that the License Conditions below are met.
 * 
 * License Conditions
 * ******************
 * 
 * A.  Redistributions of source code must retain the above copyright notice,
 * and this list of conditions, and the following disclaimer.
 * 
 * B.  Redistributions in binary form must reproduce the above copyright
 * notice, and this list of conditions, and the following disclaimer in
 * the documentation and/or other materials provided with the distribution.
 * 
 * C.  Neither the name of Image Power, Inc. nor any other contributor
 * (including, but not limited to, the University of British Columbia and
 * Michael David Adams) may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * 
 * D.  User agrees that it shall not commence any action against Image Power,
 * Inc., the University of British Columbia, Michael David Adams, or any
 * other contributors (collectively "Licensors") for infringement of any
 * intellectual property rights ("IPR") held by the User in respect of any
 * technology that User owns or has a right to license or sublicense and
 * which is an element required in order to claim compliance with ISO/IEC
 * 15444-1 (i.e., JPEG-2000 Part 1).  "IPR" means all intellectual property
 * rights worldwide arising under statutory or common law, and whether
 * or not perfected, including, without limitation, all (i) patents and
 * patent applications owned or licensable by User; (ii) rights associated
 * with works of authorship including copyrights, copyright applications,
 * copyright registrations, mask work rights, mask work applications,
 * mask work registrations; (iii) rights relating to the protection of
 * trade secrets and confidential information; (iv) any right analogous
 * to those set forth in subsections (i), (ii), or (iii) and any other
 * proprietary rights relating to intangible property (other than trademark,
 * trade dress, or service mark rights); and (v) divisions, continuations,
 * renewals, reissues and extensions of the foregoing (as and to the extent
 * applicable) now existing, hereafter filed, issued or acquired.
 * 
 * E.  If User commences an infringement action against any Licensor(s) then
 * such Licensor(s) shall have the right to terminate User's license and
 * all sublicenses that have been granted hereunder by User to other parties.
 * 
 * F.  The JPEG-2000 codec implementation included in the JasPer software
 * is for use only in hardware or software products that are compliant
 * with ISO/IEC 15444-1 (i.e., JPEG-2000 Part 1).  No license or right to
 * this codec implementation is granted for products that do not comply
 * with ISO/IEC 15444-1.
 * 
 * THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF THIS LICENSE.
 * NO USE OF THE JASPER SOFTWARE IS AUTHORIZED HEREUNDER EXCEPT UNDER
 * THIS DISCLAIMER.  THE JASPER SOFTWARE IS PROVIDED BY THE LICENSORS AND
 * CONTRIBUTORS UNDER THIS LICENSE ON AN ``AS-IS'' BASIS, WITHOUT WARRANTY
 * OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION,
 * WARRANTIES THAT THE JASPER SOFTWARE IS FREE OF DEFECTS, IS MERCHANTABLE,
 * IS FIT FOR A PARTICULAR PURPOSE OR IS NON-INFRINGING.  THOSE INTENDING
 * TO USE THE JASPER SOFTWARE OR MODIFICATIONS THEREOF FOR USE IN HARDWARE
 * OR SOFTWARE PRODUCTS ARE ADVISED THAT THEIR USE MAY INFRINGE EXISTING
 * PATENTS, COPYRIGHTS, TRADEMARKS, OR OTHER INTELLECTUAL PROPERTY RIGHTS.
 * THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE JASPER SOFTWARE
 * IS WITH THE USER.  SHOULD ANY PART OF THE JASPER SOFTWARE PROVE DEFECTIVE
 * IN ANY RESPECT, THE USER (AND NOT THE INITIAL DEVELOPERS, THE UNIVERSITY
 * OF BRITISH COLUMBIA, IMAGE POWER, INC., MICHAEL DAVID ADAMS, OR ANY
 * OTHER CONTRIBUTOR) SHALL ASSUME THE COST OF ANY NECESSARY SERVICING,
 * REPAIR OR CORRECTION.  UNDER NO CIRCUMSTANCES AND UNDER NO LEGAL THEORY,
 * WHETHER TORT (INCLUDING NEGLIGENCE), CONTRACT, OR OTHERWISE, SHALL THE
 * INITIAL DEVELOPER, THE UNIVERSITY OF BRITISH COLUMBIA, IMAGE POWER, INC.,
 * MICHAEL DAVID ADAMS, ANY OTHER CONTRIBUTOR, OR ANY DISTRIBUTOR OF THE
 * JASPER SOFTWARE, OR ANY SUPPLIER OF ANY OF SUCH PARTIES, BE LIABLE TO
 * THE USER OR ANY OTHER PERSON FOR ANY INDIRECT, SPECIAL, INCIDENTAL, OR
 * CONSEQUENTIAL DAMAGES OF ANY CHARACTER INCLUDING, WITHOUT LIMITATION,
 * DAMAGES FOR LOSS OF GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR
 * MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL DAMAGES OR LOSSES, EVEN IF
 * SUCH PARTY HAD BEEN INFORMED, OR OUGHT TO HAVE KNOWN, OF THE POSSIBILITY
 * OF SUCH DAMAGES.  THE JASPER SOFTWARE AND UNDERLYING TECHNOLOGY ARE NOT
 * FAULT-TOLERANT AND ARE NOT DESIGNED, MANUFACTURED OR INTENDED FOR USE OR
 * RESALE AS ON-LINE CONTROL EQUIPMENT IN HAZARDOUS ENVIRONMENTS REQUIRING
 * FAIL-SAFE PERFORMANCE, SUCH AS IN THE OPERATION OF NUCLEAR FACILITIES,
 * AIRCRAFT NAVIGATION OR COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, DIRECT
 * LIFE SUPPORT MACHINES, OR WEAPONS SYSTEMS, IN WHICH THE FAILURE OF THE
 * JASPER SOFTWARE OR UNDERLYING TECHNOLOGY OR PRODUCT COULD LEAD DIRECTLY
 * TO DEATH, PERSONAL INJURY, OR SEVERE PHYSICAL OR ENVIRONMENTAL DAMAGE
 * ("HIGH RISK ACTIVITIES").  LICENSOR SPECIFICALLY DISCLAIMS ANY EXPRESS
 * OR IMPLIED WARRANTY OF FITNESS FOR HIGH RISK ACTIVITIES.
 * 
 * 
 * __END_OF_JASPER_LICENSE__
 */

/*
 * Primitive Types
 *
 * $Id$
 */

#ifndef JAS_TYPES_H
#define JAS_TYPES_H

#include <jasper/jas_config.h>

#if !defined(JAS_CONFIGURE)

#if defined(WIN32) || defined(HAVE_WINDOWS_H)
/*
   We are dealing with Microsoft Windows and most likely Microsoft
   Visual C (MSVC).  (Heaven help us.)  Sadly, MSVC does not correctly
   define some of the standard types specified in ISO/IEC 9899:1999.
   In particular, it does not define the "long long" and "unsigned long
   long" types.  So, we work around this problem by using the "INT64"
   and "UINT64" types that are defined in the header file "windows.h".
 */
#include <windows.h>
#undef longlong
#define	longlong	INT64
#undef ulonglong
#define	ulonglong	UINT64
#endif

#endif

#if defined(HAVE_STDLIB_H)
#include <stdlib.h>
#endif
#if defined(HAVE_STDDEF_H)
#include <stddef.h>
#endif
#if defined(HAVE_SYS_TYPES_H)
#include <sys/types.h>
#endif

#ifndef __cplusplus
#if defined(HAVE_STDBOOL_H)
/*
 * The C language implementation does correctly provide the standard header
 * file "stdbool.h".
 */
#include <stdbool.h>
#else

/*
 * The C language implementation does not provide the standard header file
 * "stdbool.h" as required by ISO/IEC 9899:1999.  Try to compensate for this
 * braindamage below.
 */
#if !defined(bool)
#define	bool	int
#endif
#if !defined(true)
#define true	1
#endif
#if !defined(false)
#define	false	0
#endif
#endif

#endif

#if defined(HAVE_STDINT_H)
/*
 * The C language implementation does correctly provide the standard header
 * file "stdint.h".
 */
#include <stdint.h>
#else
/*
 * The C language implementation does not provide the standard header file
 * "stdint.h" as required by ISO/IEC 9899:1999.  Try to compensate for this
 * braindamage below.
 */
#include <limits.h>

#ifdef __INTTYPES_INCLUDED

#if !defined(INT_FAST8_MIN)
#define INT_FAST8_MIN	(-127)
#define INT_FAST8_MAX	128
#endif
/**********/
#if !defined(UINT_FAST8_MAX)
#define UINT_FAST8_MAX	255
#endif
/**********/
#if !defined(INT_FAST16_MIN)
#define INT_FAST16_MIN	SHRT_MIN
#define INT_FAST16_MAX	SHRT_MAX
#endif
/**********/
#if !defined(UINT_FAST16_MAX)
#define UINT_FAST16_MAX	USHRT_MAX
#endif
/**********/
#if !defined(INT_FAST32_MIN)
#define INT_FAST32_MIN	INT_MIN
#define INT_FAST32_MAX	INT_MAX
#endif
/**********/
#if !defined(UINT_FAST32_MAX)
#define UINT_FAST32_MAX	UINT_MAX
#endif
/**********/
#if !defined(INT_FAST64_MIN)
#define INT_FAST64_MIN	LLONG_MIN
#define INT_FAST64_MAX	LLONG_MAX
#endif
/**********/
#if !defined(UINT_FAST64_MAX)
#define UINT_FAST64_MAX	ULLONG_MAX
#endif
/**********/

#else

/**********/
#if !defined(INT_FAST8_MIN)
typedef signed char int_fast8_t;
#define INT_FAST8_MIN	(-127)
#define INT_FAST8_MAX	128
#endif
/**********/
#if !defined(UINT_FAST8_MAX)
typedef unsigned char uint_fast8_t;
#define UINT_FAST8_MAX	255
#endif
/**********/
#if !defined(INT_FAST16_MIN)
typedef short int_fast16_t;
#define INT_FAST16_MIN	SHRT_MIN
#define INT_FAST16_MAX	SHRT_MAX
#endif
/**********/
#if !defined(UINT_FAST16_MAX)
typedef unsigned short uint_fast16_t;
#define UINT_FAST16_MAX	USHRT_MAX
#endif
/**********/
#if !defined(INT_FAST32_MIN)
typedef int int_fast32_t;
#define INT_FAST32_MIN	INT_MIN
#define INT_FAST32_MAX	INT_MAX
#endif
/**********/
#if !defined(UINT_FAST32_MAX)
typedef unsigned int uint_fast32_t;
#define UINT_FAST32_MAX	UINT_MAX
#endif
/**********/
#if !defined(INT_FAST64_MIN)
typedef longlong int_fast64_t;
#define INT_FAST64_MIN	LLONG_MIN
#define INT_FAST64_MAX	LLONG_MAX
#endif
/**********/
#if !defined(UINT_FAST64_MAX)
typedef ulonglong uint_fast64_t;
#define UINT_FAST64_MAX	ULLONG_MAX
#endif
/**********/
#endif

#endif

/* The below macro is intended to be used for type casts.  By using this
  macro, type casts can be easily located in the source code with
  tools like "grep". */
#define	JAS_CAST(t, e) \
	((t) (e))

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __cplusplus
}
#endif

#endif
