" =======
" Sources
" =======
source ~/.config/nvim/table.vim
source ~/.config/nvim/chrysline.vim

" ===================
" Remapping Functions
" ===================
function! s:config_vimwiki_mappings()
  " Ctrl-T -> increase list indent
  imap <buffer> <C-T> <Plug>VimwikiIncreaseLvlSingleItem
  " \wO -> open vimwiki notes in split view
  nmap <buffer> <LocalLeader>wO <Plug>VimwikiSplitLink
  " \wo -> open vimwiki links in vertical split
  nmap <buffer><silent> <LocalLeader>wo <Plug>VimwikiVSplitLink
  " \wb -> show backlinks
  nnoremap <buffer><silent> <LocalLeader>wb <CMD>VimwikiBacklinks<CR>
  " \w<Space> -> toggle todo list items
  nnoremap <buffer><silent> <LocalLeader>w<Space> <CMD>VimwikiToggleListItem<CR>
  " alias \w/ -> VimwikiGoto
  nmap <buffer> <LocalLeader>w/ <CMD>VimwikiGoto<CR>
  " Ctrl-I in visual mode -> format selected text as italics
  vnoremap <buffer> <C-I> c*<C-R>"*<C-[>
  " Ctrl-B in visual mode -> format selected text as bold
  vnoremap <buffer> <C-B> c**<C-R>"**<C-[>
  " - -> normal function in vinegar, fixes conflict
  nmap <buffer> - <Plug>VinegarUp
  " : -> auto-insert tags
  inoremap <buffer><expr> : !search('\a\%#', 'bn') ? ':<C-X><C-O><C-P>' : ':'
  " Backspace -> trigger pear-tree backspace, fixes integration issue
  inoremap <silent> <buffer> <BS> <Plug>(PearTreeBackspace)
endfunction

function! s:config_telescope_mappings()
  " Alt-E -> pick a buffer
  nnoremap <silent> <M-e> <CMD>Telescope buffers<CR>
  " \er -> grep
  nnoremap <silent> <Leader>er <CMD>Telescope live_grep<CR>
  " \et -> pick a tag
  nnoremap <silent> <Leader>et <CMD>Telescope tags<CR>
  " \ep -> list all builtin pickers
  nnoremap <silent> <Leader>ep <CMD>Telescope builtin<CR>
  " \ef -> pick files
  nnoremap <silent> <Leader>ef <CMD>Telescope find_files<CR>
  " \ec -> pick a command from command history
  nnoremap <silent> <Leader>ec <CMD>Telescope command_history<cr>
  " \em -> pick a mark
  nnoremap <silent> <Leader>em <CMD>Telescope marks<CR>
  " Alt-F -> fuzzy find in the current buffer
  nnoremap <silent> <M-f> <CMD>Telescope current_buffer_fuzzy_find<CR>
endfunction

function! s:config_leader_mappings()
  " \s -> toggle spell check
  nnoremap <silent> <Leader>s <CMD>setl spell!<CR>
  " \h -> toggle highlighted search
  nmap <silent> <Leader>h <CMD>set hlsearch!<CR>
  " \l -> toggle colour line
  nmap <silent> <Leader>l <CMD>setl cul!<CR>
  " \L -> toggle visible whitespace
  nnoremap <silent> <Leader>L <CMD>setl list!<CR>
  " \z -> toggle goyo mode
  nnoremap <silent> <Leader>z <CMD>Goyo<cr>
  " \n -> toggle line numbers
  nnoremap <silent> <Leader>n <CMD>setl nu! rnu!<CR>
endfunction

function! s:config_bracket_swapping_mappings()
  " Example: where | is the cursor position
  "   |{ ... } --<\r(>--> |( ... )
  nnoremap <silent> <Leader>r( m'%r)`'r(
  nnoremap <silent> <Leader>r) m'%r)`'r(
  nnoremap <silent> <Leader>r[ m'%r]`'r[
  nnoremap <silent> <Leader>r] m'%r]`'r[
  nnoremap <silent> <Leader>r{ m'%r}`'r{
  nnoremap <silent> <Leader>r} m'%r}`'r{
endfunction

function! s:config_misc_mappings()
  " Ctrl-S -> save current file if modified (normal and insert mode)
  nnoremap <silent> <C-S> <CMD>call SaveCurrentModifiedFile()<CR>
  imap <C-S> <C-O><C-S>

  " F5 -> Load last saved view of current file
  " Shift-F5 -> Save view of current file
  nnoremap <F5> <CMD>call SafeLoadView()<CR>
  nnoremap <F17> <CMD>mkview<BAR>echo 'Created view'<CR>

  " Ctrl-Backspace -> Delete word
  imap <C-H> <C-W>
  cmap <C-H> <C-W>

  " Escape terminal mode
  tmap <C-[> <C-\><C-N>

  " Q -> format paragraph
  nnoremap Q gwap
endfunction

function! s:config_command_keys()
  " inspired by emacs-keys in the vim manual
  cnoremap <C-A> <Home>
  cnoremap <C-B> <Left>
  cnoremap <C-E> <End>
  cnoremap <C-F> <Right>
endfunction

" global mappings
call s:config_misc_mappings()
call s:config_bracket_swapping_mappings()
call s:config_leader_mappings()
call s:config_telescope_mappings()
call s:config_command_keys()

" filetype-specific mappings
augroup chrys_ft_mappings
  autocmd!
  autocmd FileType vimwiki call s:config_vimwiki_mappings()
augroup END

" =========
" Functions
" =========

" s:change_directory_to_vimwiki_root(bufnr)
"   sets the current working directory to the root directory for the wiki for
"   the specified buffer
function! s:change_directory_to_vimwiki_root(bufnr)
  let wiki_nr = getbufvar(a:bufnr, "vimwiki_wiki_nr", -1)
  if wiki_nr == -1
    return
  endif

  let wiki_path =  vimwiki#vars#get_wikilocal('path', wiki_nr)
  execute "lchdir" wiki_path
endfunction

" SetMakeBuildDir(dir)
"   set the build directory for :make
function! SetMakeBuildDir(dir)
  if (!isdirectory(a:dir))
    echo a:dir . " is not a directory"
    return -1
  endif

  let &makeprg = "ninja -C " . a:dir
endfunction

" ResetMakeBuildDir()
"   reset the build directory for :make
function! ResetMakeBuildDir()
  let dir = "./build"
  if (!isdirectory(dir))
    let dir = "."
  endif

  let &makeprg = "ninja -C " . dir
endfunction

" PromptQuickfix()
"   shows quickfix window if there are errors in the current list
function! PromptQuickfix()
  let qflist = getqflist()
  for item in qflist
    if item.lnum > 0
      copen
      return
    endif
  endfor

  cclose
endfunction

" WikiDate()
"   return formatted date
function! WikiDate()
  return strftime('%B %e, %Y')
endfunction

" Qdate()
"   return formatted date
function! Qdate()
  return strftime('%Y-%m-%d')
endfunction

" SaveCurrentModifiedFile()
"   save the current file if it has been modified
function! SaveCurrentModifiedFile()
  if &modified
    write
  endif
endfunction

" SafeLoadView
"   attempt to run builin loadview, but give a nicer message if command errors
function! SafeLoadView()
  try
    loadview
    echo 'Loaded view'
  catch /Vim(loadview):E484/
    echo 'No saved view'
  endtry
endfunction

let g:last_window_info = {}

" UndoLastClose()
"   re-open last window that was close
"   buffer id for this window is set from autocmd
function! UndoLastClose()
  let bufnr = get(g:last_window_info, "bufnr", -1)
  if bufnr == -1
    return
  endif

  " topline defaults to first line if otherwise unknown/not set
  let topline = get(g:last_window_info, "topline", 1)

  let bufinfo = getbufinfo(bufnr)
  if bufinfo->len() == 0
    return
  endif

  let bufname = get(bufinfo[0], "name", "")
  if bufname == ""
    return
  endif

  execute "vnew +" .. topline .. " " .. bufname
endfunction

augroup chrys_undolastclose
  autocmd!
  autocmd WinClosed * let g:last_window_info = getwininfo(expand("<afile>"))[0]
augroup END

" UpdateModifiedDate
"   find lines in the current buffer matching a pattern and update the line to
"   the given datestring
"
"   For example:
"     /\clast updated: / matches Last Updated: <date>
"     and changes the <date>, which is everything on the line after the match
function! UpdateModifiedDate(pattern, datestring)
  let report_changes = 0
  " pattern to only match on lines that need changing
  let pattern = printf('%S\%%(%S\)\@!', a:pattern, a:datestring)
  for match in matchbufline(bufnr(), pattern, 1, "$")
    let new_text = slice(getline(match.lnum), 0, match.byteidx)
    let new_text ..= match.text
    let new_text ..= a:datestring
    call setline(match.lnum, new_text)
    let report_changes = 1
  endfor

  if report_changes
    echomsg "Datestring updated"
  endif
endfunction

let g:thousands_sep = ','

function! Pprint_number(num)
  if type(a:num) != type(0)
    return num
  endif

  let as_str = string(a:num)
  let result = []
  while len(as_str) > 0
    call add(result, slice(as_str, -3))
    let as_str = slice(as_str, 0, -3)
  endwhile
  return join(reverse(result), g:thousands_sep)
endfunction

let g:cached_define_buffers = {}

function! s:find_cached_buffer(word)
  let cached_bufnr = get(g:cached_define_buffers, a:word, 0)
  if cached_bufnr == 0
    return 0
  else
    return bufloaded(cached_bufnr) ? cached_bufnr : 0
  endif
endfunction

function! s:define_word_w_curl(word) abort
  let curl_cmd = "!curl dict.org/d:" .. a:word
  silent execute "new" "+set\\ bt=nofile\\ nobl\\ ft=dictionary" "dictionary - " .. a:word
  silent execute "read" curl_cmd
  silent %s/\r//
  silent 1,/^151/-1d _
  silent /^250/,$d _
  let g:cached_define_buffers[a:word] = bufnr()
endfunction

function! s:call_dict(cmd_args) abort
  if match(a:cmd_args, '[A-Za-z -]\+') == -1
    echoerr printf("Invalid args to dict: '%s'", a:cmd_args)
    return
  elseif ! executable("dict")
    echoerr "'dict' is not installed on your system"
    return
  endif

  new +set\ bt=nofile
  silent execute "read" "!dict" a:cmd_args
  normal go
endfunction

function! s:define_word_w_dict(word) abort
  let dict_cmd = "!dict " .. a:word
  silent execute "new" "+set\\ bt=nofile\\ nobl\\ ft=dictionary" "dictionary - " .. a:word
  silent execute "read" dict_cmd
  normal go
  let g:cached_define_buffers[a:word] = bufnr()
endfunction

function! s:define_word(word) abort
  if match(a:word, '[A-Za-z]\+') == -1
    echoerr printf("Cannot define '%s'", a:word)
    return
  endif

  let cached_bufnr = s:find_cached_buffer(a:word)
  if cached_bufnr != 0
    execute "new" "+set\\ nobl" "#"..cached_bufnr
  elseif executable("dict")
    call s:define_word_w_dict(a:word)
  else
    echomsg "'dict' is not installed on your system"
    call s:define_word_w_curl(a:word)
  endif
endfunction

function! s:define_word_confirm(word) abort
  if match(a:word, '[A-Za-z]\+') == -1
    echoerr printf("Cannot define '%s'", a:word)
    return
  elseif confirm(printf("Define '%s'?", a:word), "&Yes\n&No", 2) != 1
    return
  endif
  call s:define_word(a:word)
endfunction

let s:compile_macro = "\<C-W>b\"=get(g:,'compile_cmd','')\<C-M>pa\<C-M>\<C-[>\<C-W>p"

function! s:edit_compile_command()
  call inputsave()
  let g:compile_cmd = input("Compile command: ", get(g:, "compile_cmd", ""))
  call inputrestore()
endfunction

function! s:open_terminal()
  call inputsave()
  let term_cmd = input("Terminal (defaults to `bash`): ")
  call inputrestore()

  if len(term_cmd) == 0
    let term_cmd = "bash"
  endif

  execute "new" "term://"..term_cmd
endfunction

function! s:half_window(bang)
  if empty(a:bang)
    setlocal wrap linebreak statusline=%f
    let width = &tw / 2
    execute width "wincmd" "|"
  else " assuming some defaults here for conciseness
    setlocal nowrap nolinebreak statusline=%!CustomStatusline()
    execute "wincmd ="
  endif
endfunction

function! s:ddgr()
  if ! executable("ddgr")
    echoerr "You do not have ddgr installed"
    return
  endif

  new term://ddgr
  setlocal filetype=ddgr cursorline
  nnoremap <buffer> <silent> h <NOP>
  nnoremap <buffer> <silent> j <CMD>call search('^\s\d\<bar>^ddgr', 'W')<CR>
  nnoremap <buffer> <silent> k <CMD>call search('^\s\d\<bar>^ddgr', 'Wb')<CR>
  nnoremap <buffer> <silent> l <NOP>
  nnoremap <buffer> <silent> <CR> <CMD>call <SID>ddgr_enter()<CR>
  nnoremap <buffer> <silent> q <CMD>call feedkeys("i\<C-D>")<CR>

  tnoremap <buffer> <silent> <CR> <CR><C-\><C-N>

  startinsert
endfunction

function! s:ddgr_enter()
  let linenr = search('^\s\d', 'bWc')
  if linenr == 0
    return
  endif

  let index = matchstr(getline(linenr), '\d\+')
  call feedkeys("m'i"..index.."\<CR>\<Esc>`'")
endfunction

" ========
" Commands
" ========

" CopyCWDToClipboard
"   copy current working directory to clipboard
command! CopyCWDToClipboard call setreg("*", getcwd())

" Qdate
"   echo quick date/set to register
command! -register Qdate
      \ if empty('<reg>') |
      \   echo Qdate() |
      \ else |
      \   call setreg('<reg>', Qdate()) |
      \   echo "Set \"" .. '<reg>' .. " to \"" .. getreg('<reg>') .. "\"" |
      \ endif

" UndoLastClose
"   re-open last closed window in vertical
command! UndoLastClose call UndoLastClose()

" Scratch
"   create a temporary scratch buffer
command! Scratch new +set\ bt=nofile

" HideTabline
"   command to hide the tabline, When [!] is specified, it restores the
"   tabline. Note that entering and leaving Goyo mode resets this
command! -bang HideTabline
      \ if empty(<q-bang>)  |
      \   set showtabline=0 |
      \ else                |
      \   set showtabline=3 |
      \ endif

" Define
"   define word with online dictionary
command! -nargs=1 Define call <SID>define_word('<args>')

" DefineConfirm
"   user needs to confirm they want dictionary definition
command! -nargs=1 DefineConfirm call <SID>define_word_confirm('<args>')

" Dict
"   read result of dict command into new buffer
command! -nargs=1 Dict call <SID>call_dict('<args>')

" SetCommandMacro
"   set the contents of the register to run the compile command
command! -register SetCommandMacro
  \ if empty('<reg>')                                    |
  \   echoerr "Provide a register for the macro"         |
  \ else                                                 |
  \   call setreg('<reg>', s:compile_macro)              |
  \   echomsg "Set \"" .. '<reg>' .. " as compile macro" |
  \ endif

" CompileCommand
"   set the global compile command
command! CompileCommand call <SID>edit_compile_command()

" Reminder
"   edit the reminder file if it exists and correct perms
let s:reminder_path = resolve(expand('~/REMINDER'))
if filereadable(s:reminder_path) && filewritable(s:reminder_path)
  command! Reminder new ~/REMINDER
endif

" Terminal
command! Terminal call <SID>open_terminal()

" HalfWindow
command! -bang HalfWindow call <SID>half_window(<q-bang>)

" DDGR
command! DDGR call <SID>ddgr()

" =================
" Vim Configuration
" =================
set hidden
set incsearch
set nohlsearch
set number
set relativenumber
set sidescroll=0

" disable intro message
set shortmess+=I

" set custom statusline and tabline
set laststatus=2
set statusline=%!CustomStatusline()
set showtabline=2
set tabline=%!CustomTabline()

" default wrap settings
set nowrap
set listchars+=space:·
set listchars+=eol:¶

" default tab settings
set tabstop=2
set shiftwidth=2
set expandtab

" path and ignore
"set path+=** " disabled because it caused an issue with :isearch
set wildignore+=*/__pycache__
set wildignore+=*/__pycache__/*
set wildignore+=*.bak

" mouse
set mousemodel=extend
set mousescroll=ver:2,hor:6

" =====================
" General Configuration
" =====================

" set configuration for :make
call ResetMakeBuildDir()

" use Qdate to set d register to today's date silently
silent Qdate d

" open quickfix window if :make yields errors
augroup chrys_quickfix
  autocmd!
  autocmd QuickfixCmdPost make call PromptQuickfix()
augroup END

" markdown-specific configuration
function! s:markdown_config()
  " disable line numbers, textwidth:80, conceallevel:2, and set keyword
  " program to define words with dictionary
  setlocal nonumber norelativenumber
  setlocal textwidth=80
  setlocal conceallevel=2
  setlocal keywordprg=:DefineConfirm

  " set table->plaintext decorators
  let b:table_plain_before = "```\n"
  let b:table_plain_after = "\n```"
endfunction

" reminder-specific configuration
function! s:reminder_config()
  if get(b:, "reminder_autosave_done", 0)
    " avoid setting autocmd for this buffer twice!
    return
  endif
  " set up augroup for autosaving the buffer
  augroup chrys_reminder_autosave
    autocmd BufLeave <buffer> call SaveCurrentModifiedFile()
  augroup END
  let b:reminder_autosave_done = 1
endfunction

augroup chrys_ft
  autocmd!
  autocmd FileType markdown call s:markdown_config()
  autocmd FileType qf setlocal statusline=%!QuickfixStatusline()
  autocmd FileType dictionary setlocal keywordprg=:DefineConfirm
  autocmd FileType reminder call s:reminder_config()
augroup END

" =======
" Plugins
" =======

" Plugins with `vim_plug`
"  use :PlugInstall to actually install them
call plug#begin('~/.config/nvim/plugged')
Plug 'joshdick/onedark.vim'

Plug 'vimwiki/vimwiki'

Plug 'tmsvg/pear-tree'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'

Plug 'junegunn/goyo.vim'

Plug 'vlime/vlime', {'rtp': 'vim/'}

call plug#end()

" =======
" Vimwiki
" =======

" disable temporary wikis
let g:vimwiki_global_ext = 0

"   disable vimwiki tables in preference for table.vim
let g:vimwiki_table_auto_fmt = 0
let g:vimwiki_key_mappings = {
      \ 'table_format': 0,
      \ 'table_mappings': 0,
      \ 'mouse': 1,
      \ }

" disable emoji support
let g:vimwiki_emoji_enable = 0

" disable auto write
let g:vimwiki_autowriteall = 0

function! s:vimwiki_config()
  " textwidth:80, include hyphens and apostrophes in words, and set keyword
  " program to define words with dictonary
  setlocal textwidth=80
  setlocal iskeyword+=-,'
  setlocal keywordprg=:DefineConfirm

  " fix conflict with pear-tree
  let b:pear_tree_map_special_keys = 0

  " set table-to-plaintext decorators
  let b:table_plain_before = "```\n"
  let b:table_plain_after = "\n```"

  " add Vcd command
  command! -buffer Vcd call <SID>change_directory_to_vimwiki_root(bufnr())

  " delete deprecated VimwikiGenerateTags command
  if exists(":VimwikiGenerateTags") == 2
    delcommand -buffer VimwikiGenerateTags
  endif

  " extend vimwiki syntax
  syntax region VimwikiSourcable start=/^"\s/ end=/^finish$/
endfunction

augroup chrys_ft_vimwiki
  autocmd!
  autocmd FileType vimwiki call s:vimwiki_config()
augroup END

let personal_wiki = {}
let personal_wiki.path = '~/vimwiki/'
let personal_wiki.name = 'Personal Wiki'
let personal_wiki.syntax = 'markdown'
let personal_wiki.ext = '.md'
let personal_wiki.diary_caption_level = 1
let personal_wiki.auto_diary_index = 1
let personal_wiki.auto_toc = 1
let personal_wiki.auto_tags = 1
let personal_wiki.auto_generate_tags = 1

let notes_wiki = {}
let notes_wiki.path = '~/Documents/Notes/'
let notes_wiki.name = 'Notes Wiki'
let notes_wiki.syntax = 'markdown'
let notes_wiki.ext = '.md'
let notes_wiki.diary_caption_level = 1
let notes_wiki.auto_diary_index = 1
let notes_wiki.auto_toc = 1
let notes_wiki.auto_tags = 1
let notes_wiki.auto_generate_tags = 1
let notes_wiki.listsyms = ' x'

let techtona_wiki = {}
let techtona_wiki.path = '~/Documents/Writing/techtona_wiki/'
let techtona_wiki.name = 'Techtona Wiki'
let techtona_wiki.syntax = 'markdown'
let techtona_wiki.ext = '.md'
let techtona_wiki.diary_caption_level = 1
let techtona_wiki.auto_diary_index = 1
let techtona_wiki.auto_toc = 1
let techtona_wiki.auto_tags = 1
let techtona_wiki.auto_generate_tags = 1

let g:vimwiki_list = [personal_wiki, notes_wiki, techtona_wiki]

" =========
" Pear Tree
" =========

" disable for telescope prompt buffers
let g:pear_tree_ft_disabled = ['TelescopePrompt']

" disable unexpected behaviour when repeating text insert with characters
" recognised by pear-tree
let g:pear_tree_repeatable_expand = 0

" =========
" Telescope
" =========

" map i_Ctrl-Backspace to backspace
" map i_Ctrl-Q to select horizontal
lua <<
require("telescope").setup{
  defaults = {
      mappings = {
          i = {
              ["<C-_>"] = function()
                vim.cmd [[normal! bcw]]
              end,
              ["<C-Q>"] = require("telescope.actions").select_vertical,
            }
        }
    }
}
.

" ====
" Goyo
" ====

let g:goyo_width = 85

" configure display during goyo
function! s:goyo_enter()
  set showtabline=2
  set cmdheight=0
  set tabline=%!FocusTabline()
endfunction

function! s:goyo_leave()
  set showtabline=2
  set cmdheight=1
  set tabline=%!CustomTabline()
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" ===============
" Onedark (theme)
" ===============

function! s:configure_onedark()
  let g:onedark_terminal_italics = 1

  " onedark comment highlighting is too dark for my taste
  call onedark#set_highlight("Comment", { "fg": { "gui": "#7C828C", "cterm": "1" } })
  " add better contrast for listchars (currently same as comment)
  call onedark#set_highlight("Whitespace", { "fg": { "gui": "#7C828C", "cterm": "1" } })
  " better contrast for cursor line highlighting
  call onedark#extend_highlight("CursorLine", { "bg" : { "gui" : "#1c1e22" } })

  highlight! link netrwMarkFile PmenuSel
  highlight! SpecialKey guifg=#505762
  highlight! clear NonText
  highlight! link NonText SpecialKey
  highlight! link DiagnosticError ErrorMsg
  highlight! Italic cterm=italic gui=italic

  highlight! vimVar guifg=#abb2bf
  highlight! vimUserFunc guifg=#abb2bf

  highlight! qfText guifg=#abb2bf
  highlight! qfLineNr guifg=#abb2bf

  highlight! StatusLine guifg=#abb2bf guibg=#373f4c

  highlight! User1 guifg=#282c34 guibg=#98c379
  highlight! User2 guifg=#98c379 guibg=#373f4c
  highlight! User3 guifg=#282c34 guibg=#98c379 gui=bold
  highlight! User4 guifg=#98c379 guibg=#373f4c gui=italic
  highlight! User5 guifg=#282c34 guibg=#e06c75
  highlight! User6 guifg=#98c379
  highlight! User7 guifg=#98c379

  highlight! BoldTitle ctermfg=114 cterm=bold guifg=#98c379 gui=bold

  highlight! link VimwikiHeader1 BoldTitle
  highlight! link VimwikiHeader2 BoldTitle
  highlight! link VimwikiHeader3 BoldTitle
  highlight! link VimwikiHeader4 BoldTitle
  highlight! link VimwikiHeader5 BoldTitle
  highlight! link VimwikiHeader6 BoldTitle
  highlight! link VimwikiHeaderChar Comment

  highlight! link VimwikiTag Comment
  highlight! link VimwikiSourcable Comment
  highlight! link TodoDate String
  highlight! link Vimwikilist String

  highlight! link StatusLineNC StatusLine
  highlight! link StatusLineTerm StatusLine
  highlight! link StatusLineTermNC StatusLine
endfunction

autocmd ColorScheme onedark call <SID>configure_onedark()

colorscheme onedark

