" Vim syntax file
" Language:     GNU's Recutils
" Maintainer:   Zaid Al-Jarrah
" Filenames:    *.rec

if exists("b:current_syntax")
    finish
endif

syntax keyword recKeyword %allowed %auto %confidential %doc %key
syntax keyword recKeyword %mandatory %prohibit %rec %sort %unique
syntax keyword recKeyword %unique

syntax match recComment "\v^#.*$"
syntax match recField "\v^\w+"
syntax match recComparisonOperator "\v\>?\<?\!?\=?" contained
syntax match recMultilineMarker "\v^\+"

syntax keyword recType int bool range real size line regexp date contained containedin=recTypeAssociation,recTypeDeclaration
syntax keyword recType enum field email uuid rec contained containedin=recTypeAssociation,recTypeDeclaration
syntax region recTypeComment start="\v\(" end="\v\)" contained containedin=recTypeAssociation,recTypeDeclaration
syntax match recTypeAssociation "\v^[%]type\: .*"hs=s,he=s+5 contains=recType
syntax match recTypeDeclaration "\v^[%]typedef\: .*"hs=s,he=s+8 contains=recType
syntax keyword recTypeLimit MIN MAX contained containedin=recTypeAssociation,recTypeDeclaration
syntax match recConstraintDeclaration "\v^[%]constraint\: .*"hs=s,he=s+11 contains=recComparisonOperator
syntax match recSizeDeclaration "\v^[%]size\: .*"hs=s,he=s+5 contains=recComparisonOperator

syntax match recNumber "\v\-?\d+"
syntax match recNumber "\v\-?\d+\.\d+"
syntax match recNumber "\v\-?0\o+"
syntax match recNumber "\v\-?0[xX]\x+"

highlight default link recComment Comment
highlight default link recComparisonOperator Operator
highlight default link recConstraintDeclaration Keyword
highlight default link recField Label
highlight default link recKeyword Keyword
highlight default link recMultilineMarker Special
highlight default link recNumber Number
highlight default link recSizeDeclaration Keyword
highlight default link recType Type
highlight default link recTypeAssociation Keyword
highlight default link recTypeComment Comment
highlight default link recTypeDeclaration Keyword
highlight default link recTypeLimit Constant

let b:current_syntax = "rec"
