/****************************** Module Header *******************************
*
* Module Name: mkex.cmd
*
* Syntax: mkex target_dir sourcefile
*
* Script for to create the NEPMD version of EPM.EX
*
* As a precaution EPMPATH is set to the macros directory only in order not
* to use any of source files from other directories
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: mkex.cmd,v 1.1 2002-08-19 17:47:21 cla Exp $
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

 '@ECHO OFF';
 env = 'OS2ENVIRONMENT';
 rcx = SETLOCAL();
 call RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 call SysLoadFuncs

 /* get parms */
 PARSE ARG TargetDir SourceFile;
 TargetDir = STRIP( TargetDir);
 IF (TargetDir = '') THEN
 DO
    SAY 'mkex: error: target directory not specified.';
    EXIT( 87); /* ERROR.INVALID_PARAMETER */
 END;

 IF (SourceFile = '') THEN
    SourceFile = 'epm.e';

 TargetFile = SourceFile'x';

 /* create tempfile */
 TmpFile = SysTempFilename( VALUE('TMP',,env)'\mkex.???');

 /* call compiler */
 'etpm' SourceFile TargetDir'\'TargetFile '>' TmpFile;

 IF (rc \= 0) THEN
    rcx = ShowEtpmError( TmpFile);

 EXIT (rc);

/* ========================================================================= */
/* This routine is applicable only for non-verbose output !!! */
ShowEtpmError: PROCEDURE
 PARSE ARG Filename;

 /* skip header */
 DO WHILE (LINES( FileName) > 0)
    ThisLine = LINEIN( FileName);
    IF (ThisLine = ' compiling ...') THEN
       LEAVE;
 END;

 /* read error info */
 ErrorMessage = LINEIN( FileName);
 Dummy        = LINEIN( FileName);
 Dummy        = LINEIN( FileName);
 FileInfo     = LINEIN( FileName);
 LineInfo     = LINEIN( FileName);
 ColInfo      = LINEIN( FileName);

 /* close and remove file */
 rcx = STREAM( Filename, 'C', 'CLOSE');
 rcx = SysFileDelete( Filename);

 /* display error information */
 PARSE VAR FileInfo .'='File' ';
 PARSE VAR LineInfo .'= 'Line' ';
 PARSE VAR ColInfo  .'= 'Col;
 SAY File'('Line':'Col'):' ErrorMessage;

 RETURN( 0);

