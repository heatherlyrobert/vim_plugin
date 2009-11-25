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
let g:hcsc_locked   = "n"

"---(script/general)-----------------------------#
let s:hcsc_title    = "HCSC_buffer"
let s:hcsc_size     = 10

"---(script/search)------------------------------#
let s:hcsc_soption     = ""
let s:hcsc_sword1      = ""
let s:hcsc_sword2      = ""
let s:hcsc_sregex      = ""
let s:hcsc_syank       = ""
let s:hcsc_scurr       = ""
let s:hcsc_sbufname    = ""
let s:hcsc_ssubject    = ""
let s:hcsc_sscope      = ""
let s:hcsc_smessage    = ""

"---(script/tag)---------------------------------#
let s:hcsc_tagn        = ""
let s:hcsc_line        = 0
let s:hcsc_file        = ""
let s:hcsc_orig        = ""



"==============================================================================#
"=======                        initialization                          =======#
"==============================================================================#



"===[ ROOT   ]===> main setup routine
function! s:HCSC_init()
   silent! exec 'botright split ' . s:hcsc_title
   setlocal modifiable
   call HALL_start()
   call s:HCSC_syntax()
   call s:HCSC_keys()
   setlocal nomodifiable
   hide
   return
endfunction



"===[ LEAF   ]===> establish syntax highlighting
function! s:HCSC_syntax()
   syntax clear
   syntax match hcsc_mtag     '^[a-z-][a-z-]  '        containedin=hcsc_entry
   syntax match hcsc_ftag     ' \[[a-z-][a-z-]\] '   containedin=hcsc_entry
   syntax match hcsc_num      ' : [0-9 ][0-9 ][0-9 ][0-9] : ' containedin=hcsc_entry
   syntax match hcsc_entry    '^[a-z-][a-z-]  .*$'
            \ containedin=rsh_fix_eone, rsh_fix_wone
   hi hcsc_entry    cterm=bold   ctermbg=none  ctermfg=3
   hi hcsc_mtag     cterm=bold   ctermbg=none  ctermfg=4
   hi hcsc_ftag     cterm=bold   ctermbg=none  ctermfg=4
   hi hcsc_num      cterm=bold   ctermbg=none  ctermfg=5
   syntax match hcsc_count    ' [0-9][0-9]* '        containedin=hcsc_sum
   syntax match hcsc_search   '^? :: .*$'
   syntax match hcsc_sum      '^grep/cscope .*$'
   hi hcsc_search   cterm=none   ctermbg=1     ctermfg=none
   hi hcsc_sum      cterm=none   ctermbg=2     ctermfg=none
   hi hcsc_count    cterm=none   ctermbg=3     ctermfg=none
   return
endfunction



"===[ LEAF   ]===> establish the buffer specific key mapping
function! s:HCSC_keys()
   nmap          ,g       :call HCSC_show(expand("<cword>"), expand("<cWORD>"))<cr>
   "---(types of searches)---------------------------#
   nmap <buffer>  a       :call HCSC_search("a")<cr>
   nmap <buffer>  A       :call HCSC_search("A")<cr>
   nmap <buffer>  b       :call HCSC_search("b")<cr>
   nmap <buffer>  B       :call HCSC_search("B")<cr>
   nmap <buffer>  p       :call HCSC_search("p")<cr>
   nmap <buffer>  P       :call HCSC_search("P")<cr>
   nmap <buffer>  s       :call HCSC_search("s")<cr>
   nmap <buffer>  S       :call HCSC_search("S")<cr>
   nmap <buffer>  y       :call HCSC_search("y")<cr>
   nmap <buffer>  Y       :call HCSC_search("Y")<cr>
   "---(presentation/size)---------------------------#
   nmap <buffer>  -       :call HCSC_resize("-")<cr>
   nmap <buffer>  +       :call HCSC_resize("+")<cr>
   nmap <buffer>  h       :call HCSC_hide()<cr>
   "---(replacement)---------------------------------#
   nmap <buffer>  v       :call HCSC_replace(1)<cr>
   nmap <buffer>  r       :call HCSC_replace(2)<cr>
   "nmap          ;r       :call RSH_CSC_replace()<cr>
   return
endfunction



""===[[ START/STOP ]]==========================================================#



function! HCSC_show(cword1, cword2)
   "---(remember where we were)------------------#
   if (HBUF_save("HCSC_show()         :: ") < 1)
      return
   endif
   let  s:hcsc_sbufname = bufname('%')
   "---(lock it down)----------------------------#
   call HALL_lock()
   "---(check for the buffer)--------------------#
   let l:buf_num = HBUF_by_name(s:hcsc_title) 
   if (l:buf_num < 0)
      call s:HCSC_init()
   elseif (l:buf_num > 0)
      hide
   endif
   "---(open the buffer window)------------------#
   silent! exec 'botright split ' . s:hcsc_title
   silent! exec "resize ".s:hcsc_size
   "---(grab the current conditions)-------------#
   let  s:hcsc_sword1  = a:cword1
   let  s:hcsc_sword2  = a:cword2
   let  s:hcsc_sregex  = @/
   let  s:hcsc_sregex  = substitute(s:hcsc_sregex, "\\", "", "g")
   let  s:hcsc_sregex  = substitute(s:hcsc_sregex, "\<", "", "g")
   let  s:hcsc_sregex  = substitute(s:hcsc_sregex, "\>", "", "g")
   let  s:hcsc_syank   = strpart(substitute(@0, "[\n\'\"]", "", "g"), 0, 20)
   "---(update the top line)---------------------#
   setlocal modifiable
   call  s:HCSC_topline()
   setlocal nomodifiable
   "---(open it up)------------------------------#
   call HALL_unlock()
   "---(complete)--------------------------------#
   return
endfunction



function! HCSC_resize(height)
   " update size and stay in the window
   " allow a range of 10 - 40 lines
   let s:hcsc_size  = winheight(0)
   if (a:height == "+")
      let s:hcsc_size += 10
   else
      let s:hcsc_size -= 10
   endif
   if (s:hcsc_size > 40)
      let s:hcsc_size = 40
   endif
   if (s:hcsc_size < 10)
      let s:hcsc_size = 10
   endif
   silent! exec "resize ".s:hcsc_size
   return
endfunction



function! HCSC_hide()
   "---(check for the buffer)--------------------#
   let l:buf_num = bufnr(s:hcsc_title)
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
   echon "HCSC_hide()      :: put away the cscope/grep window..."
   "---(complete)--------------------------------#
   normal ,a
   return
endfunction



function! s:HCSC_sparms(type)
   setlocal noignorecase
   setlocal nosmartcase
   let  s:hcsc_soption   = a:type
   if     a:type == "A"
      let  s:hcsc_ssubject = s:hcsc_sword1
      let  s:hcsc_sscope   = '*.{c,h,cpp,hpp,vim,sh}'
      let  s:hcsc_smessage = "in all programs (c,h,cpp,hpp,vim,sh) in current directory..."
   elseif a:type == "a"
      let  s:hcsc_ssubject = s:hcsc_sword1
      let  s:hcsc_sscope   = s:hcsc_sbufname
      let  s:hcsc_smessage = "in just the ".s:hcsc_sscope." program file..."
   elseif a:type == "B"
      let  s:hcsc_ssubject = s:hcsc_sword2
      let  s:hcsc_sscope   = '*.{c,h,cpp,hpp,vim,sh}'
      let  s:hcsc_smessage = "in all programs (c,h,cpp,hpp,vim,sh) in current directory..."
   elseif a:type == "b"
      let  s:hcsc_ssubject = s:hcsc_sword2
      let  s:hcsc_sscope   = s:hcsc_sbufname
      let  s:hcsc_smessage = "in just the ".s:hcsc_sscope." program file..."
   elseif a:type == "P"
      if (s:hcsc_scurr ==  "")
         return -1
      endif
      let  s:hcsc_ssubject = s:hcsc_scurr
      let  s:hcsc_sscope   = '*.{c,h,cpp,hpp,vim,sh}'
      let  s:hcsc_smessage = "in all programs (c,h,cpp,hpp,vim,sh) in current directory..."
   elseif a:type == "p"
      if (s:hcsc_scurr ==  "")
         return -1
      endif
      let  s:hcsc_ssubject = s:hcsc_scurr
      let  s:hcsc_sscope   = s:hcsc_sbufname
      let  s:hcsc_smessage = "in just the ".s:hcsc_sscope." program file..."
   elseif a:type == "S"
      let  s:hcsc_ssubject = s:hcsc_sregex
      let  s:hcsc_sscope   = '*.{c,h,cpp,hpp,vim,sh}'
      let  s:hcsc_smessage = "in all programs (c,h,cpp,hpp,vim,sh) in current directory..."
   elseif a:type == "s"
      let  s:hcsc_ssubject = s:hcsc_sregex
      let  s:hcsc_sscope   = s:hcsc_sbufname
      let  s:hcsc_smessage = "in just the ".s:hcsc_sscope." program file..."
   elseif a:type == "Y"
      let  s:hcsc_ssubject = s:hcsc_syank
      let  s:hcsc_sscope   = '*.{c,h,cpp,hpp,vim,sh}'
      let  s:hcsc_smessage = "in all programs (c,h,cpp,hpp,vim,sh) in current directory..."
   elseif a:type == "y"
      let  s:hcsc_ssubject = s:hcsc_syank
      let  s:hcsc_sscope   = s:hcsc_sbufname
      let  s:hcsc_smessage = "in just the ".s:hcsc_sscope." program file..."
   else
      return -2
   endif
   let  s:hcsc_scurr  = s:hcsc_ssubject
   return 0
endfunction



function! HCSC_search(type)
   if (bufwinnr(g:HTAG_title) < 1)
      echon "HCSC_search()    :: tag window must be open (returning)..."
      return
   endif
   "---(local variables)-------------------------#
   let  l:hmajor    = 13                         " major letter of hint (awk)
   let  l:hminor    = 0                          " minor letter of hint (awk)
   let  l:replace   = "[zz] testing"             " default function ref
   let  l:full_line = ""                         " current buffer line contents
   let  l:line_eof  = 0                          " end of file line number
   let  l:entry     = 1                          " current iteration
   "---(pick search subject)---------------------#
   if (s:HCSC_sparms(a:type) < 0)
      return
   endif
   call HALL_lock()
   "---(clean off old data)----------------------#
   setlocal modifiable
   normal "GG"
   let  l:line_eof     = line('.')
   if (l:line_eof > 1)
      exec ":2,$delete"
   endif
   normal o
   "---(find with grep)--------------------------#
   exec ":silent $!grep --line-number --with-filename --no-messages --word-regexp \"".s:hcsc_ssubject."\" ".s:hcsc_sscope
   "---(clean with awk)--------------------------#
   silent! exec ":silent! 2,$!rsh_csc.awk 'g_hmajor=".l:hmajor."' 'g_hminor=".l:hminor."' 'g_symbol=".s:hcsc_ssubject."' 'g_scope=".s:hcsc_smessage."' 'g_option=".s:hcsc_soption."'"
   "---(set match syntax)------------------------#
   execute 'silent! syntax clear hcsc_match'
   execute 'highlight hcsc_match cterm=bold ctermbg=4 ctermfg=6'
   execute 'syntax match hcsc_match "\<' .s:hcsc_ssubject. '\>" containedin=ALL'
   "---(get the last line)-----------------------#
   normal "GG"
   let  l:line_eof = line('.') - 2
   let  l:entry    = 1
   if (l:entry > l:line_eof)
      normal o
      normal 0
      exec "normal igrep/cscope has 0 matches...                                                                                            "
   endif
   "---(get the function names)------------------#
   while l:entry <= l:line_eof
      exec "normal ".(l:entry + 2)."G"
      call s:HCSC_parse()
      let  l:replace = HTAG_findloc(s:hcsc_file, s:hcsc_line)
      call s:HCSC_fixtag(l:replace)
      let l:entry = l:entry + 1
   endwhile
   "---(complete)--------------------------------#
   call  s:HCSC_topline()
   normal gg
   setlocal nomodifiable
   call HBUF_restore()
   call HALL_unlock()
   return
endfunction



function! s:HCSC_parse()
   "---(initialize)------------------------------#
   let  s:hcsc_tagn    = ""
   let  s:hcsc_line    = 0
   let  s:hcsc_file    = ""
   let  s:hcsc_orig    = ""
   "---(check for null)--------------------------#
   let  l:full_line = getline('.')
   if (strpart(l:full_line, 2, 2) != "  ")
      return 0
   endif
   "---(tag number)------------------------------#
   let  s:hcsc_tagn    = strpart(l:full_line, 0, 2)
   "---(file name)-------------------------------#
   normal 0
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
   return 1
endfunction



function! s:HCSC_topline()
   let l:linenum = line('.')
   normal gg
   normal 0
   exec "normal R? :: ".
            \ " p=<".s:hcsc_scurr.">  ".
            \ " a=<".s:hcsc_sword1.">  ".
            \ " b=<".s:hcsc_sword2.">  ".
            \ " s=<".s:hcsc_sregex.">  ".
            \ " y=<".s:hcsc_syank.">  ".
            \ "                                                                  "
   normal 0
   normal gg
   "silent! exec "normal " . (l:linenum - 1) . "j"
   "silent! exec "normal z."
   return
endfunction



function! s:HCSC_fixtag(tagtext)
   normal 0
   normal 25l
   exec "normal R".a:tagtext
   let l:its_buf = bufnr(s:hcsc_file)
   if l:its_buf < 1
      let l:its_buf = '-'
   endif
   if l:its_buf > 9
      let l:its_buf = '+'
   endif
   normal 0
   normal 4l
   exec "normal R".l:its_buf
   return
endfunction



function! HCSC_hints(tag)
   "---(switch to tag window)-----------------#
   let    l:buf_cur = bufnr('%')
   let    l:win_num = HBUF_by_name(s:hcsc_title)
   if (l:win_num < 1)
      echon "  -- CSC not open, can not process..."
   endif
   silent exec l:win_num.' wincmd w'
   normal gg
   "---(find the tag)-------------------------#
   call   search("^" . a:tag . "  ")
   if line(".") < 2
      echon "  -- tag not found, can not process..."
      return
   endif
   normal 0
   let  l:full_line    = getline('.')
   "---(parse the tag entry)------------------#
   normal 7l
   normal E
   let  l:word_end = col('.')
   let  l:rcsc_file    = strpart(l:full_line, 6, l:word_end - 6)
   "---(get the line number)------------------#
   normal 0
   normal 52lw
   let  l:word_beg = col('.') - 1
   normal e
   let  l:word_end = col('.')
   let  l:rcsc_line    = strpart(l:full_line, l:word_beg, l:word_end - l:word_beg) + 0
   "---(get back to the original window)------#
   normal ,a
   let l:buf_num = bufnr(l:rcsc_file)
   if (l:buf_num == -1)
      echon "HCSC_hints()          :: buffer not open in wim..."
      return
   else
      silent exec('b! ' . l:buf_num)
   endif
   "---(get to the right line)----------------# make sure to show comments above
   normal gg
   silent! exec "normal " . (l:rcsc_line - 1) . "j"
   silent! exec "normal z."
   "---(do special highlighting)--------------#
   "silent exec "highlight rsh_tag_match cterm=reverse"
   "silent exec "match rsh_tag_match /".l:rtag_iden."/"
   return
endfunction



function! HCSC_replace(pass)
   " TODO handle both a "r" (global) and an "R" (only in current buffer/file)
   "---(local variables)-------------------------#
   let  l:line_eof   = 0                         " end of file line number
   let  l:entry      = 1                         " current iteration
   let  l:prog_line  = 0
   let  l:tobe       = ""
   let  l:confirm    = ""
   let  l:misses     = 0
   let  l:pass_count = 1
   "---(lock us in)------------------------------#
   call HALL_lock()
   let l:my_buf      = bufnr('%')     " get the tag buffer number
   while (l:pass_count <= a:pass)
      silent exec('b! ' . l:my_buf)
      let  l:entry      = 1                         " current iteration
      if (l:pass_count == 2)
         "---(get the replacement text)----------------#
         redrawstatus
         let l:tobe = input("change <<".s:hcsc_scurr.">> to : ", s:hcsc_scurr)
         if (l:tobe == "")
            echo "RSH_CSC_replace()        :: tobe null, canceled by user..."
            call HBUF_restore()
            call HALL_unlock()
            return -3
         endif
         "---(verify the change)-----------------------#
         let    l:confirm = input("change <<".s:hcsc_scurr.">> to <<".l:tobe.">> (y/n/c) : ", "n")
         if (l:confirm != "y" && l:confirm != "c")
            echo "RSH_CSC_replace()        :: canceled by user..."
            call HBUF_restore()
            call HALL_unlock()
            return -3
         endif
      endif
      "---(get the last line)-----------------------#
      normal "GG"
      let  l:line_eof = line('.') - 2
      if (l:entry > l:line_eof)
         call HBUF_restore()
         call HALL_unlock()
         return -1
      endif
      "---(cycle through the entries)---------------#
      while l:entry <= l:line_eof
         exec "normal ".(l:entry + 2)."G"
         call s:HCSC_parse()
         echon "HCSC_search()    :: (p=".l:pass_count.") processing file=".s:hcsc_file.", line=".s:hcsc_line."..."
         let l:buf_num = bufnr(s:hcsc_file)
         if (l:buf_num == -1)
            echon "HCSC_hints()          :: could not load ".s:hcsc_file." FATAL..."
            let l:misses += 1
         endif
         silent! exec('b! ' . l:buf_num)
         "---(get to the right line)----------------# make sure to show comments above
         normal gg
         silent! exec "normal ".s:hcsc_line."G"
         let  l:curr_line = getline('.')
         if (l:curr_line != s:hcsc_orig)
            echon "HCSC_search()    :: could not match line ".l:entry." to original..."
            let l:misses += 1
         else
            echon "HCSC_search()    :: matched line ".l:entry." to original..."
         endif
         "sleep 1
         if (l:pass_count == 2)
            setlocal noignorecase
            setlocal nosmartcase
            let  l:curr_line = getline('.')
            "echo "HCSC_search()    :: current line ".l:curr_line."..."
            let  l:adj_line  = "  ".l:curr_line."  "  " to ease bol and eol match
            let  l:pattern   = "\\(\\W\\)".s:hcsc_scurr."\\(\\W\\)"
            "echo "HCSC_search()    :: pattern is ".l:pattern."..."
            let  l:new_line = substitute(l:adj_line, l:pattern, "\\1".l:tobe."\\2", "g")
            let  l:new_line  = strpart(l:new_line, 2, strlen(l:new_line) - 4)
            "echo "HCSC_search()    :: changed to ".l:new_line."..."
            if (l:new_line == s:hcsc_orig)
               echon "HCSC_search()    :: change on line ".l:entry." didn't take..."
               let l:misses += 1
            else
               normal 0
               normal D
               exec "normal R".l:new_line
            endif
            setlocal ignorecase
            setlocal smartcase
         endif
         silent exec('b! ' . l:my_buf)
         "---(get ready for the next loop)----------#
         let l:entry = l:entry + 1
      endwhile
      "---(lock us in)------------------------------#
      silent! exec('b! ' . l:my_buf)
      normal gg
      normal 0
      "---(complete)--------------------------------#
      if (l:pass_count == 1)
         if (l:misses == 0)
            echon "HCSC_search()    :: all matched."
         else
            echon "HCSC_search()    :: missed on ".l:misses." lines (ABORTED) ..."
            call HBUF_restore()
            call HALL_unlock()
            return -1
         endif
      elseif (l:pass_count == 2)
         if (l:misses == 0)
            echon "HCSC_search()    :: all changes successful."
         else
            echon "HCSC_search()    :: failed on ".l:misses." changes ..."
         endif
      endif
      let l:pass_count = l:pass_count + 1
   endwhile
   call HBUF_restore()
   call HALL_unlock()
   return 0
endfunction



call s:HCSC_init()
""===[[ END ]]=================================================================#
