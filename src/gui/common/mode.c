/****************************** Module Header *******************************
*
* Module Name: mode.c
*
* Generic routines to support extended syntax hilighting
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: mode.c,v 1.1 2002-10-06 20:42:07 cla Exp $
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

#define INCL_DOS
#define INCL_WIN
#define INCL_ERRORS
#include <os2.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <search.h>

#include "macros.h"
#include "nepmd.h"
#include "mode.h"
#include "init.h"
#include "file.h"

// some characters
#define CHAR_MODEDELIMITER '�'

// global string vars
static   PSZ            pszEnvnameEpmKeywordpath = "EPMKEYWORDPATH";
static   PSZ            pszGlobalSection  = "GLOBAL";

// defines for strings used only once
#define SEARCHMASK_MODEDIR     "%s\\*"
#define SEARCHMASK_DEFAULTINI  "%s\\default.ini"

// some useful macros
#define QUERYOPTINITVALUE(h,s,k,t,d) \
InitQueryProfileString( h, s, k, d, t, sizeof( t));

// #############################################################################

char * strwrd( const char * string, const char * word)
{
         char * result = NULL;
         char * p;

         char * eow;
         BOOL  fStartWord;
         BOOL  fEndWord;
do
   {
   // check parm
   if ((!string) || (!word))
      break;

   p = strstr( string, word);
   while (p)
      {
      // search end of word
      eow = p;
      while (*eow > 32)
         { eow++; }
      fEndWord = (eow - p == strlen( word));

      // check start of word
      fStartWord = ((p == string) || (*(p - 1) == ' '));

      // if word, found
      if ((fStartWord) && (fEndWord))
         {
         result = p;
         break;
         }


      // search again
      p = strstr( p + 1, word);
      }

   } while (FALSE);

return result;
}

// #############################################################################

static APIRET _scanModes( PSZ pszBasename, PSZ pszExtension, PMODEINFO pmi, ULONG ulBuflen)
{
         APIRET         rc = NO_ERROR;
         PSZ            p;
         PSZ            pszMode;
         PSZ            pszModeFile;

         HDIR           hdir = NULLHANDLE;

         PSZ            pszNameMode = NULL;
         PSZ            pszExtMode = NULL;
         CHAR           szNameModeFile[ _MAX_PATH];
         CHAR           szExtModeFile[ _MAX_PATH];

         PSZ            pszKeywordPath = NULL;
         PSZ            pszKeywordDir;

         CHAR           szSearchMask[ _MAX_PATH];
         CHAR           szDir[ _MAX_PATH];
         PSZ            pszDirName;

         CHAR           szModeList[ _MAX_PATH];
         CHAR           szModeTag[ 64];

         CHAR           szFile[ _MAX_PATH];
         HINIT          hinit = NULLHANDLE;

         CHAR           szDefExtensions[ _MAX_PATH];
         CHAR           szDefNames[ _MAX_PATH];
         CHAR           szCaseSensitive[ 5];
         ULONG          ulCaseSensitive;
         ULONG          ulInfoSize;

do
   {
   // check parm
   if ((!pszBasename)  || 
       (!pszExtension) ||
       (!pmi)) 
      {
      rc = ERROR_INVALID_PARAMETER;
      break;
      }

   // init vars
   sprintf( szModeList, "%c", CHAR_MODEDELIMITER);

   // create a strdup of the path, so that we can tokenize it
   pszKeywordPath = getenv( pszEnvnameEpmKeywordpath);
   if (!pszKeywordPath)
      {
      rc = ERROR_ENVVAR_NOT_FOUND;
      break;
      }

   pszKeywordPath = strdup( pszKeywordPath);
   if (!pszKeywordPath)
      {
      rc = ERROR_NOT_ENOUGH_MEMORY;
      break;
      }

   // go through all keyword directories
   pszKeywordDir = strtok( pszKeywordPath, ";");
   while (pszKeywordDir)
      {
      // seatch all directories in that directory
      sprintf( szSearchMask, SEARCHMASK_MODEDIR, pszKeywordDir);

      // store a filenames
      hdir = HDIR_CREATE;

      while (rc == NO_ERROR)
         {
         // search it
         rc = GetNextDir( szSearchMask, &hdir,
                           szDir, sizeof( szDir));
         if (rc != NO_ERROR)
            break;

         // did we use that mode already ?
         pszDirName = Filespec( szDir, FILESPEC_NAME);
         strupr( pszDirName);
         sprintf( szModeTag, "%c%s%c", CHAR_MODEDELIMITER, pszDirName, CHAR_MODEDELIMITER);
         if (!strstr( szModeList, szModeTag))
            {
            // new mode found, first of all check for default.ini
            sprintf( szFile, SEARCHMASK_DEFAULTINI, szDir);
            rc = InitOpenProfile( szFile, &hinit, INIT_OPEN_READONLY, 0, NULL);
            if (rc == NO_ERROR)
               {
               // new mode found, first of all add to the list
               sprintf( _EOS( szModeList), "%s%c", pszDirName, CHAR_MODEDELIMITER);
   
               // query names and extensions
               QUERYOPTINITVALUE( hinit, pszGlobalSection, "DEFEXTENSIONS",  szDefExtensions, "");
               QUERYOPTINITVALUE( hinit, pszGlobalSection, "DEFNAMES",       szDefNames, "");
               strupr( szDefExtensions);
               strupr( szDefNames);
   
               // check extension and name
               if ((!pszExtMode) && 
                   (pszExtension) &&
                   (*pszExtension) &&
                   (strlen( szDefExtensions)) &&
                   (strwrd( szDefExtensions, pszExtension)))
                  {
                  pszExtMode = strdup( pszDirName);
                  strcpy( szExtModeFile, szFile);
                  }
   
               if ((!pszNameMode) && 
                   (pszBasename) &&
                   (*pszBasename) &&
                   (strlen( szDefNames)) &&
                   (strwrd( szDefNames, pszBasename)))
                  {
                  pszNameMode = strdup( pszDirName);
                  strcpy( szNameModeFile, szFile);
                  }
   
               // close profile again
               InitCloseProfile( hinit, FALSE);
               }
            else
               rc = NO_ERROR;

            }  // if (!strstr( szModeList, szModeTag))

        // extension mode found ? then break here
        if (pszExtMode)
           break;


         } // while (rc == NO_ERROR)

      DosFindClose( hdir);

      // handle special errors
      if (rc = ERROR_NO_MORE_FILES)
         rc = NO_ERROR;

      // next please
      pszKeywordDir = strtok( NULL, ";");
      }

   // prefer extmode over
   pszMode = NULL;
   if (pszNameMode)
      {
      pszMode = pszNameMode;
      pszModeFile = szNameModeFile;
      }
   if (pszExtMode)
      {
      pszMode = pszExtMode;
      pszModeFile = szExtModeFile;
      }

   // break if no mode found 
   if (!pszMode)
      {
      rc = ERROR_PATH_NOT_FOUND;
      break;
      }

   // reread details
   InitOpenProfile( pszModeFile, &hinit, INIT_OPEN_READONLY, 0, NULL);
   QUERYOPTINITVALUE( hinit, pszGlobalSection, "DEFEXTENSIONS",  szDefExtensions, "");
   QUERYOPTINITVALUE( hinit, pszGlobalSection, "DEFNAMES",       szDefNames, "");
   QUERYOPTINITVALUE( hinit, pszGlobalSection, "CASESENSITIVE",  szCaseSensitive, "");
   InitCloseProfile( hinit, FALSE);
   strupr( szDefExtensions);
   strupr( szDefNames);

   // check detail size
   ulInfoSize = sizeof( MODEINFO) + 
                strlen( pszMode) + 1 +
                strlen( szDefExtensions) + 1 + 
                strlen( szDefNames) + 1;
   if (ulInfoSize > ulBuflen)
      {
      rc = ERROR_BUFFER_OVERFLOW;
      break;
      }

   // set data
   p = (PBYTE) pmi + sizeof( MODEINFO);
   pmi->pszModeName = p;
   strcpy( p, pszMode);
   p = NEXTSTR( p);

   if (strlen( szDefExtensions))
      {
      pmi->pszDefExtensions = p;
      strcpy( p, szDefExtensions);
      p = NEXTSTR( p);
      pmi->ulModeFlags |= MODEINFO_EXTENSIONS;
      }

   if (strlen( szDefNames))
      {
      pmi->pszDefNames = p;
      strcpy( p, szDefNames);
      p = NEXTSTR( p);
      pmi->ulModeFlags |= MODEINFO_NAMES;
      }

   ulCaseSensitive = atol( szCaseSensitive);
   if (ulCaseSensitive)
      pmi->ulModeFlags |= MODEINFO_CASESENSITIVE;

   } while (FALSE);

// cleanup
if (pszKeywordPath) free( pszKeywordPath);
if (pszNameMode)    free( pszNameMode);
if (pszExtMode)     free( pszExtMode);
return rc;
}

// #############################################################################


APIRET QueryFileModeInfo( PSZ pszFilename, PMODEINFO pmi, ULONG ulBuflen)

{
         APIRET         rc = NO_ERROR;
         PSZ            p;

         PSZ            pszBasename = NULL;
         PSZ            pszExtension;
         CHAR           szMode[ 64];

do
   {
   // init return value first
   if (pmi)
      memset( pmi, 0, ulBuflen);

   // check parms
   if ((!pszFilename)   ||
       (!pmi))
      {
      rc = ERROR_INVALID_PARAMETER;
      break;
      }

   // get basename and extension of file
   pszBasename  = Filespec( pszFilename, FILESPEC_NAME);
   if (!pszBasename)
      {
      // don't call free() here
      pszBasename  = NULL;
      rc = ERROR_INVALID_PARAMETER;
      break;
      }
   pszBasename = strdup( pszBasename);
   if (!pszBasename)
      {
      rc = ERROR_NOT_ENOUGH_MEMORY;
      break;
      }
   pszExtension = Filespec( pszBasename, FILESPEC_EXTENSION);
   if (pszExtension)
      // cut off extension from basename
      *(pszExtension - 1) = 0;
   else
      pszExtension = "";

   // upercase names
   strupr( pszBasename);
   strupr( pszExtension);

   // search mode
   rc = _scanModes( pszBasename, pszExtension, pmi, ulBuflen);

   } while (FALSE);

// cleanup
if (pszBasename)  free( pszBasename);

return rc;
}

