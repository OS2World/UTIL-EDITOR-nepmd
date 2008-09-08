/****************************** Module Header *******************************
*
* Module Name: nldeinst.cmd
*
* Frame batch for to call all required CMD files when deleting
* the NEPMD base package
*
* This module is called by the WarpIN package directly.
* In order to prevent a VIO window opening for this REXX script,
* this (and only this script) is compiled to a PM executable.
*
* This program is intended to be called only during installation of the
* Netlabs EPM Distribution.
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: nldeinst.cmd,v 1.7 2008-09-08 02:46:56 aschn Exp $
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

 /* init */
 '@ECHO OFF';
 env = 'OS2ENVIRONMENT';

 /* defaults */
 ErrorTitle = 'netlabs.org EPM Distribution Installation';
 rc = 0;

 /* make sure we are called on purpose */
 ARG Parm .;
 IF (Parm \= 'NEPMD') THEN
    ShowError( ErrorTitle, 'Error: Not called by WarpIN package!');

 /* create private queue for error messages and set as default */
 QueueName = RXQUEUE('CREATE');
 rcx = RXQUEUE( 'SET', QueueName);
 rcx = VALUE( 'NEPMD_RXQUEUE', QueueName, env);

 /* make calldir the current directory */
 PARSE Source . . CallName;
 CallDir = LEFT( CallName, LASTPOS( '\', CallName) - 1);
 rcx = DIRECTORY( CallDir);

 /* call all modules required */
 DO UNTIL (1)
    'CALL DYNCFG DEINSTALL'; IF (rc \= 0) THEN LEAVE;
 END;

 /* show error message where applicable */
 IF ((rc \= 0) & (QUEUED() > 0)) THEN
 DO
    PARSE PULL ErrorMessage;
    ShowError( ErrorTitle, ErrorMessage);
 END;

 EXIT( rc);


/* ========================================================================= */
ShowError: PROCEDURE
 PARSE ARG Title, Message;

 /* show message box in PM mode */
 SIGNAL ON SYNTAX;
 rcx = rxmessagebox( Message, Title, 'CANCEL', 'ERROR');
 EXIT( 99);

 /* print text in VIO mode */
SYNTAX:
 SIGNAL OFF SYNTAX;
 SAY '';
 SAY Title;
 SAY Message;
 EXIT( 99);

