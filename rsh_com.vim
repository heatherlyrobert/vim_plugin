""===[[ START HDOC ]]==========================================================#
""===[[ HEADER ]]==============================================================#

"   niche         : integrated development environment
"   application   : rsh_com.vim
"   purpose       : rapid commenting, comment alignment, and uncommenting
"   base_system   : gnu/linux
"   lang_name     : vim script
"   created       : svq - long, long ago
"   author        : the_heatherlys
"   dependencies  : none (vim only)
"   permissions   : GPL-2 with no warranty of any kind
"
"
""===[[ PURPOSE ]]=============================================================#

"   rsh_com is a simple, focused, and fast C commenting tool to keep the
"   programmer focused on writing code rather than the nastiness of blocking,
"   aligning, realigning, and clearing of comments.  without comments, code
"   can be difficult to follow, so why not make it as simple, fast, and
"   efficient as possible
"
"   rsh_com is focused on...
"   - changing a code block/line into a code comment (encomment)
"   - changing a code comment into a code block/line (decomment)
"   - uncommenting a line or a multi-line comment
"   - adding a line comment
"   - adding an end-of-line comment
"   - section comments
"   - header comments and its sub-sections
"   - aligning end-of-line comments
"
"
""===[[ FORMATTING ]]==========================================================#

"   code comments are to temporarily separate out code so that it is not seen
"   by the compilier, but can still be easily retrieved by the programmer for
"   later inclusion.  they should stand out, but not so much as to not be seen
"   within the normal flow of the program.  it would also be useful to have the
"   comment marks be unique so they are easy to find, maintain, and transform
"      - encomment a code block or line
"      - decomment a code block or line
"
"
""===[[ END HDOC ]]============================================================#



"==============================================================================#
"                               header guard                                   #
"==============================================================================#
if exists('RSH_COM_hguard')
   finish
endif
let g:RSH_COM_hguard = 1



"==============================================================================#
"                             global variables                                 #
"==============================================================================#
let  g:preA = "/*> "
let  g:preB = " *> "
let  g:sufA = " <* "
let  g:sufB = " <*/"



noremap  ,cc     :call RSH_COM_en_comment()<cr>
noremap  ,cu     :call RSH_COM_de_comment()<cr>



function! RSH_COM_en_comment() range
   "---(local variables)-------------------------#
   let l:ind_1st    = indent(a:firstline)        " first line indentation
   let l:ind_len    = l:ind_1st                  " current line indentation
   let l:ind_min    = 1000                       " minimum indentation
   let l:line_max   = 0                          " longest line length
   let l:line_num   = a:firstline                " line being processed
   let l:line_cur   = ""                         " contents of current line
   "---(get line statistics)---------------------#
   while l:line_num <= a:lastline
      let l:ind_len   = indent(l:line_num)
      let l:ind_min   = min([l:ind_len, l:ind_min])
      let l:line_cur  = getline(l:line_num)
      let l:line_max  = max([l:line_max, len(l:line_cur)])
      let l:line_num += 1
   endwhile
   "---(fail on indent issues)-------------------#
   if  l:ind_1st != l:ind_min
      echon "RSH_COM_to_comment()     :: indent must only grow..."
      return
   endif
   "---(mask internal comments)------------------#
   exec ":".a:firstline.",".a:lastline."s,/[*],/+,ge"
   exec ":".a:firstline.",".a:lastline."s,[*]/,+/,ge"
   "---(process comment)-------------------------#
   let l:a  = a:firstline
   let l:b  = indent(l:a)
   let l:c  = max([l:line_max + 6, 85])
   let l:s  = repeat(" ", l:c)
   let l:t  = repeat(" ", l:b)
   call setline(l:a, strpart(l:t.g:preA.strpart(getline(l:a),l:b).l:s, 0, l:c).g:sufA)
   let l:a += 1
   while l:a <= a:lastline
      call setline(l:a, strpart(l:t.g:preB.strpart(getline(l:a),l:b).l:s, 0, l:c).g:sufA)
      let l:a += 1
   endwhile
   let l:a -= 1
   call setline(l:a, strpart(getline(l:a), 0, strlen(getline(l:a)) - strlen(g:sufA)).g:sufB)
   "---(first line)------------------------------#
   return
endfunction



function! RSH_COM_cc_status(line_beg, line_end)
   "---(local variables)-------------------------#
   let l:ind_base   = indent(a:firstline)        " base indentation
   let l:pre_len    = strlen(g:preA)             " prefix size
   let l:pre_cur    = ""                         " current prefix
   let l:suf_len    = strlen(g:sufA)             " suffix size
   let l:suf_cur    = ""                         " current suffix
   let l:line_num   = a:line_beg                 " line being processed
   let l:line_cur   = ""                         " contents of current line
   let l:line_len   = ""                         " length of current line
   "---(test prefixes)---------------------------#
   "> echo "checking lines ".a:line_beg." to ".a:line_end." ..."
   "> sleep 2
   while l:line_num <= a:line_end
      let l:line_cur  = getline(l:line_num)
      let l:line_len  = strlen(l:line_cur)
      "---(check prefixes)-----------------------#
      let l:pre_cur   = strpart(l:line_cur, l:ind_base, l:pre_len)
      if l:line_num == a:line_beg
         if l:pre_cur != g:preA
            echon "RSH_COM_cc_status()      :: bad prefix on first line..."
            return -1
         endif
      else
         if l:pre_cur != g:preB
            echon "RSH_COM_cc_status()      :: bad prefix on line (".(l:line_num - a:firstline + 1).")..."
            return -1
         end
      endif
      "---(check suffixes)-----------------------#
      let l:suf_cur   = strpart(l:line_cur, (l:line_len - l:suf_len))
      if l:line_num == a:line_end
         if l:suf_cur != g:sufB
            echon "RSH_COM_cc_status()      :: bad suffix on last line..."
            return -2
         endif
      else
         if l:suf_cur != g:sufA
            echon "RSH_COM_cc_status()      :: bad suffix on line (".(l:line_num - a:firstline + 1).")..."
            return -2
         endif
      endif
      let l:line_num += 1
   endwhile
   "> echon "RSH_COM_cc_status()      :: prefixes and suffixes are good..."
   return 0
endfunction



function! RSH_COM_de_comment() range
   "---(local variables)-------------------------#
   let l:ind_base   = indent(a:firstline)        " base indentation
   let l:pre_len    = strlen(g:preA)             " prefix size
   let l:suf_len    = strlen(g:sufA)             " suffix size
   let l:line_num   = a:firstline                " line being processed
   let l:line_cur   = ""                         " contents of current line
   let l:line_len   = ""                         " length of current line
   let l:line_beg   = l:ind_base + l:pre_len
   let l:line_end   = 0
   let r            = 0                          " temp return code
   "---(check for format)------------------------#
   let r = RSH_COM_cc_status(a:firstline, a:lastline)
   if r != 0
      echon "RSH_COM_de_comment()     :: format does not check out..."
      return
   end
   "---(test prefixes)---------------------------#
   while l:line_num <= a:lastline
      let l:line_cur  = getline(l:line_num)
      let l:line_len  = strlen(l:line_cur)
      let l:line_end  = l:line_len - l:suf_len  - l:line_beg
      let l:line_cur  = strpart(l:line_cur, l:line_beg, l:line_end)
      call setline(l:line_num, repeat(" ",l:ind_base).l:line_cur)
      let l:line_num += 1
   endwhile
   "---(take spaces off the end)-----------------#
   exec ":".a:firstline.",".a:lastline."s/[ ]*$//ge"
   exec ":".a:firstline.",".a:lastline."s/<[*]$/<* /ge"
   "---(unmask internal comments)----------------#
   exec ":".a:firstline.",".a:lastline."s,/[+],/*,ge"
   exec ":".a:firstline.",".a:lastline."s,[+]/,*/,ge"
   "---(complete)--------------------------------#
   return
endfunction
