/****************************** Module Header *******************************
*
* Module Name: wps.e
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: wps.e,v 1.3 2004-06-04 00:13:45 aschn Exp $
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

; Commands/procedures to communicate with the WPS

; ---------------------------------------------------------------------------
; Opens the location of the current file as a WPS folder.
; arg(1) = setup string for the folder.
; Notes for the current version:
;    -  Open.erx is needed.
;    -  The setup string will be passed to the REXX function
;       SysSetObjectData.
;    -  If no setup string is specified, the folder will open in it's
;       default view.
defc OpenFolder
   SetupString = strip( arg(1) )
   if SetupString = '' then
      SetupString = 'OPEN=DEFAULT'
   endif
   Filename = .filename
   -- Get Dir of Filename
   p = lastpos( '\', Filename)
   if p > 1 then
      Dir = substr( Filename, 1, p - 1)
   else
      Dir = Filename'\..'
   endif
   'rx open 'Dir','SetupString
   return

; ---------------------------------------------------------------------------
; Opens the location of the specified file as a WPS folder.
; arg(1) = filename
; Notes for the current version:
;    -  Open.erx is needed.
;    -  The setup string will be passed to the REXX function
;       SysSetObjectData.
;    -  If no filename is specified, the folder of the current filename
;       will open.
defc OpenFolderOf
   SetupString = 'OPEN=DEFAULT'
   Filename = arg(1)
   if leftstr( Filename, 1) = '"' & rightstr( Filename, 1) = '"' then
      Filename = substr( Filename, 2, length(Filename) - 2)
   endif
   if Filename = '' then
      Filename = .filename
   endif
   -- Get Dir of Filename
   p = lastpos( '\', Filename)
   if p > 1 then
      Dir = substr( Filename, 1, p - 1)
   else
      Dir = Filename'\..'
   endif
   'rx open 'Dir','SetupString
   return

; ---------------------------------------------------------------------------
; Opens the properties dialog of the specified object
; arg(1) = objectname or objectid
; Notes for the current version:
;    -  Open.erx is needed.
;    -  The setup string will be passed to the REXX function
;       SysSetObjectData.
;    -  If no objectname is specified, the properties dialog of the
;       current filename will open.
defc OpenSettings
   SetupString = 'OPEN=SETTINGS'
   Filename = arg(1)
   if leftstr( Filename, 1) = '"' & rightstr( Filename, 1) = '"' then
      Filename = substr( Filename, 2 length(Filename) - 2)
   endif
   if Filename = '' then
      Filename = .filename
   endif
   'rx open 'Filename','SetupString
   return

