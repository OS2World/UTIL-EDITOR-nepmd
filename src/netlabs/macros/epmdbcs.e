definit
   universal country
   universal countryinfo
   universal codepage
   universal dbcsvec
   universal ondbcs

compile if EPM32
   inp=copies(\0, 8)
   countryinfo=copies(\0, 44)
   ret=\0\0\0\0
   call dynalink32('NLS', '#5',        -- DOS32QueryCountryInfo
                   atol(length(countryinfo))  ||
                   address(inp)       ||
                   address(countryinfo)       ||
                   address(ret),
                   2)
   country=ltoa(leftstr(countryinfo,4),10)

   codepage = '????'; datalen = '????'
   call dynalink32('DOSCALLS',            -- dynamic link library name
                   '#291',                -- ordinal value for DOS32QueryCP
                   atol(4)            ||  -- length of code page list
                   address(codepage)  ||
                   address(datalen),2)
   codepage = ltoa(codepage,10)

   inp=copies(\0,8)
   dbcsvec=copies(\0, 12)
   call dynalink32('NLS', '#6',
                   atol(length(dbcsvec)) ||
                   address(inp)          ||
                   address(dbcsvec),
                   2)
   ondbcs = leftstr(dbcsvec, 2) <> atoi(0)
compile else
   inp=atol(0)
   countryinfo=copies(\0, 38)
   ret=\0\0
   call dynalink('NLS', 'DOSGETCTRYINFO',
                 atoi(length(countryinfo)) ||
                 address(inp)      ||
                 address(countryinfo)      ||
                 address(ret),
                 1)
   country=itoa(substr(countryinfo,1,2),10)
   codepage=itoa(substr(countryinfo,3,2),10)

   inp=atol(0)
   dbcsvec=copies(\0, 10)
   call dynalink('NLS', 'DOSGETDBCSEV',
                 atoi(length(dbcsvec)) ||
                 address(inp)          ||
                 address(dbcsvec),
                 1)
   ondbcs = leftstr(dbcsvec, 2) <> atoi(0)
compile endif  -- EPM32

defproc isdbcs(c)
   universal dbcsvec, ondbcs
   if not ondbcs then
      return 0
   endif
   c=leftstr(c,1)
   for i = 1 to length(dbcsvec) by 2
      if substr(dbcsvec,i,2)=atoi(0) then
         leave
      endif
      if substr(dbcsvec, i, 1) <= c and c <= substr(dbcsvec, i + 1, 1) then
         return 1
      endif
   endfor
   return 0

defproc whatisit(s, p)
   l = length(s)
   i = 1
   while i <= l do
      if i > p then
         leave
      endif
      if isdbcs(substr(s, i, 1)) then
         if i = p then
            return 1 -- DBCS 1st
         elseif i + 1 = p then
            return 2 -- DBCS 2nd
         else
            i = i + 2
         endif
      else
         i = i + 1
      endif
   endwhile
   return 0 -- SBCS
