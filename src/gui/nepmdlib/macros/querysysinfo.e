/****************************** Module Header *******************************
*
* Module Name: querysysinfo.e
*
* .e wrapper routine to access the NEPMD library DLL.
* include of nepmdlib.e
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: querysysinfo.e,v 1.3 2002-09-05 13:23:19 cla Exp $
*
* ===========================================================================
*
* This file is part of the Netlabs EPM Distribution package and is free
* software.  You can redistribute it and/or modify it under the terms of the
* GNU General Public License as published by the Free Software
* Foundation, in version 2 as it comes in the "COPYING" file of the
* Netlabs EPM Distribution.  This library is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
****************************************************************************/

/*
@@NepmdQuerySysInfo@PROTOTYPE
SysValue = NepmdQuerySysInfo( ValueTag);

@@NepmdQuerySysInfo@CATEGORY@SYSTEM

@@NepmdQuerySysInfo@SYNTAX
This function queries system related values.

@@NepmdQuerySysInfo@PARM@ValueTag
This parameter specifies a keyword determining the
system value to be returned.

The following keywords are supported and queried from *DosQuerySysInfo*:
.pl bold
- MAXPATH
= Maximum length, in bytes, of a path name
- MAXCOMPONENT
= Maximum length, in bytes, of one component in a path name.
- BOOTDRIVE
= Drive from which the system was started
- OS2VERSION
= version number of the operating system

The following keywords are supported and queried from *WinQuerySysValue*:
.pl bold
- SWAPBUTTON
= TRUE if pointing device buttons are swapped. Normally, the
  pointing device buttons are set for right-handed use. If this value is TRUE,
  they are changed for left-handed use.
- ALARM
= TRUE if the alarm sound generated by WinAlarm is enabled;
  FALSE if the alarm sound is disabled.
- CXSCREEN
= Width of the screen.
- CYSCREEN
= Height of the screen.
- CXFULLSCREEN
= Width of the client area when the window is full screen.
- CYFULLSCREEN
= Height of the client area when the window is full screen (excluding menu height).
- DEBUG
= FALSE indicates this is not a debug system.
- CMOUSEBUTTONS
= The number of buttons on the pointing device  (zero if no pointing device is installed).
- POINTERLEVEL
= Pointer hide level. If the pointer level is zero, the pointer is visible.
  If it is greater than zero, the pointer is not visible.
- CURSORLEVEL
= The cursor hide level.
- MOUSEPRESENT
= When TRUE a mouse pointing device is attached to the system.
- PRINTSCREEN
= TRUE when the Print Screen function is enabled; FALSE when
  the Print Screen function is disabled.

@@NepmdQuerySysInfo@REMARKS
NepmdQuerySysInfo queries selected values from the *DosQuerySysInfo*
and *WinQuerySysValue* APIs.

@@NepmdQuerySysInfo@RETURNS
NepmdQuerySysInfo returns either
.ul compact
- the system value  or
- the string *ERROR:xxx*, where *xxx* is an OS/2 error code.

@@
*/

/* ------------------------------------------------------------- */
/*   allow editor command to call function                       */
/* ------------------------------------------------------------- */


defc NepmdQuerySysInfo, QuerySysInfo

 'xcom e /c .TEST_NEPMDQUERYSYSINFO';
 insertline '';
 insertline 'NepmdQuerySysInfo';
 insertline '-----------------';
 insertline '';
 insertline helperNepmdQuerySysInfoValue( 'MAXPATH');
 insertline helperNepmdQuerySysInfoValue( 'MAXCOMPONENT');
 insertline helperNepmdQuerySysInfoValue( 'BOOTDRIVE');
 insertline helperNepmdQuerySysInfoValue( 'OS2VERSION');
 insertline helperNepmdQuerySysInfoValue( 'SWAPBUTTON');
 insertline helperNepmdQuerySysInfoValue( 'ALARM');
 insertline helperNepmdQuerySysInfoValue( 'CXSCREEN');
 insertline helperNepmdQuerySysInfoValue( 'CYSCREEN');
 insertline helperNepmdQuerySysInfoValue( 'CXFULLSCREEN');
 insertline helperNepmdQuerySysInfoValue( 'CYFULLSCREEN');
 insertline helperNepmdQuerySysInfoValue( 'DEBUG');
 insertline helperNepmdQuerySysInfoValue( 'CMOUSEBUTTONS');
 insertline helperNepmdQuerySysInfoValue( 'POINTERLEVEL');
 insertline helperNepmdQuerySysInfoValue( 'CURSORLEVEL');
 insertline helperNepmdQuerySysInfoValue( 'MOUSEPRESENT');
 insertline helperNepmdQuerySysInfoValue( 'PRINTSCREEN');

 .modify = 0;

defproc helperNepmdQuerySysInfoValue( ValueTag) =
  return leftstr( ValueTag, 15) ':' NepmdQuerySysInfo( ValueTag);


/* ------------------------------------------------------------- */
/* procedure: NepmdQuerySysInfo                                  */
/* ------------------------------------------------------------- */
/* .e Syntax:                                                    */
/*    SysValue = NepmdQuerySysInfo( ValueTag);                   */
/*                                                               */
/*  See valig tags in src\gui\common\nepmd.h : NEPMD_SYSINFO_*   */
/* ------------------------------------------------------------- */
/* C prototype:                                                  */
/*  APIRET EXPENTRY NepmdQuerySysInfo( PSZ pszTagName,           */
/*                                     PSZ pszBuffer,            */
/*                                     ULONG ulBuflen)           */
/* ------------------------------------------------------------- */

defproc NepmdQuerySysInfo( ValueTag) =

 BufLen    = 260;
 SysValue = copies( atoi( 0), BufLen);

 /* prepare parameters for C routine */
 ValueTag = ValueTag''atoi( 0);

 /* call C routine */
 LibFile = getlibfile();
 rc = dynalink32( LibFile,
                  "NepmdQuerySysInfo",
                  address( ValueTag)         ||
                  address( SysValue)         ||
                  atol( Buflen));

 checkliberror( LibFile, rc);

 return makerexxstring( SysValue);

