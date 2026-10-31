" Vim syntax file
" Language:     teal (adapted from lua syntax file)
" Maintainer:   chrysplusplus
" First Author: Carlos Augusto Teixeira Mendes <cmendes 'at' inf puc-rio br>
" Last Change:  2026 Oct 31
" Options:      From lua syntax file
"               lua_version = 4 or 5
"               lua_subversion = 0 (for 4.0 or 5.0)
"                               or 1, 2, 3 (for 5.1, 5.2 or 5.3)
"               the default is 5.3

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match

" syncing method
syn sync minlines=1000

syn keyword tealMetaMethod __add __sub __mul __div __pow __unm __concat
syn keyword tealMetaMethod __eq __lt __le
syn keyword tealMetaMethod __index __newindex __call
syn keyword tealMetaMethod __metatable __mode __gc __tostring
syn keyword tealMetaMethod __mod __len
syn keyword tealMetaMethod __pairs
syn keyword tealMetaMethod __idiv __name
syn keyword tealMetaMethod __band __bor __bxor __bnot __shl __shr
syn keyword tealMetaMethod __close

" catch errors caused by wrong parenthesis and wrong curly brackets or
" keywords placed outside their respective blocks

syn region tealParen transparent start='(' end=')' contains=TOP,tealParenError
syn match  tealParenError ")"
syn match  tealError "}"
syn match  tealError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"

" Function declaration
syn region tealFunctionBlock transparent matchgroup=tealFunction start="\<function\>" end="\<end\>" contains=TOP

" Enum declaration
syn region tealEnumBlock transparent matchgroup=tealFunction start="\<enum\>" end="\<end\>" contains=TOP

" Record declaration
syn region tealRecordBlock transparent matchgroup=tealFunction start="\<record\>" end="\<end\>" contains=TOP

" Interface declaration
syn region tealInferfaceBlock transparent matchgroup=tealFunction start="\<interface\>" end="\<end\>" contains=TOP

" else
syn keyword tealCondElse matchgroup=tealCond contained containedin=tealCondEnd else

" then ... end
syn region tealCondEnd contained transparent matchgroup=tealCond start="\<then\>" end="\<end\>" contains=TOP

" elseif ... then
syn region tealCondElseif contained containedin=tealCondEnd transparent matchgroup=tealCond start="\<elseif\>" end="\<then\>" contains=TOP

" if ... then
syn region tealCondStart transparent matchgroup=tealCond start="\<if\>" end="\<then\>"me=e-4 contains=TOP nextgroup=tealCondEnd skipwhite skipempty

" do ... end
syn region tealBlock transparent matchgroup=tealStatement start="\<do\>" end="\<end\>" contains=TOP
" repeat ... until
syn region tealRepeatBlock transparent matchgroup=tealRepeat start="\<repeat\>" end="\<until\>" contains=TOP

" while ... do
syn region tealWhile transparent matchgroup=tealRepeat start="\<while\>" end="\<do\>"me=e-2 contains=TOP nextgroup=tealBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region tealFor transparent matchgroup=tealRepeat start="\<for\>" end="\<do\>"me=e-2 contains=TOP nextgroup=tealBlock skipwhite skipempty

syn keyword tealFor contained containedin=tealFor in

" other keywords
syn keyword tealStatement return local break is where
syn keyword tealStatement goto
syn match tealLabel "::\I\i*::"

" operators
syn keyword tealOperator and or not

syn match tealSymbolOperator "[#<>=~^&|*/%+-]\|\.\{2,3}"

" comments
syn keyword tealTodo            contained TODO FIXME XXX
syn match   tealComment         "--.*$" contains=tealTodo,@Spell
syn region  tealComment         matchgroup=tealCommentDelimiter start="--\[\z(=*\)\[" end="\]\z1\]" contains=tealTodo,@Spell

" first line may start with #!
syn match tealComment "\%^#!.*"

syn keyword tealConstant nil
syn keyword tealConstant true false

" strings
syn match  tealSpecial contained #\\[\\abfnrtv'"[\]]\|\\[[:digit:]]\{,3}#
syn match  tealSpecial contained #\\u{[[:xdigit:]]\+}#
syn region tealString2 matchgroup=tealStringDelimiter start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
syn region tealString matchgroup=tealStringDelimiter start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=tealSpecial,@Spell
syn region tealString matchgroup=tealStringDelimiter start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=tealSpecial,@Spell

" integer number
syn match tealNumber "\<\d\+\>"
" floating point number, with dot, optional exponent
syn match tealNumber  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\="
" floating point number, starting with a dot, optional exponent
syn match tealNumber  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" floating point number, without dot, with exponent
syn match tealNumber  "\<\d\+[eE][-+]\=\d\+\>"

" hex numbers
syn match tealNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"

" tables
syn region tealTableBlock transparent matchgroup=tealTable start="{" end="}" contains=TOP,tealStatement

" methods
syntax match tealFunc ":\@<=\k\+"

" built-in functions
syn keyword tealFunc assert collectgarbage dofile error next
syn keyword tealFunc print rawget rawset self tonumber tostring type _VERSION

syn keyword tealFunc getmetatable setmetatable
syn keyword tealFunc ipairs pairs
syn keyword tealFunc pcall xpcall
syn keyword tealFunc _G loadfile rawequal require
syn keyword tealFunc load select
syn match   tealFunc /\<package\.cpath\>/
syn match   tealFunc /\<package\.loaded\>/
syn match   tealFunc /\<package\.loadlib\>/
syn match   tealFunc /\<package\.path\>/
syn match   tealFunc /\<package\.preload\>/

syn match tealFunc /\<coroutine\.isyieldable\>/
syn keyword tealFunc warn
syn match tealFunc /\<coroutine\.close\>/
syn match tealFunc /\<coroutine\.running\>/
syn match tealFunc /\<coroutine\.create\>/
syn match tealFunc /\<coroutine\.resume\>/
syn match tealFunc /\<coroutine\.status\>/
syn match tealFunc /\<coroutine\.wrap\>/
syn match tealFunc /\<coroutine\.yield\>/
syn match tealFunc /\<string\.byte\>/
syn match tealFunc /\<string\.char\>/
syn match tealFunc /\<string\.dump\>/
syn match tealFunc /\<string\.find\>/
syn match tealFunc /\<string\.format\>/
syn match tealFunc /\<string\.gsub\>/
syn match tealFunc /\<string\.len\>/
syn match tealFunc /\<string\.lower\>/
syn match tealFunc /\<string\.rep\>/
syn match tealFunc /\<string\.sub\>/
syn match tealFunc /\<string\.upper\>/
syn match tealFunc /\<string\.gmatch\>/
syn match tealFunc /\<string\.match\>/
syn match tealFunc /\<string\.reverse\>/
syn match tealFunc /\<string\.pack\>/
syn match tealFunc /\<string\.packsize\>/
syn match tealFunc /\<string\.unpack\>/
syn match tealFunc /\<utf8\.char\>/
syn match tealFunc /\<utf8\.charpattern\>/
syn match tealFunc /\<utf8\.codes\>/
syn match tealFunc /\<utf8\.codepoint\>/
syn match tealFunc /\<utf8\.len\>/
syn match tealFunc /\<utf8\.offset\>/
syn match tealFunc /\<table\.pack\>/
syn match tealFunc /\<table\.unpack\>/
syn match tealFunc /\<table\.move\>/
syn match tealFunc /\<table\.concat\>/
syn match tealFunc /\<table\.insert\>/
syn match tealFunc /\<table\.sort\>/
syn match tealFunc /\<table\.remove\>/
syn match tealFunc /\<math\.abs\>/
syn match tealFunc /\<math\.acos\>/
syn match tealFunc /\<math\.asin\>/
syn match tealFunc /\<math\.atan\>/
syn match tealFunc /\<math\.ceil\>/
syn match tealFunc /\<math\.sin\>/
syn match tealFunc /\<math\.cos\>/
syn match tealFunc /\<math\.tan\>/
syn match tealFunc /\<math\.deg\>/
syn match tealFunc /\<math\.exp\>/
syn match tealFunc /\<math\.floor\>/
syn match tealFunc /\<math\.log\>/
syn match tealFunc /\<math\.max\>/
syn match tealFunc /\<math\.min\>/
syn match tealFunc /\<math\.huge\>/
syn match tealFunc /\<math\.fmod\>/
syn match tealFunc /\<math\.modf\>/
syn match tealFunc /\<math\.rad\>/
syn match tealFunc /\<math\.sqrt\>/
syn match tealFunc /\<math\.maxinteger\>/
syn match tealFunc /\<math\.mininteger\>/
syn match tealFunc /\<math\.tointeger\>/
syn match tealFunc /\<math\.type\>/
syn match tealFunc /\<math\.ult\>/
syn match tealFunc /\<math\.random\>/
syn match tealFunc /\<math\.randomseed\>/
syn match tealFunc /\<math\.pi\>/
syn match tealFunc /\<io\.close\>/
syn match tealFunc /\<io\.flush\>/
syn match tealFunc /\<io\.input\>/
syn match tealFunc /\<io\.lines\>/
syn match tealFunc /\<io\.open\>/
syn match tealFunc /\<io\.output\>/
syn match tealFunc /\<io\.popen\>/
syn match tealFunc /\<io\.read\>/
syn match tealFunc /\<io\.stderr\>/
syn match tealFunc /\<io\.stdin\>/
syn match tealFunc /\<io\.stdout\>/
syn match tealFunc /\<io\.tmpfile\>/
syn match tealFunc /\<io\.type\>/
syn match tealFunc /\<io\.write\>/
syn match tealFunc /\<os\.clock\>/
syn match tealFunc /\<os\.date\>/
syn match tealFunc /\<os\.difftime\>/
syn match tealFunc /\<os\.execute\>/
syn match tealFunc /\<os\.exit\>/
syn match tealFunc /\<os\.getenv\>/
syn match tealFunc /\<os\.remove\>/
syn match tealFunc /\<os\.rename\>/
syn match tealFunc /\<os\.setlocale\>/
syn match tealFunc /\<os\.time\>/
syn match tealFunc /\<os\.tmpname\>/
syn match tealFunc /\<debug\.debug\>/
syn match tealFunc /\<debug\.gethook\>/
syn match tealFunc /\<debug\.getinfo\>/
syn match tealFunc /\<debug\.getlocal\>/
syn match tealFunc /\<debug\.getupvalue\>/
syn match tealFunc /\<debug\.setlocal\>/
syn match tealFunc /\<debug\.setupvalue\>/
syn match tealFunc /\<debug\.sethook\>/
syn match tealFunc /\<debug\.traceback\>/
syn match tealFunc /\<debug\.getmetatable\>/
syn match tealFunc /\<debug\.setmetatable\>/
syn match tealFunc /\<debug\.getregistry\>/
syn match tealFunc /\<debug\.getuservalue\>/
syn match tealFunc /\<debug\.setuservalue\>/
syn match tealFunc /\<debug\.upvalueid\>/
syn match tealFunc /\<debug\.upvaluejoin\>/
syn match tealFunc /\<debug.setcstacklimit\>/

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

hi def link tealStatement        Statement
hi def link tealRepeat           Repeat
hi def link tealFor              Repeat
hi def link tealString           String
hi def link tealString2          String
hi def link tealStringDelimiter  tealString
hi def link tealNumber           Number
hi def link tealOperator         Operator
hi def link tealSymbolOperator   tealOperator
hi def link tealConstant         Constant
hi def link tealCond             Conditional
hi def link tealCondElse         Conditional
hi def link tealFunction         Function
hi def link tealMetaMethod       Function
hi def link tealComment          Comment
hi def link tealCommentDelimiter tealComment
hi def link tealTodo             Todo
hi def link tealTable            Structure
hi def link tealError            Error
hi def link tealParenError       Error
hi def link tealSpecial          SpecialChar
hi def link tealFunc             Identifier
hi def link tealLabel            Label

let b:current_syntax = "teal"

let &cpo = s:cpo_save
unlet s:cpo_save
