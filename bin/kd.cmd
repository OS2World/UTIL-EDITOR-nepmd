/*
 *      KD.CMD - V1.0 C.Langanke for Netlabs EPM Distribution Project 2002
 *
 *      Syntax: kd directory
 *
 *    This program kills a directory tree. 
 *    Names including blanks are not supported !
 */
/* The first comment is used as online help text */
/****************************** Module Header *******************************
*
* Module Name: kd.cmd
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: kd.cmd,v 1.2 2002-04-18 17:01:36 cla Exp $
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

 SIGNAL ON HALT

 TitleLine = STRIP(SUBSTR(SourceLine(2), 3));
 PARSE VAR TitleLine CmdName'.CMD 'Info
 Title     = CmdName Info

 env          = 'OS2ENVIRONMENT';
 TRUE         = (1 = 1);
 FALSE        = (0 = 1);
 CrLf         = '0d0a'x;
 Redirection  = '> NUL 2>&1';
 '@ECHO OFF'

 /* OS/2 Error codes */
 ERROR.NO_ERROR           =   0;
 ERROR.INVALID_FUNCTION   =   1;
 ERROR.FILE_NOT_FOUND     =   2;
 ERROR.PATH_NOT_FOUND     =   3;
 ERROR.ACCESS_DENIED      =   5;
 ERROR.NOT_ENOUGH_MEMORY  =   8;
 ERROR.INVALID_FORMAT     =  11;
 ERROR.INVALID_DATA       =  13;
 ERROR.NO_MORE_FILES      =  18;
 ERROR.WRITE_FAULT        =  29;
 ERROR.READ_FAULT         =  30;
 ERROR.GEN_FAILURE        =  31;
 ERROR.INVALID_PARAMETER  =  87;
 ERROR.ENVVAR_NOT_FOUND   = 203;

 GlobalVars = 'Title CmdName CrLf env TRUE FALSE Redirection ERROR.';
 SAY;

 /* eventually show help */
 ARG Parm .
 IF ((Parm = '') | (POS('?', Parm) > 0)) THEN
 DO
    rc = ShowHelp();
    EXIT(ERROR.INVALID_PARAMETER);
 END;

 call RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 call SysLoadFuncs

 /* dafault values */
 GlobalVars = GlobalVars '';
 rc = ERROR.NO_ERROR;


 DO UNTIL (TRUE)

    /* get parm */
    PARSE ARG Dir;

    /* get all subdirectories */
    rc = SysFileTree( Dir'\*', 'Dir.', 'DOS');
    IF (rc \= 0) THEN
    DO
       SAY CmdName': error in SysFileTree, rc='rc;
       LEAVE;
    END;

    /* kill anything moving ... ;-) */
    DO d = Dir.0 TO 1 BY -1
       rc = SysFileTree( Dir.d'\*', 'File.', 'FO');
       DO f = 1 TO File.0
          rc = SysFileDelete( File.f);
          IF (rc \= ERROR.NO_ERROR) THEN
             SAY 'Warning: cannot delete file:' File.f;
       END;
       rc = SysRmDir( Dir.d);
       IF (rc \= ERROR.NO_ERROR) THEN
          SAY 'Warning: cannot delete direcory:' Dir.d;
    END;

    rc = SysFileTree( Dir'\*', 'File.', 'FO');
    DO f = 1 TO File.0
       rc = SysFileDelete( File.f);
       IF (rc \= ERROR.NO_ERROR) THEN
          SAY 'Warning: cannot delete file:' File.f;
    END;
    rc = SysRmDir( Dir);
    IF (rc \= ERROR.NO_ERROR) THEN
       SAY 'Warning: cannot delete direcory:' Dir;


    rc = ERROR.NO_ERROR;

 END;
 EXIT( rc);

/* ------------------------------------------------------------------------- */
HALT:
 SAY 'Abbruch durch Benutzer.';
 EXIT(ERROR.GEN_FAILURE);

/* ------------------------------------------------------------------------- */
ShowHelp: PROCEDURE EXPOSE (GlobalVars)

 /* show title */
 SAY Title;
 SAY;

 PARSE SOURCE . . ThisFile

 /* skip header */
 DO i = 1 TO 3
    rc = LINEIN(ThisFile);
 END;

 /* show help text */
 ThisLine = LINEIN(Thisfile);
 DO WHILE (ThisLine \= ' */')
    SAY SUBSTR(ThisLine, 7);
    ThisLine = LINEIN(Thisfile);
 END;

 /* close file */
 rc = LINEOUT(Thisfile);

 RETURN('');

