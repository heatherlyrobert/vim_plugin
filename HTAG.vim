""===[[ START HDOC ]]==========================================================#
""===[[ HEADER ]]==============================================================#

"   niche         : vim-ide (integrated development environment)
"   application   : htag.vim
"   purpose       : effective visual ctags navigation within vim/ide
"   base_system   : gnu/linux
"   lang_name     : vim script
"   created       : svq - long, long ago
"   author        : the_heatherlys
"   dependencies  : none (vim only)
"   permissions   : GPL-2 with no warranty of any kind
"
"
""===[[ PURPOSE ]]=============================================================#

"   rsh_tag is a fast, clear, standard, and simple tag navigation tool to
"   provide the programmer with a categorized table of global symbols for all
"   buffers open in the current vim session
"
"   this tool is meant to provide...
"      - an inventory of all global symbols in active buffers
"      - help organize tags into major groups for ease of use
"      - to work with all major programming and scripting languages
"      - quick, short-cut based navigation within a file/window
"      - automatically show the current buffer's tags when switching
"      - easy to update tags quickly with limited keystrokes
"      - provide other function the ability to move through a tag list
"      - provide information on a specific tag
"      - and nothing else
"
"   rsh_tag will only be effective if it is blazing fast and simple
"
""===[[ WORK ]]================================================================#

"  TODO create function accessors for first, next, current, and count
"  TODO change all init() functions to be like rsh_tag.vim
"
""===[[ END HDOC ]]============================================================#



"==============================================================================#
"=======                           global vars                          =======#
"==============================================================================#



"---(general)------------------------------------#
let   g:HTAG_title    = "polymnia tags"
let   g:HTAG_locked   = "n"
let   g:HTAG_times    = 0
let   g:HTAG_cword    = "---"

"---(current tag)--------------------------------#
let   s:HTAG_tagn     = ""
let   s:HTAG_iden     = ""
let   s:HTAG_file     = ""
let   s:HTAG_line     = 0
let   s:HTAG_type     = ""
let   s:HTAG_desc     = ""

"---(function cursor)----------------------------#
let   s:HTAG_cfile    = 0
let   s:HTAG_ctype    = 0
let   s:HTAG_chead    = 0
let   s:HTAG_ccount   = 0
let   s:HTAG_ccurr    = 0

""---(stats processing)---------------""
let   s:HTAG_sbase    = ""
let   s:HTAG_sfile    = 0
let   s:HTAG_scfile   = 0
let   s:HTAG_sfunc    = 0
let   s:HTAG_sgood    = 0
let   s:HTAG_sgroup   = 0
let   s:HTAG_sbad     = 0



""=========================-------------------------==========================##
""===----             standard initialization fuctions (6)             ----===##
""=========================-------------------------==========================##
""  ...._init        :: prepare script/window at vim startup
""  ...._syntax      :: setup syntax rules
""  ...._keys        :: setup key mappings
""  ...._unkeys      :: remove key mappings
""  ...._auto        :: setup auto commands
""  ...._unauto      :: remove auto commands
func! s:o___STD_INIT________o ()
endf


""=[[ main setup driver ]]================================[ root   [ 113n0s ]=##
func! HTAG_init ()
   sil!  exec 'vert split '.g:HTAG_title
   setl  modifiable
   call  HALL_start  ()
   call  HTAG_syntax ()
   call  HTAG_keys   ()
   "setl  modifiable
   "sil!  exec   ".:!grep \"NAME_BASE\" Makefile | cut -c 14-100"
   "let   s:HTAG_sbase = getline (".")
   "setl  nomodifiable
   hide
   retu  0
endf


""=[[ establish syntax highlighting ]]====================[ leaf   [ 210n0x ]=##
func! HTAG_syntax ()
   synt  clear
   synt  match htag_file           '^[A-Za-z0-9_.-]\+[ ]\+FILE'
   synt  match htag_major          '^[a-z].*[ ]([0-9]\+)$'
   synt  match htag_major_new      '^function[ ]([0-9]\+)'
   synt  match htag_context        '^  [a-z][a-z/][a-z] [=].*'
   synt  match htag_detail         '^[a-z-][a-z-]  [a-zA-Z][a-zA-Z0-9_].*'
   synt  match htag_tag            '^[a-z-][a-zA-Z-0#]  '   containedin=rsh_tag_detail
   synt  match htag_separator      'o___[A-Z_].*___'        containedin=rsh_tab_detail
   hi    htag_file      cterm=reverse,bold   ctermbg=none   ctermfg=5
   hi    htag_major     cterm=bold,underline ctermbg=none   ctermfg=5
   hi    htag_major_new cterm=bold,underline ctermbg=none   ctermfg=5
   hi    htag_context   cterm=none           ctermbg=none   ctermfg=3
   hi    htag_detail    cterm=none           ctermbg=none   ctermfg=0
   hi    htag_tag       cterm=bold           ctermbg=none   ctermfg=4
   hi    htag_separator cterm=none           ctermbg=none   ctermfg=7
   retu  0
endf


""=[[ establish buffer specific key mapping ]]============[ leaf   [ 110n0x ]=##
func! HTAG_keys ()
   nmap           ,t  :call HTAG_show    (expand("<cword>"))<cr>
   nnor           ;;  :call HTAG_hints   ()<cr>
   nmap  <buffer> t   :call HTAG_update  ()<cr>
   nmap  <buffer> h   :call HTAG_hide    ()<cr>
   nmap  <buffer> d   :call HTAG_detail  ()<cr>
   " nmap  <buffer> s   :call HTAG_stats_full  ("r")<cr>
   " nmap  <buffer> S   :call HTAG_stats_full  ("w")<cr>
   " nmap  <buffer> f   :call HTAG_stats_full  ("f")<cr>
   " nmap  <buffer> c   :call HTAG_stats_full  ("c")<cr>
   retu
endf


""=[[ establish automatic updating strategy ]]============[ leaf   [ 110n0x ]=##
funct! HTAG_auto_on ()
   augr  HTAG
      auto  HTAG      BufEnter      * call HTAG_change ()
      auto  HTAG      BufRead       * call HTAG_change ()
      auto  HTAG      BufNewFile    * call HTAG_change ()
   augr  END
   retu
endf


""=[[ tuwn off automatic updating strategy ]]=============[ leaf   [ 110n0x ]=##
func! HTAG_auto_off ()
   auto! HTAG
   augr! HTAG
augr  END
retu
endf




""=========================-------------------------==========================##
""===----             standard window action fuctions (4)              ----===##
""=========================-------------------------==========================##
""  ...._on          :: display the window without entering it
""  ...._show        :: enter the window
""  ...._hide        :: take the window off the display
""  ...._resize      :: change the width/height of the window
func! s:o___STD_ACTIONS_____o ()
endf


"===[[ ROOT   ]]==> simplified interface for starting up vim from CLI w/"-c"
function! HTAG_on()
   call HTAG_show("")
   call HTAG_update()
endfunction


""=[[ display the tag window ]]===========================[ twig   [ 433y6s ]=##
func! HTAG_show (cword)
   ""---(locals)-----------+-----------+-##
   let   l:prefix    = "HTAG_show"
   let   l:rce       = -10
   ""---(defense : no recursion)---------##
   let   l:rce -= 1
   if    (g:HTAG_locked == "y")
      call  HALL_message (l:prefix, "htag is locked", l:rce)
      retu  l:rce
   endi
   ""---(save working win/buf/loc)-------##
   let   l:rce -= 1
   if    (HBUF_save ("HTAG_show()         :: ") < 1)
      call  HALL_message (l:prefix, "can't save current buffer", l:rce)
      retu  l:rce
   endi
   ""---(lock her down)------------------##
   let   g:hbuf_locked = "y"
   let   g:HTAG_locked = "y"
   let   g:HTAG_cword  = a:cword
   ""---(verify the buffer)--------------##
   let   l:tag_buf = bufnr (g:HTAG_title)
   if    (l:tag_buf < 1)
      call  HTAG_init ()
   endi
   ""---(close the existing window)------##
   let   l:tag_win = bufwinnr(l:tag_buf)
   if    (l:tag_win > 0)
      sil   exec l:tag_win.' wincmd w'
      hide
   endi
   ""---(position it properly)-----------##
   sil!  exec 'vert split '.g:HTAG_title
   vert  resize 20
   ""---(activate the repositioning)-----##
   call  HTAG_auto_on()
   ""---(set it up)----------------------##
   norm  zt
   ""---(let her go)---------------------##
   let   g:hbuf_locked = "n"
   let   g:HTAG_locked = "n"
   ""---(complete)-----------------------##
   call  HALL_message (l:prefix, "complete.", 0)
   retu  0
endf


"===[ LEAF   ]===> hide the window
function! HTAG_hide()
   "---> can only be called from inside the window
   call HTAG_auto_off()
   hide
   call HBUF_restore()
   return
endfunction



"==============================================================================#
"===----                              hints                             ----===#
"==============================================================================#

func! s:o___SPECIFIC________o()
endf




"===[ LEAF   ]===> get a two-char tag identifier from the user <===============#
function! HTAG_hint_input()
   echon   "enter tag text = "
   let    l:x_one = printf("%c", getchar())
   echon  l:x_one
   if (l:x_one < "a" || l:x_one > "z") && (l:x_one < "A" || l:x_one > "Z")
      echon "  (invalid character) user canceled..."
      return "--"
   endif
   let    l:x_two = printf("%c", getchar())
   echon  l:x_two
   if (l:x_two < "a" || l:x_two > "z") && (l:x_two < "A" || l:x_two > "Z")
      echon "  (invalid character) user canceled..."
      return "--"
   endif
   let    l:x_tag = l:x_one . l:x_two
   return l:x_tag
endfunction



"===[ PETAL  ]===> go directly to a tag based on its two-char identifier <=====#
function! HTAG_hints()       " PURPOSE : move to a specific hint/tag
   "---(save working win/buf/loc)----------------#
   echon "HTAG_hints()          :: "
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HTAG_hints()        :: ") < 1)
      return
   endif
   "---(get and vaidate the hint)-------------#
   let l:tag_id = HTAG_hint_input()
   if  l:tag_id == "--"
      return -1
   endif
   "---(identify the handler)-----------------#
   if    (match (l:tag_id, "[a-z][A-Za-z]") >= 0)
      echon "  (normal ctag) processing..."
   elsei (match (l:tag_id, "[A-L][A-Za-z]") >= 0)
      echon "  (HFIX/quickfix tag) processing..."
      call HFIX_hints(l:tag_id)
      return
   elsei (match (l:tag_id, "[M-Z][A-Za-z]") >= 0)
      echon "  (HCSC/cscope/grep tag) processing..."
      call HCSC_hints(l:tag_id)
      return
   endif
   "---(switch to tag window)-----------------#
   let    l:win_num = HBUF_by_name(g:HTAG_title)
   if (l:win_num != -1)
      silent exec l:win_num.' wincmd w'
   endif
   silent exec   ":norm  _"
   "---(find the tag)-------------------------#
   call   search("^" . l:tag_id . "  ","cW")
   if line(".") <= 1
      echon "  TAG NOT FOUND, exiting"
      call HBUF_restore()
      return
   endif
   let  l:full_line   = getline(".")
   call HTAG_parse()
   "---(highlight the tag)--------------------#
   silent exec "silent! syntax clear rsh_tag_identifier"
   silent exec "hi link rsh_tag_identifier function"
   silent exec "syntax match rsh_tag_identifier ' " . s:HTAG_iden . " ' containedin=ALL"
   "---(get back to the original window)------#
   let l:rc = HBUF_restore()
   if l:rc < 1
      return -1
   endif
   "---(get to the right buffer)--------------#
   if bufname('%') != s:HTAG_file
      let l:buf_num = bufnr(s:HTAG_file)
      if (l:buf_num == -1)
         echo "HTAG_hints() :: buffer (".s:HTAG_file.")not open in wim..."
         return
      else
         silent exec('b! ' . l:buf_num)
      endif
   endif
   "---(get to the right line)----------------# make sure to show comments above
   silent exec ":norm  _"
   "silent! exec ":normal ".(s:HTAG_line - 1). "j"
   silent! exec ":".s:HTAG_line
   if s:HTAG_type == "function"
      silent exec "normal {j"
   endif
   silent exec "normal zt"
   "---(complete)-----------------------------#
   return
endfunction



"==============================================================================#
"=======                             update                             =======#
"==============================================================================#



"===[ PETAL  ]===> adjust tag display when buffers change <====================#
function! HTAG_change()
   "---(do not allow recursion)------------------#
   if    (g:HTAG_locked == "y")
      retu
   endi
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HTAG_change()       :: ") < 1)
      return
   endif
   "---(find the tags window)--------------------#
   if (HBUF_by_name(g:HTAG_title) < 1)
      return
   endif
   "---(lock her down)---------------------------#
   let  g:hbuf_locked = "y"
   let  g:HTAG_locked = "y"
   silent! exec l:tag_win.' wincmd w'
   "---(go to the right place)-------------------"
   norm  _
   call search("^".g:hbuf_pname."[ ].*FILE$","cW")
   silent exec "normal zt"
   silent exec "normal zt"
   "---(go back to working win/buf/loc)----------#
   call HBUF_restore()
   "---(let her go)------------------------------#
   let  g:HTAG_locked = "n"
   let  g:hbuf_locked = "n"
   "---(complete)--------------------------------#
   return
endfunction



"===[ PETAL  ]===> create tag list for all active buffers <====================#
function! HTAG_update()
   "---(do not allow recursion)------------------#
   if (g:HTAG_locked == "y")
      retu
   endif
   "---(start locked code)-----------------------#
   let  g:hbuf_locked = "y"
   let  g:HTAG_locked = "y"
   "---(run)-------------------------------------#
   let  g:HTAG_times  += 1
   call HTAG_list_BUFSONLY()
   "---(unlock code)-----------------------------#
   let  g:HTAG_locked = "n"
   let  g:hbuf_locked = "n"
   "---(return to previous window)---------------#
   call HBUF_restore()
   "---(complete)--------------------------------#
   echon "HTAG_update()      :: complete."
   return
endfunction


""=[ branch ]=== create tag list for all active buffers ===========[ 433y6s ]=##
func! HTAG_list_BUFSONLY ()
   setl   modifiable
   sil!   exec ":!polymnia --htags > polymnia.htags"
   sil!   exec ":1,$delete"
   sil!   exec ":read polymnia.htags"
   sil!   norm _dd
   sil!   exec ":redraw!"
   setl   nomodifiable
   return
endfunction



"===[ PETAL  ]===> create tag list for all active buffers <====================#
function! HTAG_func_syn(base_name)
   "> start of next buffer entriies
   normal j
   let l:stop_line  = search("   FILE$", "W") - 1
   if l:stop_line == -1
      normal GG
      let  l:stop_line    = line('.')
   endif
   "---(find the functions)----------------------#
   silent! normal 'X
   let  l:curr_line = search("function (","W", l:stop_line)
   silent! exec "normal mX"
   if l:curr_line == 0
      return
   endif
   let  l:full_line    = getline('.')
   let  l:count        = matchstr(l:full_line, "(.*)")
   let  l:count        = strpart(l:count, 1, strlen(l:count) - 2 ) - 0
   let  l:curr         = 1
   let  l:rtag_iden    = " "
   let  l:rtag_list    = []
   while l:curr <= l:count
      silent! exec "normal 'X"
      exec "normal ".l:curr."j"
      let  l:full_line    = getline('.')
      if l:full_line == ""
         break
      endif
      "echo "HTAG_findloc()        :: parse (".l:curr.") ".l:full_line
      "sleep 1
      let  l:rtag_iden    = matchstr(l:full_line, "  #3#  .*  #4#  ")
      let  l:rtag_iden    = strpart(l:rtag_iden, 7, strlen(l:rtag_iden) - 14)
      "echo "HTAG_findloc()        :: parse (".l:curr.") ".l:rtag_iden
      "sleep 1
      let  l:rtag_list += [l:rtag_iden]
      let  l:curr = l:curr + 1
   endwhile
   "---(complete)--------------------------------#
   "echo "HTAG_findloc()        :: returning ".l:rtag_iden."..."
   "sleep 1
   let l:my_buf = bufnr('%')
   silent exec('b! ' . bufnr(a:base_name))
   "echo "HTAG_findloc()        :: moved from ".l:my_buf." to ".bufnr('%')
   "sleep 1
   execute 'silent! syntax clear rsh_tag_function'
   for  l:temp in l:rtag_list
      silent exec "syntax match rsh_tag_function '".l:temp."'"
      "echo "HTAG_findloc()        :: parsing ".l:temp."..."
      "sleep 1
   endfor
   "hi rsh_tag_function     cterm=bold ctermbg=none   ctermfg=5
   hi rsh_tag_function     cterm=bold ctermbg=6      ctermfg=4
   silent exec('b! '.l:my_buf)
   return
endfunction



function! HTAG_parse()
   "---(initialize)------------------------------#
   let  s:HTAG_tagn    = ""
   let  s:HTAG_iden    = ""
   let  s:HTAG_cats    = ""
   let  s:HTAG_file    = ""
   let  s:HTAG_line    = 0
   let  s:HTAG_desc    = 0
   "---(check for null)--------------------------#
   let  l:full_line = getline('.')
   if (l:full_line == "")
      return 0
   endif
   "---(parse polymnia output)-------------------#
   let  s:HTAG_tagn    = trim (strpart (l:full_line,   0,   2))
   let  s:HTAG_iden    = trim (strpart (l:full_line,   4,  25))
   let  s:HTAG_cats    = trim (strpart (l:full_line, 169,  76))
   let  s:HTAG_line    = trim (strpart (l:full_line, 248,   4))
   let  s:HTAG_file    = trim (strpart (l:full_line, 255,  25))
   let  s:HTAG_desc    = trim (strpart (l:full_line, 298,  40))
   return 1
endfunction



function! HTAG_head(file, type)
   "---(do not allow recursion)------------------#
   if (g:HTAG_locked == "y")
      return -2
   endif
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HTAG_head()         :: ") < 1)
      return -2
   endif
   "---(make sure tags are updated)--------------#
   normal ,tt
   "---(check for the window)--------------------#
   if (HBUF_by_name(g:HTAG_title) < 1)
      echon "HTAG_head()         :: tag window not showing..."
      return -2
   endif
   "---(get full tag range for buffer)-----------#
   norm  _
   let  l:start_line = search("^".a:file,"cW")
   if (l:start_line < 1)
      echon "HTAG_head()         :: could not file file entry for ".a:file." FATAL"
      return -1
   endif
   normal mX
   normal j
   let l:stop_line  = search("   FILE$", "W") - 1
   if l:stop_line == -1
      normal GG
      let  l:stop_line    = line('.')
   endif
   "---(find the functions)----------------------#
   normal 'X
   if (search("function (","W", l:stop_line) < 1)
      echon "HTAG_findloc()        :: no functions in file ".a:base_name."..."
      return 0
   endif
   let  l:full_line    = getline('.')
   let  l:count        = matchstr(l:full_line, "(.*)")
   let  l:count        = strpart(l:count, 1, strlen(l:count) - 2 ) - 0
   normal mX
   normal j
   call HTAG_parse()
   "---(save context)----------------------------#
   normal 'X
   let  s:HTAG_cfile   = a:file
   let  s:HTAG_ctype   = a:type
   let  s:HTAG_chead   = line('.')
   let  s:HTAG_ccount  = l:count
   let  s:HTAG_ccurr   = 1
   "---(complete)--------------------------------#
   call HBUF_restore()
   return s:HTAG_chead
endfunction



function! HTAG_curr()
   echo "file=".s:HTAG_cfile.", type=".s:HTAG_ctype.", head=".s:HTAG_chead.", count=".s:HTAG_ccount.", curr=".s:HTAG_ccurr
   return
endfunction


"==[[ create tag list for all active buffers ]]====================[ 433y6s ]==#
func! HTAG_next ()
   "---(do not allow recursion)------------------#
   if    (g:HTAG_locked == "y")
      retu  -2
   endi
   "---(verify position in range)----------------#
   if    (s:HTAG_ccurr >= s:HTAG_ccount)
      retu  -1
   endi
   "---(save working win/buf/loc)----------------#
   if    (HBUF_save("HTAG_head()         :: ") < 1)
      retu  -2
   endi
   "---(check for the window)--------------------#
   if    (HBUF_by_name(g:HTAG_title) < 1)
      echon "HTAG_head()         :: tag window not showing..."
      retu  -2
   endi
   "---(get full tag range for buffer)-----------#
   let   s:HTAG_ccurr += 1
   norm  _
   exec  "normal ".s:HTAG_chead."G"
   exec  "normal ".s:HTAG_ccurr."j"
   call  HTAG_parse()
   "---(complete)--------------------------------#
   call  HBUF_restore()
   retu  s:HTAG_chead
endf



function! HTAG_findloc(base_name, line_num)
   "echo "was curnum=".bufnr("%").", which is <<".bufname("%").">>"
   let   rc = HBUF_by_name(g:HTAG_title)
   if    rc < 1
      return "[--] <<no tags>>"
   endi
   "echo "now curnum=".bufnr("%").", which is <<".bufname("%").">>"
   "---(get full tag range for buffer)-----------#
   "> start of buffer entries
   norm  _
   "echo "<<".a:base_name.">>"
   let  l:start_line = search("^".a:base_name,"cW")
   "echo start_line
   if (l:start_line < 1)
      return "[--] n/a       "
   endif
   silent! exec "normal mX"
   "> start of next buffer entriies
   normal j
   let l:stop_line  = search("   FILE$", "W") - 1
   "echo stop_line
   if l:stop_line == -1
      normal GG
      let  l:stop_line    = line('.')
   endif
   "---(find the functions)----------------------#
   silent! exec "normal 'X"
   let  l:curr_line = search("function (","W", l:stop_line)
   silent! exec "normal mX"
   if l:curr_line == 0
      "echon "HTAG_findloc()        :: no functions in file ".a:base_name."..."
      return "[--] <<global>>"
   endif
   let  l:full_line    = getline('.')
   let  l:count        = matchstr(l:full_line, "(.*)")
   let  l:count        = strpart(l:count, 1, strlen(l:count) - 2 ) - 0
   let  l:curr         = 1
   let  l:rtag_iden    = " "
   let  l:rtag_final   = "[--] <<global>>"
   while l:curr <= l:count
      silent! exec "normal 'X"
      exec "normal ".l:curr."j"
      if (HTAG_parse() < 1)
         break
      endif
      if s:HTAG_line > a:line_num
         break
      endif
      let  l:rtag_final   = "[".s:HTAG_tagn."] ".s:HTAG_iden
      let  l:curr = l:curr + 1
   endwhile
   "---(complete)--------------------------------#
   "echo "done"
   return l:rtag_final
endf



call HTAG_init()
""===[[ END ]]=================================================================#
