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
let g:HTAG_title    = "HTAG_buffer"
let g:HTAG_locked   = "n"
let g:HTAG_times    = 0
let g:HTAG_cword    = "---"

"---(current tag)--------------------------------#
let s:HTAG_tagn     = ""
let s:HTAG_line     = 0
let s:HTAG_file     = ""
let s:HTAG_type     = ""
let s:HTAG_stat     = ""
let s:HTAG_class    = ""
let s:HTAG_iden     = ""

"---(function cursor)----------------------------#
let s:HTAG_cfile    = 0
let s:HTAG_ctype    = 0
let s:HTAG_chead    = 0
let s:HTAG_ccount   = 0
let s:HTAG_ccurr    = 0

""---(stats processing)---------------""
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
   setl  nomodifiable
   hide
   retu  0
endf


""=[[ establish syntax highlighting ]]====================[ leaf   [ 210n0x ]=##
func! HTAG_syntax ()
   synt  clear
   synt  match htag_file           '^[A-Za-z0-9_.-]\+[ ]\+FILE'
   synt  match htag_major          '^[a-z].*[ ]([0-9]\+)$'
   synt  match htag_context        '^  [a-z][a-z/][a-z] [=].*'
   synt  match htag_detail         '^[a-z-][a-z-]  [a-zA-Z][a-zA-Z0-9_].*'
   synt  match htag_tag            '^[a-z-][a-zA-Z-0#]  '   containedin=rsh_tag_detail
   synt  match htag_separator      'o___[A-Z_].*___'        containedin=rsh_tab_detail
   hi    htag_file      cterm=reverse,bold   ctermbg=none   ctermfg=5
   hi    htag_major     cterm=bold,underline ctermbg=none   ctermfg=5
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
   nmap  <buffer> s   :call HTAG_stats_full  ("r")<cr>
   nmap  <buffer> S   :call HTAG_stats_full  ("w")<cr>
   nmap  <buffer> f   :call HTAG_stats_full  ("f")<cr>
   nmap  <buffer> c   :call HTAG_stats_full  ("c")<cr>
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
         echo "HTAG_hints() :: buffer not open in wim..."
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
   ""---(prepare locals)-----------------##
   let    l:g_hint_major = 1
   let    l:g_hint_minor = 0
   let    l:g_total      = 0
   let    l:g_empty      = 0
   let    l:g_comment    = 0
   let    l:g_debugging  = 0
   let    l:g_code       = 0
   let    l:g_slocl      = 0
   ""---(clear out existing contents)-----#
   setl   modifiable
   sil    exec ":1,$delete"
   setl   nomodifiable
   "---(get the grand totals first)-------#
   let    l:i = HBUF_next (0)              " buffer index
   while  (l:i > 0)
      ""---(clear it out)----------------##
      setl  modifiable
      sil   exec ":1,$delete"
      ""---(get the file name)-----------##
      let   l:full_name = bufname (l:i)
      let   l:base_loc  = match   (l:full_name, "[A-Za-z0-9_.]*$")
      let   l:base_name = strpart (l:full_name, l:base_loc)
      let   l:ext_loc   = match   (l:full_name, "[.][A-Za-z0-9_]*$")
      let   l:ext_name  = strpart (l:full_name, l:ext_loc)
      ""---(collect data)----------------##
      sil!  exec   ".:!cat ".l:full_name." | wc -l"
      let   total  =getline('.')
      sil!  exec   ".:!grep \"^[ ]*$\" ".l:full_name." | wc -l"
      let   empty  =getline('.')
      "---(grand totals)-----------------#
      let   g_total     += total
      let   g_empty     += empty
      ""---(skip non-c files)------------##
      if (l:ext_name != ".c" && l:ext_name != ".h")
         setl  nomodifiable
         let l:i = HBUF_next(l:i)            " buffer index
         continue
      endi
      ""---(collect data)----------------##
      sil!  exec   ".:!grep \"^[ ]*[\/][*]\" ".l:full_name." | wc -l"
      let   comm1  =getline('.')
      sil!  exec   ".:!grep \"^[ ]*[*]\" ".l:full_name." | wc -l"
      let   comm2  =getline('.')
      sil!  exec   ".:!grep \"^[ ]*DEBUG_\" ".l:full_name." | wc -l"
      let   debug  =getline('.')
      sil!  exec   ".:!grep \"^[ ]*DEBUG_.*yLOG_\" ".l:full_name." | wc -l"
      let   dlogs  =getline('.')
      sil!  exec   ".:!grep \"yLOG_\" ".l:full_name." | wc -l"
      let   ylogs  =getline('.')
      ""---(slocl)-----------------------""
      sil!  exec   ".:!cat ".l:full_name." | tr -cd \";\" | wc -c"
      let   slocl  =getline('.')
      ""---(calculate stats)-------------##
      let   debugging    = dlogs + (ylogs - dlogs) + (debug - dlogs)
      let   code         = total - empty - comm1 - comm2 - debugging
      let   slocl       -= debugging
      "---(grand totals)----------------#
      let   g_comment   += (comm1 + comm2)
      let   g_debugging += debugging
      let   g_code      += code
      let   g_slocl     += slocl
      "---(next)------------------------#
      let   l:i = HBUF_next(l:i)            " buffer index
   endwhile
   ""---(clear out existing contents)------------#
   setl   modifiable
   sil    exec ":1,$delete"
   setl   nomodifiable
   "---(loop through the valid buffers)----------#
   let    l:i = HBUF_next (0)              " buffer index
   while  (l:i > 0)
      ""---(get the file name)-----------##
      let   l:full_name = bufname (l:i)
      let   l:base_loc  = match   (l:full_name, "[A-Za-z0-9_.]*$")
      let   l:base_name = strpart (l:full_name, l:base_loc)
      let   l:ext_loc   = match   (l:full_name, "[.][A-Za-z0-9_]*$")
      let   l:ext_name  = strpart (l:full_name, l:ext_loc)
      ""---(message to console)----------##
      echon "HTAG_list()           :: processing ".l:base_name."..."
      ""---(mark the start of new file)--##
      setl  modifiable
      norm  GG
      sil!  normal mX
      ""---(run the tags)----------------##
      ""sil!  exec "$:!ctags -x --sort=no --c-kinds=cdefgnpstuvx --c++-kinds=cdefgnpstuvx --file-scope=yes ".l:full_name
      sil!  exec "$:!ctags -x --sort=no --file-scope=yes ".l:full_name
      "---(go back and awk them)--------#
      sil!  normal 'X
      sil!  exec ":silent! .,$!HTAG.awk 'g_hint_major=".l:g_hint_major."' 'g_hint_minor=".l:g_hint_minor."' 'g_file_name=".l:base_name."'"
      ""---(count total lines)-----------##
      sil!  normal 'X
      sil!  exec   "norm o"
      sil!  exec   ".:!cat ".l:full_name." | wc -l"
      let   total=getline('.')
      sil!  exec   "norm ddk"
      sil!  exec   "norm olines :".printf ("%5d %6d", total, g_total)
      ""---(count blank lines)-----------##
      sil!  exec   "norm o"
      sil!  exec   ".:!grep \"^[ ]*$\" ".l:full_name." | wc -l"
      let   empty=getline('.')
      sil!  exec   "norm ddk"
      sil!  exec   "norm oempty :".printf ("%5d %6d", empty, g_empty)
      ""---(skip non-c files)------------##
      if (l:ext_name != ".c" && l:ext_name != ".h")
         sil!  exec   "norm odocs  :  --- ".printf ("%6d", g_comment)
         sil!  exec   "norm odebug :  --- ".printf ("%6d", g_debugging)
         sil!  exec   "norm ocode  :  --- ".printf ("%6d", g_code)
         sil!  exec   "norm oslocl :  --- ".printf ("%6d", g_slocl)
         "---(collect the 'last tag')------#
         norm  GG
         let   l:g_hint_minor = getline('.')
         norm  Dk
         let   l:g_hint_major = getline('.')
         norm  D
         setl  nomodifiable
         let l:i = HBUF_next(l:i)            " buffer index
         continue
      endi
      ""---(count c-comment begin)-------##
      sil!  exec   "norm o"
      sil!  exec   ".:!grep \"^[ ]*[\/][*]\" ".l:full_name." | wc -l"
      let   comm1=getline('.')
      sil!  exec   "norm ddk"
      ""---(count c-comment continue)----##
      sil!  exec   "norm o"
      sil!  exec   ".:!grep \"^[ ]*[*]\" ".l:full_name." | wc -l"
      let   comm2=getline('.')
      sil!  exec   "norm ddk"
      ""---(write total comments)--------##
      sil!  exec   "norm odocs  :".printf ("%5d %6d", comm1 + comm2, g_comment)
      ""---(count debug lines)-----------##
      sil!  exec   "norm o"
      sil!  exec   ".:!grep \"^[ ]*DEBUG_\" ".l:full_name." | wc -l"
      let   debug=getline('.')
      sil!  exec   "norm ddk"
      ""---(count log lines)-------------##
      sil!  exec   "norm o"
      sil!  exec   ".:!grep \"^[ ]*DEBUG_.*yLOG_\" ".l:full_name." | wc -l"
      let   dlogs=getline('.')
      sil!  exec   "norm ddk"
      ""---(count log lines)-------------##
      sil!  exec   "norm o"
      sil!  exec   ".:!grep \"yLOG_\" ".l:full_name." | wc -l"
      let   ylogs=getline('.')
      sil!  exec   "norm ddk"
      let   l:debugging= (dlogs + (ylogs - dlogs) + (debug - dlogs))
      sil!  exec   "norm odebug :".printf ("%5d %6d", debugging, g_debugging)
      ""---(write code total)------------##
      sil!  exec   "norm ocode  :".printf ("%5d %6d", ( total - empty - comm1 - comm2 - debugging), g_code)
      ""---(write sloc total)------------##
      sil!  exec   "norm o"
      sil!  exec   ".:!grep \";\" ".l:full_name." | wc -l"
      let   slocl=getline('.')
      sil!  exec   "norm ddk"
      sil!  exec   "norm oslocl :".printf ("%5d %6d", slocl + debugging, g_slocl)
      "---(collect the 'last tag')------#
      norm  GG
      let   l:g_hint_minor = getline('.')
      norm  Dk
      let   l:g_hint_major = getline('.')
      norm  D
      setl  nomodifiable
      "---(prep next)-------------------#
      let l:i = HBUF_next(l:i)            " buffer index
   endwhile
   norm  _
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
   let  s:HTAG_line    = 0
   let  s:HTAG_file    = ""
   let  s:HTAG_type    = ""
   let  s:HTAG_stat    = ""
   let  s:HTAG_iden    = ""
   let  s:HTAG_iden    = ""
   "---(check for null)--------------------------#
   let  l:full_line = getline('.')
   if (l:full_line == "")
      return 0
   endif
   "---(tag number)------------------------------#
   let  s:HTAG_tagn    = strpart    (l:full_line, 0, 2)
   "---(line number)-----------------------------#
   let  s:HTAG_line    = matchstr   (l:full_line, "  #1#  .*  #2#  ")
   let  s:HTAG_line    = substitute (strpart (s:HTAG_line , 7, strlen (s:HTAG_line ) - 14), " ", "", "g")
   "---(file name)-------------------------------#
   let  s:HTAG_file    = matchstr   (l:full_line, "  #2#  .*  #3#  ")
   let  s:HTAG_file    = substitute (strpart (s:HTAG_file , 7, strlen (s:HTAG_file ) - 14), " ", "", "g")
   "---(tag type)--------------------------------#
   let  s:HTAG_type    = matchstr   (l:full_line, "  #3#  .*  #4#  ")
   let  s:HTAG_type    = substitute (strpart (s:HTAG_type , 7, strlen (s:HTAG_type ) - 14), " ", "", "g")
   "---(statistics)------------------------------#
   let  s:HTAG_stat    = matchstr   (l:full_line, "  #4#  .*  #5#  ")
   let  s:HTAG_stat    = substitute (strpart (s:HTAG_stat , 7, strlen (s:HTAG_stat ) - 14), " ", "", "g")
   "---(class)-----------------------------------#
   let  s:HTAG_class   = matchstr   (l:full_line, "  #5#  .*  #6#  ")
   let  s:HTAG_class   = substitute (strpart (s:HTAG_class, 7, strlen (s:HTAG_class) - 14), " ", "", "g")
   "---(identifier)------------------------------#
   let  s:HTAG_iden    = matchstr   (l:full_line, "  #6#  .*  #7#  ")
   let  s:HTAG_iden    = substitute (strpart (s:HTAG_iden , 7, strlen (s:HTAG_iden ) - 14), " ", "", "g")
   "---(complete)--------------------------------#
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

let   s:HTAG_shead    = "-"
let   s:HTAG_sprefix  = ""
let   s:HTAG_stitle   = ""
let   s:HTAG_sclass   = ""
let   s:HTAG_sscope   = "-"
let   s:HTAG_srv      = "-"
let   s:HTAG_stsize   = "-"
let   s:HTAG_sssize   = "-"
let   s:HTAG_sdsize   = "-"
let   s:HTAG_srsize   = "-"
let   s:HTAG_spsize   = "-"
let   s:HTAG_scsize   = "-"
let   s:HTAG_smsize   = "-"
let   s:HTAG_snsize   = "-"
let   s:HTAG_sosize   = "-"
let   s:HTAG_sgsize   = "-"
let   s:HTAG_s0size   = "-"
let   s:HTAG_slsize   = "-"
let   s:HTAG_sfsize   = "-"
let   s:HTAG_sisize   = "-"
let   s:HTAG_sGsize   = "-"
let   s:HTAG_sLsize   = "-"
let   s:HTAG_sDsize   = "-"
let   s:HTAG_sUsize   = "-"
let   s:HTAG_sadjust  = 0

func HTAG_stats_prep  ()
   let   s:HTAG_shead    = "-"
   let   s:HTAG_sprefix  = ""
   let   s:HTAG_stitle   = ""
   let   s:HTAG_sclass   = ""
   let   s:HTAG_sscope   = "-"
   let   s:HTAG_srv      = "-"
   let   s:HTAG_stsize   = "-"
   let   s:HTAG_sssize   = "-"
   let   s:HTAG_sdsize   = "-"
   let   s:HTAG_srsize   = "-"
   let   s:HTAG_spsize   = "-"
   let   s:HTAG_scsize   = "-"
   let   s:HTAG_smsize   = "-"
   let   s:HTAG_snsize   = "-"
   let   s:HTAG_sosize   = "-"
   let   s:HTAG_sgsize   = "-"
   let   s:HTAG_s0size   = "-"
   let   s:HTAG_slsize   = "-"
   let   s:HTAG_sfsize   = "-"
   let   s:HTAG_sisize   = "-"
   let   s:HTAG_sGsize   = "-"
   let   s:HTAG_sLsize   = "-"
   let   s:HTAG_sDsize   = "-"
   let   s:HTAG_sUsize   = "-"
   retu  0
endf

func HTAG_stats_check ()
   let   l:type   = getline('.')
   if    (strpart (l:type, 77, 3) != "]*/")
      echon "-1"
      retu  -1
   endif
   if    (strpart (l:type, 62, 2) != " [")
      echon "-2"
      retu  -2
   endif
   if    (strpart (l:type, 53, 3) != "-[ ")
      echon "-3"
      retu  -3
   endif
   if    (strpart (l:type, 12, 6) != " /*-> ")
      echon "-4"
      retu  -4
   endif
   retu  0
endf

func HTAG_stats_head_srp  ()
   ""---(check function)-----------------""
   exec  "norm ".(s:HTAG_line + s:HTAG_sadjust)."G"
   redraw!
   let   l:recd  = getline('.')
   if    (match (l:recd, s:HTAG_iden) != 0)
      retu  0
   endi
   ""---(verify space)-------------------""
   norm  kk
   let   l:space = getline('.')
   if    (l:space != "")
      norm  o
      let   s:HTAG_sadjust  += 1
   endi
   norm  j
   "---(mark top)----------------------#
   norm  mY
   let   l:beg    = line (".")
   let   l:type   = getline('.')
   "---(determine header quality)------#
   let   s:HTAG_shead   = "y"
   if    (HTAG_stats_check () < 0)
      let   s:HTAG_shead   = "-"
   endi
   "---(determine title)---------------#
   let   l:loc1   = match (l:type, "/[*]")
   if    (l:loc1 >= 0)
      let   s:HTAG_sprefix = strpart (l:type, 0, l:loc1 - 1)
      let   l:loc1   = match   (l:type, "[A-Za-z0-9]", l:loc1 + 1)
      let   l:loc2   = match   (l:type, "--", l:loc1 + 1) - 1
      let   l:len    = l:loc2 - l:loc1
      if    (l:len > 33)
         let   l:len = 33
      endi
      let   s:HTAG_stitle  = strpart (l:type, l:loc1, l:len)
   else
      let   s:HTAG_shead   = "r"
      let   s:HTAG_sprefix = strpart (l:type , 0, 12)
   endi
   "---(determine scope)---------------#
   if    (match (s:HTAG_iden, "__unit") >  0)
      let   s:HTAG_sscope  = "u"
   elsei (match (s:HTAG_iden, "__test") >  0)
      let   s:HTAG_sscope  = "u"
   elsei (match (s:HTAG_iden, "__"    ) >  0)
      let   s:HTAG_sscope  = "f"
   elsei (match (l:type, "static")      == 0)
      let   s:HTAG_sscope  = "s"
   else
      let   s:HTAG_sscope  = "g"
   endi
   "---(determine type)----------------#
   if    (match (s:HTAG_sprefix, "char[*]")     >= 0)
      let   s:HTAG_srv     = "s"
   elsei (match (s:HTAG_sprefix, "char" )       >= 0)
      let   s:HTAG_srv     = "c"
   elsei (match (s:HTAG_sprefix, "void" )       >= 0)
      let   s:HTAG_srv     = "v"
   elsei (match (s:HTAG_sprefix, "[*]")         >= 0)
      let   s:HTAG_srv     = "p"
   else
      let   s:HTAG_srv     = "n"
   endi
   "---(count params)------------------#
   let   l:parms = len (split (l:recd, "\,")) - 1
   if    (match (l:recd, "()") >  0)
      let   s:HTAG_spsize = "0"
   elsei (match (l:recd, "(void)") >  0)
      let   s:HTAG_spsize = "0"
   elsei (l:parms > 9)
      let   s:HTAG_spsize = "#"
   else
      let   s:HTAG_spsize = l:parms + 1
   endi
   "---(mark bot)----------------------#
   let   l:end = search ("^}$", "eW")
   exec  "norm ".l:end."G"
   norm  mZ
   "---(get to blank above function)---#
   exec  "norm ".l:beg."G"
   norm  k
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_size_tsd  ()
   ""---(defense)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endi
   ""---(locals)-------------------""
   let   l:file    = "HTAG.c"
   ""---(write function out)-------------""
   sil!  exec  ":'Y,'Zwrite! ".l:file
   ""---(total size)---------------------""
   sil!  exec   ".:!cat ".l:file." | wc -l"
   let   l:total  = getline('.')
   sil!  exec   ".:!grep \"^[ ]*$\" ".l:file." | wc -l"
   let   l:empty  = getline('.')
   if    (l:total >= 180)
      let   s:HTAG_stsize = "#"
   elsei (l:total <=   0)
      let   s:HTAG_stsize = "0"
   else
      let   s:HTAG_stsize = strpart ("123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:total / 5, 1)
   endi
   ""---(comments)-----------------------""
   sil!  exec   ".:!grep \"^[ ]*[\/][*]\" ".l:file." | wc -l"
   let   l:comm1  = getline('.')
   sil!  exec   ".:!grep \"^[ ]*[*] \" ".l:file." | wc -l"
   let   l:comm2  = getline('.')
   let   l:comms  = l:comm1 + l:comm2 + l:empty
   ""---(debugging)----------------------""
   sil!  exec   ".:!grep \"^[ ]*DEBUG_\" ".l:file." | wc -l"
   let   l:yurg   = getline('.')
   sil!  exec   ".:!grep \"^[ ]*DEBUG_.*yLOG_\" ".l:file." | wc -l"
   let   l:dlogs  = getline('.')
   sil!  exec   ".:!grep \"yLOG_\" ".l:file." | wc -l"
   let   l:ylogs  = getline('.')
   let   l:debug  = l:dlogs + (l:ylogs - l:dlogs) + (l:yurg - l:dlogs)
   if    (l:debug >= 180)
      let   s:HTAG_sdsize = "#"
   elsei (l:debug <=   0)
      let   s:HTAG_sdsize = "0"
   else
      let   s:HTAG_sdsize = strpart ("123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:debug  / 5, 1)
   endi
   ""---(slocl)--------------------------""
   sil!  exec   ".:!cat ".l:file." | tr -cd \";\" | wc -c"
   let   l:colon  = getline('.')
   let   l:code   = l:total - l:comms - l:debug
   let   l:slocl  = l:colon - l:debug
   if    (l:slocl >= 180)
      let   s:HTAG_sssize = "#"
   elsei (l:slocl <=   0)
      let   s:HTAG_sssize = "0"
   else
      let   s:HTAG_sssize = strpart ("123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:slocl  / 5, 1)
   endi
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_stat_rlf   ()
   ""---(defense)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endi
   ""---(locals)-------------------""
   let   l:file    = "HTAG.c"
   ""---(returns)------------------""
   sil!  exec   ".:!grep \" return \" ".l:file." | wc -l"
   let   l:retns  = getline('.')
   sil!  exec   ".:!grep \" rce \" ".l:file." | wc -l"
   let   l:rced   = getline('.')
   sil!  exec   ".:!grep \" return rce;\" ".l:file." | wc -l"
   let   l:rces   = getline('.')
   sil!  exec   ".:!grep \" return -(rce);\" ".l:file." | wc -l"
   let   l:rcesn  = getline('.')
   sil!  exec   ".:!grep \" return [0-9-]*;\" ".l:file." | wc -l"
   let   l:retn2  = getline('.')
   sil!  exec   ".:!grep \" return 0;\" ".l:file." | wc -l"
   let   l:retnz  = getline('.')
   if    (s:HTAG_srv  == "c")
      if    (l:rces  > 0)
         let   s:HTAG_srv     = "e"
      elsei (l:rcesn > 0)
         let   s:HTAG_srv     = "e"
      elsei (l:rced  > 0)
         let   s:HTAG_srv     = "e"
      elsei (l:retns == 1 && l:retnz == 1)
         let   s:HTAG_srv     = "z"
      endi
   endi
   if    (l:retns == 0)
      let   s:HTAG_srsize = "0"
   elsei (l:retns >  9)
      let   s:HTAG_srsize = "#"
   else
      let   s:HTAG_srsize = l:retns
   endi
   ""---(locals)-------------------""
   sil!  exec   ".:!ctags -x --sort=no --c-kinds=l ".l:file." | wc -l"
   let   l:local  = getline('.')
   if    (l:local >= 36)
      let   s:HTAG_slsize = "#"
   elsei (l:local <=   0)
      let   s:HTAG_slsize = "0"
   else
      let   s:HTAG_slsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:local, 1)
   endi
   ""---(func calls)---------------""
   sil!  exec   ".:!cflow -d 2 ".l:file." | wc -l"
   let   l:funca  = getline('.')
   sil!  exec   ".:!cflow -d 2 ".l:file." | grep \"^[ ]*y\" | wc -l"
   let   l:funcl  = getline('.')
   sil!  exec   ".:!cflow -d 2 ".l:file." | grep \"^[ ]*yLOG\" | wc -l"
   let   l:funcd  = getline('.')
   sil!  exec   ".:!cflow -d 2 ".l:file." | grep \"^[ ]*[a-xz]\" | wc -l"
   let   l:funcc  = getline('.')
   let   l:funcs  = l:funca - l:funcd -l:funcc - 1
   if    (l:funcs >= 36)
      let   s:HTAG_sfsize = "#"
   elsei (l:funcs <=   0)
      let   s:HTAG_sfsize = "0"
   else
      let   s:HTAG_sfsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:funcs, 1)
   endi
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_stat_cmi   ()
   ""---(defense)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endi
   ""---(locals)-------------------""
   let   l:file    = "HTAG.c"
   ""---(decisions)----------------""
   sil!  exec   ".:!grep \" if[ ]*(\" ".l:file." | wc -l"
   let   l:cif    = getline('.')
   sil!  exec   ".:!grep \" else[ ]*if[ ]*(\" ".l:file." | wc -l"
   let   l:celif  = getline('.')
   sil!  exec   ".:!grep \" else \" ".l:file." | wc -l"
   let   l:celse  = getline('.')
   sil!  exec   ".:!grep \" switch[ ]*(\" ".l:file." | wc -l"
   let   l:cswi   = getline('.')
   sil!  exec   ".:!grep \" while[ ]*(\" ".l:file." | wc -l"
   let   l:cwhi   = getline('.')
   let   l:choos  = l:cif + (l:celse - l:celif) + l:cswi + l:cwhi
   if    (l:choos >= 36)
      let   s:HTAG_scsize = "#"
   elsei (l:choos <=   0)
      let   s:HTAG_scsize = "0"
   else
      let   s:HTAG_scsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:choos, 1)
   endi
   ""---(memory)-------------------""
   sil!  exec   ".:!grep \" free[ ]*(\" ".l:file." | wc -l"
   let   l:mfree  = getline('.')
   sil!  exec   ".:!grep \" malloc[ ]*(\" ".l:file." | wc -l"
   let   l:mmall  = getline('.')
   sil!  exec   ".:!grep \" cmalloc[ ]*(\" ".l:file." | wc -l"
   let   l:mcmall = getline('.')
   sil!  exec   ".:!grep \" malloca[ ]*(\" ".l:file." | wc -l"
   let   l:mamall = getline('.')
   let   l:mem    = l:mfree + l:mmall + l:mcmall + l:mamall
   if    (l:mem   >= 36)
      let   s:HTAG_smsize = "#"
   elsei (l:mem   <=   0)
      let   s:HTAG_smsize = "0"
   else
      let   s:HTAG_smsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:mem  , 1)
   endi
   ""---(indent)-------------------""
   let   s:HTAG_sisize = 0
   sil!  exec   ".:!grep \"^      \" ".l:file." | wc -l"
   let   l:inden = getline('.')
   if    (l:inden > 0)
      let   s:HTAG_sisize = 1
   endi
   sil!  exec   ".:!grep \"^         \" ".l:file." | wc -l"
   let   l:inden = getline('.')
   if    (l:inden > 0)
      let   s:HTAG_sisize = 2
   endi
   sil!  exec   ".:!grep \"^            \" ".l:file." | wc -l"
   let   l:inden = getline('.')
   if    (l:inden > 0)
      let   s:HTAG_sisize = 3
   endi
   sil!  exec   ".:!grep \"^               \" ".l:file." | wc -l"
   let   l:inden = getline('.')
   if    (l:inden > 0)
      let   s:HTAG_sisize = 4
   endi
   sil!  exec   ".:!grep \"^                  \" ".l:file." | wc -l"
   let   l:inden = getline('.')
   if    (l:inden > 0)
      let   s:HTAG_sisize = 5
   endi
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_stat_nog0  ()
   ""---(defense)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endi
   ""---(locals)-------------------""
   let   l:file    = "HTAG.c"
   ""---(ncurses output)-----------""
   sil!  exec   ".:!grep \" mvprintw[ ]*(\" ".l:file." | wc -l"
   let   l:ncursp = getline('.')
   sil!  exec   ".:!grep \" attr(set\|on\|off)[ ]*(\" ".l:file." | wc -l"
   let   l:ncursa = getline('.')
   let   l:ncurse = l:ncursp + l:ncursa
   if    (l:ncurse >= 36)
      let   s:HTAG_snsize = "#"
   elsei (l:ncurse <=   0)
      let   s:HTAG_snsize = "0"
   else
      let   s:HTAG_snsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:ncurse  , 1)
   endi
   ""---(normal output)------------""
   sil!  exec   ".:!grep \" printf[ ]*(\" ".l:file." | wc -l"
   let   l:outp   = getline('.')
   sil!  exec   ".:!grep \" fprintf[ ]*(\" ".l:file." | wc -l"
   let   l:outf   = getline('.')
   sil!  exec   ".:!grep \" write[ ]*(\" ".l:file." | wc -l"
   let   l:outw   = getline('.')
   sil!  exec   ".:!grep \" fwrite[ ]*(\" ".l:file." | wc -l"
   let   l:outw2  = getline('.')
   let   l:output = l:outp + l:outf + l:outw + l:outw2
   if    (l:ncurse >= 36)
      let   s:HTAG_sosize = "#"
   elsei (l:ncurse <=   0)
      let   s:HTAG_sosize = "0"
   else
      let   s:HTAG_sosize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:output  , 1)
   endi
   ""---(opengl output)------------""
   sil!  exec   ".:!grep \" glVertex[23]f[ ]*(\" ".l:file." | wc -l"
   let   l:openv  = getline('.')
   sil!  exec   ".:!grep \" yFONT_print[ ]*(\" ".l:file." | wc -l"
   let   l:openf  = getline('.')
   let   l:opengl = l:openv + l:openf
   if    (l:opengl >= 36)
      let   s:HTAG_sgsize = "#"
   elsei (l:opengl <=   0)
      let   s:HTAG_sgsize = "0"
   else
      let   s:HTAG_sgsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:opengl  , 1)
   endi
   ""---(reading input)------------""
   sil!  exec   ".:!grep \" fgets[ ]*(\" ".l:file." | wc -l"
   let   l:readf  = getline('.')
   sil!  exec   ".:!grep \" scanf[ ]*(\" ".l:file." | wc -l"
   let   l:reads  = getline('.')
   sil!  exec   ".:!grep \" read[ ]*(\" ".l:file." | wc -l"
   let   l:readr  = getline('.')
   sil!  exec   ".:!grep \" fread[ ]*(\" ".l:file." | wc -l"
   let   l:readr2 = getline('.')
   sil!  exec   ".:!grep \" getch[ ]*(\" ".l:file." | wc -l"
   let   l:readn  = getline('.')
   let   l:read   = l:readf + l:reads + l:readr + l:readr2 + l:readn
   if    (l:read   >= 36)
      let   s:HTAG_s0size = "#"
   elsei (l:read   <=   0)
      let   s:HTAG_s0size = "0"
   else
      let   s:HTAG_s0size = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:read    , 1)
   endi
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_stat_GLD   ()
   ""---(defense)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endi
   ""---(locals)-------------------""
   let   l:file    = "HTAG.c"
   ""---(callers)------------------""
   sil!  exec   ".:!HTAG_call.awk -v g_func=".s:HTAG_iden." < HTAG.lcalls"
   let   l:lcalls = getline('.')
   if    (l:lcalls  >= 36)
      let   s:HTAG_sLsize = "#"
   elsei (l:lcalls  <=   0)
      let   s:HTAG_sLsize = "0"
   else
      let   s:HTAG_sLsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:lcalls   , 1)
   endi
   sil!  exec   ".:!HTAG_call.awk -v g_func=".s:HTAG_iden." < HTAG.gcalls"
   let   l:gcalls = getline('.') - l:lcalls
   if    (l:gcalls  >= 36)
      let   s:HTAG_sGsize = "#"
   elsei (l:gcalls  <=   0)
      let   s:HTAG_sGsize = "0"
   else
      let   s:HTAG_sGsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:gcalls   , 1)
   endi
   ""---(call depth)---------------""
   sil!  exec   ":!grep \"".s:HTAG_iden."\" HTAG.flow > HTAG.mydepth"
   let   l:prefix         = ""
   let   l:level          =  0
   let   l:depth          = -1
   while (l:depth < 0 && l:level < 36)
      sil!  exec   ".:!grep \"^".l:prefix.s:HTAG_iden."\" HTAG.mydepth | wc -l"
      let   l:inden = getline('.')
      if    (l:inden > 0)
         let   l:depth = l:level
      endi
      let   l:level  += 1
      let   l:prefix  = printf ("%s    ", l:prefix)
   endw
   if    (l:depth   <   0)
      let   s:HTAG_sDsize = "#"
   else
      let   s:HTAG_sDsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:depth    , 1)
   endi
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_stat_U     ()
   ""---(defense)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endi
   ""---(unit test)----------------""
   let   s:HTAG_sUsize = "!"
   sil!  exec   ".:!ls *.unit 2> /dev/null | wc -l"
   let   l:units  = getline('.')
   if    (l:units > 0)
      let   l:target    = printf (" %-20.20s ", s:HTAG_iden)
      sil!  exec   ".:!grep \"".l:target."\" *.unit | wc -l"
      let   l:units  = getline('.')
      if    (l:units   >= 36)
         let   s:HTAG_sUsize = "#"
      elsei (l:units   <=   0)
         let   s:HTAG_sUsize = "!"
      else
         let   s:HTAG_sUsize = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:units    , 1)
      endi
   endi
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_class ()
   ""---(defense)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endi
   "---(check for easy leaf)--------------#
   if    (match (s:HTAG_iden, "^main$") > 0)
      let   s:HTAG_sclass  = "trunk"
   elsei (match (s:HTAG_iden, "_init$") > 0)
      let   s:HTAG_sclass  = "shoot"
   elsei (match (s:HTAG_iden, "_wrap$") > 0)
      let   s:HTAG_sclass  = "shoot"
   elsei (match (s:HTAG_iden, "__unit") > 0)
      let   s:HTAG_sclass  = "light"
   elsei (s:HTAG_sfsize == 0)
      let   s:HTAG_sclass  = "leaf"
   endi
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_write ()
   ""---(handle groups)------------------""
   if    (s:HTAG_sscope == "-")
      retu  0
   endif
   ""---(new header)---------------------""
   norm  0D
   if    (s:HTAG_shead == "-")
      exec  ":norm  o".printf ("%-12.12s", s:HTAG_sprefix)." /*-> ------------------------------------[ ------ [--.---.---.--]*/ /*-[--.----.--.--]-*/ /*-[--.---.---.--]-*/"
      let   s:HTAG_sadjust  += 1
   else
      norm  j
      norm  0D
      exec  ":norm  0DR".printf ("%-12.12s", s:HTAG_sprefix)." /*-> ------------------------------------[ ------ [--.---.---.--]*/ /*-[--.----.--.--]-*/ /*-[--.---.---.--]-*/"
   endi
   if    (s:HTAG_stitle == "")
      exec  ":norm  19|Rtbd "
   else
      exec  ":norm  19|R".s:HTAG_stitle." "
   endi
   if    (s:HTAG_sclass == "")
      exec  ":norm  57|R------"
   else
      exec  ":norm  57|R".printf ("%-6.6s",s:HTAG_sclass)." "
   endi
   exec  ":norm  65|R".s:HTAG_sscope.s:HTAG_srv."."
   exec  ":norm  68|R".s:HTAG_stsize.s:HTAG_sssize.s:HTAG_sdsize."."
   exec  ":norm  72|R".s:HTAG_spsize.s:HTAG_slsize.s:HTAG_srsize."."
   exec  ":norm  76|R".s:HTAG_scsize.s:HTAG_sfsize
   exec  ":norm  86|R".s:HTAG_smsize.s:HTAG_sisize."."
   exec  ":norm  89|R".s:HTAG_snsize.s:HTAG_sosize.s:HTAG_sgsize.s:HTAG_s0size."."
   exec  ":norm  94|R".s:HTAG_sGsize.s:HTAG_sLsize.s:HTAG_sDsize."."
   exec  ":norm  98|R".s:HTAG_sUsize
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_read  ()
   ""---(check function)-----------------""
   exec  "norm ".s:HTAG_line."G"
   let   l:recd  = getline('.')
   if    (match (l:recd, s:HTAG_iden) != 0)
      retu  0
   endi
   ""---(check for prefix)---------------""
   norm  k
   let   l:space = getline('.')
   if    (l:space == "")
      retu  0
   endi
   "---(determine header quality)--------""
   if    (HTAG_stats_check () < 0)
      retu  0
   endi
   let   l:recd  = getline('.')
   ""---(parse base values)--------------""
   let   s:HTAG_sprefix = strpart (l:recd,  0, 12)
   let   l:loc          = match   (l:recd, " -*[ ", 20)
   let   s:HTAG_stitle  = strpart (l:recd, 18, l:loc - 18)
   let   l:loc          = match   (l:recd, " ", 57)
   let   s:HTAG_sclass  = strpart (l:recd, 56, l:loc - 56)
   let   s:HTAG_sscope  = strpart (l:recd, 64, 1)
   let   s:HTAG_srv     = strpart (l:recd, 65, 1)
   let   s:HTAG_stsize  = strpart (l:recd, 67, 1)
   let   s:HTAG_sssize  = strpart (l:recd, 68, 1)
   let   s:HTAG_sdsize  = strpart (l:recd, 69, 1)
   let   s:HTAG_spsize  = strpart (l:recd, 71, 1)
   let   s:HTAG_slsize  = strpart (l:recd, 72, 1)
   let   s:HTAG_srsize  = strpart (l:recd, 73, 1)
   let   s:HTAG_scsize  = strpart (l:recd, 75, 1)
   let   s:HTAG_sfsize  = strpart (l:recd, 76, 1)
   ""---(parse extended values)----------""
   if    (strpart (l:recd, 80, 5) != " /*-[")
      retu  0
   endif
   if    (strpart (l:recd, 98, 4) != "]-*/")
      retu  0
   endif
   let   s:HTAG_smsize  = strpart (l:recd, 85, 1)
   let   s:HTAG_sisize  = strpart (l:recd, 86, 1)
   let   s:HTAG_snsize  = strpart (l:recd, 88, 1)
   let   s:HTAG_sosize  = strpart (l:recd, 89, 1)
   let   s:HTAG_sgsize  = strpart (l:recd, 90, 1)
   let   s:HTAG_s0size  = strpart (l:recd, 91, 1)
   let   s:HTAG_sGsize  = strpart (l:recd, 93, 1)
   let   s:HTAG_sLsize  = strpart (l:recd, 94, 1)
   let   s:HTAG_sDsize  = strpart (l:recd, 95, 1)
   let   s:HTAG_sUsize  = strpart (l:recd, 97, 1)
   ""---(complete)-----------------------""
   retu  0
endf

func HTAG_stats_tag   ()
   ""---(go to tags)---------------------""
   norm  ,t
   norm  'X
   setl  modifiable
   ""---(handle groups)------------------""
   if    (s:HTAG_sscope == "-")
      if    (match (s:HTAG_iden, "o___") >= 0)
         let   s:HTAG_sgroup   += 1
         exec  ":norm  93|Rgroup     "
         exec  ":norm  120|R sr tsd plr cf   mi nog0 GLD U   -- --- --- -- "
      else
         let   s:HTAG_sbad     += 1
      endi
   endif
   ""---(update tag entry)---------------""
   if    (s:HTAG_sscope != "-")
      let   s:HTAG_sgood    += 1
      ""---(tag group 1)-----------------""
      exec  ":norm  120|R["
      exec  ":norm  121|R".s:HTAG_sscope.s:HTAG_srv."."
      exec  ":norm  124|R".s:HTAG_stsize.s:HTAG_sssize.s:HTAG_sdsize."."
      exec  ":norm  128|R".s:HTAG_spsize.s:HTAG_slsize.s:HTAG_srsize."."
      exec  ":norm  132|R".s:HTAG_scsize.s:HTAG_sfsize."]"
      ""---(tag group 2)-----------------""
      exec  ":norm  136|R["
      exec  ":norm  137|R".s:HTAG_smsize.s:HTAG_sisize."."
      exec  ":norm  140|R".s:HTAG_snsize.s:HTAG_sosize.s:HTAG_sgsize.s:HTAG_s0size."."
      exec  ":norm  145|R".s:HTAG_sGsize.s:HTAG_sLsize.s:HTAG_sDsize."."
      exec  ":norm  149|R".s:HTAG_sUsize."]"
      ""---(title and type)--------------""
      exec  ":norm  174|R".s:HTAG_sclass
      exec  ":norm  238|R".s:HTAG_stitle
   endif
   "---(complete)-------------------------#
   setl  nomodifiable
   retu  0
endf

func HTAG_stats_file  (action, bufno)
   ""---(get the file name)-----------##
   let   l:source = bufname (a:bufno)
   let   l:loc    = match   (l:source, "[A-Za-z0-9_.]*$")
   let   l:base   = strpart (l:source, l:loc)
   let   l:loc    = match   (l:source, "[.][A-Za-z0-9_]*$")
   let   l:ext    = strpart (l:source, l:loc)
   ""---(skip non-c files)---------------""
   let   s:HTAG_sfile   += 1
   if (l:ext != ".c")
      retu  0
   endi
   let   s:HTAG_scfile  += 1
   ""---(prepare local flow)-------------""
   if    (a:action == "w")
      sil!  exec ":!cflow -r -d 2 ".l:source." 2> /dev/null > HTAG.lcalls"
      redraw!
   endi
   "---(mark top)-------------------------#
   norm  _
   let   l:top = search ("^".l:source,"cW")
   if    (l:top == 0)
      retu  0
   endif
   norm  mX
   ""---(find bottom)--------------------""
   norm  j
   let   l:bot = search ("   FILE$", "W") - 1
   if    (l:bot == -1)
      norm  G
      let   l:bot = line('.')
   endif
   "---(find the functions)---------------#
   norm  'X
   if    (search ("^function (","W", l:bot) < 1)
      retu  0
   endi 
   "---(parse the first)------------------#
   if    (a:action == "c")
      if    (search ("^[a-z][A-Za-z]  ".g:HTAG_cword, "W", l:bot) < 1)
         retu  0
      endi 
      norm  mX
   else
      norm  mX
      norm  j
   endi
   call  HTAG_parse ()
   "---(walk the functions)---------------#
   let   s:HTAG_sadjust  = 0
   while (s:HTAG_type == "function" || s:HTAG_type == "group")
      ""---(common)-------------------------""
      let   s:HTAG_sfunc += 1
      norm  mX
      norm  ,a
      call  HBUF_goto (l:source)
      call  HTAG_stats_prep  ()           
      ""---(read)---------------------------""
      if    (a:action == "r")
         call  HTAG_stats_read  ()           
      endi
      ""---(write)--------------------------""
      if    (a:action == "w" || a:action == "c")
         call  HTAG_stats_head_srp  ()           
         call  HTAG_stats_size_tsd  ()           
         call  HTAG_stats_stat_rlf  ()           
         call  HTAG_stats_stat_cmi  ()           
         call  HTAG_stats_stat_nog0 ()           
         call  HTAG_stats_stat_GLD  ()           
         call  HTAG_stats_stat_U    ()           
         call  HTAG_stats_class     ()           
         call  HTAG_stats_write     ()           
      endi
      ""---(common)-------------------------""
      call  HTAG_stats_tag   ()           
      if    (a:action == "c")
         break
      endi
      norm  0j
      call  HTAG_parse       ()
   endw
   "---(complete)-------------------------#
   retu  0
endf

func HTAG_stats_full  (action)
   ""---(clear stats)------+-----+-----+-""
   let   s:HTAG_sfile      = 0
   let   s:HTAG_scfile     = 0
   let   s:HTAG_sfunc      = 0
   let   s:HTAG_sgood      = 0
   let   s:HTAG_sgroup     = 0
   let   s:HTAG_sbad       = 0
   ""---(prepare global flow)------------""
   sil!  exec ":!make clean"
   sil!  exec ":!cflow -r -d 2 *.c 2> /dev/null > HTAG.gcalls"
   sil!  exec ":!cflow -d 150  *.c 2> /dev/null > HTAG.flow"
   redraw!
   ""---(run all files)------------------""
   if    (a:action == "r" || a:action == "w")
      let   l:bufno           = HBUF_next (0)
      while (l:bufno > 0)
         call  HTAG_stats_file (a:action, l:bufno)
         let   l:bufno = HBUF_next (l:bufno)
      endw
   endi
   ""---(run only current file)----------""
   if    (a:action == "f")
      norm  mX
      norm  ,a
      let   l:bufno           = bufnr ('%')
      norm  ,t
      call  HTAG_stats_file ("w", l:bufno);
   endi
   ""---(run only current function)------""
   if    (a:action == "c")
      norm  mX
      norm  ,a
      let   l:bufno           = bufnr ('%')
      norm  ,t
      call  HTAG_stats_file (a:action, l:bufno);
   endi
   ""---(final status)-------------------""
   echon "HTAG_stats ()         :: files=".s:HTAG_sfile.", procd=".s:HTAG_scfile.", funcs=".s:HTAG_sfunc.", good =".s:HTAG_sgood.", group=".s:HTAG_sgroup.", bad  =".s:HTAG_sbad
   sil!  exec  ":write! HTAG.tags"
   sil!  exec  ":!HTAG_gyges.awk < HTAG.tags > HTAG.gyges"
   sil!  exec  ":!grep \"^[a-z][A-Za-z]  [A-Za-z][A-Za-z]\" HTAG.tags    > HTAG.asterion"
   sil!  exec  ":!printf \"\\\n\"                                       >> HTAG.asterion"
   sil!  exec  ":!cat  HTAG.flow                                        >> HTAG.asterion"
   norm  ,a
   redraw!
   ""---(complete)-----------------------""
   retu  0
endf



call HTAG_init()
""===[[ END ]]=================================================================#
