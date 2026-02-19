" =======
" Sources
" =======
source ~/.config/nvim/table.vim

" ====================
" table.vim Extensions
" ====================
let s:table_pattern = TableExposeVariable("table_pattern")
let s:_table_imap_return = TableExposeFunction("imap_return")
let s:_table_imap_backspace = TableExposeFunction("imap_backspace")
let s:_table_nmap_o = TableExposeFunction("nmap_o")
let s:_table_nmap_O = TableExposeFunction("nmap_O")

function! s:in_table(text)
  return match(a:text, s:table_pattern) == 0
endfunction

function! s:table_imap_return()
  return s:_table_imap_return()
endfunction

function! s:table_imap_backspace()
  return s:_table_imap_backspace()
endfunction

function! s:table_nmap_o()
  return s:_table_nmap_o()
endfunction

function! s:table_nmap_O()
  return s:_table_nmap_O()
endfunction

" ===================
" Remapping Functions
" ===================
function! s:config_vimwiki_mappings()
  " Remap Ctrl-T to increase list indent for vimwiki
  imap <buffer> <C-T> <Plug>VimwikiIncreaseLvlSingleItem
  " \wO to open vimwiki notes in split view
  nmap <buffer> <LocalLeader>wO <Plug>VimwikiSplitLink
  " \wo to open vimwiki links in vertical split
  nmap <buffer><silent> <LocalLeader>wo <Plug>VimwikiVSplitLink
  " \wb to show backlinks
  nnoremap <buffer><silent> <LocalLeader>wb <CMD>VimwikiBacklinks<CR>
  " \w<Space> to toggle todo list items
  nnoremap <buffer><silent> <LocalLeader>w<Space> <CMD>VimwikiToggleListItem<CR>
  " alias \w/ to VimwikiGoto
  nmap <buffer> <LocalLeader>w/ <CMD>VimwikiGoto<CR>
  " create locations list for vimwiki table of contents, similar to help files
  nnoremap <buffer><silent> gO <CMD>lvimgrep/^#/%<BAR>lopen<CR>
  " Ctrl-I in visual mode to format selected text as italics
  vnoremap <buffer> <C-I> c*<C-R>"*<C-[>
  " Ctrl-B in visual mode to format selected text as bold
  vnoremap <buffer> <C-B> c**<C-R>"**<C-[>
  " - to normal function in vinegar; fix conflict
  nmap <buffer> - <Plug>VinegarUp
  " : auto-insert tags
  inoremap <buffer><expr> : !search('\a\%#', 'bn') ? ':<C-X><C-O><C-P>' : ':'
  " dispatch return key to table.vim and vimwiki
  inoremap <buffer><expr> <CR> <SID>in_table(getline('.')) ? <SID>table_imap_return() : pumvisible() ? "\<CR>" : "\<C-]>\<Esc>:VimwikiReturn 1 5\<CR>"
  " dispatch o to table.vim and vimwiki
  nmap <buffer><expr> o <SID>in_table(getline('.')) ? <SID>table_nmap_o() : '<Plug>VimwikiListo'
  " dispatch O to table.vim and vimwiki
  nmap <buffer><expr> O <SID>in_table(getline('.')) ? <SID>table_nmap_O() : '<Plug>VimwikiListO'
endfunction

function! s:config_cpp_mappings()
  " remap gd to search for word under cursor in source files in directory
  nnoremap <silent> <buffer> gd <CMD>vim/\<<C-R><C-W>\>/gj **/*.h **/*.cpp<BAR>copen<CR>
  vnoremap <silent> <buffer> gd y<CMD>vim/\<<C-R>"\>/gj **/*.h **/*.cpp<BAR>copen<CR>
endfunction

function! s:config_netrw_mappings()
  " P to close preview window
  nnoremap <silent> <buffer> P <CMD>pclose<CR>
  " warn on moving
  nnoremap <silent> <buffer> mm <CMD>echoerr 'mm has been unmapped'<CR>
  " Ctrl-Q to return to alt buffer (disabled)
  "nnoremap <buffer> <C-Q> <C-^>
endfunction

function s:config_table_mappings()
  " dispatch for pear-tree compatibility
  inoremap <silent><expr> <CR> <SID>in_table(getline('.')) ? <SID>table_imap_return() : "\<Plug>(PearTreeExpand)"
  inoremap <silent><expr> <BS> <SID>in_table(getline('.')) ? <SID>table_imap_backspace() : "\<Plug>(PearTreeBackspace)"
endfunction

function! s:config_telescope_mappings()
  " \ee and Alt-e to pick a buffer
  nnoremap <silent> <Leader>ee <CMD>Telescope buffers<CR>
  nnoremap <silent> <M-e> <CMD>Telescope buffers<CR>
  " \er to grep
  nnoremap <silent> <Leader>er <CMD>Telescope live_grep<CR>
  " \et to pick a tag
  nnoremap <silent> <Leader>et <CMD>Telescope tags<CR>
  " \ep to list all builtin pickers
  nnoremap <silent> <Leader>ep <CMD>Telescope builtin<CR>
  " \ef to pick files
  nnoremap <silent> <Leader>ef <CMD>Telescope find_files<CR>
  " \ec to pick a command from command history
  nnoremap <silent> <Leader>ec <CMD>Telescope command_history<cr>
  " \em to pick a mark
  nnoremap <silent> <Leader>em <CMD>Telescope marks<CR>
  " \ez and Alt-f to fuzzy find in the current buffer
  nnoremap <silent> <Leader>ez <CMD>Telescope current_buffer_fuzzy_find<CR>
  nnoremap <silent> <M-f> <CMD>Telescope current_buffer_fuzzy_find<CR>
endfunction

function! s:config_leader_mappings()
  " \s to toggle spell check
  nnoremap <silent> <Leader>s <CMD>setl spell!<CR>
  " \h to toggle highlighted search
  "   with table dispatch
  nmap <silent><expr> <Leader>h <SID>in_table(getline('.')) ? '<Plug>(TableLeftCell)' : '<CMD>set hlsearch!<cr>'
  " \j to goto the below paragraph-cell
  nmap <silent><expr> <Leader>j <SID>in_table(getline('.')) ? '<Plug>(TableDownCell)' : 'j'
  " \k to goto the above paragraph-cell
  nmap <silent><expr> <Leader>k <SID>in_table(getline('.')) ? '<Plug>(TableUpCell)' : 'k'
  " \l to toggle colour line
  "   with table dispatch
  nmap <silent><expr> <Leader>l <SID>in_table(getline('.')) ? '<Plug>(TableRightCell)' : '<CMD>setl cul!<CR>'
  " \L to toggle visible whitespace
  nnoremap <silent> <Leader>L <CMD>setl list!<CR>
  " \z to toggle goyo mode
  nnoremap <silent> <Leader>z <CMD>Goyo<cr>
  " \n to toggle line numbers
  nnoremap <silent> <Leader>n <CMD>setl nu! rnu!<CR>
  " \g to open fugitive buffer and Alt-G
  nnoremap <silent> <expr> <Leader>g exists('g:loaded_fugitive') ? '<CMD>Git<CR>' : ''
  nnoremap <silent> <expr> <M-g> exists('g:loaded_fugitive') ? '<CMD>Git<CR>' : ''
endfunction

function! s:config_windowing_mappings()
  " Alt + key bindings
  nnoremap <M-q> <C-W>q
  nnoremap <M-w> <C-W>w
  nnoremap <M-o> <C-W>o
  nnoremap <M-p> <C-W>p
  nnoremap <M-s> <C-W>s
  nnoremap <M-h> <C-W>h
  nnoremap <M-j> <C-W>j
  nnoremap <M-k> <C-W>k
  nnoremap <M-l> <C-W>l
  nnoremap <M-v> <C-W>v
  nnoremap <M-S-h> <C-W>H
  nnoremap <M-S-j> <C-W>J
  nnoremap <M-S-k> <C-W>K
  nnoremap <M-S-l> <C-W>L

  " Alt + t to split window to new tab
  nnoremap <M-t> <C-W>s<C-W>T

  " Alt + number key bindings to go to window
  nnoremap <M-1> 1<C-W>w
  nnoremap <M-2> 2<C-W>w
  nnoremap <M-3> 3<C-W>w
  nnoremap <M-4> 4<C-W>w
  nnoremap <M-5> 5<C-W>w
  nnoremap <M-6> 6<C-W>w
  nnoremap <M-7> 7<C-W>w
  nnoremap <M-8> 8<C-W>w
  nnoremap <M-9> 9<C-W>w

  " Alt + - to 'zoom' current window (Ctr-W _)
  nnoremap <M--> <C-W>_<C-W><bar>

  " Alt + = to 'equalise' windows
  nnoremap <M-=> <C-W>=
endfunction

function! s:config_bracket_swapping_mappings()
  nnoremap <silent> <Leader>r( m'%r)`'r(
  nnoremap <silent> <Leader>r) m'%r)`'r(
  nnoremap <silent> <Leader>r[ m'%r]`'r[
  nnoremap <silent> <Leader>r] m'%r]`'r[
  nnoremap <silent> <Leader>r{ m'%r}`'r{
  nnoremap <silent> <Leader>r} m'%r}`'r{
endfunction

" ================
" General Mappings
" ================

" Convenience mappings
" Ctrl-S to save the current file
nnoremap <silent> <C-S> <CMD>call SaveCurrentModifiedFile()<CR>
" Ctrl-S in insert mode to save the current file without leaving insert mode
imap <C-S> <C-O><C-S>

" Load view and make view set to F5 and Shift+F5 respectively
nnoremap <F5> <CMD>call SafeLoadView()<CR>
nnoremap <F17> <CMD>mkview<BAR>echo 'Created view'<CR>

" Ctrl-Backspace to Ctrl-W in Insert and Command mode
imap <C-H> <C-W>
cmap <C-H> <C-W>

" Esc to escape terminal
tmap <C-[> <C-\><C-N>

" Q to format paragraph (similar to vim)
nnoremap Q <CMD>FormatParagraph<CR>

" J to join lines without jumping (sets last mark)
nnoremap J m'J`'

call s:config_bracket_swapping_mappings()
call s:config_windowing_mappings()
call s:config_leader_mappings()
call s:config_telescope_mappings()
call s:config_table_mappings()

" filetype mappings
augroup chrys_ft_mappings
  autocmd!
  autocmd FileType vimwiki call s:config_vimwiki_mappings()
  autocmd FileType cpp call s:config_cpp_mappings()
  " <C-J> in insert mode in python files refreshes coc
  autocmd FileType python inoremap <silent> <C-J> <CMD>call coc#refresh()<CR>
  autocmd FileType netrw call s:config_netrw_mappings()
  " restore default backspace mapping for filetypes with pear-tree disabled
  autocmd FileType TelescopePrompt inoremap <buffer> <BS> <BS>
augroup END

" =================
" Tabline Functions
" =================
" s:highlight_modified
function! s:highlight_modified(tabline)
  if &modified
    return '%#Italic#' .. a:tabline .. '%#TabLineFill#*'
  else
    return a:tabline
endfunction

" CustomDefaultTabline
function! CustomDefaultTabline()
  let tabline = ''
  if &previewwindow
    let tabline .= ' [Preview]'
  endif

  let tabline .= ' ' .. s:highlight_modified('%f') .. ' %='
  return tabline
endfunction

" CurrentDirectoryDetail
function! CurrentDirectoryDetail()
  return '%#airline_a# %{fnamemodify(getcwd(), '':t'')} %#TabLineFill#'
endfunction

let g:tabline_symbols = {
      \ 'cursorline': '=',
      \ 'digraph':    '~',
      \ 'hlsearch':   'φ',
      \ 'linebreak':  ']',
      \ 'list':       '¶',
      \ 'spell':      '¤',
      \ 'wrap':       'W',
      \ }

" TablineSymbols
"   display symbols to indicate specified settings
function! TablineSymbols()
  let symbols = ''
  for [opt_name, symbol] in items(g:tabline_symbols)
    let do_display = 0
    execute 'let do_display = &' .. opt_name .. ' == v:true'
    if !do_display
      continue
    endif

    let symbols .= symbol
  endfor

  return symbols
endfunction

let g:tabline_flags = {
      \ 'virtualedit': ['ve', {val -> val != ''}],
      \ 'colorcolumn': ['cc', {val -> val != ''}],
      \ 'textwidth':   ['tw', {val -> val != 0}],
      \ 'tabstop':     ['ts', {val -> val != 2}],
      \ 'scrolloff':   ['so', {val -> val != 0}],
      \ }

" TablineFlags
"   display flags when specified settings **don't** meet a default condition
function! TablineFlags()
  let flags = []
  for opt_name in keys(g:tabline_flags)
    let [flag_display, Condition_fn] = g:tabline_flags[opt_name]
    execute 'let opt_val = &' .. opt_name
    if !Condition_fn(opt_val)
      continue
    endif

    call add(flags, flag_display .. '=' .. opt_val)
  endfor

  return flags->sort()->join(', ')
endfunction

" TabPageDetail
function! TabPageDetail()
  if tabpagenr('$') > 1
    return '%#airline_a# %{tabpagenr()} / %{tabpagenr(''$'')} %#TabLineFill#'
  else
    return ''
  endif
endfunction

" CustomNetrwTabline
function! CustomNetrwTabline()
  let tabline_netrw = ''

  let curdir = get(b:, "netrw_curdir")
  let tabline_netrw .= ' %#Directory#' .. curdir .. '%#TabLineFill#'

  let target = netrw#Expose("netrwmftgt")
  let tabline_netrw .= ' target: ' .. target
  let tabline_netrw .= '%='
  return tabline_netrw
endfunction

" HelpTabline
" could be more intelligent to report the last help term that was searched
" but this will do for now
function! HelpTabline()
  let title = expand('%:t:r') "report the name of help file
  return ' ' .. title .. '%='
endfunction

" TelescopeTabline
function! TelescopeTabline()
  return '%='
endfunction

" s:tabline_strip_leading_zeroes
function! s:tabline_strip_leading_zeroes(value)
  return a:value =~ "^0" ? a:value[1:] : a:value
endfunction

" s:tabline_format_vimwiki_date
function! s:tabline_format_vimwiki_date(date)
  let year = a:date[0]
  let month_nr = s:tabline_strip_leading_zeroes(a:date[1])
  let month = vimwiki#vars#get_global('diary_months')->get(month_nr)
  let day = s:tabline_strip_leading_zeroes(a:date[2])
  return day .. ' ' .. month .. ' ' .. year
endfunction

" s:get_vimwiki_last_header()
"   returns current header in wiki file
function! s:get_vimwiki_last_header()
  let linenr = line('.')
  let headers = vimwiki#base#collect_headers()
  let last_header = []
  for header in headers
    if header[0] <= linenr
      let last_header = header

    else
      break
    endif
  endfor

  if !empty(last_header)
    return repeat('#', last_header[1]) .. ' %#VimwikiHeader1#' .. last_header[2]
          \ .. '%#TabLineFill#'
  else
    return ''
  endif
endfunction

" VimwikiTabline
function! VimwikiTabline()
  let tabline = ''
  let page = expand('%:t:r')
  let buf_subdir = vimwiki#vars#get_bufferlocal('subdir')
  let sub_path = substitute(buf_subdir, '\/\|\\', ' -> ', 'g')
  let wikiname = vimwiki#vars#get_wikilocal('name')
  if wikiname == ''
    let wikiname = vimwiki#vars#get_wikilocal('path')
  endif

  if buf_subdir == vimwiki#vars#get_wikilocal('diary_rel_path')
    " if we're in the diary
    if page == vimwiki#vars#get_wikilocal('diary_index')
      " if we're on the diary index page
      let tabline = ' ' .. wikiname .. ' Diary'

    else
      " otherwise
      let tabline = ' ' .. wikiname .. ' Diary: '
      let tabline .= s:tabline_format_vimwiki_date(page->split('-'))
    endif

  elseif page == vimwiki#vars#get_wikilocal('index') && sub_path == ''
    " if we're on the wiki index page
    let tabline = ' ' .. wikiname

  else
    " otherwise
    let page = substitute(page, '_', ' ', 'g')
    let tabline = ' ' .. wikiname .. ' -> ' .. sub_path .. page
  endif

  "return s:highlight_modified(tabline) .. ' ' .. s:get_vimwiki_last_header() ..
  "      \' %='
  return s:highlight_modified(tabline) .. ' ' .. ' %='
endfunction

" TablineFlagsAndSymbols
"   combine tabline for flags and values
function! TablineFlagsAndSymbols()
  let tabline = ''
  let flags = TablineFlags()
  let tabline .= flags
  if flags->len() > 0
    let tabline .= ' '
  endif
  let symbols = TablineSymbols()
  let tabline .= symbols
  if symbols->len() > 0
    let tabline .= ' '
  endif
  return tabline
endfunction

" TODO this code could also do with cleanup

" flags for filetypes
let g:tabline_ft = {}
let g:tabline_ft.netrw = {'fn': function("CustomNetrwTabline")}
let g:tabline_ft.help = {'fn': function("HelpTabline")}
let g:tabline_ft.TelescopePrompt = {'fn': function("TelescopeTabline"), 'nofiletype': 1}
let g:tabline_ft.vimwiki = {'fn': function("VimwikiTabline"), 'nofiletype': 1}

" CustomTabline
function! CustomTabline()
  for ft in keys(g:tabline_ft)
    if &filetype == ft
      let tabline = ''
      let tabline .= '%{%CurrentDirectoryDetail()%}'
      let tabline .= '%{%' .. string(g:tabline_ft[ft].fn) .. '()%}'
      if !g:tabline_ft[ft]->get("nofiletype")
        let tabline .= ' [' .. ft .. '] '
      endif
      let tabline .= '%{%TabPageDetail()%}'
      return tabline
    endif
  endfor

  " when no tabline is defined for the current filetype
  let tabline = ''
  let tabline .= '%{%CurrentDirectoryDetail()%}'
  let tabline .= '%{%CustomDefaultTabline()%}'
  let tabline .= '%{%TabPageDetail()%}'
  return tabline
endfunction

" GoyoTabline
function! GoyoTabline()
  for ft in keys(g:tabline_ft)
    if &filetype == ft
      let tabline = ''
      let tabline .= '%=%{%' .. string(g:tabline_ft[ft].fn) .. '()%}'
      if !g:tabline_ft[ft]->get("nofiletype")
        let tabline .= ' [' .. ft .. '] '
      endif
      return tabline
    endif
  endfor

  " when no tabline is defined for the current filetype
  let tabline = ''
  let tabline .= '%=%{%CustomDefaultTabline()%}'
  return tabline
endfunction

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

" FormatParagraph
"   format a paragraph, restoring original mark
command! FormatParagraph normal m'gqap`'

" ClearReg
"   clears specified register
command! -register ClearReg
      \ if !empty('<reg>') |
      \   call setreg('<reg>','') |
      \ endif

" ClipHTMLToMarkdown
" ClipMarkdownToHTML
"   TODO more testing required (usage may have broken)
"   commands for converting clipboard buffer to/from markdown
"   (for now this is linux only)
command! ClipHTMLToMarkdown !~/scripts/clip_html_to_markdown.sh
command! ClipMarkdownToHTML !~/scripts/clip_markdown_to_html.sh

" UndoLastClose
"   re-open last closed window in vertical
command! UndoLastClose call UndoLastClose()

" Scratch
"   create a temporary scratch buffer
command! Scratch new +set\ bt=nofile

" ReadMode
"   toggle scrolloff setting for using j and k for easy reading
command ReadMode
      \ if &scrolloff == 0        |
      \   setlocal scrolloff=999  |
      \ else                      |
      \   setlocal scrolloff<     |
      \ endif

" =================
" Vim Configuration
" =================
set number
set relativenumber
syntax enable
set ruler
set nohlsearch " looks better
set incsearch
set path+=**
set mousescroll=ver:1,hor:6
set laststatus=3
set sidescroll=0

" set custom tabline
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

" wildignore
"   also inspiration for .gitignore files
set wildignore+=*/__pycache__
set wildignore+=*/__pycache__/*
set wildignore+=*.bak

set nocompatible
set hidden

set mousemodel=extend

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

" disable line numbers in vimwiki
" set textwidth for vimwiki
" disable suggestions for vimwiki
" fix key mapping conflict with vimwiki and pear-tree
" add command for link tag hierarchy TODO underused, maybe remove
augroup chrys_ft_vimwiki
  autocmd!
  autocmd FileType vimwiki setlocal nonumber norelativenumber textwidth=80
  autocmd FileType vimwiki let b:coc_suggest_disable = 1
  autocmd FileType vimwiki let b:pear_tree_map_special_keys = 0
  autocmd FileType vimwiki command! -buffer -nargs=1 -complete=custom,vimwiki#tags#complete_tags
        \ ChryswikiGenerateTagLinks call call("vimwiki#tags#generate_tags", extend([1], vimwiki#tags#get_tags()->filter('v:val =~ "'..<f-args>..'"')))
  autocmd FileType vimwiki command! -buffer Vcd call <SID>change_directory_to_vimwiki_root(bufnr())
  autocmd FileType vimwiki autocmd BufWrite <buffer> call UpdateModifiedDate('\clast updated\?: ', getreg('d'))
augroup END

" set textwidth for markdown
" disable suggestions for markdown
" set conceallevel for markdown
augroup chrys_ft_markdown
  autocmd!
  autocmd FileType markdown setlocal nonumber norelativenumber textwidth=80 conceallevel=2
  autocmd FileType markdown let b:coc_suggest_disable = 1
augroup END

" =======
" Plugins
" =======

" Plugins with `vim_plug`
"  use :PlugInstall to actually install them
call plug#begin('~/.config/nvim/plugged')
Plug 'joshdick/onedark.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'vimwiki/vimwiki'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tmsvg/pear-tree'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'

Plug 'junegunn/goyo.vim'

Plug 'vlime/vlime', {'rtp': 'vim/'}

call plug#end()

" airline customisation
let g:airline_symbols_ascii = 1
"   call to function set defaults for filetypes variable, which we then extend
call airline#extensions#wordcount#apply()
let g:airline#extensions#wordcount#filetypes += ['vimwiki']

" airline advanced customisation
function! ChrysAirlineInit()
  let g:airline_section_x = airline#section#create(['%{TablineFlagsAndSymbols()}']) .. g:airline_section_x
endfunction

augroup chrys_airline_init
  autocmd!
  autocmd User AirlineAfterInit call ChrysAirlineInit()
augroup END

" vimwiki customisation
let g:vimwiki_global_ext = 0
"   disable vimwiki tables in preference for table.vim
let g:vimwiki_table_auto_fmt = 0
let g:vimwiki_key_mappings = {
      \ 'table_format': 0,
      \ 'table_mappings': 0,
      \ }

" pear_tree configuration
let g:pear_tree_ft_disabled = ['TelescopePrompt']
let g:pear_tree_repeatable_expand = 0

" telescope configuration
"   map i_Ctrl-Backspace to backspace
"   map i_Ctrl-Q to select horizontal
lua require("telescope").setup{
      \ defaults = {
      \   mappings = {
      \     i = {
      \       ["<C-_>"] = function()
      \         vim.cmd [[normal! bcw]]
      \       end,
      \       ["<C-Q>"] = require("telescope.actions").select_vertical,
      \     }
      \   }
      \ }}

" my wikis
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

" coc_nvim configuration
let g:coc_snippet_prev = ''

" onedark customisation
function! s:configure_onedark()
  let g:onedark_terminal_italics = 1
  let g:airline_theme = 'onedark'

  " onedark comment highlighting is too dark for my taste
  call onedark#extend_highlight("Comment", { "fg" : { "gui" : "#7C828C" } })
  " add better contrast for listchars (currently same as comment)
  call onedark#set_highlight("Whitespace", { "fg" : { "gui" : "#7c828C", "cterm" : "0", "cterm16": "0" } })
  " better contrast for cursor line highlighting
  call onedark#extend_highlight("CursorLine", { "bg" : { "gui" : "#48505E" } })

  highlight! link netrwMarkFile PmenuSel
  highlight! SpecialKey guifg=#505762
  highlight! clear NonText
  highlight! link NonText SpecialKey
  highlight! tabline_purple ctermfg=235 ctermbg=170 guifg=#282c34 guibg=#c678dd
  highlight! link DiagnosticError ErrorMsg
  highlight! Italic cterm=italic gui=italic
endfunction

autocmd ColorScheme onedark call <SID>configure_onedark()

" goyo configuration
let g:goyo_width = 85

" configure display during goyo
function! s:goyo_enter()
  set showtabline=2
  set tabline=%!GoyoTabline()
endfunction

function! s:goyo_leave()
  set showtabline=2
  set tabline=%!CustomTabline()
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" Colorscheme and Highlighting
set termguicolors
colorscheme onedark

