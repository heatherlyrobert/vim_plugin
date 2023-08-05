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



func!  HALL_start()
   setlo  modifiable
   "---(structural addributes)-------------------#
   setlo  noswapfile
   setlo  buftype=nofile
   setlo  filetype=nofile
   setlo  nobuflisted
   setlo  bufhidden=hide
   "---(cosmetic attributes)---------------------#
   setlo  winfixwidth
   setlo  nowrap
   setlo  textwidth=1000
   setlo  foldcolumn=0
   setlo  nonumber
   setlo  nocursorcolumn
   setlo  nocursorline
   "---(complete)--------------------------------#
   setlo  nomodifiable
   retu
endf



func!  HALL_lock()
   let   g:hbuf_locked      = "y"
   let   g:hcsc_locked      = "y"
   let   g:hfix_locked      = "y"
   let   g:HTAG_locked      = "y"
   retu
endf



func!  HALL_unlock()
   let   g:hbuf_locked      = "n"
   let   g:hcsc_locked      = "n"
   let   g:hfix_locked      = "n"
   let   g:HTAG_locked      = "n"
   retu
endf


"==[ leaf   ]==[[ display a simple statls message ]]===============[ 110n0m ]==#
func! HALL_message (prefix, message, rc)
   if    (a:rc ==  0)
      let   l:status="(good)"
   elsei (a:rc >   0)
      let   l:status=printf("(warning , rc=%d)", a:rc)
   elsei (a:rc < -10)
      let   l:status=printf("(ABORTED , rc=%d)", a:rc)
   elsei (a:rc <   0)
      let   l:status=printf("(SKIPPING, rc=%d)", a:rc)
   endi
   echon printf ("%-12.12s :: %s %s", a:prefix, a:message, l:status)
   retu  0
endf

