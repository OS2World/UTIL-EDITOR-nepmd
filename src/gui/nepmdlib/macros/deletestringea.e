/****************************** Module Header *******************************
*
* Module Name: deletestringea.e
*
* .e wrapper routine to access the NEPMD library DLL.
* include of nepmdlib.e
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: deletestringea.e,v 1.2 2002-08-23 08:29:42 cla Exp $
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

defc NepmdDeleteStringEa, DeleteStringEa =

  Filename = arg( 1);
  rc = NepmdWriteStringEa( Filename, NEPMD_TEST_EANAME, '');

  if (rc > 0) then
     sayerror 'Extended attribute not deleted, rc='rc;
     return;
  endif

  sayerror 'Extended attribute "'NEPMD_TEST_EANAME'" deleted from:' Filename;

