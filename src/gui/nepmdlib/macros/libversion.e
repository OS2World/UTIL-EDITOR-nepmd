/****************************** Module Header *******************************
*
* Module Name: libversion.e
*
* .e wrapper routine to access the NEPMD library DLL.
* include of nepmdlib.e
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: libversion.e,v 1.1 2002-08-20 14:56:57 cla Exp $
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

/* ------------------------------------------------------------- */
/*   allow editor command to call function                       */
/* ------------------------------------------------------------- */

defc NepmdLibVersion =

  sayerror 'NEPMDLIB Version' NepmdLibVersion();

/* ------------------------------------------------------------- */
/* procedure: NepmdLibVersion                                    */
/* ------------------------------------------------------------- */
/* .e Syntax:                                                    */
/*    data = NepmdLibVersion();                                  */
/* ------------------------------------------------------------- */
/* C prototype:                                                  */
/*  APIRET EXPENTRY NepmdLibVersion( PSZ pszBuffer,              */
/*                                   ULONG ulBuflen)             */
/*                                                               */
/* ------------------------------------------------------------- */

defproc NepmdLibVersion() =

 BufLen     = 20;
 LibVersion = copies( atoi( 0), BufLen);

 /* prepare parameters for C routine */
 Token    = Token''atoi( 0);

 /* call C routine */
 LibFile = getlibfile();
 rc = dynalink32( LibFile,
                  "NepmdLibVersion",
                  address( LibVersion) ||
                  atol( Buflen));

 checkliberror( LibFile, rc);

 return LibVersion;

