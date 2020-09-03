" Maintainer:   Zaid Al-Jarrah

if exists('g:autoloaded_rec')
  finish
endif
let g:autoloaded_rec = 1

" Execute a command with arguments (either synchronously or asynchronously).
function! rec#ExecuteCommand(command, ...) abort
  let commandWithArguments = [a:command]
  let filename = fnameescape(s:GetFilenameFromArgumentsList(a:000, expand('%@')))
  let arguments = s:GetCommandArgumentsFromArgumentsList(a:000)

  call extend(l:commandWithArguments, l:arguments + [l:filename])
  call s:PrepareLocationWindow(join(l:commandWithArguments))

  if s:SupportsAsyncJobs()
    call s:ExecuteAsyncCommand(l:commandWithArguments)
  else
    call s:ExecuteSyncCommand(l:commandWithArguments)
  endif
endfunction

" Check if Vim/Neovim was compiled with job control support.
function! s:SupportsAsyncJobs() abort
  return exists('*job_start') || exists('*jobstart')
endfunction

" Execute a command asynchronously and populate the location list with the
" results.
function! s:ExecuteAsyncCommand(commandWithArguments) abort
  let command = a:commandWithArguments[0]

  if exists('*job_start')
    let s:job = job_start(a:commandWithArguments, s:GetCallbackFunctionsForVim(l:command))
  elseif exists('*jobstart')
    let s:job = jobstart(a:commandWithArguments, s:GetCallbackFunctionsForNeovim(l:command))
  else
    throw 'No supported job control mechanism found.'
  endif
endfunction

" Execute a command synchronously and populate the location list with the
" results.
function! s:ExecuteSyncCommand(commandWithArguments) abort
  let command = a:commandWithArguments[0]
  let output = system(join(a:commandWithArguments))
  let callbackFunction = s:GetOutputCallbackFunctionName(l:command)

  call function(l:callbackFunction)('', l:output)
endfunction

" Prepare the location list by clearing it's content, setting the title to the command
" that we're going to execute (plus it's arguments) then closing the window
" (in case it was open from a previous run).
function! s:PrepareLocationWindow(command) abort
  call setloclist(0, [], 'r', {'title': a:command, 'lines': []})
  lclose
endfunction

" The job execution callback which appends the output to the location list.
function! s:LocationListJobCallback(channel, msg, ...) abort
  let output = type(a:msg) == type([]) ? join(a:msg, "\n") : a:msg
  call setloclist(0, [], 'a', {'lines': split(l:output, "\n", 1)})
  lopen
endfunction

" Parse the command arguments and return the filename.
function! s:GetFilenameFromArgumentsList(arguments, defaultValue) abort
  if empty(a:arguments)
    return a:defaultValue
  endif

  let filename = filter(copy(a:arguments), {idx, entry -> match(expand(entry), '\v[[:alnum:]]+\.rec$') != -1})
  return empty(filename) ? a:defaultValue : expand(get(filename, 0))
endfunction

" Parse the command arguments and return a list without the filename.
function! s:GetCommandArgumentsFromArgumentsList(arguments) abort
  return filter(copy(a:arguments), { idx, entry -> match(expand(entry), '\v[[:alnum:]]+\.rec$') == -1 || empty(entry) })
endfunction

" Get the success callback function name for a specific command.
function! s:GetOutputCallbackFunctionName(command) abort
  return 's:LocationListJobCallback'
endfunction

" Get the error callback function name for a specific command.
function! s:GetErrorCallbackFunctionName(command) abort
  return 's:LocationListJobCallback'
endfunction

" Return a dictionary with the callback function names for Vim.
function! s:GetCallbackFunctionsForVim(command) abort
  return {
        \ 'out_cb': function(s:GetOutputCallbackFunctionName(a:command)),
        \ 'err_cb': function(s:GetErrorCallbackFunctionName(a:command)),
        \ }
endfunction

" Return a dictionary with the callback function names for Neovim.
function! s:GetCallbackFunctionsForNeovim(command) abort
  return {
        \ 'on_stdout': function(s:GetOutputCallbackFunctionName(a:command)),
        \ 'on_stderr': function(s:GetErrorCallbackFunctionName(a:command)),
        \ }
endfunction
