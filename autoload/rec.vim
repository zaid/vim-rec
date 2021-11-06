" Maintainer:   Zaid Al-Jarrah

if exists('g:autoloaded_rec')
  finish
endif
let g:autoloaded_rec = 1

" Execute recsel command with arguments.
function! rec#Recsel(...) abort
  call s:ExecuteCommand('recsel', s:GetLocationListCallbackFunctions(), a:000)
endfunction

" Execute recinf command with arguments.
function! rec#Recinf(...) abort
  call s:ExecuteCommand('recinf', s:GetLocationListCallbackFunctions(), a:000)
endfunction

" Execute recfix command with arguments.
function! rec#Recfix(...) abort
  call s:ExecuteCommand('recfix', s:GetLocationListCallbackFunctions(), a:000)
endfunction

" Execute rec2csv command with arguments.
function! rec#Rec2csv(...) abort
  call s:ExecuteCommand('rec2csv', s:GetBufferCallbackFunctions(a:000), a:000)
endfunction

" Find the previous record descriptor.
function! rec#RecPreviousDescriptor() abort
  call s:FindElement('\v^\%rec:', 1)
endfunction

" Find the next record descriptor.
function! rec#RecNextDescriptor() abort
  call s:FindElement('\v^\%rec:', 0)
endfunction

" Execute a command with arguments (either synchronously or asynchronously).
function! s:ExecuteCommand(command, callbackFunctions, arguments) abort
  let commandWithArguments = [a:command]
  let filename = fnameescape(s:GetFilenameFromArgumentsList(a:arguments, expand('%@')))
  let arguments = s:GetCommandArgumentsFromArgumentsList(a:arguments)

  call extend(l:commandWithArguments, l:arguments + [l:filename])
  call s:PrepareLocationWindow(join(l:commandWithArguments))

  if s:SupportsAsyncJobs()
    call s:ExecuteAsyncCommand(a:callbackFunctions, l:commandWithArguments)
  else
    call s:ExecuteSyncCommand(a:callbackFunctions, l:commandWithArguments)
  endif
endfunction

" Check if Vim/Neovim was compiled with job control support.
function! s:SupportsAsyncJobs() abort
  return exists('*job_start') || exists('*jobstart')
endfunction

" Execute a command asynchronously and populate the location list with the
" results.
function! s:ExecuteAsyncCommand(callbackFunctions, commandWithArguments) abort
  let command = a:commandWithArguments[0]

  if exists('*job_start')
    let s:job = job_start(a:commandWithArguments, a:callbackFunctions)
  elseif exists('*jobstart')
    let s:job = jobstart(a:commandWithArguments, a:callbackFunctions)
  else
    throw 'No supported job control mechanism found.'
  endif
endfunction

" Execute a command synchronously and populate the location list with the
" results.
function! s:ExecuteSyncCommand(callbackFunctions, commandWithArguments) abort
  let command = a:commandWithArguments[0]
  let output = system(join(a:commandWithArguments))
  let OutputCallbackFunction = get(a:callbackFunctions, 'out_cb', get(a:callbackFunctions, 'on_stdout'))

  call function(l:OutputCallbackFunction)('', l:output)
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

  if strlen(l:output) > 0
    call setloclist(0, [], 'a', {'lines': split(l:output, "\n", 1)})
    lopen
  endif
endfunction

" The job execution callback which appends the output to a named buffer.
function! s:BufferJobCallback(bufferNumber, channel, msg, ...) abort
  call appendbufline(a:bufferNumber, '$', a:msg)
endfunction

" The job exit callback which splits the window and loads the specified
" buffer.
function! s:BufferExitJobCallback(bufferNumber, ...) abort
  if strlen(join(getbufline(a:bufferNumber, 1))) == 0
    call deletebufline(a:bufferNumber, 1)
  endif

  if bufwinid(a:bufferNumber) == -1
    execute 'sbuffer' . a:bufferNumber
  endif
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

" Return a dictionary with the callback function names for location-list
" output.

function! s:GetLocationListCallbackFunctions() abort
  let callbacks = {}

  if exists('*job_start')
    let l:callbacks['out_cb'] = function('s:LocationListJobCallback')
    let l:callbacks['err_cb'] = function('s:LocationListJobCallback')
  elseif exists('*jobstart')
    let l:callbacks['on_stdout'] = function('s:LocationListJobCallback')
    let l:callbacks['on_stderr'] = function('s:LocationListJobCallback')
  endif

  return l:callbacks
endfunction

" Return a dictionary with the callback function names for location-list
" output.
function! s:GetBufferCallbackFunctions(arguments) abort
  let callbacks = {}
  let filename = s:GetFilenameFromArgumentsList(a:arguments, expand('%@'))
  let bufferNumber = s:AddCsvBuffer(l:filename)

  if exists('*job_start')
    let l:callbacks['out_cb'] = function('s:BufferJobCallback', [l:bufferNumber])
    let l:callbacks['err_cb'] = function('s:LocationListJobCallback')
    let l:callbacks['exit_cb'] = function('s:BufferExitJobCallback', [l:bufferNumber])
  elseif exists('*jobstart')
    let l:callbacks['on_stdout'] = function('s:BufferJobCallback', [l:bufferNumber])
    let l:callbacks['on_stderr'] = function('s:LocationListJobCallback')
    let l:callbacks['on_exit'] = function('s:BufferExitJobCallback', [l:bufferNumber])
  end

  return l:callbacks
endfunction

function! s:AddCsvBuffer(filename) abort
  let csvFilename = substitute(a:filename, '\.rec', '.csv', '')
  let csvBuffer = bufadd(l:csvFilename)
  call bufload(l:csvBuffer)
  call setbufvar(l:csvBuffer, '&buflisted', 1)
  call deletebufline(l:csvBuffer, 1, '$')

  return l:csvBuffer
endfunction

" Find an element in the current buffer without wrapping around the end of
" the file.
function! s:FindElement(pattern, backwards) abort
  let flags = a:backwards ? 'bW' : 'W'

  call search(a:pattern, l:flags)
endfunction
