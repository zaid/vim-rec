setlocal commentstring=#\ %s
setlocal iskeyword+=%
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

" Only do this when not done yet for this buffer
if exists('b:did_ftplugin')
  finish
endif

" Return fold level for a given line
function! GetRecFold(lnum) abort
  let currentline = getline(a:lnum)
  let previousline = getline(a:lnum - 1)

  if s:IsRecBlankLine(previousline) && s:IsRecFieldLine(currentline)
    return '1'
  elseif (s:IsRecFieldLine(previousline) || s:IsRecMultilineValue(previousline)) && s:IsRecFieldLine(currentline)
    return '2'
  elseif (s:IsRecFieldLine(previousline) || s:IsRecMultilineValue(previousline)) && s:IsRecMultilineValue(currentline)
    return '3'
  endif

  return '0'
endfunction

" Check if the line starts with a field label
function! s:IsRecFieldLine(line) abort
  return a:line =~? '\v^\w+'
endfunction

" Check if the line starts with a multiline character
function! s:IsRecMultilineValue(line) abort
  return a:line =~? '\v^\+\s*'
endfunction

" Check if the line is a blank line
function! s:IsRecBlankLine(line) abort
  return a:line =~? '\v^\s*$'
endfunction

" Enable folding if Vim was compiled with +folding support
if has('folding') && !get(g:, 'recutils_no_folding')
  setlocal foldmethod=expr
  setlocal foldexpr=GetRecFold(v:lnum)
endif

" Define commands wrappers for GNU Recutils
command! -nargs=* Recsel call rec#Recsel(<f-args>)
command! -nargs=* Recinf call rec#Recinf(<f-args>)
command! -nargs=* Recfix call rec#Recfix(<f-args>)
command! -nargs=* Rec2csv call rec#Rec2csv(<f-args>)
command! RecPreviousDescriptor call rec#RecPreviousDescriptor()
command! RecNextDescriptor call rec#RecNextDescriptor()
command! RecPreviewDescriptor call rec#RecPreviewDescriptor()

" Define command maps
if !get(g:, 'recutils_no_maps')
  nnoremap <buffer> <localleader>rf :Recfix --check<cr>
  nnoremap <buffer> <localleader>rn :Recinf<space>
  nnoremap <buffer> <localleader>rs :Recsel<space>
  nnoremap <buffer> <localleader>rv :Rec2csv<space>
  noremap <silent> <buffer> <localleader>rN :RecNextDescriptor<cr>
  noremap <silent> <buffer> <localleader>rP :RecPreviousDescriptor<cr>
  noremap <silent> <buffer> <localleader>r? :RecPreviewDescriptor<cr>
endif

"" Enable auto-completion for record sets
if has('eval') && !get(g:, 'recutils_no_autocompletion')
  setlocal omnifunc=reccomplete#Complete
endif
