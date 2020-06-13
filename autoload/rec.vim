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

  call extend(commandWithArguments, [filename] + arguments)
  call s:PrepareLocationWindow(join(commandWithArguments))

  if s:SupportsAsyncJobs()
    call s:ExecuteAsyncCommand(commandWithArguments)
  else
    call s:ExecuteSyncCommand(commandWithArguments)
  endif
endfunction

" Check if Vim/Neovim was compiled with job control support.
function! s:SupportsAsyncJobs() abort
  return exists('*job_start') || exists('*jobstart')
endfunction

" Execute a command asynchronously and populate the location list with the
" results.
function! s:ExecuteAsyncCommand(commandWithArguments) abort
  if exists('*job_start')
    let callbackFunctions = {
          \ 'callback': function('s:JobCallback')
          \ }
    let s:job = job_start(a:commandWithArguments, callbackFunctions)
  elseif exists('*jobstart')
    let callbackFunctions = {
          \ 'on_stdout': function('s:JobCallback'),
          \ 'on_stderr': function('s:JobCallback'),
          \ }
    let s:job = jobstart(a:commandWithArguments, callbackFunctions)
  else
    throw 'No supported job control mechanism found.'
  endif
endfunction

" Execute a command synchronously and populate the location list with the
" results.
function! s:ExecuteSyncCommand(commandWithArguments) abort
  let output = system(join(a:commandWithArguments))
  call s:JobCallback('', output)
endfunction

" Prepare the location list by clearing it's content, setting the title to the command
" that we're going to execute (plus it's arguments) then closing the window
" (in case it was open from a previous run).
function! s:PrepareLocationWindow(command) abort
  call setloclist(0, [], 'r', {'title': a:command, 'lines': []})
  lclose
endfunction

" The job execution callback which appends the output to the location list.
function! s:JobCallback(channel, msg, ...) abort
  let output = type(a:msg) == type([]) ? join(a:msg, "\n") : a:msg
  call setloclist(0, [], 'a', {'lines': split(output, "\n", 1)})
  lopen
endfunction

function! s:GetFilenameFromArgumentsList(arguments, defaultValue) abort
  if empty(a:arguments)
    return a:defaultValue
  endif

  let filename = filter(copy(a:arguments), { idx, entry -> match(expand(entry), '\v[[:alnum:]]+\.rec$') != -1 })->get(0)
  return filename->empty() ? a:defaultValue : expand(filename)
endfunction

function! s:GetCommandArgumentsFromArgumentsList(arguments) abort
  return filter(copy(a:arguments), { idx, entry -> match(expand(entry), '\v[[:alnum:]]+\.rec$') == -1 || empty(entry) })
endfunction
