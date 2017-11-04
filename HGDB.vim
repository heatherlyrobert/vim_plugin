""===[[ HEADER ]]==============================================================#

"    focus         : development
"    niche         : integrated development environment
"    application   : HGDB.vim
"    purpose       : provide simple, productive, effective debugging access
"
"    base_system   : gnu/linux
"    lang_name     : vim-script
"    dependencies  : none
"    size goal     : tiny (less than 500 slocL)
"
"    priorities    : direct, simple, brief, vigorous, and lucid (h.w. fowler)
"    end goal      : loosely coupled, strict interface, maintainable, portable
"
"
""===[[ PURPOSE ]]=============================================================#

"    HGDB is an integrated set of debugging services to make a painful,
"    repetitive, lengthy, tedious, and haphazard process into a clear, reliable,
"    consistent, automated, and smooth one.  why make something so frequently
"    needed be so hard to do?
"
"    typically the process entails...
"       - bringing up a comannd line debugger
"       - attaching the output to another terminal
"       - reviewing the code
"       - setting a breakpoint manually
"       - looking at some variables
"       - guessing at the next breakpoint
"       - bomb and repeat
"    this is a painful enough process that programmers often waste time trying
"    to avoid having to use a debugger.
"
"    most IDEs come with integrated debuggers that are hampered by GUIs or are
"    simply weaker because the IDE needs it to sell but its users are not that
"    critical.  in linux is blessed with all the power of GDB and related tools,
"    but the cost is that they are hard to use.
"
"    so, my goal is to create a vim-script that integrates GDB into our vim IDE
"    framework and allows us to use vim to set breaks, select variables to
"    print, move through code, and attach to executing processes.
"
"    many existing libraries and utilities have been built by better programmers
"    and are likely superior in speed, size, capability, and reliability; BUT,
"    i would not have learned nearly as much using them,  so follow the adage..
"
"    TO TRULY LEARN> do not seek to follow in the footsteps of the men of old;
"    seek what they sought ~ Matsuo Basho
"
"
""===[[ END ]]=================================================================#


""===[[ GLOBALS ]]=============================================================#
let   g:hgdb_title    = "HGDB_buffer"
let   g:hgdb_locked   = "n"
let   g:hgdb_curbuf   = -1

let   s:hgdb_bufname  = ""
let   s:hgdb_size     = 15

let   s:hgdb_file     = ""
let   s:hgdb_line     = 0
let   s:hgdb_tagn     = ""






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


func! s:HGDB_init()
   sil!  exec  'split ' . g:hgdb_title
   call  HGDB_resize("o")
   call  HALL_start()
   call  s:HGDB_syntax()
   call  s:HGDB_keys()
   hide
   retu
endf


func! s:HGDB_syntax()
   setlo modifiable
   syn   clear
   syn    match hcsc_coproc   '^HGDB .*$'
   high   hcsc_coproc   cterm=none   ctermbg=1     ctermfg=none
   setlo nomodifiable
   retu
endf


func! s:HGDB_keys()
   setlo modifiable
   nmap            ,d      :call HGDB_show()<cr>
   nmap  <buffer>   d      :call HGDB_start()<cr>
   nmap  <buffer>   q      :call HGDB_stop()<cr>
   nmap  <buffer>   h      :call HGDB_hide()<cr>
   "---(complete)------------------------------------#
   setlo  nomodifiable
   retu
endf


func! s:HGDB_unkeys()
   setlo modifiable
   nunm  <buffer>  h
   setlo nomodifiable
   retu
endf


func! s:HGDB_auto()
endf


func! s:HGDB_unauto()
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

function! HGDB_show()
   "---(do not allow recursion)------------------#
   if (g:hgdb_locked == "y")
      return
   endif
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HBUF_show()         :: ") < 1)
      return
   endif
   "---(lock her down)---------------------------#
   call HALL_lock()
   "---(verify the buffer)-----------------------#
   let buf_num         = bufnr(g:hgdb_title)
   if (buf_num < 1)
      call s:HGDB_init()
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
   sil!  exec 'split ' . g:hgdb_title
   call  HGDB_resize("c")
   "---(create the autocommands)-----------------#
   call s:HGDB_auto()
   "---(update)----------------------------------#
   "call HBUF_restore()
   call HALL_unlock()
   "---(complete)--------------------------------#
   return
endfunction



func! HGDB_hide()
   ""---(defense)--------------------------------#
   if    (bufname("%") != g:hgdb_title)
      retu  -1
   endi
   ""---(process)--------------------------------#
   call  s:HGDB_unauto()
   hide
   call  HBUF_restore()
   ""---(complete)-------------------------------#
   retu
endf


"" PURPOSE : update window size
func! HGDB_resize(height)
   ""---(get current state)----------------------#
   "let   s:hgdb_size  = winheight(0)
   ""---(process change)-------------------------#
   if    (a:height == "+")
      let   s:hgdb_size += 10
   elsei (a:height == "-")
      let   s:hgdb_size -= 10
   elsei (a:height == "o")
      let   s:hgdb_size  = 10
   endi
   ""---(test size values)-----------------------#
   if    (s:hgdb_size > 45)
      let   s:hgdb_size = 45 
   elsei (s:hgdb_size < 15)
      let   s:hgdb_size = 15
   endi
   ""---(resize)---------------------------------#
   sil!  exec  "resize ".s:hgdb_size
   ""---(complete)-------------------------------#
   return
endf




""=========================-------------------------==========================##
""===----                specialized plugin functions                  ----===##
""=========================-------------------------==========================##
func! s:o___SPECIFIC________o()
endf


function! HGDB_start()
   setl  modifiable
   sil!  exec  ":silent 1,$d"
   sil!  exec printf ("normal i%-86.86s\n", "HGDB session being started now...")
   sil!  exec  ":silent !./gdb.sh &"
   sleep 1
   "sil!  exec  ":silent $,$!echo tty /dev/pts/3 > gdb_head"
   sil!  exec ":silent !read VI_GDB_PID < gdb_pid"
   sil!  exec printf ("normal opid=%s\n",   $VI_GDB_PID)
   sil!  exec printf ("normal oname=%s\n",  $VI_EXEC)
   sil!  exec printf ("normal osource=%s\n",$VI_SOURCE)
   redraw!
   "sil!  exec  "printf \"onormal o\n\")"
   sil!  exec  ":!echo b main > gdb_head"
   "sleep 1
   sil!  exec  ":$,$!cat gdb_tail"
   "setl  nomodifiable
   ""---(complete)-------------------------------#
   return
endf


function! HGDB_stop()
   setl  modifiable
   sil!  exec ":silent 1,$d"
   sil!  exec  printf("normal i%-86.86s\n", "HGDB session being stopped...")
   sil! exec ":silent !read GDB_PID < gdb_pid; kill $GDB_PID; unset GDB_PID"
   sil! exec ":silent !rm -f gdb_pid"
   redraw!
   setl   nomodifiable
   ""---(complete)-------------------------------#
   return
endf




call s:HGDB_init()
""===[[ END ]]=================================================================#
