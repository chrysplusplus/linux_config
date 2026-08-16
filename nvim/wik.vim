" File: wik.vim
" Author: chrysplusplus
" Description: Interface between the wik CLI and vim

if get(g:, "wik_vim_loaded", 0)
  finish
elseif ! executable('wik')
  finish
endif

" TODO implement
" - [x] search mode wik -s
" - [x] info mode wik -i
" - [ ] quick mode wik -q

function! s:wik_search(search_str)
  execute "!wik -s " .. a:search_str
endfunction

function! s:wik_info(topic_str)
  let wik_cmd = "!wik -i " .. a:topic_str
  silent execute "new" "+set\\ bt=nofile\\ nobl" "wik - " .. a:topic_str
  silent execute "read" wik_cmd
  normal go
endfunction

function! s:wik_quick(topic_str)
  execute "!wik -q " .. a:topic_str
endfunction

command! -nargs=1 WikSearch call s:wik_search(<q-args>)
command! -nargs=1 WikInfo call s:wik_info(<q-args>)
command! -nargs=1 Wik call s:wik_quick(<q-args>)

let g:wik_vim_loaded = 1

