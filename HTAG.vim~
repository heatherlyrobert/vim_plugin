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
let g:htag_title    = "HTAG_buffer"
let g:htag_locked   = "n"
let g:HTAG_times    = 0

"---(current tag)--------------------------------#
let s:HTAG_tagn     = ""
let s:HTAG_line     = 0
let s:HTAG_file     = ""
let s:HTAG_type     = ""
let s:HTAG_stat     = ""
let s:HTAG_iden     = ""

"---(function cursor)----------------------------#
let s:HTAG_cfile    = 0
let s:HTAG_ctype    = 0
let s:HTAG_chead    = 0
let s:HTAG_ccount   = 0
let s:HTAG_ccurr    = 0




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
   sil!  exec 'vert split '.g:htag_title
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
   nmap           ,t  :call HTAG_show   ()<cr>
   nnor           ;;  :call HTAG_hints  ()<cr>
   nmap  <buffer> t   :call HTAG_update ()<cr>
   nmap  <buffer> h   :call HTAG_hide   ()<cr>
   nmap  <buffer> s   :call HTAG_stats  ()<cr>
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
   call HTAG_show()
   call HTAG_update()
endfunction


""=[[ display the tag window ]]===========================[ twig   [ 433y6s ]=##
func! HTAG_show ()
   ""---(locals)-----------+-----------+-##
   let   l:prefix    = "HTAG_show"
   let   l:rce       = -10
   ""---(defense : no recursion)---------##
   let   l:rce -= 1
   if    (g:htag_locked == "y")
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
   let   g:htag_locked = "y"
   ""---(verify the buffer)--------------##
   let   l:tag_buf = bufnr (g:htag_title)
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
   sil!  exec 'vert split '.g:htag_title
   vert  resize 20
   ""---(activate the repositioning)-----##
   call  HTAG_auto_on()
   ""---(set it up)----------------------##
   norm  zt
   ""---(let her go)---------------------##
   let   g:hbuf_locked = "n"
   let   g:htag_locked = "n"
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
   if    tag_id >= "aa"
      echon "  (normal ctag) processing..."
   elsei tag_id >= "MA"
      echon "  (HCSC/cscope/grep tag) processing..."
      call HCSC_hints(l:tag_id)
      return
   elsei tag_id >= "AA"
      echon "  (HFIX/quickfix tag) processing..."
      call HFIX_hints(l:tag_id)
      return
   endif
   "---(switch to tag window)-----------------#
   let    l:win_num = HBUF_by_name(g:htag_title)
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
   silent exec "syntax match rsh_tag_identifier ' " . g:HTAG_iden . " ' containedin=ALL"
   "---(get back to the original window)------#
   let l:rc = HBUF_restore()
   if l:rc < 1
      return -1
   endif
   "---(get to the right buffer)--------------#
   if bufname('%') != g:HTAG_file
      let l:buf_num = bufnr(g:HTAG_file)
      if (l:buf_num == -1)
         echo "HTAG_hints() :: buffer not open in wim..."
         return
      else
         silent exec('b! ' . l:buf_num)
      endif
   endif
   "---(get to the right line)----------------# make sure to show comments above
   silent exec ":norm  _"
   "silent! exec ":normal ".(g:HTAG_line - 1). "j"
   silent! exec ":".g:HTAG_line
   if g:HTAG_type == "function"
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
   if    (g:htag_locked == "y")
      retu
   endi
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HTAG_change()       :: ") < 1)
      return
   endif
   "---(find the tags window)--------------------#
   if (HBUF_by_name(g:htag_title) < 1)
      return
   endif
   "---(lock her down)---------------------------#
   let  g:hbuf_locked = "y"
   let  g:htag_locked = "y"
   silent! exec l:tag_win.' wincmd w'
   "---(go to the right place)-------------------"
   norm  _
   call search("^".g:hbuf_pname."[ ].*FILE$","cW")
   silent exec "normal zt"
   silent exec "normal zt"
   "---(go back to working win/buf/loc)----------#
   call HBUF_restore()
   "---(let her go)------------------------------#
   let  g:htag_locked = "n"
   let  g:hbuf_locked = "n"
   "---(complete)--------------------------------#
   return
endfunction



"===[ PETAL  ]===> create tag list for all active buffers <====================#
function! HTAG_update()
   "---(do not allow recursion)------------------#
   if (g:htag_locked == "y")
      retu
   endif
   "---(start locked code)-----------------------#
   let  g:hbuf_locked = "y"
   let  g:htag_locked = "y"
   "---(run)-------------------------------------#
   let  g:HTAG_times  += 1
   call HTAG_list_BUFSONLY()
   "---(unlock code)-----------------------------#
   let  g:htag_locked = "n"
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
   ""---(clear out existing contents)------------#
   setl   modifiable
   sil    exec ":1,$delete"
   setl   nomodifiable
   "---(get the totals)--------------------------#
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
      "---(grand totals)----------------#
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
      " sil!  exec   ".:!grep \";\" ".l:full_name." | wc -l"
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
      sil!  normal mx
      ""---(run the tags)----------------##
      ""sil!  exec "$:!ctags -x --sort=no --c-kinds=cdefgnpstuvx --c++-kinds=cdefgnpstuvx --file-scope=yes ".l:full_name
      sil!  exec "$:!ctags -x --sort=no --file-scope=yes ".l:full_name
      "---(go back and awk them)--------#
      sil!  normal 'x
      sil!  exec ":silent! .,$!HTAG.awk 'g_hint_major=".l:g_hint_major."' 'g_hint_minor=".l:g_hint_minor."' 'g_file_name=".l:base_name."'"
      ""---(count total lines)-----------##
      sil!  normal 'x
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
      "---(go back and awk them)--------#
      "silent! normal 'x
      "call HTAG_func_syn(l:base_name)
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
   silent! normal 'x
   let  l:curr_line = search("function (","W", l:stop_line)
   silent! exec "normal mx"
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
      silent! exec "normal 'x"
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
   let  g:HTAG_tagn    = ""
   let  g:HTAG_line    = 0
   let  g:HTAG_file    = ""
   let  g:HTAG_type    = ""
   let  g:HTAG_stat    = ""
   let  g:HTAG_iden    = ""
   "---(check for null)--------------------------#
   let  l:full_line = getline('.')
   if (l:full_line == "")
      return 0
   endif
   "---(tag number)------------------------------#
   let  g:HTAG_tagn    = strpart    (l:full_line, 0, 2)
   "---(line number)-----------------------------#
   let  g:HTAG_line    = matchstr   (l:full_line, "  #1#  .*  #2#  ")
   let  g:HTAG_line    = substitute (strpart (g:HTAG_line, 7, strlen (g:HTAG_line) - 14), " ", "", "g")
   "---(file name)-------------------------------#
   let  g:HTAG_file    = matchstr   (l:full_line, "  #2#  .*  #3#  ")
   let  g:HTAG_file    = substitute (strpart (g:HTAG_file, 7, strlen (g:HTAG_file) - 14), " ", "", "g")
   "---(tag type)--------------------------------#
   let  g:HTAG_type    = matchstr   (l:full_line, "  #3#  .*  #4#  ")
   let  g:HTAG_type    = substitute (strpart (g:HTAG_type, 7, strlen (g:HTAG_type) - 14), " ", "", "g")
   "---(statistics)------------------------------#
   let  g:HTAG_stat    = matchstr   (l:full_line, "  #4#  .*  #5#  ")
   let  g:HTAG_stat    = substitute (strpart (g:HTAG_stat, 7, strlen (g:HTAG_stat) - 14), " ", "", "g")
   "---(identifier)------------------------------#
   let  g:HTAG_iden    = matchstr   (l:full_line, "  #5#  .*  #6#  ")
   let  g:HTAG_iden    = substitute (strpart (g:HTAG_iden, 7, strlen (g:HTAG_iden) - 14), " ", "", "g")
   "---(complete)--------------------------------#
   return 1
endfunction



function! HTAG_head(file, type)
   "---(do not allow recursion)------------------#
   if (g:htag_locked == "y")
      return -2
   endif
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HTAG_head()         :: ") < 1)
      return -2
   endif
   "---(make sure tags are updated)--------------#
   normal ,tt
   "---(check for the window)--------------------#
   if (HBUF_by_name(g:htag_title) < 1)
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
   normal mx
   normal j
   let l:stop_line  = search("   FILE$", "W") - 1
   if l:stop_line == -1
      normal GG
      let  l:stop_line    = line('.')
   endif
   "---(find the functions)----------------------#
   normal 'x
   if (search("function (","W", l:stop_line) < 1)
      echon "HTAG_findloc()        :: no functions in file ".a:base_name."..."
      return 0
   endif
   let  l:full_line    = getline('.')
   let  l:count        = matchstr(l:full_line, "(.*)")
   let  l:count        = strpart(l:count, 1, strlen(l:count) - 2 ) - 0
   normal mx
   normal j
   call HTAG_parse()
   "---(save context)----------------------------#
   normal 'x
   let  g:HTAG_cfile   = a:file
   let  g:HTAG_ctype   = a:type
   let  g:HTAG_chead   = line('.')
   let  g:HTAG_ccount  = l:count
   let  g:HTAG_ccurr   = 1
   "---(complete)--------------------------------#
   call HBUF_restore()
   return g:HTAG_chead
endfunction



function! HTAG_curr()
   echo "file=".g:HTAG_cfile.", type=".g:HTAG_ctype.", head=".g:HTAG_chead.", count=".g:HTAG_ccount.", curr=".g:HTAG_ccurr
   return
endfunction


"==[[ create tag list for all active buffers ]]====================[ 433y6s ]==#
func! HTAG_next ()
   "---(do not allow recursion)------------------#
   if    (g:htag_locked == "y")
      retu  -2
   endi
   "---(verify position in range)----------------#
   if    (g:HTAG_ccurr >= g:HTAG_ccount)
      retu  -1
   endi
   "---(save working win/buf/loc)----------------#
   if    (HBUF_save("HTAG_head()         :: ") < 1)
      retu  -2
   endi
   "---(check for the window)--------------------#
   if    (HBUF_by_name(g:htag_title) < 1)
      echon "HTAG_head()         :: tag window not showing..."
      retu  -2
   endi
   "---(get full tag range for buffer)-----------#
   let   g:HTAG_ccurr += 1
   norm  _
   exec  "normal ".g:HTAG_chead."G"
   exec  "normal ".g:HTAG_ccurr."j"
   call  HTAG_parse()
   "---(complete)--------------------------------#
   call  HBUF_restore()
   retu  g:HTAG_chead
endf



function! HTAG_findloc(base_name, line_num)
   "echo "was curnum=".bufnr("%").", which is <<".bufname("%").">>"
   let   rc = HBUF_by_name(g:htag_title)
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
   silent! exec "normal mx"
   "> start of next buffer entriies
   normal j
   let l:stop_line  = search("   FILE$", "W") - 1
   "echo stop_line
   if l:stop_line == -1
      normal GG
      let  l:stop_line    = line('.')
   endif
   "---(find the functions)----------------------#
   silent! exec "normal 'x"
   let  l:curr_line = search("function (","W", l:stop_line)
   silent! exec "normal mx"
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
      silent! exec "normal 'x"
      exec "normal ".l:curr."j"
      if (HTAG_parse() < 1)
         break
      endif
      if g:HTAG_line > a:line_num
         break
      endif
      let  l:rtag_final   = "[".g:HTAG_tagn."] ".g:HTAG_iden
      let  l:curr = l:curr + 1
   endwhile
   "---(complete)--------------------------------#
   "echo "done"
   return l:rtag_final
endfunction

func HTAG_stats ()
   "---(locals)----+-------+-----+-----+--#
   let   l:c       = 0
   let   l:good    = 0
   let   l:bad     = 0
   let   l:recd    = ""
   let   l:file    = "func.tmp"
   let   l:source  = "gyges_cell.c"
   "---(mark top)-------------------------#
   norm  _
   let   l:top = search ("^".l:source,"cW")
   if    l:top == 0 
      echon "HTAG_stats ()         :: gyges_cell.c not found"
      retu  0
   endif
   norm  mx
   ""---(skip non-c files)---------------""
   "let   l:loc    = match   (l:source, "[.][A-Za-z0-9_]*$")
   "let   l:ext    = strpart (l:source, l:loc)
   "if (l:ext != ".c")
   "   retu  0
   "endi
   ""---(find bottom)--------------------""
   norm  j
   let   l:bot = search ("   FILE$", "W") - 1
   if    l:bot == -1
      norm  G
      let   l:bot = line('.')
   endif
   "---(find the functions)---------------#
   norm  'x
   if    (search ("^function (","W", l:bot) < 1)
      echon "HTAG_stats ()         :: top = ".l:top.", bot = ".l:bot.", but no function header"
      retu  0
   endi 
   "---(parse the first)------------------#
   norm  mx
   norm  j
   call  HTAG_parse()
   "---(walk the functions)---------------#
   while (g:HTAG_type == "function")
      "---(update and mark)---------------#
      let   l:c += 1
      norm  mx
      "---(update and mark)---------------#
      norm  ,a
      exec  "norm ".g:HTAG_line."G"
      "redraw!
      let   l:recd = getline('.')
      if    (match (l:recd, g:HTAG_iden) == 0)
         let   l:good += 1
         "---(mark top)----------------------#
         norm  k
         let   l:beg    = line (".")
         let   l:type   = getline('.')
         if    (match (l:type, "char[*]")     >= 0)
            let   l:rv     = "s"
         elsei (match (l:type, "char" )       >= 0)
            let   l:rv     = "c"
         else
            let   l:rv     = "v"
         endi
         if    (match (g:HTAG_iden, "__unit") >  0)
            let   l:scope  = "u"
         elsei (match (g:HTAG_iden, "__"    ) >  0)
            let   l:scope  = "p"
         elsei (match (l:file, "y")           == 0)
            let   l:scope  = "y"
         elsei (match (l:type, "static")      == 0)
            let   l:scope  = "s"
         else
            let   l:scope  = "g"
         endi
         norm  my
         "---(mark bot)----------------------#
         let   l:end = search ("^}$", "eW")
         exec  "norm ".l:end."G"
         norm  mz
         "echon "HTAG_stats ()         :: top = ".l:top.", bot = ".l:bot.", beg = ".l:beg.", end = ".l:end
         "retu  0
         "---(write to file)-----------------#
         sil!  exec  ":'y,'zwrite! func.tmp"
         "---(get to blank above function)---#
         exec  "norm ".l:beg."G"
         norm  k
         ""---(collect data)----------------##
         sil!  exec   ".:!cat ".l:file." | wc -l"
         let   l:total  = getline('.')
         sil!  exec   ".:!grep \"^[ ]*$\" ".l:file." | wc -l"
         let   l:empty  = getline('.')
         ""---(comments)-----------------""
         sil!  exec   ".:!grep \"^[ ]*[\/][*]\" ".l:file." | wc -l"
         let   l:comm1  = getline('.')
         sil!  exec   ".:!grep \"^[ ]*[*] \" ".l:file." | wc -l"
         let   l:comm2  = getline('.')
         ""---(debugging)----------------""
         sil!  exec   ".:!grep \"^[ ]*DEBUG_\" ".l:file." | wc -l"
         let   l:yurg   = getline('.')
         sil!  exec   ".:!grep \"^[ ]*DEBUG_.*yLOG_\" ".l:file." | wc -l"
         let   l:dlogs  = getline('.')
         sil!  exec   ".:!grep \"yLOG_\" ".l:file." | wc -l"
         let   l:ylogs  = getline('.')
         ""---(slocl)--------------------""
         sil!  exec   ".:!cat ".l:file." | tr -cd \";\" | wc -c"
         let   l:colon  = getline('.')
         if    (l:colon >= 360)
            let   l:size = "#"
         else
            let   l:size = strpart ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", l:total / 10, 1)
         endi
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
         ""---(summary)------------------""
         let   l:comms  = l:comm1 + l:comm2 + l:empty
         let   l:debug  = l:dlogs + (l:ylogs - l:dlogs) + (l:yurg - l:dlogs)
         let   l:code   = l:total - l:comms - l:debug
         let   l:slocl  = l:colon - l:debug
         if    (l:total >= 360)
            let   l:tsize = "#"
         elsei (l:total <=   0)
            let   l:tsize = "-"
         else
            let   l:tsize = strpart ("0123456789abcdefghijklmnopqrstuvwxyz", l:total / 10, 1)
         endi
         if    (l:comms <=   0)
            let   l:csize = "-"
         else
            let   l:csize = strpart ("0123456789abcdefghijklmnopqrstuvwxyz", (l:comms * 10) / l:slocl, 1)
         endi
         if    (l:debug <=   0)
            let   l:dsize = "-"
         else
            let   l:dsize = strpart ("0123456789", (l:debug * 10) / l:slocl, 1)
         endi
         if    (l:slocl >= 360)
            let   l:ssize = "#"
         else
            let   l:ssize = strpart ("0123456789abcdefghijklmnopqrstuvwxyz", l:slocl  / 10, 1)
         endi
         if    (l:rv  == "c")
            if    (l:rces  > 0)
               let   l:rv     = "e"
            elsei (l:rcesn > 0)
               let   l:rv     = "e"
            elsei (l:rced  > 0)
               let   l:rv     = "e"
            endi
         endi
         exec  "norm Rtotal=".l:total.", tsize=".l:tsize.", scope=".l:scope.", rv=".l:rv.", comms=".l:comms.", csize=".l:csize.", debug=".l:debug.", dsize=".l:dsize.", slocl=".l:slocl.", ssize=".l:ssize.", retns=".l:retns.", rces=".l:rces.", rcesn=".l:rcesn.", retn2=".l:retn2
      else
         let   l:bad  += 1
      endi
      "---(go to next function)-----------#
      norm  ,t
      norm  'x
      "exec  ":norm  120|R".l:scope
      "sleep 100m
      "norm  0
      norm  j
      call  HTAG_parse()
      "---(done)--------------------------#
   endw
   "---(final status)---------------------#
   if    (l:c <= 0)
      echon "HTAG_stats ()         :: top = ".l:top.", bot = ".l:bot.", but no functions found (".g:HTAG_type.")"
      retu  0
   endi
   echon "HTAG_stats ()         :: top = ".l:top.", bot = ".l:bot.", cnt = ".l:c.", good = ".l:good.", bad = ".l:bad
   "---(complete)-------------------------#
   retu  0
endf



call HTAG_init()
""===[[ END ]]=================================================================#
