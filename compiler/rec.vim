" Vim Compiler File
" Compiler:	rec

if exists("current_compiler")
  finish
endif
let current_compiler = "rec"

if exists(":CompilerSet") != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet errorformat=%f:%l:\ %trror:\ %m
CompilerSet errorformat+=%f:\ %l:\ %trror:\ %m
exe 'CompilerSet makeprg=recfix\ '.substitute(shellescape(expand('%')), ' ', '\\ ', 'g')
