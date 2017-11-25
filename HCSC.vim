""===[[ START HDOC ]]==========================================================#
""===[[ HEADER ]]==============================================================#

"   niche         : vim-ide (integrated development environment)
"   application   : rsh_csc.vim
"   purpose       : provide cscope x-ref and search access inside vim
"   base_system   : gnu/linux
"   lang_name     : vim script
"   created       : svq - long, long ago
"   author        : the_heatherlys
"   dependencies  : none (vim only)
"   permissions   : GPL-2 with no warranty of any kind
"
"
""===[[ PURPOSE ]]=============================================================#

"   rsh_csc is a fast, clear, standard, and integrated x-ref tool based on
"   grep to allow a programmer to rapidly understand and move through
"   a group of source files, confidently make changes, and support automated
"   refactoring
"
"   cscope is an enduring, powerful, and insightful tool, but its traditional
"   uss is as a stand-alone tool that calls, but does not integrate, with an
"   editor.  what this plugin will do is tie the capability back into vim and
"   then make it available to automated refacortoring in order to drive down
"   the cost (in time, testing, and stress) and danger of making changes
"
"
""===[[ EXTERNAL INTERFACE ]]==================================================#

"   principle   -- keep all external interfaces small, flexible, and clean
"
"   key mapping -- only ",g" is externally visible to call up the window
"
"   functions   -- s:HCSC_init() is visible to the system at startup
"                  HCSC_show() is visible through ",g"
"
""===[[ WORK ]]================================================================#

"  TODO make key mapping work like rsh_tag using ",g"
"  TODO have search options, incl, last '/' search, regex, and under cursor
"  TODO have a "replace" option that can immitate the last ":s" replacement
"  TODO add an undo feature
"  TODO create a pre-verify option for relacement (buffer vs. saved file)
"
"
""===[[ END HDOC ]]============================================================#



""===[[ GLOBALS ]]=============================================================#

"---(global)-------------------------------------#
let g:hcsc_locked       = "n"
let g:hcsc_title        = "HCSC_buffer"
let g:hcsc_times        = 10

"---(script/general)-----------------------------#
let s:hcsc_size         = 10
let s:hcsc_type         = " "
let s:hcsc_matches      = 0
let s:hcsc_matchstr     = ""

"---(script/search)------------------------------#
let s:hcsc_soption      = ""
let s:hcsc_sword1       = ""
let s:hcsc_sword2       = ""
let s:hcsc_sregex       = ""
let s:hcsc_syank        = ""
let s:hcsc_scurr        = ""
let s:hcsc_sbufname     = ""
let s:hcsc_ssubject     = ""
let s:hcsc_sscope       = ""
let s:hcsc_sshort       = ""
let s:hcsc_smessage     = ""

"---(script/tag)---------------------------------#
let s:hcsc_head         = 0
let s:hcsc_curr         = 0
let s:hcsc_tagn         = ""
let s:hcsc_line         = 0
let s:hcsc_file         = ""
let s:hcsc_orig         = ""




""=========================-------------------------==========================##
""===----             standard initialization fuctions (6)             ----===##
""=========================-------------------------==========================##
""  ...._init        :: prepare script/window at vim startup
""  ...._syntax      :: setup syntax rules
""  ...._keys        :: setup key mappings
""  ...._unkeys      :: remove key mappings
""  ...._auto        :: setup auto commands
""  ...._unauto      :: remove auto commands
func! s:o___STD_INIT________o()
endf



"===[ ROOT   ]===> main setup routine
func!  s:HCSC_init()
   sil!  exec 'botright split ' . g:hcsc_title
   call  HALL_start()
   call  s:HCSC_syntax()
   call  s:HCSC_keys()
   call  s:HCSC_sparms("d")
   hide
   retu
endf



"===[ LEAF   ]===> establish syntax highlighting
func!  s:HCSC_syntax()
   setlo  modifiable
   syn    clear
   syn    match hcsc_mtag     '^[A-Z-][A-Z-]  '               containedin=hcsc_entry
   syn    match hcsc_ftag     ' \[[a-z-][a-z-]\] '            containedin=hcsc_entry
   syn    match hcsc_num      ' : [0-9 ][0-9 ][0-9 ][0-9] : ' containedin=hcsc_entry
   syn    match hcsc_miss     ' | [0-9 ][0-9 ][0-9 ][0-9] | ' containedin=hcsc_entry
   syn    match hcsc_entry    '^[A-Z-][A-Z-]  .*$'
   syn    match hcsc_current  '^[A-Z-][A-Z-]+ .*$'
            \ containedin=rsh_fix_eone, rsh_fix_wone
   high   hcsc_entry    cterm=bold   ctermbg=none  ctermfg=3
   high   hcsc_current  cterm=none   ctermbg=3     ctermfg=8
   high   hcsc_mtag     cterm=bold   ctermbg=none  ctermfg=4
   high   hcsc_ftag     cterm=bold   ctermbg=none  ctermfg=4
   high   hcsc_num      cterm=bold   ctermbg=none  ctermfg=5
   high   hcsc_miss     cterm=bold   ctermbg=1     ctermfg=5
   syn    match hcsc_count    '| [0-9][0-9][0-9] |'           containedin=hcsc_sum,hcsc_sumbad
   syn    match hcsc_search   '^w=.*$'
   syn    match hcsc_sum      '^HCSC .*$'
   syn    match hcsc_sumbad   '^hCSC .*$'
   syn    match hcsc_end      '^end of matches .*$'
   syn    match hcsc_empty    '^NO MATCHES FOUND .*$'
   high   hcsc_search   cterm=none   ctermbg=2     ctermfg=none
   high   hcsc_sum      cterm=none   ctermbg=2     ctermfg=none
   high   hcsc_sumbad   cterm=none   ctermbg=1     ctermfg=none
   high   hcsc_count    cterm=none   ctermbg=3     ctermfg=none
   high   hcsc_end      cterm=none   ctermbg=2     ctermfg=none
   high   hcsc_empty    cterm=none   ctermbg=1     ctermfg=none
   setlo  nomodifiable
   retu
endf



"===[ LEAF   ]===> establish the buffer specific key mapping
func!  s:HCSC_keys()
   setlo  modifiable
   nmap            ,g       :call HCSC_show(expand("<cword>"), expand("<cWORD>"))<cr>
   "---(search types)--------------------------------#
   nmap   <buffer>  c       :call HCSC_search("c")<cr>
   nmap   <buffer>  w       :call HCSC_search("w")<cr>
   nmap   <buffer>  W       :call HCSC_search("W")<cr>
   nmap   <buffer>  s       :call HCSC_search("s")<cr>
   nmap   <buffer>  y       :call HCSC_search("y")<cr>
   "---(search scopes)-------------------------------#
   nmap   <buffer>  a       :call HCSC_search("a")<cr>
   nmap   <buffer>  d       :call HCSC_search("d")<cr>
   nmap   <buffer>  v       :call HCSC_search("v")<cr>
   nmap   <buffer>  b       :call HCSC_search("b")<cr>
   nmap   <buffer>  f       :call HCSC_search("f")<cr>
   "---(presentation/size)---------------------------#
   nmap   <buffer>  -       :call HCSC_resize("-")<cr>
   nmap   <buffer>  +       :call HCSC_resize("+")<cr>
   nmap   <buffer>  h       :call HCSC_hide()<cr>
   "---(replacement)---------------------------------#
   nmap   <buffer>  t       :call HCSC_test()<cr>
   nmap   <buffer>  r       :call HCSC_replace()<cr>
   "---(relative searches)---------------------------#
   nmap   <buffer>  n       :call HCSC_next("+")<cr>
   nmap   <buffer>  p       :call HCSC_next("-")<cr>
   "---(complete)------------------------------------#
   setlo  nomodifiable
   retu
endf


func!  s:HCSC_unkeys()
   setlo modifiable
   "---(search types)--------------------------------#
   nunmap <buffer>  c
   nunmap <buffer>  w
   nunmap <buffer>  W
   nunmap <buffer>  s
   nunmap <buffer>  y
   "---(search scopes)-------------------------------#
   nunmap <buffer>  a
   nunmap <buffer>  d
   nunmap <buffer>  v
   nunmap <buffer>  b
   nunmap <buffer>  f
   "---(presentation/size)---------------------------#
   nunmap <buffer>  -
   nunmap <buffer>  +
   nunmap <buffer>  h
   "---(replacement)---------------------------------#
   nunmap <buffer>  t
   nunmap <buffer>  r
   setlo nomodifiable
   retu
endf




""=========================-------------------------==========================##
""===----             standard window action fuctions (4)              ----===##
""=========================-------------------------==========================##
""  ...._on          :: display the window without entering it
""  ...._show        :: enter the window
""  ...._hide        :: take the window off the display
""  ...._resize      :: change the width/height of the window
func! s:o___STD_ACTIONS_____o()
endf



"-- [------] update the search window -----------------------------------------#
func! HCSC_show (cword1, cword2)
   "---(remember where we were)------------------#
   if    (HBUF_save("HCSC_show()         :: ") < 1)
      retu
   endi
   let   s:hcsc_sbufname = bufname('%')
   "---(lock it down)----------------------------#
   call  HALL_lock()
   "---(check for the buffer)--------------------#
   let   buf_num = HBUF_by_name(g:hcsc_title) 
   if    (buf_num <= 0)
      call  s:HCSC_init()
      sil!  exec 'botright split ' . g:hcsc_title
      sil!  exec "resize ".s:hcsc_size
   endi
   "---(grab the current conditions)-------------#
   let   s:hcsc_sword1  = a:cword1
   let   s:hcsc_sword2  = a:cword2
   let   s:hcsc_sregex  = @/
   let   s:hcsc_sregex  = substitute(s:hcsc_sregex, "\\", "", "g")
   let   s:hcsc_sregex  = substitute(s:hcsc_sregex, "\<", "", "g")
   let   s:hcsc_sregex  = substitute(s:hcsc_sregex, "\>", "", "g")
   let   s:hcsc_syank   = strpart(substitute(@0, "[\n\'\"]", "", "g"), 0, 20)
   "---(update the top line)---------------------#
   setl  modifiable
   call  s:HCSC_topline()
   setl  nomodifiable
   "---(open it up)------------------------------#
   call  HALL_unlock()
   "---(complete)--------------------------------#
   retu
endf



function! HCSC_resize(height)
   " update size and stay in the window
   " allow a range of 10 - 40 lines
   let s:hcsc_size  = winheight(0)
   if (a:height == "+")
      let s:hcsc_size += 10
   else
      let s:hcsc_size -= 10
   endif
   if (s:hcsc_size > 60)
      let s:hcsc_size = 60
   endif
   if (s:hcsc_size < 10)
      let s:hcsc_size = 10
   endif
   silent! exec "resize ".s:hcsc_size
   return
endfunction



function! HCSC_hide()
   "---(check for the buffer)--------------------#
   let l:buf_num = bufnr(g:hcsc_title)
   if (l:buf_num < 1)
      return
   endif
   "---(check for the window)--------------------#
   let l:win_num = bufwinnr(l:buf_num)
   if (l:win_num < 1)
      return
   endif
   "---(open the buffer window)------------------#
   silent! exec l:win_num.' wincmd w'
   silent! hide
   echon "HCSC_hide()        :: put away the cscope/grep window..."
   "---(complete)--------------------------------#
   normal ,a
   return
endfunction



func! s:o___SPECIFIC________o()
endf


func! s:HCSC_sparms(type)
   setlo noignorecase
   setlo nosmartcase
   if     a:type == "a"           " all files scope
      let  s:hcsc_sscope   = '*.{c,h,cpp,hpp,unit,vim,sh}'
      let  s:hcsc_sshort   = "dirtree"
      let  s:hcsc_smessage = "in dirtree (".s:hcsc_sscope.")"
   elseif a:type == "d"           " directory scope
      let  s:hcsc_sscope   = '*.{c,h,cpp,hpp,unit,vim,sh}'
      let  s:hcsc_sshort   = "directory"
      let  s:hcsc_smessage = "in current dir (".s:hcsc_sscope.")"
   elseif a:type == "v"           " vim buffers scope   FIXME
      let  s:hcsc_sscope   = g:hbuf_raw
      let  s:hcsc_sshort   = "vim"
      let  s:hcsc_smessage = "in all vim buf (".g:hbuf_raw.")"
   elseif a:type == "b"           " buffer scope
      let  s:hcsc_sscope   = s:hcsc_sbufname
      let  s:hcsc_sshort   = "buffer"
      let  s:hcsc_smessage = "in current buf (".s:hcsc_sbufname.")"
   elseif a:type == "f"           " function scope      FIXME
      let  s:hcsc_sscope   = s:hcsc_sbufname
      let  s:hcsc_sshort   = "function"
      let  s:hcsc_smessage = "in current func (".s:hcsc_sbufname.")"
   elseif a:type == "w"
      let  s:hcsc_ssubject = s:hcsc_sword1
      let  s:hcsc_soption = a:type
   elseif a:type == "W"
      let  s:hcsc_ssubject = s:hcsc_sword2
      let  s:hcsc_soption = a:type
   elseif a:type == "c"
      let  s:hcsc_ssubject = s:hcsc_scurr
      let  s:hcsc_soption = a:type
   elseif a:type == "s"
      let  s:hcsc_ssubject = s:hcsc_sregex
      let  s:hcsc_soption = a:type
   elseif a:type == "y"
      let  s:hcsc_ssubject = s:hcsc_syank
      let  s:hcsc_soption = a:type
   else
      return -2
   endif
   if    s:hcsc_ssubject == ""
      return -1
   endi
   let  s:hcsc_scurr  = s:hcsc_ssubject
   retu 0
endf



" PURPOSE : conduct a search for a given symbol or string
" parms   : search type
" exit    : single point (plus defense) with simple numeric error code
func!  HCSC_search(type)
   if    bufwinnr(g:HTAG_title) < 1
      echon "HCSC_search()      :: tag window must be open (returning)..."
      retu
   endif
   "---(local variables)-------------------------#
   let  l:hmajor    = 13                         " major letter of hint (awk)
   let  l:hminor    = 0                          " minor letter of hint (awk)
   let  l:replace   = "[zz] testing"             " default function ref
   let  l:full_line = ""                         " current buffer line contents
   let  l:line_eof  = 0                          " end of file line number
   let  l:entry     = 1                          " current iteration
   let  g:hcsc_times  += 1
   "---(pick search subject)---------------------#
   if (s:HCSC_sparms(a:type) < 0)
      retu
   endif
   call HALL_lock()
   "---(clean off old data)----------------------#
   silent! call s:HCSC_unkeys()
   normal "GG"
   let  l:line_eof     = line('.')
   setl   modifiable
   if (l:line_eof > 2)
      silent! exec ":3,$delete"
   endif
   normal o
   "---(find with grep)--------------------------#
   exec ":silent $!grep --line-number --with-filename --no-messages --word-regexp \"".s:hcsc_ssubject."\" ".s:hcsc_sscope
   "---(clean with awk)--------------------------#
   silent! exec ":silent! 3,$!HCSC.awk 'g_hmajor=".l:hmajor."' 'g_hminor=".l:hminor."' 'g_symbol=".s:hcsc_ssubject."' 'g_scope=".s:hcsc_smessage."' 'g_option=".s:hcsc_soption."'"
   "---(get the last line)-----------------------#
   normal "GG"
   let  l:line_eof = line('.')
   if (l:line_eof < 3)
      "---(get a no matches line in)-------------#
      normal o
      normal 0
      exec "normal iNO MATCHES FOUND                                                                                                                "
      let  s:hcsc_matches  = 0
   else
      "---(get key information back)-------------#
      normal _
      normal jj
      normal 0
      normal ww
      let  l:word_beg = col('.') - 1
      normal e
      let  l:word_end = col('.')
      let  l:full_line = getline('.')
      let  s:hcsc_matches  = strpart(l:full_line, l:word_beg, l:word_end - l:word_beg) + 0
      normal dd
   endif
   "---(set match syntax)------------------------#
   execute 'silent! syntax clear hcsc_match'
   execute 'highlight hcsc_match cterm=bold ctermbg=4 ctermfg=6'
   execute 'syntax match hcsc_match "\<' .s:hcsc_ssubject. '\>" containedin=ALL'
   setl   nomodifiable
   "---(get the function names)------------------#
   let   x_rc     = s:HCSC__list_head()
   while x_rc == 0
      let   replace  = HTAG_findloc(s:hcsc_file, s:hcsc_line)
      call  HBUF_by_name(g:hcsc_title)
      if    (replace != -1)
         let   x_rc     = s:HCSC__list_update(replace)
      endif
      let   x_rc     = s:HCSC__list_next()
   endwhile
   "---(complete)--------------------------------#
   call  s:HCSC_topline()
   norm  _
   call  s:HCSC_keys()
   call  HBUF_restore()
   call  HALL_unlock()
   retu
endf


func!  s:HCSC_topline()
   setl   modifiable
   let l:linenum     = line('.')
   let l:prev_text   = "<".s:hcsc_scurr.">"
   let l:search_text = "w=<".s:hcsc_sword1.">  "."W=<".s:hcsc_sword2.">  "."s=<".s:hcsc_sregex.">"
   ""    "y=<".s:hcsc_syank. ">  ".
   normal _
   silent! exec ":1,2delete"
   normal 0
   exec "normal O".printf("HCSC | c(%1.1s)=%-35.35s | %03d | scope=%-9.9s | a:all, d:dir, v:vim, b:buf, f:fun", s:hcsc_soption, l:prev_text, s:hcsc_matches, s:hcsc_sshort)
            \ ."                                                                  "
   exec "normal o"
   exec "normal i".printf("%-71.71s | r:rep, t:tst, h:hid, +:big, -:sma", l:search_text)
            \ ."                                                                  "
   normal 0
   normal _
   setl   nomodifiable
   "silent! exec "normal " . (l:linenum - 1) . "j"
   "silent! exec "normal z."
   retu
endf



"==[ twig   ]=== go to a specific tag in source code ==============[ ------ ]==#
func! HCSC_hints (tag)
   "---(switch to tag window)-----------------#
   let   buf_cur = bufnr('%')
   let   win_num = HBUF_by_name(g:hcsc_title)
   if    win_num < 1
      echon "  -- CSC not open, can not process..."
   endi
   sil   exec win_num.' wincmd w'
   sil!  call s:HCSC_unkeys()        " get the key mappings off
   "---(clear current tag)--------------------#
   norm  _
   call  search("^[A-Z][A-Z]+ ")
   if    line(".") > 2
      norm  0
      norm  2l
      setl  modifiable
      norm  r 
      setl  nomodifiable
   endi
   "---(find the tag)-------------------------#
   norm  _
   call  search("^" . a:tag . "  ")
   if    line(".") < 2
      echon "  -- tag not found, can not process..."
      sil!  call s:HCSC_keys()
      retu
   endi
   "---(mark the tag)-------------------------#
   norm  0
   norm  2l
   setl  modifiable
   norm  r+
   setl  nomodifiable
   norm  z.
   "---(parse it)-----------------------------#
   norm  0
   call  s:HCSC__list_entry()
   "---(get the keys back on)-----------------#
   sil!  call s:HCSC_keys()
   "---(get back to the original window)------#
   norm  ,a
   let   buf_num = bufnr(s:hcsc_file)
   if    buf_num == -1
      echon "HCSC_hints()       :: buffer not open in wim..."
      retu  -1
   else
      sil   exec('b! ' . buf_num)
   endi
   "---(get to the right line)----------------# make sure to show comments above
   norm  _
   sil!  exec "normal " . (s:hcsc_line - 1) . "j"
   sil!  exec "normal z."
   "---(complete)-----------------------------#
   retu
endf




func! HCSC_next (dir)
   ""---(locals)-----------+-----------+-##
   let   l:prefix    = "HCSC_next"
   let   l:rce       = -10
   let   l:tag       = ""
   ""---(initialize)---------------------##
   set   lazyredraw
   "---(switch to tag window)-----------------#
   let   buf_cur = bufnr('%')
   let   win_num = HBUF_by_name(g:hcsc_title)
   let   l:rce -= 1
   if    win_num < 1
      echon "  -- CSC not open, can not process..."
   endi
   sil   exec win_num.' wincmd w'
   sil!  call s:HCSC_unkeys()        " get the key mappings off
   "---(find the current tag)-----------------#
   norm  _
   call  search("^[A-Z][A-Z]+ ")
   if    line(".") <= 2
      norm  _
      norm  j
   else
      let   l:full_line = getline('.')
      let   l:tag       = strpart (l:full_line, 0, 2)
   endi
   "---(go to next line)-------------------------#
   if (a:dir == "+")
      norm  j
   else
      norm  k
   endi
   "---(check for past beginning)----------------#
   let   l:rce -= 1
   if    line(".") <= 2
      sil!  call s:HCSC_keys()
      norm  ,a
      set   nolazyredraw
      call  HALL_message (l:prefix, "previous can not go any further upward", l:rce)
      retu  l:rce
   endi
   "---(check for null)--------------------------#
   let   l:full_line = getline('.')
   let   l:rce -= 1
   if    (strpart(l:full_line, 0, 14) == "end of matches")
      sil!  call s:HCSC_keys()
      norm  ,a
      set   nolazyredraw
      call  HALL_message (l:prefix, "next can not go any further downward", l:rce)
      retu  l:rce
   endif
   "---(get the keys back on)-----------------#
   let   l:tag       = strpart (l:full_line, 0, 2)
   norm  ,a
   call  HCSC_hints (l:tag)
   set   nolazyredraw
   call  HALL_message (l:prefix, printf ("complete with %s.", l:tag), 0)
   retu  0
endf


" PURPOSE : verify search entries matches current source buffers
" parms   : none
" exit    : single point with simple numeric error code
func! HCSC_test()
   sil!  call s:HCSC_unkeys()
   call  HALL_lock()
   let   my_buf   = bufnr('%')     " get the tag buffer number
   "---(local variables)-------------------------#
   let   i        = 0                           " line being processed
   let   x_rc     = 0                           " function return code
   let   misses   = 0                           " lines not matching source
   "---(check each entry)------------------------#
   let   x_rc     = s:HCSC__list_head()
   while x_rc == 0
      let   i += 1
      echon printf("HCSC_test()        :: [[%03d of %03d]] tag %2s in file %s on line %04d",
               \ i, s:hcsc_matches, s:hcsc_tagn, s:hcsc_file, s:hcsc_line)
      redraw
      let   x_rc = s:HCSC__list_goto()
      sil   exec('b! ' . my_buf)
      if    x_rc < 0
         call  s:HCSC__list_missed()
         let   misses += 1
         let   x_rc = 0
      else
         call  s:HCSC__list_passed()
      endi
      sil   exec('b! ' . my_buf)
      let   x_rc     = s:HCSC__list_next()
   endw
   "---(update query header)---------------------#
   norm  _
   norm  0
   setl  modifiable
   if    misses < 1
      echon "HCSC_test()        :: confirmed all"
      exec  "normal rH"
   else
      echon "HCSC_verify()      :: MISSED (".misses."), check list for red line numbers"
      exec  "normal rh"
   endi
   setl  nomodifiable
   "---(restore environment)---------------------#
   norm  _
   sil!  call  s:HCSC_keys()
   call  HBUF_restore()
   call  HALL_unlock()
   "---(complete)--------------------------------#
   retu  -misses
endf



" PURPOSE : replace all entries in the search table with a new symbol/string
" parms   : none
" exit    : single point with simple numeric error code
func! HCSC_replace()
   sil!  call s:HCSC_unkeys()
   call  HALL_lock()
   let   my_buf   = bufnr('%')     " get the tag buffer number
   "---(local variables)-------------------------#
   let   i        = 0                           " line being processed
   let   x_rc     = 0                           " function return code
   let   misses   = 0                           " lines not matching source
   "---(get the replacement text)----------------#
   redrawstatus
   let tobe = input("change <<".s:hcsc_scurr.">> to : ", s:hcsc_scurr)
   if (tobe == "")
      echo "RSH_CSC_replace()        :: tobe null, canceled by user..."
      call HBUF_restore()
      call HALL_unlock()
      return -3
   endif
   "---(verify the change)-----------------------#
   let    confirm = input("change <<".s:hcsc_scurr.">> to <<".tobe.">> (y/n/c) : ", "n")
   if (confirm != "y" && confirm != "c")
      echo "RSH_CSC_replace()        :: canceled by user..."
      call HBUF_restore()
      call HALL_unlock()
      return -3
   endif
   "---(check each entry)------------------------#
   let   x_rc     = s:HCSC__list_head()
   while x_rc == 0
      let   i += 1
      echon printf("HCSC_test()        :: [[%03d of %03d]] tag %2s in file %s on line %04d",
               \ i, s:hcsc_matches, s:hcsc_tagn, s:hcsc_file, s:hcsc_line)
      redraw
      let   x_rc = s:HCSC__list_goto()
      if    x_rc < 0
         sil   exec('b! ' . my_buf)
         call  s:HCSC__list_missed()
         let   misses += 1
         let   x_rc = 0
      else
         setl  noignorecase
         setl  nosmartcase
         let   curr_line = getline('.')
         "echo "HCSC_search()    :: current line ".curr_line."..."
         let   adj_line  = "  ".curr_line."  "  " to ease bol and eol match
         let   pattern   = "\\(\\W\\)".s:hcsc_scurr."\\(\\W\\)"
         "echo "HCSC_search()    :: pattern is ".pattern."..."
         let   new_line = substitute(adj_line, pattern, "\\1".tobe."\\2", "g")
         let   new_line  = strpart(new_line, 2, strlen(new_line) - 4)
         "echo "HCSC_search()    :: changed to ".new_line."..."
         if (new_line == s:hcsc_orig)
            echon "HCSC_search()      :: change on line ".entry." didn't take..."
            sil   exec('b! ' . my_buf)
            call  s:HCSC__list_missed()
            let   misses += 1
         else
            norm  0
            norm  D
            exec  "normal R".l:new_line
            sil   exec('b! ' . my_buf)
            call  s:HCSC__list_passed()
         endif
         setl  ignorecase
         setl  smartcase
      endi
      sil   exec('b! ' . my_buf)
      let   x_rc     = s:HCSC__list_next()
   endw
   "---(update query header)---------------------#
   norm  _
   norm  0
   setl  modifiable
   if    misses < 1
      echon "HCSC_test()        :: confirmed all"
      exec  "normal rH"
   else
      echon "HCSC_verify()      :: MISSED (".misses."), check list for red line numbers"
      exec  "normal rh"
   endi
   setl  nomodifiable
   "---(restore environment)---------------------#
   norm  _
   sil!  call  s:HCSC_keys()
   call  HBUF_restore()
   call  HALL_unlock()
   "---(complete)--------------------------------#
   retu  -misses
endf





""=========================-------------------------==========================##
""===----                   standard list handling                     ----===##
""=========================-------------------------==========================##
""  ...._head        :: go to the first entry
""  ...._next        :: go to the next entry
""  ...._entry       :: parse the current entry
""  ...._goto        :: show the source at the current entry
""  ...._update      :: add tags and buffer numbers to current entry
func! s:o___STD_LIST________o()
endf

let  s:hcsc_lhead       = 2
let  s:hcsc_lcurr       = 0

function! s:HCSC__list_head()
   "echo "HCSC__list_head()"
   let  s:hcsc_lhead  = 2
   let  s:hcsc_lcurr  = 0
   let  l:x_rc = s:HCSC__list_next()
   return l:x_rc
endfunction

function! s:HCSC__list_next()
   "echo "HCSC__list_next()"
   let  s:hcsc_lcurr += 1
   normal _
   exec "normal ".s:hcsc_lhead."G"
   exec "normal ".s:hcsc_lcurr."j"
   let  l:x_rc = s:HCSC__list_entry()
   return l:x_rc
endfunction

function! s:HCSC__list_entry()
   "echo "HCSC__list_entry()"
   "---(initialize)------------------------------#
   let  s:hcsc_tagn    = ""
   let  s:hcsc_line    = 0
   let  s:hcsc_file    = ""
   let  s:hcsc_orig    = ""
   "---(check for null)--------------------------#
   let  l:full_line = getline('.')
   if ((strpart(l:full_line, 2, 2) != "  " && strpart(l:full_line, 2, 2) != "+ "))
      return -1        " bad line
   endif
   "---(tag number)------------------------------#
   let  s:hcsc_tagn    = strpart(l:full_line, 0, 2)
   "---(place mark)------------------------------#
   normal 0
   "---(file name)-------------------------------#
   normal 7l
   normal E
   let  l:word_end = col('.')
   let  s:hcsc_file    = strpart(l:full_line, 6, l:word_end - 6)
   "---(line number)-----------------------------#
   normal 0
   normal 52lw
   let  l:word_beg = col('.') - 1
   normal e
   let  l:word_end = col('.')
   let  s:hcsc_line    = strpart(l:full_line, l:word_beg, l:word_end - l:word_beg) + 0
   "---(full line)-------------------------------#
   let  s:hcsc_orig    = matchstr(l:full_line, "::: .*$")
   let  s:hcsc_orig    = strpart(s:hcsc_orig, 4, strlen(s:hcsc_orig) - 4)
   "---(complete)--------------------------------#
   return 0
endfunction

func!  s:HCSC__list_goto()
   "---(go to source buffer)---------------------#
   let   buf_num = bufnr(s:hcsc_file)
   if    buf_num == -1
      retu  -1
   endi
   sil!  exec('b! ' . buf_num)
   "---(go to source line)-----------------------#
   norm  _
   sil!  exec  "normal ".s:hcsc_line."G"
   "---(verify line)-----------------------------#
   let   curr_line = getline('.')
   if    curr_line != s:hcsc_orig
      retu  -2
   endi
   "---(complete)--------------------------------#
   retu  0
endf

func!  s:HCSC__list_passed()
   setl  modifiable
   norm  0
   norm  51l
   exec  "normal r:"
   norm  7l
   exec  "normal r:"
   norm  0
   "---(complete)--------------------------------#
   setl  nomodifiable
   retu  0
endf

func!  s:HCSC__list_missed()
   setl  modifiable
   norm  0
   norm  51l
   exec  "normal r|"
   norm  7l
   exec  "normal r|"
   norm  0
   "---(complete)--------------------------------#
   setl  nomodifiable
   retu  0
endf

function! s:HCSC__list_update(tagtext)
   setlo  modifiable
   normal 0
   normal 25l
   if (strlen(a:tagtext) <= 25)
      exec "normal R".printf("%-25.25s", a:tagtext)
   else
      exec "normal R".printf("%-24.24s>", a:tagtext)
   endif
   let l:its_buf = bufnr(s:hcsc_file) - 1
   if l:its_buf < 0
      let l:its_buf = '-'
   endif
   if l:its_buf > 9
      let l:its_buf = printf("%c", 65 - 11 + bufnr(s:hcsc_file))
   endif
   normal 0
   normal 4l
   exec "normal R".l:its_buf
   setlo  nomodifiable
   return 0
endfunction



"=============================--------------------=============================#
"===----                             startup                            ----===#
"=============================--------------------=============================#

call s:HCSC_init()



""===[[ END ]]=================================================================#
