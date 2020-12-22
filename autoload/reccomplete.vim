" Maintainer:   Zaid Al-Jarrah

if exists('g:autoloaded_rec_autocomplete')
  finish
endif
let g:autoloaded_rec_autocomplete = 1

let s:record_set_descriptors = {
      \ '%allowed': 'List of allowed fields',
      \ '%auto': 'List of fields with auto-generated values',
      \ '%confidential': 'List of encrypted field names',
      \ '%constraint': 'Arbitrary constraint for a given field',
      \ '%doc': 'Description for the record set',
      \ '%key': 'Primary key for the record set (implied %unique and %mandatory)',
      \ '%mandatory': 'List of required fields',
      \ '%prohibit': 'List of prohibited fields',
      \ '%rec': 'Record set type',
      \ '%size': 'Constraint for the total number of records allowed for a record set',
      \ '%sort': 'List of fields to use when querying the records',
      \ '%type': 'Specify the type of a specific field',
      \ '%typedef': 'Declare a new type which can be used in a %type declaration',
      \ '%unique': 'List of unique fields',
      \ }

" Auto-completion function for record sets.
function! reccomplete#Complete(findstart, base) abort
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1

    if s:LineSupportsAutocompletion(l:line)
      while l:start > 0 && l:line[l:start - 1] =~ '\<'
        let l:start -= 1
      endwhile

      if l:start > 1
        let l:start = -3
      endif
    else
      let l:start = -3
    endif

    return l:start
  else
    let res = []
    for [field, description] in s:RecordSetFields()
      if field =~ '^' . a:base
        call add(res, { 'word': field . ':', 'menu': description })
      endif
    endfor
    return res
  endif
endfunction

" Check if a line supports autocompletion (if it starts with a % or is an
" empty line.
function! s:LineSupportsAutocompletion(line) abort
  return a:line =~ '^%' || strlen(trim(a:line)) == 0
endfunction

" Return the list of the record set descriptors.
function! s:RecordSetFields() abort
  return items(s:record_set_descriptors)
endfunction
