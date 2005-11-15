/****************************** Module Header *******************************
*
* Module Name: ckeys.e
*
* Copyright (c) Netlabs EPM Distribution Project 2002
*
* $Id: ckeys.e,v 1.11 2005-11-15 16:29:34 aschn Exp $
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
Todo:

-- Expand <Enter> -----------------------------------------------------------

WANT_BRACE_BELOW_STATEMENT_INDENTED
WANT_BRACE_BELOW_STATEMENT
WANT_BRACE_BELOW_PROC
WANT_BRACE_BELOW_JAVA_STATEMENT
WANT_BRACE_BELOW_JAVA_PROC


ok xxxxx (xxx) {xxx}|   -->   xxxxx (xxx) {xxx}
                        -->   |

ok xxxxx (xxx) {|xxx}   -->   xxxxx (xxx) {     for WANT_BRACE_BELOW_STATEMENT = 0
                        -->      |xxx
                        -->   }

ok xxxxx (xxx) {|xxx}   -->   xxxxx (xxx)       for WANT_BRACE_BELOW_STATEMENT = 1
                        -->   {
                        -->      |xxx
                        -->   }

-----------







ok xxxx {|              -->   xxxxx {
                        -->      |


ok {|                   -->   {
                        -->      |

ok {|}                  -->   {
                        -->      |
                        -->   }

ok {|xxxx               -->   {
                        -->      |xxxxx

ok while (xxx) {|xxxx   -->   while (xxx) {
                        -->      |xxxxx

\  while (xxx) {xx|xx   -->   while (xxx) {xxxx
                        -->      |

ok while (xxx) {xx|xx   -->   while (xxx) {xx
                        -->      |xx

ok while (xxx) {|}      -->   while (xxx) {
                        -->      |
                        -->   }
\  xxxxx (xxx)| {xxx}   -->   xxxxx (xxx)
                        -->   {
                        -->      xxx
                        -->      |
                        -->   }

-- <Enter> on line with non-closed paren ------------------------------------
   -- this will not respect current indent
-  xxxxx( xxxxx |       -->   xxxxx( xxxxx
                        -->          |

-  xxxxx ( xxxxx |      -->   xxxxx ( xxxxx
                        -->           |

-  xxxxx (xxxxx |       -->   xxxxx (xxxxx
                        -->          |

   -- stream mode only (break line at current pos)
-  xxxxx( xx|xxx        -->   xxxxx( xx
                        -->          |xxx

-  xxxxx( |)            -->   xxxxx(
                        -->          |)

-  xxxxx( |xxx)         -->   xxxxx(
                        -->          |xxx)

-  xxxxx( xxx)|         -->   xxxxx( xxx)
                        -->   |

-- Expand } -----------------------------------------------------------------
ok xxxx {               -->   xxxx {    <-- opening brace is highlighted
      xxxx              -->      xxxx
             |          -->   }|        <-- unindent, compared to non-blank line above

ok xxxx {               -->   xxxx {    <-- opening brace is highlighted
             |          -->   }|        <-- same indent, compared to non-blank line
                                        <-- with opening brace above

?  maybe unindent lines starting with }, dependent from the opening paren or
   the opening statement (e.g. if, else)  --> not required anymore

-- To be fixed --------------------------------------------------------------
ok expand 'int main' as well as 'main'

ok don't expand main twice

ok do
      {
      } while ();  <-- cursor on this line should not split line

ok do
   {
   } while ();  <-- cursor on this line should not split line

ok do| + <Space>        -->   do {
                        -->     |
                        -->   } while ();   <-- 1 space before ); too much

ok for + <Space>                        -->   for (|; ; ) {
                                        -->   }
ok fo|r ( xxx; xxx; xxx) { + <Enter>    -->   for ( xxx|; xxx; xxx) {
ok for ( xxx; x|xx; xxx) { + <Enter>    -->   for ( xxx; xxx|; xxx) {
ok for ( xxx; xxx|; xxx) { + <Enter>    -->   for ( xxx; xxx; xxx|) {
ok for ( xxx; xxx; xxx|) { + <Enter>    -->   for ( xxx; xxx; xxx) {
                                        -->      |

-  don't split line in line mode

-- <Return> on line with keyword --------------------------------------------
   -- before opening paren in stream and line mode
?  } whi|le (); + <Return>       -->   } while (|);
?  } whi|le (xxx); + <Return>    -->   } while (xxx|);
   -- after opening paren
?  } while (|); + <Return>       -->   } while ();
                                 -->   |

-- Options ------------------------------------------------------------------
-  omit { and } while expanding  <-- not much useful

   -- general options, selectable for every mode:
-  Change 1st expansion from <Space> to <Ctrl>+<Space>
-  Change 2nd expansion from <Enter> to <Ctrl>+<Enter>
   This would keep the rest of defined syntax expansion defs
-  Enable/disable add matching brace/bracket/parenthesis on typing opening one

-  Ignore blank lines when determining indent of last line
-  Ignore comments when determining indent of last line

-- Expand ; -----------------------------------------------------------------
-  add ; and a new, unindented line

*/

/*                    C keys                            */
/*                                                      */
/* The enter and space bar keys have been defined to do */
/* specific C editing features.                         */

CONST
compile if not defined(I_like_my_cases_under_my_switch)
   --I_like_my_cases_under_my_switch = 1
   I_like_my_cases_under_my_switch = 0  --  changed aschn
compile endif
compile if not defined(I_like_a_semicolon_supplied_after_default)
   I_like_a_semicolon_supplied_after_default = 0
compile endif
compile if not defined(ADD_BREAK_AFTER_DEFAULT)
   ADD_BREAK_AFTER_DEFAULT = 1
compile endif
compile if not defined(WANT_BRACE_BELOW_STATEMENT)
   --WANT_BRACE_BELOW_STATEMENT = 0
   WANT_BRACE_BELOW_STATEMENT = 1  -- changed aschn
compile endif
compile if not defined(WANT_BRACE_BELOW_STATEMENT_INDENTED)
   WANT_BRACE_BELOW_STATEMENT_INDENTED = 0
compile endif
compile if not defined(USE_ANSI_C_NOTATION)
   USE_ANSI_C_NOTATION = 1  -- 1 means use shorter ANSI C notation on MAIN.
compile endif
compile if not defined(TERMINATE_COMMENTS)
   TERMINATE_COMMENTS = 0
compile endif
compile if not defined(WANT_END_COMMENTED)
 compile if defined(WANT_END_BRACE_COMMENTED)
   WANT_END_COMMENTED = WANT_END_BRACE_COMMENTED
 compile else
   --WANT_END_COMMENTED = 1
   WANT_END_COMMENTED = 0  -- changed aschn
 compile endif
compile endif
compile if not defined(JAVA_SYNTAX_ASSIST)
   --JAVA_SYNTAX_ASSIST = 0
   JAVA_SYNTAX_ASSIST = 1   -- changed aschn
compile endif

;compile if not defined(GetCIndent())
;   C_SYNTAX_INDENT = SYNTAX_INDENT
;compile endif

; Now defined in mode\c\default.ini:
;compile if not defined(C_EXTENSIONS)  -- Keep in sync with TAGS.E
;   C_EXTENSIONS = 'C H SQC'
;compile endif

; Now used only to distinguish between C and C++:
compile if not defined(CPP_EXTENSIONS)  -- Keep in sync with TAGS.E
   CPP_EXTENSIONS = 'CPP HPP CXX HXX SQX JAV JAVA'
compile endif


; Want a space after '(', an opening parenthesis?
compile if not defined(WANT_SPACE_AFTER_PAREN)
   WANT_SPACE_AFTER_PAREN = 1                            -- new
compile endif
compile if not defined(C_HEADER_LENGTH)
   C_HEADER_LENGTH = 77
compile endif
compile if not defined(C_HEADER_STYLE)
   C_HEADER_STYLE = 1  -- (1 | 2), 1 = not indented
compile endif

;  Keyset selection is now done once at file load time, not every time
;  the file is selected.  And because the DEFLOAD procedures don't have to be
;  kept together in the macros (ET will concatenate all the DEFLOADs the
;  same way it does DEFINITs), we can put the DEFLOAD here where it belongs,
;  with the rest of the keyset function.  (what a concept!)
-- Moved defload to MODE.E

defkeys c_keys

def space
   universal expand_on
   if expand_on then
      if not c_first_expansion() then
         'Space'
      endif
   else
      'Space'
   endif

compile if ASSIST_TRIGGER = 'ENTER'
def enter=
 compile if ENHANCED_ENTER_KEYS & ENTER_ACTION <> ''
   universal enterkey
 compile endif
compile else
def c_enter=
 compile if ENHANCED_ENTER_KEYS & c_ENTER_ACTION <> ''
   universal c_enterkey
 compile endif
compile endif
   universal expand_on

   if expand_on then
      if not c_second_expansion() then
compile if ASSIST_TRIGGER = 'ENTER'
 compile if ENHANCED_ENTER_KEYS & ENTER_ACTION <> ''
         call enter_common(enterkey)
 compile else
         call my_enter()
 compile endif
compile else  -- ASSIST_TRIGGER
 compile if ENHANCED_ENTER_KEYS & c_ENTER_ACTION <> ''
         call enter_common(c_enterkey)
 compile else
         call my_c_enter()
 compile endif
compile endif -- ASSIST_TRIGGER
      endif
   else
compile if ASSIST_TRIGGER = 'ENTER'
 compile if ENHANCED_ENTER_KEYS & ENTER_ACTION <> ''
      call enter_common(enterkey)
 compile else
      call my_enter()
 compile endif
compile else  -- ASSIST_TRIGGER
 compile if ENHANCED_ENTER_KEYS & c_ENTER_ACTION <> ''
      call enter_common(c_enterkey)
 compile else
      call my_c_enter()
 compile endif
compile endif -- ASSIST_TRIGGER
   endif


def '{'
   keyin '{}'
   left

def '('
   keyin '()'
   left

def '['
   keyin '[]'
   left

def '}'
   -- check if line is blank, before typing }
   LineIsBlank = (verify( textline(.line), ' '\t) = 0)
   if LineIsBlank then
      l = 0
      PrevIndent = 0
      do l = 1 to 100 -- upper limit
         getline line0, .line - l             -- line0 = line before }
         p0 = max( 1, verify( line0, ' '\t))  -- p0     = pos of first non-blank in line 0
         if length(line0) > p0 - 1 then  -- if not a blank line
            PrevIndent = p0 - 1
            -- check if last non-empty line is a {
            if rightstr( strip( line0), 1) = '{' then
               NewIndent = PrevIndent
            else
               NewIndent = PrevIndent - GetCIndent()
            endif
            leave
         endif
      enddo
      .col = max( 1, NewIndent + 1)  -- unindent
   endif
   -- type } and highlight matching {
   'balance }'

/* Taken out, interferes with some people's c_enter. */
;def c_enter=   /* I like Ctrl-Enter to finish the comment field also. */
;   getline line
;   if pos('/*',line) then
;      if not pos('*/',line) then
;         end_line;keyin' */'
;      endif
;   endif
;   down;begin_line

def c_x=       /* Force expansion if we don't have it turned on automatic */
   if not c_first_expansion() then
      call c_second_expansion()
   endif

define
compile if WANT_END_COMMENTED = '//'
   END_CATCH  = ' // endcatch'
   END_DO     = ' // enddo'
   END_FOR    = ' // endfor'
   END_IF     = ' // endif'
   END_SWITCH = ' // endswitch'
   END_TRY    = ' // endtry'
   END_WHILE  = ' // endwhile'
compile elseif WANT_END_COMMENTED
   END_CATCH  = ' /* endcatch */'
   END_DO     = ' /* enddo */'
   END_FOR    = ' /* endfor */'
   END_IF     = ' /* endif */'
   END_SWITCH = ' /* endswitch */'
   END_TRY    = ' /* endtry */'
   END_WHILE  = ' /* endwhile */'
compile else
   END_CATCH  = ''
   END_DO     = ''
   END_FOR    = ''
   END_IF     = ''
   END_SWITCH = ''
   END_TRY    = ''
   END_WHILE  = ''
compile endif

; ---------------------------------------------------------------------------
defproc GetCIndent
   universal indent
compile if defined(C_SYNTAX_INDENT)
   ind = C_SYNTAX_INDENT  -- this const has priority, it is normally undefined
compile else
   ind = indent  -- will be changed at defselect for every mode, if defined
compile endif
   if ind = '' | ind = 0 then
compile if defined(SYNTAX_INDENT)
      ind = SYNTAX_INDENT
compile endif
   endif
   if ind = '' | ind = 0 then
      ind = 3
   endif
   return ind

; ---------------------------------------------------------------------------
; Want a space after opening parenthesis '(' of a function?
; Inserts a space or nothing
defproc GetPSpc
   ret = ''
compile if WANT_SPACE_AFTER_PAREN
   ret = ' '
compile endif
   return ret

; ---------------------------------------------------------------------------
defproc ExpandJava
   java = 0
compile if JAVA_SYNTAX_ASSIST
   java = (NepmdGetMode() = 'JAVA')
compile endif -- JAVA_SYNTAX_ASSIST
   return java

; ---------------------------------------------------------------------------
defproc ExpandCpp
   cpp = 0
compile if CPP_SYNTAX_ASSIST
   cpp = (NepmdGetMode() = 'C') & (wordpos( filetype(), CPP_EXTENSIONS))
compile endif -- CPP_SYNTAX_ASSIST
   return cpp


; ---------------------------------------------------------------------------
defproc c_first_expansion
   retc = 1
   if .line then
      getline line
      line = strip( line, 'T')
      w = line                                                   -- w   = current line, stripped trailing spaces
      wrd = upcase(w)                                            -- wrd = current line, stripped blanks, upcase
      wrd = strip(wrd)
      wrd = strip(wrd, 'b', \9)
      wrd = strip(wrd)
      ws  = substr( line, 1, max( verify( line, ' '\9) - 1, 0))  -- ws  = indent of current line
      ws1 = ws''substr( '', 1, GetCIndent())                     -- ws1 = indent of current line plus syntax indent
      p   = pos( wrd, upcase( line))                             -- p   = startpos of wrd in line

      -- Skip expansion when cursor is not at line end
      line_l = substr( line, 1, .col - 1) -- split line into two parts at cursor
      lw = strip( line_l, 'T')
      if w <> lw then
         retc = 0

      elseif wrd = 'FOR' then
compile if WANT_BRACE_BELOW_STATEMENT
         replaceline w' (; ; )'
 compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 1
         insertline ws1'}'END_FOR, .line + 2
 compile else
         insertline ws'{', .line + 1
         insertline ws'}'END_FOR, .line + 2
 compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
compile else
         replaceline w' (; ; ) {'
         insertline ws'}'END_FOR, .line + 1
compile endif -- WANT_BRACE_BELOW_STATEMENT
         if not insert_state() then
            insert_toggle
            call fixup_cursor()
         endif
         .col = .col + 2

      elseif wrd = 'IF' then
compile if WANT_BRACE_BELOW_STATEMENT
         replaceline w' ()'
 compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 1
         insertline ws1'}', .line + 2
 compile else
         insertline ws'{', .line + 1
         insertline ws'}', .line + 2
 compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws'else', .line + 3
 compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 4
         insertline ws1'}'END_IF, .line + 5
 compile else
         insertline ws'{', .line + 4
         insertline ws'}'END_IF, .line + 5
 compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
compile else
         replaceline w' () {'
         insertline ws'} else {', .line + 1
         insertline ws'}'END_IF, .line + 2
compile endif -- WANT_BRACE_BELOW_STATEMENT
         if not insert_state() then
            insert_toggle
            call fixup_cursor()
         endif
         .col = .col + 2

      elseif wrd = 'WHILE' then
compile if WANT_BRACE_BELOW_STATEMENT
         replaceline w' ()'
 compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 1
         insertline ws1'}'END_WHILE, .line + 2
 compile else
         insertline ws'{', .line + 1
         insertline ws'}'END_WHILE, .line + 2
 compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
compile else
         replaceline w' () {'
         insertline ws'}'END_WHILE, .line + 1
compile endif -- WANT_BRACE_BELOW_STATEMENT
         if not insert_state() then
            insert_toggle
            call fixup_cursor()
         endif
         .col = .col + 2

      elseif wrd = 'DO' then
compile if WANT_BRACE_BELOW_STATEMENT
 compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 1
         insertline ws1'} while ();'END_DO, .line + 2
 compile else
         insertline ws'{', .line + 1
         insertline ws'} while ();'END_DO, .line + 2
 compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
         down
compile else
         replaceline w' {'
         insertline ws'} while ();'END_DO, .line + 1
compile endif -- WANT_BRACE_BELOW_STATEMENT
         --call einsert_line()
         --replaceline ws1  -- better append real spaces, instead of just setting .col
         --.col = p + GetCindent()    -- indent for new line, don't indent it twice
         insertline ws1, .line + 1; down; endline

      elseif wrd = 'SWITCH' then
compile if WANT_BRACE_BELOW_STATEMENT
         replaceline w' ()'
 compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 1
         insertline ws1'}'END_SWITCH, .line + 2
 compile else
         insertline ws'{', .line + 1
         insertline ws'}'END_SWITCH, .line + 2
 compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
compile else
         replaceline w' () {'
         insertline ws'}'END_SWITCH, .line + 1
compile endif -- WANT_BRACE_BELOW_STATEMENT
         if not insert_state() then
            insert_toggle
            call fixup_cursor()
         endif
         .col = .col + 2    /* move cursor between parentheses of switch ()*/

      elseif wrd = 'MAIN' | (subword( wrd, 1, 1) = 'INT' & subword( wrd, 2, 1) = 'MAIN') then
         call enter_main_heading()

compile if CPP_SYNTAX_ASSIST
      elseif wrd = 'TRY' & ExpandCpp() then
 compile if WANT_BRACE_BELOW_STATEMENT
  compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 1
         insertline ws1'}'END_TRY, .line + 2
  compile else
         insertline ws'{', .line + 1
         insertline ws'}'END_TRY, .line + 2
  compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws'catch ()', .line + 3
  compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 4
         insertline ws1'}'END_CATCH, .line + 5
  compile else
         insertline ws'{', .line + 4
         insertline ws'}'END_CATCH, .line + 5
  compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
         down
 compile else
         replaceline w' {'
         insertline ws'}'END_TRY, .line + 1
         insertline ws'catch () {', .line + 2
         insertline ws'}'END_CATCH, .line + 3
 compile endif -- WANT_BRACE_BELOW_STATEMENT
         insertline ws1, .line + 1; down; endline

      elseif ExpandCpp() & wrd = 'CATCH' then
 compile if WANT_BRACE_BELOW_STATEMENT
         replaceline w' ('GetPSpc()')'
  compile if WANT_BRACE_BELOW_STATEMENT_INDENTED
         insertline ws1'{', .line + 1
         insertline ws1'}'END_CATCH, .line + 2
  compile else
         insertline ws'{', .line + 1
         insertline ws'}'END_CATCH, .line + 2
  compile endif -- WANT_BRACE_BELOW_STATEMENT_INDENTED
 compile else
         replaceline w' () {'
         insertline ws'}'END_CATCH, .line + 1
 compile endif -- WANT_BRACE_BELOW_STATEMENT
         if not insert_state() then
            insert_toggle
            call fixup_cursor()
         endif
         .col = .col + 3
compile endif -- CPP_SYNTAX_ASSIST

compile if JAVA_SYNTAX_ASSIST
      elseif wrd = 'PRINTLN(' & ExpandJava() then
         replaceline ws'System.out.println( );'
         if not insert_state() then
            insert_toggle
            call fixup_cursor()
         endif
         tab_word
compile endif -- JAVA_SYNTAX_ASSIST

      else
         retc = 0
      endif
   else
      retc = 0
   endif
   return retc

; ---------------------------------------------------------------------------
defproc c_second_expansion
   retc = 1
   if .line then
      getline line                                               -- line = current line

; From REXXKEYS.E:
      -- *word functions and parse don't recognize tab chars as word boundaries.
      -- tline = uppercase line, with converted tabs
      tline = translate( upcase(line) ' ', \t)

      -- Set firstword only to text left from the cursor
      tline_l = substr( tline, 1, .col - 1) -- split tline into two parts at cursor
; firstword is currently overwritten by the old code
      parse value tline_l with firstword rest
      -- firstword is uppercase, because line is already upcased.
      if firstword > ' ' then
         firstp = pos( firstword, tline_l)
      else
         firstp = 1
      endif

      ind = substr( line, 1, max( 1, verify( line, ' '\t)) - 1)        -- ind  = blanks before first word
      ind1 =  ind''copies( ' ', GetCIndent())                          -- ind1 = ind plus 1 level indented
-- Todo: Tabs2Spaces for line
-- doesn't handle Tabs near the end correctly:
      ind0 =  substr( ind, 1, max( length(ind) - GetCIndent(), 0))     -- ind0 = ind minus 1 level indented

;      parse value upcase(line) with '{' +0 a                     -- a    = part of line starting with '{', upcase
;      a = strip(a)
      pobrace = pos( '{', line)
      sline = strip( strip( strip( textline( .line)), 'b', \t))
      this_is_obrace = (sline = '{')
      if .line < .last then
         snextline = strip( strip( strip( textline( .line + 1)), 'b', \t))
         next_is_obrace = (snextline = '{')
      else
         snextline = ''
         next_is_obrace = 0
      endif
      parse value line with w rest                               -- w  = first word
      parse value rest with w2 .                                 -- w2 = second word
      wrd = upcase(w)                                            -- wrd = first word, stripped blanks, upcase
      wrd = strip(wrd)
      wrd = strip(wrd, 'b', \9)
      wrd = strip(wrd)
      ws  = substr( line, 1, max( verify( line, ' '\9) - 1, 0))  -- ws  = indent of current line
      ws1 = ws''substr( '', 1, GetCIndent())                     -- ws1 = indent of current line plus syntax indent
      ws2 = ws1''substr( '', 1, GetCIndent())                    -- ws2 = indent of current line plus 2x syntax indent
      -- problem if tab at the end instead of spaces:
      ws0 = substr( line, 1, max( verify( line, ' '\9) - 1 - GetCIndent(), 0))
                                                                 -- ws0  = indent of current line minus syntax indent
      p = pos( wrd, upcase(line))                                -- p   = startpos of wrd in line

      i = verify( wrd, '({:;', 'M', 1) - 1                       -- i   = position before (|{|:|;
      if i <= 0 then i = length(wrd) endif                       -- if i = 0 then i = position of last char in wrd
      firstword = substr( wrd, 1, i)                             -- firstword = first word in line left from cursor, upcase

      wrd2 = upcase(w2)                                          -- wrd2 = second word, stripped trailing spaces, upcase

      j = verify( wrd2, '({:;', 'M', 1) - 1                      -- j   = position before (|{|:|;
      if j <= 0 then j = length(wrd2) endif                      -- if j = 0 then j = position of last char in wrd2
      secondword = substr( wrd2, 1, j)                           -- secondword = second word in line left from cursor, upcase

      line_l = substr( line, 1, .col - 1)                        -- line_l = line left from cursor pos
      line_r = substr( line, .col)                               -- line_r = line right from cursor pos
      cobrace = 0                                                -- cobrace = number of opening braces in left part of line
      ccbrace = 0                                                -- ccbrace = number of closing braces in left part of line
      n       = 0                                                -- n = number of open brace blocks in left part of line,
      rest = line_l                                              --     starting at first opening brace
      do forever
         p1 = pos( '{', rest)
         p2 = pos( '}', rest)
         if p1 > 0 & (p1 < p2 | p2 = 0) then
            cobrace = cobrace + 1
            n = n + 1
            rest = substr( rest, p1 + 1)
         elseif p2 > p1 then
            ccbrace = ccbrace + 1
            if cobrace > 0 then
               n = n - 1
            endif
            rest = substr( rest, p2 + 1)
         else
            leave
         endif
      enddo

      if firstword = 'FOR' then
         /* do tabs to fields of C for statement */
         --cp = pos( ';', line, .col)
         cp = pos( ';', line, .col + 1)
         if cp and cp >= .col then
            --.col = cp + 2
            .col = cp
         else
            cp = pos( ';', line, .col)
            if cp and (cp >= .col) then
               .col = cp + 2
               bp = pos( ')', line, .col)
               if bp then
                  .col = bp
               endif
            else
               if not pobrace and next_is_obrace then down; endif
               insertline ws1, .line + 1; down; endline
           endif
         endif

      elseif firstword = 'CASE' or firstword = 'DEFAULT' then
         insertline ws1, .line + 1; down; endline
         -- get rid of line containing just a ;
         if firstword = 'DEFAULT' and .line < .last then
            getline line1, .line + 1
            line1 = strip( line1, 'b')
            line1 = strip( line1, 'b', \9)
            line1 = strip( line1, 'b')
            if line1 = ';' then
               deleteline .line + 1
            endif
         endif

      elseif firstword = 'BREAK' then
         insertline ws0'case :', .line + 1; down; endline; left
         insertline ws'break;', .line + 1

      elseif firstword = 'SWITCH' then
         if not pobrace and next_is_obrace then down; endif
compile if I_like_my_cases_under_my_switch
         insertline ws'case :', .line + 1; down; endline; left
         insertline ws1'break;', .line + 1
compile else
         insertline ws1'case :', .line + 1; down; endline; left
         insertline ws2'break;', .line + 1
compile endif

         /* look at the next line to see if this is the first time */
         /* the user typed enter on this switch statement */
         if .line <= (.last - 2) then
            getline line2, .line + 2
            line2 = strip( line2, 't')
            line2 = strip( line2, 't', \9)
            line2 = strip( line2, 't')
            if substr( line2, length(line2), 1) = '}' then
compile if I_like_my_cases_under_my_switch
               insertline ws'default:', .line + 2
 compile if ADD_BREAK_AFTER_DEFAULT
               insertline ws1'break;', .line + 3
 compile elseif I_like_a_semicolon_supplied_after_default then
               insertline ws';', .line + 3
 compile endif
compile else
               insertline ws1'default:', .line + 2
 compile if ADD_BREAK_AFTER_DEFAULT
               insertline ws2'break;', .line + 3
 compile elseif I_like_a_semicolon_supplied_after_default then
               insertline ws1';', .line + 3
 compile endif
compile endif
            endif
         endif

      elseif ExpandCpp() & firstword = 'CATCH' then
         cp = pos( '(  )', line, .col)
         if cp then
            .col = cp + 2
            if not insert_state() then insert_toggle
                call fixup_cursor()
            endif
         else
            if not pobrace and next_is_obrace then down; endif
            insertline ws1, .line + 1; down; endline
         endif

      elseif n > 0 then
         -- todo: don't split in line mode
         -- todo: support WANT_BRACE_BELOW_STATEMENT_INDENTED = 1 (not for functions)
         -- split line at cursor: replace current line with left part
         stline_l =  strip( strip( strip( line_l, 't'), 't', \t), 't')  -- strip trailing spaces and tabs
         replaceline stline_l, .line
         if rightstr( stline_l, 1) = '{' and not this_is_obrace and
            (WANT_BRACE_BELOW_STATEMENT or ws = 0) then  -- ws = indent of current line; braces for
                                                         -- functions should be put on a separate line
            -- put '{' on next line
            replaceline leftstr( stline_l, length( stline_l) - 1), .line
            insertline ws'{', .line + 1; down; endline
         endif
         sline_r =  strip( strip( strip( line_r), 'b', \t))  -- strip spaces and tabs
         if rightstr( sline_r, 1) = '}' then
            sline_r = leftstr( sline_r, length( sline_r) - 1)
            insertline ws'}', .line + 1;
         endif
         insertline ws1''sline_r, .line + 1; down; .col = length( ws1) + 1

      elseif firstword = 'MAIN' | (firstword = 'INT' & secondword = 'MAIN') then
         if not pos( '(', line) then
            call enter_main_heading()
         else
            if not pobrace and next_is_obrace then down; endif
            insertline ws1, .line + 1; down; endline
         endif

      elseif (wordpos( firstword, 'DO IF ELSE WHILE') |
              (ExpandCpp() & wordpos( firstword, 'TRY'))) then
         if not pobrace and next_is_obrace then down; endif
         insertline ws1, .line + 1; down; endline

      elseif firstword = '}' & secondword = 'WHILE' then
         insertline ws, .line + 1; down; endline

      elseif next_is_obrace then  -- add a blank, indented line after line with single opening brace
         down
         insertline ws1, .line + 1; down; endline


      elseif firstword = '/*' then
         if words( tline) = 1 then
            insertline ind' * ', .line + 1
            insertline ind' */', .line + 2
            '+1'
            endline
            retc = 1
         endif

      elseif firstword = '/**' then
         if words( tline) = 1 then
            headerlength = C_HEADER_LENGTH
            headerstyle  = C_HEADER_STYLE
            -- Style 1:
            -- /***************
            -- * |
            -- ***************/
            -- Style 2:
            -- /***************
            --  * |
            --  **************/
            replaceline '/'copies( '*', headerlength - 1)
            if headerstyle = 1 then
               insertline '* ', .line + 1
               insertline copies( '*', headerlength - 1)'/', .line + 2
            else
               insertline ' * ', .line + 1
               insertline ' 'copies( '*', headerlength - 2)'/', .line + 2
            endif
            '+1'
            endline
            retc = 1
         endif

      elseif firstword = '*' then
         -- Search for opening comment /*
         Found = 0
         startl = .line - 1
         do l = startl to 1 by -1
            if l < startl - 100 then  -- search only 100 next lines
               leave
            endif
            getline linel, l
            next = word( linel, 1)
            -- Search for first word
            if next = '*' then
               iterate
            elseif substr( next, 1, 2) = '/*' then
               Found = 1
               leave
            else
               leave
            endif
         enddo
         if Found = 1 then
            if firstp = 1 then
               insertline '* ', .line + 1
            else
               insertline ind'* ', .line + 1
            endif
            '+1'
            endline
            retc = 1
         endif

compile if TERMINATE_COMMENTS
      elseif pos( '/*', line) then
         if not pos( '*/', line) then
            end_line; keyin ' */'
         endif
         call einsert_line()  -- respect user's style
compile endif

      else
         retc = 0
      endif
   else
      retc = 0
   endif
   return retc

; ---------------------------------------------------------------------------
defproc enter_main_heading
   getline w
   w = strip( w, 't')
compile if not USE_ANSI_C_NOTATION     -- Use standard notation
   ind = substr( '', 1, GetCIndent())  /* indent spaces */
   replaceline w'('GetPSpc()'argc, argv, envp)'
   insertline ind'int argc;', .line + 1         /* double indent */
   insertline ind'char *argv[];', .line + 2
   insertline ind'char *envp[];', .line + 3
   insertline '{', .line + 4
   insertline '', .line + 5
   mainline = .line
   if .cursory < 7 then
      .cursory = 7
   endif
   mainline + 5
   .col = GetCIndent() + 1
   insertline '}', .line + 1
compile else                           -- Use shorter ANSII notation
   replaceline w'('GetPSpc()'int argc, char *argv[], char *envp[])'
   insertline '{', .line + 1
   insertline '', .line + 2
   .col = GetCIndent() + 1
   insertline '}', .line + 3
   mainline = .line
   if .cursory < 4 then
      .cursory = 4
   endif
   mainline + 2
compile endif

