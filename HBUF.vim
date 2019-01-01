""===[[ START HDOC ]]==========================================================#
""===[[ HEADER ]]==============================================================#

"   niche         : vim-ide (integrated development environment)
"   application   : HBUF.vim
"   purpose       : provide simple, efficient buffer navigation system for vim
"   base_system   : gnu/linux
"   lang_name     : vim script
"   created       : svq - long, long ago
"   author        : the_heatherlys
"   dependencies  : none (vim only)
"   permissions   : GPL-2 with no warranty of any kind
"
"
""===[[ PURPOSE ]]=============================================================#

"   HBUF is a fast, clear, standard, and simple buffer tool to keep the
"   programmer focused on the programming rather than the fussy internals of
"   juggling files, buffers, and windows.
"
"   overall, there are many advantages to editing several files in a single
"   editor session so that registers, marks, multiple copy buffers, ... can
"   be shared easily and can be seen side-by-side
"
"   but, there are also huge disadvantages to attemping to edit too many files
"   within a single editor session, including, confusion, forgotten buffers,
"   crash/recovery complexity, slower performance, file lock-outs ... so that
"   you should try to only open what you can use
"
"   also, it is very dangerous to have source from different programs or
"   libraries open in the same editor as confusion can cause some real editing
"   fiascos and issuses that may go undetected until the undo/redo history
"   is cleared
"
"   the cleanist solution for large scale editing appears to be...
"      - have multiple editor sessions running, each with a specific application
"      - within each session, group related code
"      - if files don't share symbols, keep them separate
"
"   HBUF focuses on quick navigation as that is the most common use...
"      - plan on typical editing of two to four primary files
"      - maximum speed and efficiency appoach
"      - see all buffers on a single, unobtrusive line (or as few as can be)
"      - have an optional taller view if more filer are edited
"      - autoload the buffer window and show it up front
"      - be able to toggle on/off to save screen real-estate
"      - see all the open buffers once, including which is current
"      - switch buffer in current window quickly
"      - highlight changes and hidden buffers
"      - hide specialty or read-only windows as they are not for ediding anyway
"      - do everything with shortcuts (2 keys max) -- no mouse or tabbing
"
"   rejected features (in other buffer explorers)...
"      - do not have mouse or cursor selection features
"      - do not have a delete feature (not that common or required)
"      - no more that nine (9) buffers, keeps short cuts fast, fast, fast
"      - no extended views with additional information
"      - no cleaver buffer opening dialogs (put in elsewhere)
"
"
"   PRINCIPLE > write programs that do one thing well and do it well
"
"
""===[[ END HDOC ]]============================================================#



""===[[ GLOBALS ]]=============================================================#
let g:hbuf_title    = "HBUF_buffer"              " buf/win title
let g:hbuf_list     = ""                         " formatted list
let g:hbuf_raw      = ""                         " unformatted list
let g:hbuf_locked   = "n"                        " y/n hands off flag
let g:hbuf_times    = 0                          " great debug/perf monitor

let g:hbuf_pbuf     = 0    " current programming buffer number
let g:hbuf_pname    = ""   " current programming buffer name
let g:hbuf_pline    = 0    " current programming buffer line
let g:hbuf_pcol     = 0    " current programming buffer column

let s:hbuf_size     = 1    " window height

let s:hbuf_snum     = 1
let s:hbuf_sname    = ""



""===[[ MAPPINGS ]]============================================================#
"---(whether or not its shown)-------------------#
"augroup HBUF
"   autocmd HBUF     VimEnter    * call HBUF_show()
"augroup END
"
command! -nargs=0  HBUFshow     call HBUF_show()



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


func! s:HBUF_init()
   sil!  exec 'topleft split ' . g:hbuf_title
   call  HALL_start()
   call  s:HBUF_syntax()
   call  s:HBUF_keys()
   hide
   retu
endf


funct! s:HBUF_syntax()
   setlo modifiable
   syn   clear
   syn   match hbuf_cont      '>>'
   syn   match hbuf_visible   '[0-9A-Z][>][A-Za-z0-9\._-]\+ '
   syn   match hbuf_changed   '[0-9A-Z][)][A-Za-z0-9\._-]\+ '
   syn   match hbuf_hidden    '[0-9A-Z]\][A-Za-z0-9\._-]\+ '
   syn   match hbuf_id        '[0-9A-Z][)>\]]' contained
            \ containedin=hbuf_visible,hbuf_hidden,hbuf_changed
   syn   match hbuf_timess    '[#][0-9]\+$'
   high  hbuf_cont   cterm=bold ctermbg=none ctermfg=5
   high  link hbuf_visible    function
   high  link hbuf_hidden     comment
   high  link hbuf_changed    string
   high  link hbuf_id         linenr
   high  hbuf_timess  cterm=reverse,bold ctermbg=none ctermfg=4
   setlo nomodifiable
   retu
endf


func! s:HBUF_keys()
   setlo modifiable
   "---(specific)------------------------------------#
   nmap            ,a      :silent! exec "3 wincmd w"<cr>
   nmap            ,b      :call HBUF_show()<cr>
   nmap            ,,      :call HBUF_goto(",")<cr>
   nmap  <buffer>   b      :call HBUF_update()<cr>
   "---(presentation/size)---------------------------#
   nmap  <buffer>   -      :call HBUF_resize("-")<cr>
   nmap  <buffer>   +      :call HBUF_resize("+")<cr>
   nmap  <buffer>   h      :call HBUF_hide()<cr>
   nmap  <buffer>   b      :call HBUF_update()<cr>
   "---(complete)------------------------------------#
   setlo nomodifiable
   retu
endf


func! s:HBUF_unkeys()
   setlo modifiable
   nunm  <buffer>   b
   nunm  <buffer>   -
   nunm  <buffer>   +
   nunm  <buffer>   h
   setlo nomodifiable
   retu
endf


func! s:HBUF_auto()
   setlo modifiable
   augr  HBUF
      auto  HBUF      BufWinEnter   * call HBUF_update()
      auto  HBUF      BufWinLeave   * call HBUF_update()
   augr  END
   setlo nomodifiable
   retu
endf


func! s:HBUF_unauto()
   setlo modifiable
   auto! HBUF
   augr! HBUF
   augr  END
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


func! HBUF_on()
   call  HBUF_show()
   call  HBUF_update()
endf


function! HBUF_show()
   "---(do not allow recursion)------------------#
   if (g:hbuf_locked == "y")
      return
   endif
   "---(save working win/buf/loc)----------------#
   if (HBUF_save("HBUF_show()         :: ") < 1)
      return
   endif
   "---(lock her down)---------------------------#
   call HALL_lock()
   "---(verify the buffer)-----------------------#
   let buf_num         = bufnr(g:hbuf_title)
   if (buf_num < 1)
      call s:HBUF_init()
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
   sil!  exec  'topleft split ' . g:hbuf_title
   call  HBUF_resize("?")
   "---(create the autocommands)-----------------#
   call s:HBUF_auto()
   "---(update)----------------------------------#
   "call HBUF_restore()
   call HALL_unlock()
   "call HBUF_update()
   "---(complete)--------------------------------#
   echon "HBUF_show()        :: complete."
   return
endfunction


func! HBUF_hide()
   ""---(defense)--------------------------------#
   if    (bufname("%") != g:hbuf_title)
      retu  -1
   endi
   ""---(process)--------------------------------#
   call  s:HBUF_unauto()
   hide
   call  HBUF_restore()
   ""---(complete)-------------------------------#
   retu
endf


"" PURPOSE : update window size
func! HBUF_resize(height)
   ""---(get current state)----------------------#
   "let   s:hbuf_size  = winheight(0)
   ""---(process change)-------------------------#
   if    (a:height == "+")
      let   s:hbuf_size += 1
   elsei (a:height == "-")
      let   s:hbuf_size -= 1
   elsei (a:height == "0")
      let   s:hbuf_size  = 1
   elsei (a:height == "?")
      let   s:hbuf_size  = s:hbuf_size
   else
      let   s:hbuf_size  = a:height
   endi
   ""---(test size values)-----------------------#
   if    (s:hbuf_size > 3)
      let   s:hbuf_size = 3 
   elsei (s:hbuf_size < 1)
      let   s:hbuf_size = 1
   endi
   ""---(resize)---------------------------------#
   sil!  exec  "resize ".s:hbuf_size
   ""---(complete)-------------------------------#
   return
endf



""===[[ SPECIALITY ]]==========================================================#


func! s:o___SPECIFIC________o()
endf

let s:hbuf_prev     = 1

function! HBUF_goto (buf_name)
   "---(locals)---------------------------#
   let l:buf_cnum  = bufnr('%')
   let l:buf_cname = a:buf_name
   let l:buf_nnum  = 0
   "---(basic validity checks)------------#
   if getbufvar(l:buf_cnum, '&modifiable') == 0
      echon "HBUF_goto()        :: can not load a new buffer in specialty window..."
      return
   endif
   if getbufvar(l:buf_cnum, '&buflisted') == 0
      echon "HBUF_goto()        :: can not load a new buffer in specialty window..."
      return
   endif
   "---(find destination)-----------------#
   if l:buf_cname == ","
      let l:buf_cname = s:hbuf_sname
   endif
   let l:buf_nnum = bufnr(l:buf_cname)
   "---(check on the destination)----------------#
   if l:buf_nnum < 1
      echon "HBUF_goto()        :: buffer <<".l:buf_cname.">> does not exist..."
      return -1
   endif
   if getbufvar(l:buf_nnum, '&buflisted') == 0
      echon "HBUF_goto()        :: buffer <<".l:buf_cname.">> is not listed..."
      return 0
   endif
   if l:buf_nnum == l:buf_cnum
      echon "HBUF_goto()        :: buffer (".l:buf_nnum.") already loaded in this window..."
      return
   endif
   "---(show it)---------------------------------#
   let s:hbuf_snum  = l:buf_cnum
   let s:hbuf_sname = bufname ("%")
   silent! exec('b! ' . l:buf_nnum)
   echon "HBUF_goto()        :: moved to (".l:buf_nnum.") ".l:buf_cname
   "---(complete)--------------------------------#
   return
endfunction



"===[ PETAL  ]===> go to a window based on buffer name
function! HBUF_by_name(buf_name)
   return HBUF_by_num(bufnr(a:buf_name))
endfunction



"===[ PETAL  ]===> go to a window based on buffer number
function! HBUF_by_num(buf_num)
   if (a:buf_num < 1)
      return -1
   endif
   let l:win_num = bufwinnr(a:buf_num)
   if (l:win_num < 1)
      return 0
   endif
   silent exec l:win_num.' wincmd w'
   return l:win_num
endfunction



"===[ PETAL  ]===> confirm the existance of a buf/window
function! HBUF_confirm(buf_name)
   let l:buf_num = bufnr(a:buf_name))
   if (a:buf_num < 1)
      return -1
   endif
   let l:win_num = bufwinnr(a:buf_num)
   if (l:win_num < 1)
      return 0
   endif
   return l:win_num
endfunction



""===[[ WINDOW UPDATE CODE ]]==================================================#



function! HBUF_update()
   "---(do not allow recursion)------------------#
   if (g:hbuf_locked == "y")
      return
   endif
   "---(check for the buffer)--------------------#
   let l:buf_num = bufnr(g:hbuf_title)
   if (l:buf_num < 1)
      return
   endif
   "---(check for the window)--------------------#
   let l:win_num = bufwinnr(l:buf_num)
   if (l:win_num < 1)
      return
   endif
   "---(don't update for special buffer moves)---#
   let l:buf_cur = bufnr('%')
   if (buf_num != buf_cur)
      if (getbufvar(l:buf_cur, '&modifiable') == 0)
         call HBUF_restore()
         return
      endif
      if (getbufvar(l:buf_cur, '&buflisted') == 0)
         call HBUF_restore()
         return
      endif
   endif
   "---(go to the buffer listing)----------------#
   silent! exec l:win_num.' wincmd w'
   "---(start locked code)-----------------------#
   let g:hbuf_locked = "y"
   let g:hbuf_times  += 1
   call HBUF_list()
   let g:hbuf_locked = "n"
   "---(return to previous window)---------------#
   call HBUF_restore()
   "---(complete)--------------------------------#
   return
endfunction



func! HBUF_list()
   "---(prepare output vars)---------------------#
   let   l:buf_list    = ""             " initialize the buffer list
   let   l:buf_raw     = ""             " initialize the buffer simple list
   "---(prepare loop vars)-----------------------#
   let   l:max_buf_num = bufnr('$')     " number of the last buffer.
   let   l:buf_count   = 0              " count of listed buffers
   let   l:i           = 1              " current buffer index
   let   l:bufc        = '0'
   let   l:cur         = 0
   let   l:max         = 0
   let   l:max_cols    = winwidth ('%')
   let   l:max_horz    = (l:max_cols - 2) / 21
   "---(initialize mapping)----------------------#
   while (i < 9)
      sil!  exec 'map ,'.i.'  :call HBUF_goto("UNSET")<cr>'
      let   i += 1
   endw
   while (i < 25)
      sil!  exec 'map ,A  :call HBUF_goto("UNSET")<cr>'
      let   i += 1
   endw
   "---(process all buffers)---------------------#
   let   i = HBUF_next(0)
   while (i > 0)
      "---(process name)-------------------------#
      let   l:buf_name = bufname(l:i)
      if    (strlen(l:buf_name) < 1)                 ">> only show named
         cont
      endif
      let   l:buf_short = fnamemodify(l:buf_name, ":t")
      let   l:buf_short = substitute(l:buf_short, '[][()]', '', 'g')
      "---(create meaningful markings)-----------#
      if    (bufwinnr(l:i) > 0)                      ">> if in a window
         let   l:buf_mark = ">"
         let l:cur = l:buf_count / l:max_horz
      else
         if    (getbufvar(l:i, '&modified') == 1)     ">> not in window, but changed
            let   l:buf_mark = ")"
         else
            let   l:buf_mark = "]"                  ">> not in window and saved
         endif
      endif
      "---(add to the buffer list)---------------#
      if l:buf_count != 0 && fmod (l:buf_count, l:max_horz) == 0
         let   buf_list .= ">>\n"
      endif
      "---(shortcuts)----------------------------#
      if    buf_count < 10
         let   buf_list .= printf("%d%s%-18.18s ", l:buf_count, l:buf_mark, l:buf_short)
         sil!  exec 'nmap           ,'.l:buf_count.'  ,a:call HBUF_goto("'.l:buf_name.'")<cr>'
      else
         let   buf_list .= printf("%c%s%-18.18s ", l:buf_count + 55, buf_mark, buf_short)
         sil!  exec 'nmap           ,'.nr2char(buf_count + 55).'  ,a:call HBUF_goto("'.l:buf_name.'")<cr>'
      endif
      let   buf_raw  .= buf_name . " "
      let   i = HBUF_next(i)
      let   buf_count += 1
   endw
   "---(update if changed)-----------------------#
   if (g:hbuf_list == l:buf_list)
      retu
   endif
   let g:hbuf_list = l:buf_list
   let g:hbuf_raw  = l:buf_raw
   "---(prepare)---------------------------------#
   setlocal modifiable
   "---(update)----------------------------------#
   1,$d
   norm  _
   put! = l:buf_list
   norm  0
   silent! exec "normal obufs = ".l:buf_count.", cur = ".l:cur." cols = ".l:max_cols." horz = ".l:max_horz
   "---(position)--------------------------------#
   if l:cur > 0
      silent! exec "normal _0".l:cur."j"
   else
      silent! exec "normal _0"
   endif
   norm zt
   "---(done)------------------------------------#
   setlo wrap
   setlo nomodifiable
   "---(complete)--------------------------------#
   retu
endf


func! HBUF_save (prefix)
   " return : -1 is failure, 0 is unmodifiable/unbuflisted, >0 is success
   ""---(locals)-----------+-----------+-##
   let   l:prefix    = "HBUF_save"
   let   l:rce       = -10
   let   l:buf_cur   = bufnr('%')
   "---(check for buffer issuse)-----------------#
   let   l:rce -= 1
   if   (l:buf_cur < 0)
      call  HALL_message (l:prefix, "current buffer is not valid", l:rce)
      retu  l:rce
   endif
   let   l:rce -= 1
   if    (getbufvar(l:buf_cur, '&modifiable') == 0)
      call  HALL_message (l:prefix, "can not execute from specialty (unmodifiable) window", l:rce)
      retu  l:rce
   endif
   let   l:rce -= 1
   if (getbufvar(l:buf_cur, '&buflisted') == 0)
      call  HALL_message (l:prefix, "can not execute from specialty (unbuflisted) window", l:rce)
      retu  l:rce
   endif
   "---(get the buffer name)---------------------#
   let   l:full_name    = bufname(l:buf_cur)
   let   l:base_loc     = match(l:full_name,"[A-Za-z0-9_.]*$")
   let   l:base_name    = strpart(l:full_name,l:base_loc)
   "---(save off the values)---------------------#
   let   g:hbuf_pbuf    = l:buf_cur
   let   g:hbuf_pname   = l:base_name
   let   g:hbuf_pline   = line('.')
   let   g:hbuf_pcol    = col('.')
   "---(complete)--------------------------------#
   retu  g:hbuf_pbuf
endf


function! HBUF_saved()
   echo "buf=".g:hbuf_pbuf.", name=".g:hbuf_pname.", line=".g:hbuf_pline.", col=".g:hbuf_pcol
   return
endfunction


function! HBUF_restore()
   if g:hbuf_pbuf < 1
      echo "saved buffer is invalid..."
      return -1
   endif
   let l:buf_win = bufwinnr(g:hbuf_pbuf)
   if (l:buf_win != -1)
      exec l:buf_win.' wincmd w'
   else
      normal ,a
   endif
   if bufnr('.') != g:hbuf_pbuf
      silent! exec 'b! '.g:hbuf_pbuf
   endif
   if g:hbuf_pline != line('.')
      norm  _
      silent! exec "normal ".let g:hbuf_pline."j"
   endif
   if g:hbuf_pcol != col('.')
      normal 0
      silent! exec "normal ".let g:hbuf_pcol."l"
   endif
   return g:hbuf_pbuf
endfunction



func! HBUF_next(buf_num)
   "---(local variables)-------------------------#
   let l:max  = bufnr('$')          " last buffer.
   let l:cur  = a:buf_num
   let l:nxt  = -1                  " set at end of list
   "---(process all buffers)---------------------#
   while (l:cur < l:max)
      let l:cur = l:cur + 1                      ">> add here to enable continue
      "---(check whether to list)----------------#
      if (getbufvar(l:cur, '&buflisted') != 1)   ">> only show listed
         continue
      endif
      if (getbufvar(l:cur, '&modifiable') != 1)  ">> only show modifiables
         continue
      endif
      let l:buf_name = bufname(l:cur)
      if (strlen(l:buf_name) < 1)                ">> only show named
         continue
      endif
      let l:nxt = l:cur              " current buffer
      break
   endwhile
   return l:nxt
endf



call s:HBUF_init()



""===[[ END ]]=================================================================#
