" Vim indent file
" Language:	Teal (taken from lua)
" Maintainer:	chrysplusplus
" First Author:	Max Ischenko <mfi 'at' ukr.net>
" Last Change:	2026 Oct 31

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetTealIndent()

" To make Vim call GetLuaIndent() when it finds '\s*end' or '\s*until'
" on the current line ('else' is default and includes 'elseif').
setlocal indentkeys+=0=end,0=until

setlocal autoindent

let b:undo_indent = "setlocal autoindent< indentexpr< indentkeys<"

" Only define the function once.
if exists("*GetTealIndent")
  finish
endif

function! GetTealIndent()
    let ignorecase_save = &ignorecase
  try
    let &ignorecase = 0
    return s:get_teal_indent()
  finally
    let &ignorecase = ignorecase_save
  endtry
endfunction

function! s:get_teal_indent()
  " Find a non-blank line above the current line.
  let prevlnum = prevnonblank(v:lnum - 1)

  " Hit the start of the file, use zero indent.
  if prevlnum == 0
    return 0
  endif

  " Add a 'shiftwidth' after lines that start a block:
  " 'function', 'if', 'for', 'while', 'repeat', 'else', 'elseif', '{', '('
  " 'enum', 'record', 'interface', 'record'
  let ind = indent(prevlnum)
  let prevline = getline(prevlnum)
  let midx = match(prevline, '^\s*\%(if\>\|for\>\|while\>\|repeat\>\|else\>\|elseif\>\|do\>\|then\>\)')
  if midx == -1
    let midx = match(prevline, '\%({\|(\)\s*\%(--\%([^[].*\)\?\)\?$')
    if midx == -1
      let midx = match(prevline, '\<function\>\s*\%(\k\|[.:]\)\{-}\s*(')
      if midx == -1
        let midx = match(prevline, '\<\%(enum\|record\|interface\|record\)\s*\k\{-}')
      endif
    endif
  endif

  if midx != -1
    " Add 'shiftwidth' if what we found previously is not in a comment and
    " an "end" or "until" is not present on the same line.
    if synIDattr(synID(prevlnum, midx + 1, 1), "name") != "tealComment" && prevline !~ '\<end\>\|\<until\>'
      let ind = ind + shiftwidth()
    endif
  endif

  " Subtract a 'shiftwidth' on end, else, elseif, until, '}' and ')'
  " This is the part that requires 'indentkeys'.
  let midx = match(getline(v:lnum), '^\s*\%(end\>\|else\>\|elseif\>\|until\>\|}\|)\)')
  if midx != -1 && synIDattr(synID(v:lnum, midx + 1, 1), "name") != "tealComment"
    let ind = ind - shiftwidth()
  endif

  return ind
endfunction
