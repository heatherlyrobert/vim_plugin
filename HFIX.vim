""===[[ START HDOC ]]==========================================================#
""===[[ HEADER ]]==============================================================#

"   niche         : integrated development environment
"   application   : rsh_fix.vim
"   purpose       : provide simple, productive, effective quickfix replacement
"   base_system   : gnu/linux
"   lang_name     : vim script
"   created       : svq - long, long ago
"   author        : the_heatherlys
"   dependencies  : gcc (any version) and _rsh_fix.awk (custom)
"   permissions   : GPL-2 with no warranty of any kind
"
"
""===[[ PURPOSE ]]=============================================================#

"   rsh_fix is an integrated set of compile/fix services to make a painful,
"   repetitive, lengthy, tedious, and haphazard process into a clear, reliable,
"   consistent, automated, and smooth one.  why make something so frequent and
"   repetitive take up extra programmer cycles?
"
"   typically, the process entails
"      - creating/editing the source,
"      - compiling with suitable options,
"      - reading the compilier's complaints and warnings,
"      - identifying the top errors,
"      - jumping back to source file,
"      - finding the right the line/symbol,
"      - interpreting the error message,
"      - fixing the code,
"      - and then repeating until "clean enough" for gov't work
"   this is painful enough that programmers often ignore various warnings and
"   then don't then use additional static analysis tools to find more.  this
"   process is more or less efficient if multiple term sessions are used to
"   avoid getting in and out of applications and writing/printing error info
"
"   my goal with rsh_fix, is to provide...
"      - short cut to call up rsh_fix and compile in a side-by-side window
"      - enforced options/flags, such as "-Wall" and "-g"
"      - quick visual clue as to pass, fail, warning, or linker issues
"      - format the errors in a quick, one-line format each
"      - easy compile profiles, including pure ansi, c, c++, etc
"      - interface for using a make file or not
"      - sorting errors to the top, warnings lower
"      - select any error in listing and go to it in the source code
"      - toggle to see the original gcc output
"
"   many existing libraries and utilities have been built by better programmers
"   and are likely superior in speed, size, capability, and reliability; BUT,
"   i would not have learned nearly as much using them,  so follow the adage..
"
"  TO TRULY LEARN> do not seek to follow in the footsteps of the men of old;
"  seek what they sought ~ Matsuo Basho
"
"  ADVANTAGES, integrated compile/fix cycle...
"     - no window or terminal switches that slow down the process
"     - much less trivia about compiling to remember
"     - requires no finding and searching in source code
"     - forces the programmer to have the right compile switches/options
"     - is exactly repeatable and therefore dependable
"     - does not skip steps when under stress or time pressures
"     - supports refactoring for disciplined changes by speeding this process
"
"  DISADVANTAGES
"     - means that this module must be built and that takes time
"     - requires this module to be maintained and that takes more time too
"     - can cause the programmer to forget how to do it by hand
"
"
""===[[ DECISION ]]============================================================#

"  PROBLEM (pr)
"     programs are quite tedious to run through the compile/fix cycle nearly
"     continuously and therefore warnings get ignored, fixes come slower,
"     refactoring becomes more rare and dust/cobwebs grow
"
"  OBJECTIVES (o)
"     - make the compile/fix cycle as fast and automated as possible
"     - simple so that it does not require huge learning curve
"     - eleviate much of the pain so small changes get made more often
"
"  ALTERNATIVES and CONSEQUENCES (ac)
"
"     1) keep it manual from the command line
"        - everything is already in place, so no new work
"        - it will exist like this in any environment, so consistent
"        - requires more repetition, typing, and memory
"        - user spends most of the time identifying and finding, not fixing
"
"     2) use make files consistently
"        - this is also a common tool and standard format
"        - greatly eases the compilation task
"        - does not help in identifying and finding the errors
"        - still requires too much time away from fixing
"
"     3) standard vim quickfix
"        - tool is already built in and works
"        - has all the major features needed, and then some
"        - requires the programmer to remember command line commands
"        - still requires a fair amount of coding
"
"     4) use a generally available script
"        - already built and tested on vim
"        - someone else maintains it
"        - often requires other "script" elements that that programmer built
"        - will go out of support as it is freeware
"
"     5) build my own script based on the work of others
"        - will fit like a glove and fits into my development environment
"        - allows me to minimize the keystrokes based on my needs
"        - just one more thing i must maintain
"        - will have to move it between machines to have it where i need it
"
"  JUDGEMENT
"
"     only part-timers or newbees think that this should be done by hand as
"     they don't have to maintain software under time pressure.  as long as
"     an option is relatively simple and can speed this process it is a godsend
"
"     it is critical that i do everything i can to speed this cycle so i can
"     take on as many projects as maximally possible (and then some) to keep
"     the personal goals moving forward; therefore, automate early and often.
"
"     finally, without rapid compile/fix you can not refactor with any
"     confidence and therefore maintaining code becomes more of a hit-and-miss
"     which is completely unacceptable
"
"     i choose to build my own scripts at they will never exceed 500 code lines
"     and the results will be maximally tuned to speed and my needs.  also
"     the existing scripts are continuously being superceeded and outmoded
"     so that key features come and go and user interface changes which is
"     unexceptable, so i will build a consistent one
"
"  BOTTOM LINE : code like your life depends on it, because someday it will
"
"
""===[[ END HDOC ]]============================================================#



""===[[ GLOBALS ]]=============================================================#
let   g:hfix_title    = "HFIX_buffer"
let   g:hfix_locked   = "n"
let   g:hfix_curbuf   = -1
let   g:hfix_sources  = ""

let   s:hfix_bufname  = ""
let   s:hfix_size     = 15

let   s:hfix_file     = ""
let   s:hfix_line     = 0
let   s:hfix_tagn     = ""

let   s:gcc_call      = "make -s install"
let   s:gcc_std       = " "

let   s:hfix_winline  = 0






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


func! s:HFIX_init()
   sil!  exec  'split ' . g:hfix_title
   call  HFIX_resize   ("o")
   call  HALL_start    ()
   call  s:HFIX_prefix ()
   call  s:HFIX_syntax ()
   call  HFIX_keys     ()
   hide
   retu
endf


func! s:HFIX_syntax()
   setlo modifiable
   syn   clear
   "---(syntax highlighting = headers)-----------#
   syn   match rsh_fix_file     '^sources :: .*$'
   syn   match rsh_fix_opt      '^options :: .*$'
   syn   match rsh_fix_end      '^beginning of .*$'
   syn   match rsh_fix_end      '^end of .*$'
   syn   match rsh_fix_recomp   '^recompile .*$'
   syn   match rsh_fix_relink   '^and link .*$'
   syn   match rsh_fix_help     '^gcc/make (help).*$'
   syn   match rsh_fix_clean    '^CLEANING >>.*$'
   syn   match rsh_fix_note     '^no .*'
   syn   match rsh_fix_esum     '^compiler (FAIL).*$'
   syn   match rsh_fix_wsum     '^compiler (warn).*$'
   syn   match rsh_fix_lsum     '^compiler (LINK).*$'
   syn   match rsh_fix_psum     '^compiler (pass).*$'
   syn   match rsh_fix_prog     '^compilation.*$'
   high  rsh_fix_file     cterm=bold   ctermbg=none  ctermfg=5
   high  rsh_fix_opt      cterm=bold   ctermbg=none  ctermfg=5
   "high  rsh_fix_end      cterm=bold,reverse  ctermbg=none  ctermfg=5
   high  rsh_fix_end      cterm=reverse  ctermbg=none  ctermfg=5
   high  rsh_fix_recomp   cterm=reverse  ctermbg=none  ctermfg=5
   high  rsh_fix_relink   cterm=reverse  ctermbg=none  ctermfg=5
   high  rsh_fix_esum     cterm=none   ctermbg=1     ctermfg=none
   high  rsh_fix_wsum     cterm=none   ctermbg=3     ctermfg=none
   high  rsh_fix_lsum     cterm=none   ctermbg=5     ctermfg=none
   high  rsh_fix_psum     cterm=none   ctermbg=2     ctermfg=none
   high  rsh_fix_help     cterm=none   ctermbg=2     ctermfg=none
   high  rsh_fix_clean    cterm=none   ctermbg=1     ctermfg=0
   high  rsh_fix_note     cterm=none   ctermbg=4     ctermfg=0
   high  rsh_fix_prog     cterm=bold   ctermbg=none  ctermfg=5
   "---(syntax highlighting = tags)--------------#
   syn   match hfix_mtag     '^[A-Z-][A-Z-]  '
            \ containedin=rsh_fix_eone, rsh_fix_wone
   high  hfix_mtag     cterm=bold   ctermbg=none  ctermfg=4
   syn   match hfix_ftag     ' \[[a-z-][a-z-]\] '
            \ containedin=rsh_fix_eone, rsh_fix_wone
   high  hfix_ftag     cterm=bold   ctermbg=none  ctermfg=4
   "---(syntax highlighting = numbers)-----------#
   syn   match rsh_fix_num      ' : [0-9 ][0-9 ][0-9 ][0-9] : '
            \ containedin=rsh_fix_eone, rsh_fix_wone
   high  rsh_fix_num   cterm=bold   ctermbg=none  ctermfg=5
   "---(syntax highlighting = lines)-------------#
   syn   match rsh_fix_lone     '^.*[L]$'
   syn   match rsh_fix_eone     '^.*[E]$'
   syn   match rsh_fix_wone     '^.*[-]$'
   syn   match rsh_fix_pone     '^.*[*]$'
   high  rsh_fix_lone  cterm=bold   ctermbg=none  ctermfg=1
   high  rsh_fix_eone  cterm=bold   ctermbg=none  ctermfg=1
   high  rsh_fix_wone  cterm=bold   ctermbg=none  ctermfg=3
   high  rsh_fix_pone  cterm=bold   ctermbg=none  ctermfg=2
   "---(syntax highlighting = current line)------#
   "syntax match rsh_fix_ecur      '^>>'
   "         \ containedin=rsh_fix_eline, rsh_fix_wline
   "hi rsh_fix_ecur  cterm=bold,reverse  ctermbg=none ctermfg=5
   setlo  nomodifiable
   retu
endf


func! HFIX_keys()
   setlo  modifiable
   nmap            ,q      :call HFIX_show    ()<cr>
   nmap  <buffer>   q      :call HFIX_compile ("q")<cr>
   nmap  <buffer>   f      :call HFIX_compile ("f")<cr>
   nmap  <buffer>   w      :call HFIX_compile ("w")<cr>
   nmap  <buffer>   W      :call HFIX_compile ("W")<cr>
   nmap  <buffer>   a      :call HFIX_compile ("a")<cr>
   nmap  <buffer>   c      :call HFIX_compile ("c")<cr>
   nmap  <buffer>   i      :call HFIX_compile ("i")<cr>
   nmap  <buffer>   I      :call HFIX_compile ("I")<cr>
   nmap  <buffer>   u      :call HFIX_compile ("u")<cr>
   nmap  <buffer>   m      :call HFIX_compile ("m")<cr>
   nmap  <buffer>   Z      :call HFIX_unkeys  ()<cr>
   "---(presentation/size)---------------------------#
   nmap  <buffer>   -      :call HFIX_resize  ("-")<cr>
   nmap  <buffer>   +      :call HFIX_resize  ("+")<cr>
   nmap  <buffer>   h      :call HFIX_hide    ()<cr>
   "---(complete)------------------------------------#
   setlo  nomodifiable
   retu
endf


func! HFIX_unkeys()
   setlo  modifiable
   nunm  <buffer>  q
   nunm  <buffer>  f
   nunm  <buffer>  w
   nunm  <buffer>  W
   nunm  <buffer>  a
   nunm  <buffer>  c
   nunm  <buffer>  i
   nunm  <buffer>  I
   nunm  <buffer>  u
   nunm  <buffer>  m
   nunm  <buffer>  +
   nunm  <buffer>  -
   nunm  <buffer>  h
   nmap  <buffer>  Z      :call HFIX_keys  ()<cr>
   setlo  nomodifiable
   retu
endf


func! s:HFIX_auto()
endf


func! s:HFIX_unauto()
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



function! HFIX_show()
   "---(do not allow recursion)------------------#
   if (g:hfix_locked == "y")
      return
   endif
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HBUF_show()         :: ") < 1)
      return
   endif
   "---(lock her down)---------------------------#
   call HALL_lock()
   "---(verify the buffer)-----------------------#
   let buf_num         = bufnr(g:hfix_title)
   if (buf_num < 1)
      call s:HFIX_init()
   endif
   "---(close the existing window)---------------#
   let buf_win = bufwinnr(buf_num)
   if (buf_win > 0)
      silent exec buf_win.' wincmd w'
      hide
   endif
   "---(check for the window)--------------------#
   "if (HBUF_by_name(g:hbuf_title) > 0)
   "   hide
   "endif
   "---(open the buffer window)------------------#
   sil!  exec 'split ' . g:hfix_title
   call  HFIX_resize("c")
   "---(create the autocommands)-----------------#
   call s:HFIX_auto()
   "---(update)----------------------------------#
   "call HBUF_restore()
   call HALL_unlock()
   "---(complete)--------------------------------#
   return
endfunction

func! HFIX_show_OLD()
   "---(remember where we were)------------------#
   if   (HBUF_save("HBUF_show()         :: ") < 1)
      retu
   endi
   let   s:hfix_bufname = bufname('%')
   let   buf_name = s:hfix_bufname
   "---(lock it down)----------------------------#
   call  HALL_lock()
   "---(check for the buffer)--------------------#
   let   buf_num = HBUF_by_name(g:hfix_title) 
   if    buf_num < 0
      call  s:HFIX_init()
   elsei buf_num > 0
      hide
   endi
   "---(open the buffer window)------------------#
   sil!  exec 'split ' . g:hfix_title
   call  HFIX_resize("c")
   if g:hfix_sources != l:buf_name 
      let g:hfix_sources = l:buf_name 
      setlocal modifiable
      :1,$delete
      normal _
      exec printf("normal isources :: %-74.74s", g:hfix_sources)
      normal 0
      "---(create the cleaver mappings)-------------#
      nmap          ,,  :call HFIX_next("n")<cr>
      nmap          ,.  :call HFIX_next("p")<cr>
      nmap          ,<  :call HFIX_next("f")<cr>
      nmap          ,>  :call HFIX_next("l")<cr>
      "---(complete)--------------------------------#
      setlocal nomodifiable
   else
      normal _4j
      normal 0
   endif
   redraw!
   "---(open it up)------------------------------#
   call  HALL_unlock()
   "---(complete)--------------------------------#
   retu
endf


func! HFIX_hide()
   ""---(defense)--------------------------------#
   if    (bufname("%") != g:hfix_title)
      retu  -1
   endi
   ""---(process)--------------------------------#
   call  s:HFIX_unauto()
   hide
   call  HBUF_restore()
   ""---(complete)-------------------------------#
   retu
endf


"" PURPOSE : update window size
func! HFIX_resize(height)
   ""---(get current state)----------------------#
   "let   s:hfix_size  = winheight(0)
   ""---(process change)-------------------------#
   if    (a:height == "+")
      let   s:hfix_size += 10
   elsei (a:height == "-")
      let   s:hfix_size -= 10
   elsei (a:height == "o")
      let   s:hfix_size  = 10
   endi
   ""---(test size values)-----------------------#
   if    (s:hfix_size > 45)
      let   s:hfix_size = 45 
   elsei (s:hfix_size < 15)
      let   s:hfix_size = 15
   endi
   ""---(resize)---------------------------------#
   sil!  exec  "resize ".s:hfix_size
   ""---(complete)-------------------------------#
   return
endf



func! s:o___SPECIFIC________o()
endf


func! s:HFIX_sparms(std)
   setlo noignorecase
   setlo nosmartcase
   let s:gcc_call = "gcc "
   let s:gcc_std  = "-g -pg -Wall -Wextra "
   " let s:gcc_std  = "-g -pg -Wall -Wextra -W -Wconversion -fprofile-arcs -ftest-coverage "
   if    a:std == "a"
      let s:gcc_call  = "gcc "
      let s:gcc_std  .= " -ansi -pedantic "
   elsei a:std == "c"
      let s:gcc_call  = "gcc "
      let s:gcc_std  .= " -std=gnu89 "
   elsei a:std == "p"
      let s:gcc_call  = "g++ "
      let s:gcc_std  .= " "
   elsei a:std == "m"
      let s:gcc_call  = "make -s"
      let s:gcc_std   = " "
   elsei a:std == "b"
      let s:gcc_call  = "make -s install"
      let s:gcc_std   = " "
   elsei a:std == "x"
      let s:gcc_call  = "make -s clean"
      let s:gcc_std   = " "
   elsei a:std == "q"
      let s:gcc_call  = "make -s clean"
      let s:gcc_std   = " "
   else
      return -2
   endif
   retu  0
endf

func! s:HFIX_prefix  ()
   setlo  modifiable
   sil!   exec   ":silent 1,$d"
   sil!   exec   printf ("normal i%-86.86s\n", "gcc/make (help) q:quik f:full w:wipe a:ansi c:comp i:inst u:test m:manu Z:revw")
   setlo  nomodifiable
endf

func! s:HFIX_prepare ()
   let    g:hfix_locked = "y"
   echon  "HFIX_compile()    :: compiling ".g:hfix_sources."..."
   call   HFIX_unkeys()
   setlo  modifiable
   sil!   exec   ":silent 2,$d"
   redraw!
endf

func! s:HFIX_clean   (a_opt)
   normal GG0
   if     (a:a_opt == "w")
      sil!   exec   ":silent 2,$!make -s clean"
      sil!   exec   printf ("normal GGo%-86.86s", "CLEANING >> erase primary working files before compiling (will cause FULL compile)")
   elseif (stridx ("Wf", a:a_opt) >= 0)
      sil!   exec   ":silent 2,$!make -s bigclean"
      sil!   exec   printf ("normal GGo%-86.86s", "CLEANING >> erase ALL working files before compiling (will cause FULL compile)")
   else
      sil!   exec   printf ("normal GGo%-86.86s", "no cleaning requested")
   endif
   redraw!
endf

func! s:HFIX_make     (a_opt)
   normal GG
   if     (stridx ("qca", a:a_opt) >= 0)
      "---(preview)---------------------------------#
      sil!   exec   printf ("normal GG0o%-86.86s", "previewing source code compilation...")
      let    l:curr_line    = line ('.')
      sil!   exec   ":silent ".l:curr_line.",$!make --recon base"
      sil!   exec   ":silent ".l:curr_line.",$!HFIX_recon.awk"
      "---(prepare)---------------------------------#
      sil!   exec   printf ("normal GG0o%-86.86s", "compilation and linking of base source code underway...")
      normal _0GG
      let    l:curr_line    = line ('.')
      redraw!
      "---(compile)---------------------------------#
      sil!   exec   ":silent ".l:curr_line.",$!make base"
      "---(eliminate wide-characters)---------------#
      sil!   exec   ":silent ".l:curr_line.",$:s/\%u2018/�/ge"
      sil!   exec   ":silent ".l:curr_line.",$:s/\%u2019/�/ge'"
      "---(format the results)----------------------#
      sil!   exec   ":silent ".l:curr_line.",$!HFIX.awk"
      "---(add a footer)----------------------------#
      " exec   printf ("normal GGo%-86.86s", "end of compiler feedback")
   elseif (a:a_opt == "u")
      "---(preview)---------------------------------#
      sil!   exec   printf ("normal GG0o%-86.86s", "previewing unit test compilation...")
      let    l:curr_line    = line ('.')
      sil!   exec   ":silent ".l:curr_line.",$!make --recon units"
      sil!   exec   ":silent ".l:curr_line.",$!HFIX_recon.awk"
      "---(prepare)---------------------------------#
      sil!   exec   printf ("normal GG0o%-86.86s", "compilation of unit tests underway...")
      normal GG0
      redraw!
      let    l:curr_line    = line ('.')
      "---(compile)---------------------------------#
      sil!   exec   ":silent ".l:curr_line.",$!make units"
      "---(eliminate wide-characters)---------------#
      sil!   exec   ":silent ".l:curr_line.",$:s/\%u2018/�/ge"
      sil!   exec   ":silent ".l:curr_line.",$:s/\%u2019/�/ge"
      "---(format the results)----------------------#
      sil!   exec   ":silent ".l:curr_line.",$!HFIX.awk"
      "---(add a footer)----------------------------#
      " exec   printf ("normal GGo%-86.86s", "end of compiler feedback")
   else
      sil!   exec   printf ("normal GGo%-86.86s", "no compilation requested")
   endi
   redraw!
endf

func! s:HFIX_install  (a_opt)
   if     (stridx ("qf", a:a_opt) >= 0)
      normal GG0
      let  l:full_line = getline('.')
      let  l:full_line = strpart (l:full_line, 0, 30)
      if (l:full_line == "compiler (pass) compile alread")
         sil!   exec   printf ("normal GG0o%-86.86s", "no installation required, source code not updated")
         return 0
      endif
      let  l:full_line = strpart (l:full_line, 0, 15)
      if (l:full_line != "compiler (pass)")
         sil!   exec   printf ("normal GG0o%-86.86s", "no installation allowed, source code contained errors")
         return 0
      endif
      sil!   exec   printf ("normal GG0o%-86.86s", "binary code installation underway...")
      normal GG0
      redraw!
      let    l:curr_line    = line ('.')
      sil!  exec ":silent ".l:curr_line.",$!make -s install"
      exec printf("normal GGo%-86.86s", "end of installation feedback")
   elseif (stridx ("iI", a:a_opt) >= 0)
      normal GG0
      sil!   exec   printf ("normal GG0o%-86.86s", "binary code installation underway...")
      normal GG0
      redraw!
      let    l:curr_line    = line ('.')
      sil!  exec ":silent ".l:curr_line.",$!make -s install"
      exec printf("normal GGo%-86.86s", "end of installation feedback")
   elseif (a:a_opt == "m")
      sil!   exec   printf ("normal GG0o%-86.86s", "binary code installation underway...")
      normal GG0
      redraw!
      let    l:curr_line    = line ('.')
      sil!  exec ":silent ".l:curr_line.",$!make -s install_man"
      exec printf("normal GGo%-86.86s", "end of installation feedback")
   else
      sil!   exec   printf ("normal GGo%-86.86s", "no installation requested")
   endif
endf

func! HFIX_compile  (a_opt)
   "---(defenses)--------------------------------#
   if    bufwinnr(g:HTAG_title) < 1
      call   s:HFIX_prefix ()
      echon  "HFIX_compile()           :: tag window must be open (returning)..."
      retu
   endi
   if    (g:hfix_locked == "y")
      call   s:HFIX_prefix ()
      echon  "HFIX_compile()   :: already compiling, locked!"
      retu
   endi
   "---(prepare)---------------------------------#
   " call   s:HFIX_prefix  ()
   call   s:HFIX_prepare ()
   call   s:HFIX_clean   (a:a_opt)
   call   s:HFIX_make    (a:a_opt)
   call   s:HFIX_install (a:a_opt)

   "---(get the function names)------------------#
   let   x_rc = s:HFIX__list_head()
   while x_rc == 0
       "echo  "tagn=".s:hfix_tagn.", file=".s:hfix_file.", line=".s:hfix_line
      let   replace  = HTAG_findloc(s:hfix_file, s:hfix_line)
      call  HBUF_by_name(g:hfix_title)
    "    if    (replace != -1)
      let   x_rc     = s:HFIX__list_update(replace)
    "   endi
      let   x_rc     = s:HFIX__list_next()
   endwhile

   norm  _j
   setlo nomodifiable
   let   g:hfix_locked = "n"
   call  HFIX_keys()
   call  HBUF_restore()
   retu


   "---(clean)-----------------------------------#
   " let   g:hfix_locked = "y"
   " echon "HFIX_compile()    :: compiling ".g:hfix_sources."..."
   " call  HFIX_unkeys()
   " setlocal modifiable
   " sil!  exec ":silent 1,$d"
   " sil!  exec  printf("normal i%-86.86s\n", "compilation in progress...")
   " redraw!
   "---(cleaning)-------------------s------------#
   " if    a:std == "a"
   "    sil!  exec ":silent 1,$!make -s clean"
   " endi
   " if    a:std == "x" || a:std == "X"
   "    sil!  exec ":silent 1,$!make -s clean"
   "    if (a:std == "X")
   "       sil!  exec ":silent $!make -s bigclean"
   "    endif
   "    normal _
   "    exec "normal O"
   "    exec printf("normal i%-86.86s", "gcc/make (pass) | temporary file clean request")
   "    normal GG
   "    exec "normal o"
   "    exec printf("normal i%-86.86s", "end of installation feedback")
   " endi
   "---(compliation)-----------------------------#
   " if    a:std == "q" || a:std == "c" || a:std == "a"
   "    sil!  exec ":silent 1,$!make -s"
   "    "---(eliminate wide-characters)---------------#
   "    sil!  exec ':silent 1,$:s/\%u2018/"/ge'
   "    sil!  exec ':silent 1,$:s/\%u2019/"/ge'
   "    "---(format the results)----------------------#
   "    sil!  exec ":silent 1,$!HFIX.awk"
   "    "---(add a footer)----------------------------#
   "    normal GG
   "    exec "normal o"
   "    exec printf("normal i%-86.86s", "end of compiler feedback")
   " endi
   " if    a:std == "u"
   "    sil!  exec ":silent 1,$!make -s units"
   "    "---(eliminate wide-characters)---------------#
   "    sil!  exec ':silent 1,$:s/\%u2018/"/ge'
   "    sil!  exec ':silent 1,$:s/\%u2019/"/ge'
   "    "---(format the results)----------------------#
   "    sil!  exec ":silent 1,$!HFIX.awk"
   "    "---(add a footer)----------------------------#
   "    normal GG
   "    exec "normal o"
   "    exec printf("normal i%-86.86s", "end of compiler feedback")
   " endi
   "---(installation)----------------------------#
   " if    a:std == "m"
   "    sil!  exec ":silent 1,$!make -s install_man"
   "    normal _
   "    exec "normal O"
   "    exec printf("normal i%-86.86s", "gcc/make (pass) | manual installation request")
   "    normal GG
   "    exec "normal o"
   "    exec printf("normal i%-86.86s", "end of installation feedback")
   " endif
   " if    a:std == "i"
   "    sil!  exec ":silent 1,$!make -s install"
   "    normal _
   "    exec "normal O"
   "    exec printf("normal i%-86.86s", "gcc/make (pass) | executable installation request")
   "    normal GG
   "    exec "normal o"
   "    exec printf("normal i%-86.86s", "end of installation feedback")
   " endif
   " if    a:std == "q" || a:std == "a"
   "    sil!  exec ":silent $!make -s install"
   "    normal GG
   "    exec "normal o"
   "    exec printf("normal i%-86.86s", "end of installation feedback")
   " endif
   " norm   _


   "---(get the function names)------------------#
    setl   nomodifiable
    let   x_rc     = s:HFIX__list_head()
    while x_rc == 0
       "echo  "tagn=".s:hfix_tagn.", file=".s:hfix_file.", line=".s:hfix_line
       let   replace  = HTAG_findloc(s:hfix_file, s:hfix_line)
       call  HBUF_by_name(g:hfix_title)
    "    if    (replace != -1)
          let   x_rc     = s:HFIX__list_update(replace)
       endi
       let   x_rc     = s:HFIX__list_next()
    endwhile
   echo "done"
   "---(prepare for return)----------------------#
   norm  _j
   setlo nomodifiable
   let   g:hfix_locked = "n"
   call  HFIX_keys()
   call  HBUF_restore()
   retu
endf


function! HFIX_hints(tag)
   "---(switch to tag window)-----------------#
   let   buf_cur = bufnr('%')
   let   win_num = HBUF_by_name(g:hfix_title)
   if    win_num < 1
      echon "  -- FIX not open, can not process..."
   endi
   sil   exec win_num.' wincmd w'
   sil!  call HFIX_unkeys()        " get the key mappings off
   norm  _
   "---(find the tag)-------------------------#
   call  search("^" . a:tag . "  ")
   if    line(".") < 2
      echon "  -- tag not found, can not process..."
      sil!  call HFIX_keys()
      retu
   endi
   norm  0
   call  s:HFIX__list_entry()
   "---(get the keys back on)-----------------#
   sil!  call HFIX_keys()
   "---(get back to the original window)------#
   norm  ,a
   let   buf_num = bufnr(s:hfix_file)
   if    buf_num == -1
      echon "HCSC_hints()          :: buffer not open in wim..."
      retu
   else
      sil   exec('b! ' . buf_num)
   endi
   "---(get to the right line)----------------# make sure to show comments above
   norm  _
   sil!  exec "normal " . (s:hfix_line - 1) . "j"
   sil!  exec "normal z."
   "---(complete)-----------------------------#
   retu
endf

""===[[ UTILITY ]]=============================================================#

function! HFIX_parse()
   "---(clear out old information)---------------#
   let l:efull    = ""
   let l:etype    = ""
   let l:ebuff    = ""
   let l:efile    = ""
   let l:eline    = 0
   let l:emesg    = ""
   let l:esymb    = ""
   "---(get the current error)-------------------#
   let l:efull = getline('.')
   if strpart(l:efull,0,2) != "  "
      echon "HFIX_parse()     :: not a valid error line..."
      silent! normal ,a
      return
   endif
   "---(parse the error message)-----------------#
   let l:efile = matchstr(l:efull, "  #1#  .\*  #2#  ")
   let l:efile = strpart(l:efile,7,strlen(l:efile)-14)
   let l:ebuff = matchstr(l:efull, "  #2#  .\*  #3#  ")
   let l:ebuff = strpart(l:ebuff,7,strlen(l:ebuff)-14)
   let l:eline = matchstr(l:efull, "  #3#  [1-9][0-9]\*  #4#  ")
   let l:eline = strpart(l:eline,7,strlen(l:eline)-14) + 0
   let l:emesg = matchstr(l:efull, "  #4#  .\*  #5#  ")
   let l:emesg = strpart(l:emesg,7,strlen(l:emesg)-14)
   let l:esymb = matchstr(l:efull, "  #5#  .\*  #6#  ")
   let l:esymb = strpart(l:esymb,7,strlen(l:esymb)-14)
   let l:efull = matchstr(l:efull, "  #6#  .\*  #7#  ")
   let l:efull = strpart(l:efull,7,strlen(l:efull)-14)
   "---(mark this error)-------------------------#
   setlocal modifiable
   silent! normal 0R>>
   setlocal nomodifiable
   silent! normal ,a
   silent! exec 'b! ' . l:ebuff
   silent! norm  _
   silent! exec ":normal " . l:eline . "jk"
   silent! normal z.
   "let  [x_row,x_col] = searchpos(l:identifier,"",l:destline)
   "execute "silent! syntax clear rsh_fix_identifier"
   "execute "highlight link rsh_fix_identifier error"
   "execute "syntax match rsh_fix_identifier '" . l:identifier . "' containedin=ALL"
   echon "HFIX_parse()     :: ".l:emesg
   return
endfunction



""=============================================================================#
""===[[ WINDOW UPDATE CODE ]]==================================================#
""=============================================================================#


function! HFIX_clear()
   execute "silent! syntax clear rsh_fix_identifier"
   return
endfunction


function! HFIX_next(dir)
   "---(check for the buffer)--------------------#
   let l:buf_num = bufnr(g:hfix_title)
   if (l:buf_num < 1)
      return
   endif
   "---(check for the window)--------------------#
   let l:win_num = bufwinnr(l:buf_num)
   if (l:win_num < 1)
      return
   endif
   "---(start updating)--------------------------#
   silent exec l:win_num.' wincmd w'
   "---(check for a valid error)-----------------#
   let l:line_cur = getline('.')
   if strpart(l:line_cur,0,2) != "  "
      if strpart(l:line_cur,0,2) != ">>"
         echon "HFIX_next() :: not a valid error line, return to start..."
         silent! normal _4j
         silent! normal ,a
         return
      else
         setlocal modifiable
         silent! normal 0R  
         setlocal nomodifiable
      endif
   endif
   if a:dir == "n"
      silent! normal j
   elseif a:dir == "p"
      silent! normal k
   elseif a:dir == "f"
      silent! normal _4j
   elseif a:dir == "l"
      silent! normal GGk
   endif
   let l:line_cur = getline('.')
   if strpart(l:line_cur,0,2) != "  "
      if a:dir == "n"
         silent! normal k
      endif
      if a:dir == "p"
         silent! normal j
      endif
   endif
   call HFIX_parse()
   "---(complete)--------------------------------#
   return
endfunction




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


let  s:hfix_lhead       = 1
let  s:hfix_lcurr       = 0


func! s:HFIX__list_head()
   "echo "HFIX__list_head()"
   let   s:hfix_lhead  = 1
   let   s:hfix_lcurr  = 0
   let   x_rc = s:HFIX__list_next()
   retu  x_rc
endf

func! s:HFIX__list_next()
   "echo "HCSC__list_next()"
   let   s:hfix_lcurr += 1
   norm  _
   exec  "normal ".s:hfix_lhead."G"
   exec  "normal ".s:hfix_lcurr."j"
   let   x_rc = s:HFIX__list_entry()
   retu  x_rc
endfunction

func! s:HFIX__list_entry()
   "echo "HFIX__list_entry()"
   "---(initialize)------------------------------#
   let   s:hfix_tagn    = ""
   let   s:hfix_line    = 0
   let   s:hfix_file    = ""
   "---(check for null)--------------------------#
   let   l:full_line = getline('.')
   "echo "trying"
   if    (strpart(l:full_line, 2, 2) != "  ")
      retu   -1        " bad line
   endi 
   "echo "past checking"
   "---(tag number)------------------------------#
   let   s:hfix_tagn    = strpart(l:full_line, 0, 2)
   "echo s:hfix_tagn
   "---(file name)-------------------------------#
   norm  0
   norm  7l
   norm  E
   let   l:word_end = col('.')
   let   s:hfix_file    = strpart(l:full_line, 6, l:word_end - 6)
   "echo s:hfix_file
   "---(line number)-----------------------------#
   norm  0
   norm  52lw
   let   l:word_beg = col('.') - 1
   norm  e
   let   l:word_end = col('.')
   let   s:hfix_line    = strpart(l:full_line, l:word_beg, l:word_end - l:word_beg) + 0
   "echo s:hfix_line
   "echo "done"
   "---(complete)--------------------------------#
   retu  0
endf

func!  s:HFIX__list_goto()
   "---(go to source buffer)---------------------#
   let   buf_num = bufnr(s:hfix_file)
   if    buf_num == -1
      retu  -1
   endi
   sil!  exec('b! ' . buf_num)
   "---(go to source line)-----------------------#
   norm  _
   sil!  exec  "normal ".s:hfix_line."G"
   "---(complete)--------------------------------#
   retu  0
endf

function! s:HFIX__list_update(tagtext)
   setlo  modifiable
   normal 0
   normal 25l
   if (strlen(a:tagtext) <= 25)
      exec "normal R".printf("%-25.25s", a:tagtext)
   else
      exec "normal R".printf("%-24.24s>", a:tagtext)
   endif
   let l:its_buf = bufnr(s:hfix_file) - 1
   if l:its_buf < 0
      let l:its_buf = '-'
   endif
   if l:its_buf > 9
      let l:its_buf = printf("%c", 65 - 11 + bufnr(s:hfix_file))
   endif
   normal 0
   normal 4l
   exec "normal R".l:its_buf
   setlo  nomodifiable
   return 0
endfunction




""=============================================================================#
""===[[ WINDOW UPDATE CODE ]]==================================================#
""=============================================================================#



call s:HFIX_init()
""===[[ END ]]=================================================================#
