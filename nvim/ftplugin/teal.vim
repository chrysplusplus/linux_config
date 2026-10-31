" Vim filetype plugin file.
" Language:    Teal
" Maintainer:  chrysplusplus
" Last Change: 2026 Oct 31

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal comments=:---,:--
setlocal commentstring=--\ %s
setlocal formatoptions-=t
setlocal formatoptions+=croql
setlocal path-=.

let &l:define = '\<function\|\<local\%(\s\+function\)\='

let &l:include = '\<\%(do\|load\)file\|require\)\s*('
setlocal includeexpr=s:teal_include(v:fname)
setlocal suffixesadd=.tl

let b:undo_ftplugin = "setl cms< com< def< fo< inc< inex< sua< pa<"

if exists("loaded_matchit") && !exists("b:match_words")
  let b:match_ignorecase = 0
  let b:match_words =
        \ '\<\%(do\|function\|if\)>:' ..
        \ '\<\%(return\|else\|elseif\)\>:' ..
        \ '\<end\>,' ..
        \ '\<repeat\>:\<until\>,' ..
        \ '\%(--\)\=\[\(=*\)[:]\1]'
  let b:undo_ftplugin ..= " | unlet! b:match_words b:match_ignorecase"
endif

" The rest of the file needs to be sourced only once per session
if exists("s:loaded_teal") || &cp
  let &cpo = s:cpo_save
  unlet s:cpo_save
  finish
endif
let s:loaded_teal = 1

function s:teal_include(fname) abort
  let fname = tr(a:fname, '.', '/')
  let paths = [fname .. ".tl", fname .. "/init.tl"]
  for path in paths
    if filereadable(path)
      return path
    endif
  endfor
  return fname
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
