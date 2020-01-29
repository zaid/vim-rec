" Vim syntax file
" Language:     GNU's Recutil
" Maintainer:   Zaid Al-Jarrah
" Filenames:    *.rec

if exists("b:current_syntax")
    finish
endif

syntax keyword recKeyword %allowed %auto %confidential %constraint %doc %key
syntax keyword recKeyword %mandatory %prohibit %rec %size %sort %type %typedef %unique
syntax keyword recKeyword %unique

syntax match recComment "\v^#.*$"
syntax match recField "\v^[a-zA-Z]*\:"

syntax match recNumber "\v\-?\d+"
syntax match recNumber "\v\-?\d+\.\d+"
syntax match recNumber "\v\-?0[0-7]+"
syntax match recNumber "\v\-?0[xX][0-9a-fA-F]+"

highlight default link recComment Comment
highlight default link recField Identifier
highlight default link recKeyword Keyword
highlight default link recNumber Number

let b:current_syntax = "rec"
