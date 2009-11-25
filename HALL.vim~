""===[[ START HDOC ]]==========================================================#
""===[[ HEADER ]]==============================================================#

"   niche         : vim-ide (integrated development environment)
"   application   : rsh_all.vim
"   purpose       : provide shared functions and logic for the vim-ide
"   base_system   : gnu/linux
"   lang_name     : vim script
"   created       : 2009-06
"   author        : the_heatherlys
"   dependencies  : none (vim only)
"   permissions   : GPL-2 with no warranty of any kind
"
"
""===[[ PURPOSE ]]=============================================================#

"   rsh_all is a shared set of functions used by most or all of the vim-ide
"   routines as well as some of the critical sections of code that require
"   really careful attention
"
"
""===[[ END HDOC ]]============================================================#



function! HALL_start()
   "---(structural addributes)-------------------#
   setlocal noswapfile
   setlocal buftype=nofile
   setlocal filetype=nofile
   setlocal nobuflisted
   setlocal bufhidden=hide
   "---(cosmetic attributes)---------------------#
   setlocal winfixwidth
   setlocal nowrap
   setlocal textwidth=1000
   setlocal foldcolumn=0
   setlocal nonumber
   setlocal nocursorcolumn
   setlocal nocursorline
   "---(complete)--------------------------------#
   return
endfunction



function! HALL_lock()
   let  g:hbuf_locked      = "y"
   let  g:HTAG_locked      = "y"
   let  g:hcsc_locked      = "y"
   let  g:RSH_FIX_locked   = "y"
   return
endfunction



function! HALL_unlock()
   let  g:hbuf_locked      = "n"
   let  g:HTAG_locked      = "n"
   let  g:hcsc_locked      = "n"
   let  g:RSH_FIX_locked   = "n"
   return
endfunction

