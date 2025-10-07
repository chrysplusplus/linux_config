" =========
" Functions
" =========

" ChangeDirectoryToWikiRoot (bufnr)
"   sets the current working directory to the root directory for the wiki for
"   the specified buffer
function! ChangeDirectoryToWikiRoot(bufnr)
  let wiki_nr = getbufvar(a:bufnr, "vimwiki_wiki_nr", -1)
  if wiki_nr == -1
    return
  endif

  let wiki_path =  vimwiki#vars#get_wikilocal('path', wiki_nr)
  execute "lchdir" wiki_path
endfunction

" SetTermProg(prog, args, ...)
"   set the terminal program for the current buffer
function! SetTermProg(...)
  let b:term_prog_cmd = join(a:000)
endfunction

" ClearTermProg()
"   clears the current terminal program for the current buffer
function! ClearTermProg()
  if !get(b:, 'term_prog_cmd', '')->empty()
    unlet b:term_prog_cmd
  endif
endfunction

" ConstructCommand(command_name, exec ...)
"   (re)define user command `command_name` to execute command given by `exec`
function! ConstructCommand(command_name, ...)
  let cmd = ":exec \'!&" . join(a:000) . "\'"
  execute ':command!' a:command_name cmd
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

" s:toggle_quickfix_list()
"   toggle visibility of quickfix list window
function! s:toggle_quickfix_list()
  let windows = getwininfo()
  for window in windows
    if window.quickfix == 1
      cclose
      return
    endif
  endfor

  copen
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

" s:config_vimwiki_mappings()
" set key mappings for vimwiki
function! s:config_vimwiki_mappings()
  " Remap Ctrl-T to increase list indent for vimwiki
  imap <buffer> <C-T> <Plug>VimwikiIncreaseLvlSingleItem
  " Fix for pear tree not working
  imap <buffer> <BS> <Plug>(PearTreeBackspace)
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
endfunction

" s:config_cpp_mappings()
"   set mappings for cpp files
function! s:config_cpp_mappings()
  " remap gd to search for word under cursor in source files in directory
  nnoremap <silent> <buffer> gd <CMD>vim/\<<C-R><C-W>\>/gj **/*.h **/*.cpp<BAR>copen<CR>
  vnoremap <silent> <buffer> gd y<CMD>vim/\<<C-R>"\>/gj **/*.h **/*.cpp<BAR>copen<CR>
endfunction

" s:tabpage_term_winid()
"   returns the window id for the terminal buffer in a tab
"   or -1 if there isn't one
function! s:tabpage_term_winid()
  let tab_info = gettabinfo(tabpagenr())
  if tab_info->empty()
    return -1
  endif

  let windows = get(tab_info[0], 'windows', [])
  if windows->empty()
    return -1
  endif

  for winid in windows
    let wininfo = getwininfo(winid)
    if wininfo->empty()
      continue
    elseif get(wininfo[0], 'terminal', 0)
      return winid
    endif
  endfor

  return -1
endfunction

" TODO check if colours need fixing
" set better ANSI colors from powershell for the interactive terminal
let g:term_cmd = "/bin/bash"
let g:term_cmd_title = "bash"

" s:name_term_default(name)
"   sets nicer name for default terminal
function! s:name_term_default(name)
  let count = 1
  let title = a:name
  while buflisted(title)
    let title = a:name .. ' [' .. count .. ']'
    let count = count + 1
  endwhile
  silent! execute "keepalt file" title
endfunction

" OpenCustomTerminal()
"   open customer powershell terminal job at the bottom of the screen
function! OpenCustomTerminal()
  let term_win_id = s:tabpage_term_winid()
  let term_buf_id = get(b:, 'term_buf_id', 0)

  if term_win_id != -1
    call win_gotoid(term_win_id)
    startinsert
  elseif term_buf_id && buflisted(term_buf_id)
    let term_win_id = bufwinid(term_buf_id)
    if term_win_id == -1
      execute 'botright new #' .. term_buf_id
      startinsert
    else
      call win_gotoid(term_win_id)
      startinsert
    endif
  elseif get(b:, 'term_prog_cmd', '') != ''
    let parent_buf_id = bufnr()
    let cmd = b:term_prog_cmd
    botright new
    call termopen(cmd)
    call setbufvar(parent_buf_id, 'term_buf_id', bufnr())
    startinsert
  else
    let parent_buf_id = bufnr()
    botright new
    call termopen(g:term_cmd)
    call setbufvar(parent_buf_id, 'term_buf_id', bufnr())
    call s:name_term_default(g:term_cmd_title)
    startinsert
  endif
endfunction

" s:config_netrw_mappings
function! s:config_netrw_mappings()
  " P to close preview window
  nnoremap <silent> <buffer> P <CMD>pclose<CR>
  " warn on moving
  nnoremap <silent> <buffer> mm <CMD>echoerr 'mm has been unmapped'<CR>
  " Ctrl-Q to return to alt buffer (disabled)
  "nnoremap <buffer> <C-Q> <C-^>
endfunction

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
      let tabline .= '%{%TablineFlagsAndSymbols()%}'
      let tabline .= '%{%TabPageDetail()%}'
      return tabline
    endif
  endfor

  let tabline = ''
  let tabline .= '%{%CurrentDirectoryDetail()%}'
  let tabline .= '%{%CustomDefaultTabline()%}'
  let tabline .= '%{%TablineFlagsAndSymbols()%}'
  let tabline .= '%{%TabPageDetail()%}'

  return tabline
endfunction

" GoyoTabline
"   TODO cleanup
function! GoyoTabline()
  for ft in keys(g:tabline_ft)
    if &filetype == ft
      let tabline = ''
      "let tabline .= '%{%CurrentDirectoryDetail()%}'
      let tabline .= '%{%' .. string(g:tabline_ft[ft].fn) .. '()%}'
      if !g:tabline_ft[ft]->get("nofiletype")
        let tabline .= ' [' .. ft .. '] '
      endif
      let tabline .= '%{%TablineFlagsAndSymbols()%}'
      return tabline
    endif
  endfor

  let tabline = ''
  "let tabline .= '%{%CurrentDirectoryDetail()%}'
  let tabline .= '%{%CustomDefaultTabline()%}'
  let tabline .= '%{%TablineFlagsAndSymbols()%}'

  return tabline
endfunction

function! SaveCurrentModifiedFile()
  if &modified
    write
  endif
endfunction

let g:chrys_zen_mode = 0
let g:chrys_zen_mode_restore = []

" s:toggle_zen_mode([set_mode])
"   set_mode optional int set zen mode on/off
"   return new mode
function! s:toggle_zen_mode(...)
  if a:0 > 0
    let zen_mode = a:1
  else
    let zen_mode = !g:chrys_zen_mode
  endif

  if zen_mode
    let g:chrys_zen_mode_restore = [&laststatus, &showtabline]
    set laststatus=3 showtabline=1
    let g:chrys_zen_mode = 1
  else
    let [&laststatus, &showtabline] = g:chrys_zen_mode_restore
    let g:chrys_zen_mode_restore = []
    let g:chrys_zen_mode = 0
  endif

  return zen_mode
endfunction

" ========
" Commands
" ========

" ClearTermProg
"   clears the current terminal program for the current buffer
command! ClearTermProg call ClearTermProg()

" SetTermProg [prog] [args] ...
"   set the terminal program for the current buffer
command! -nargs=+ -complete=file SetTermProg call SetTermProg(<f-args>)

" OpenCustomTerminal()
"   open customer powershell terminal job in the current window
command! OpenCustomTerminal call OpenCustomTerminal()

" ConstructCommand [command_name] [exec] ...
"   (re)define user command `command_name` to execute command given by `exec`
command! -nargs=+ -complete=file ConstructCommand call ConstructCommand(<f-args>)

" CopyCWDToClipboard
"   copy current working directory to clipboard
command! CopyCWDToClipboard call setreg("*", getcwd())

" ToggleQuickfixList
"   toggle visibility of quickfix list window
command! ToggleQuickfixList call s:toggle_quickfix_list()

" ToggleZenMode
"   toggle zen mode
command! ToggleZenMode call s:toggle_zen_mode()

" Qdate
"   echo quick data/set to register
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

" Vcd
"   change directory to wiki root
command! Vcd call ChangeDirectoryToWikiRoot(bufnr())

" ClipHTMLToMarkdown
" ClipMarkdownToHTML
"   commands for converting clipboard buffer to/from markdown
"   (for now this is linux only)
command! ClipHTMLToMarkdown !~/scripts/clip_html_to_markdown.sh
command! ClipMarkdownToHTML !~/scripts/clip_markdown_to_html.sh

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

" set custom tabline
set showtabline=2
set tabline=%!CustomTabline()

" fixes for tabline not updating enough
"augroup chrys_tabline_fix
"  autocmd!
"  "autocmd CursorMoved,CursorMovedI,ModeChanged * call airline#check_mode(winnr())|redrawtabline
"  autocmd CursorMoved,CursorMovedI,ModeChanged * if g:tabline_rapid_update|call airline#check_mode(winnr())|redrawtabline|endif
"augroup END

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

" ==========
" Remappings
" ==========

" Convenience mappings
" Remap Ctrl-S to save the current file
nnoremap <silent> <C-S> <CMD>call SaveCurrentModifiedFile()<CR>
" Remap Ctrl-S in insert mode to save the current file without leaving insert
" mode
imap <C-S> <C-O><C-S>
" Ctrl-Shift-S to save all modified files
nnoremap <silent> <C-S-S> <CMD>wall<CR>
" ...and in insert mode
imap <C-S-S> <C-O><C-S-S>

" Load view and make view set to F5 and Shift+F5 respectively
nnoremap <F5> <CMD>loadview<BAR>echo "Loaded view"<CR>
nnoremap <F17> <CMD>mkview<BAR>echo "Created view"<CR>

" Remap Leader + Ctrl-Z to open terminal in a new tab
noremap <silent> <Leader><C-Z> <CMD>OpenCustomTerminal<CR>
" Remap Ctrl-Z so it doesn't hang in cmd.exe
noremap <silent> <C-Z> <CMD>OpenCustomTerminal<CR>
" Ctrl-Backspace to Ctrl-W in Insert and Command mode
imap <C-H> <C-W>
cmap <C-H> <C-W>
" Q to format paragraph (similar to vim)
nnoremap Q <CMD>FormatParagraph<CR>

" Remap i_C-E and i_C-Y to scroll
" disabled since they cause issues with autocomplete
"imap <C-E> <C-X><C-E>
"imap <C-Y> <C-X><C-Y>

" Bracket swapping
nnoremap <silent> <Leader>r( m'%r)`'r(
nnoremap <silent> <Leader>r) m'%r)`'r(
nnoremap <silent> <Leader>r[ m'%r]`'r[
nnoremap <silent> <Leader>r] m'%r]`'r[
nnoremap <silent> <Leader>r{ m'%r}`'r{
nnoremap <silent> <Leader>r} m'%r}`'r{

" Terminal mode mappings
" Escape to escape terminal mode
tnoremap <Esc> <C-\><C-n>
" Exit terminal
"tnoremap <C-Q> <C-C>exit<CR>
" Ctrl-W to escape terminal
tmap <C-W> <C-\><C-N><C-W>p

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

" Alt + t to split window to new tab
nnoremap <M-t> <C-W>s<C-W>T

" Alt + g to open git view
nnoremap <M-g> <CMD>Git<CR>

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

" Leader toggle mappings
" \s to toggle spell check
nnoremap <silent> <Leader>s <CMD>setl spell!<CR>
" \h to toggle highlighted search
nnoremap <silent> <Leader>h <CMD>set hlsearch!<cr>
" \l to toggle colour line
nnoremap <silent> <Leader>l <CMD>setl cul!<CR>
" \L to toggle visible whitespace
nnoremap <silent> <Leader>L <CMD>setl list!<CR>
" \z to toggle goyo mode
nnoremap <silent> <Leader>z <CMD>Goyo<cr>
" \c to close quickfix list
nnoremap <silent> <Leader>c <CMD>cclose<CR>
" \m to toggle quickfix
nnoremap <silent> <Leader>m <CMD>ToggleQuickfixList<CR>
" \n to toggle line numbers
nnoremap <silent> <Leader>n <CMD>setl nu! rnu!<CR>

" Preivew window mappings
" \pp to close preview window
nnoremap <silent> <Leader>pp <CMD>pclose<cr>
" \pl to close preview window
nnoremap <silent> <Leader>pl <CMD>lclose<cr>

" \g to open fugitive buffer
nnoremap <silent> <Leader>g <CMD>Git<cr>

" Telescope mappings
" \e to pick a buffer
nnoremap <silent> <Leader>e <CMD>Telescope buffers<CR>
" \ee to pick a buffer
nnoremap <silent> <Leader>ee <CMD>Telescope buffers<CR>
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

" filetype mappings
" (disabled python terminal)
augroup chrys_map
  autocmd!
  autocmd FileType vimwiki call s:config_vimwiki_mappings()
  autocmd FileType cpp call s:config_cpp_mappings()
  autocmd FileType python inoremap <silent><expr> <C-J> coc#refresh()
  " autocmd FileType python command! -buffer
  "       \ OpenPythonTerminal botright new +call\ termopen("python")|startinsert
  " autocmd FileType python nmap <silent><buffer> <C-Z> <CMD>OpenPythonTerminal<CR>
  autocmd FileType netrw call s:config_netrw_mappings()

  " enter insert mode when window switches to a terminal
  " (disabled for now)
  "autocmd WinEnter * if getbufvar(bufnr(), "terminal_job_pid")|startinsert|endif
augroup END

" =====================
" General Configuration
" =====================

" set configuration for :make
call ResetMakeBuildDir()

" filetype specific configuration
"   disable line numbers in the terminal and vimwiki
"   set textwidth and wrapping settings for markdown and vimwiki
"   disable suggestions for vimwiki
"   fix key mapping conflict with vimwiki and pear-tree
"   add command for link tag hierarchy
augroup chrys_filetype
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber
  autocmd FileType vimwiki setlocal nonumber norelativenumber textwidth=80
  autocmd FileType markdown setlocal nonumber norelativenumber textwidth=80 conceallevel=2
  autocmd FileType vimwiki let b:coc_suggest_disable = 1
  autocmd FileType vimwiki let b:pear_tree_map_special_keys = 0
  autocmd FileType markdown let b:coc_suggest_disable = 1
  autocmd FileType vimwiki command! -buffer -nargs=1 -complete=custom,vimwiki#tags#complete_tags
        \ ChryswikiGenerateTagLinks call call("vimwiki#tags#generate_tags", extend([1], vimwiki#tags#get_tags()->filter('v:val =~ "'..<f-args>..'"')))
augroup END

"   open quickfix window if :make yields errors
augroup chrys_quickfix
  autocmd!
  autocmd QuickfixCmdPost make call PromptQuickfix()
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
Plug 'nvim-lua/telescope.nvim', { 'tag': '0.1.6' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'

Plug 'junegunn/goyo.vim'

call plug#end()

" airline customisation
let g:airline_symbols_ascii = 1
"let g:airline_stl_path_style = 'short'
"   call to function set defaults for filetypes variable, which we then extend
call airline#extensions#wordcount#apply()
let g:airline#extensions#wordcount#filetypes += ['vimwiki']
"   enable ctrlspace integration
let g:airline#extensions#ctrlspace#enabled = 1
"   tabline customisation
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#show_buffers = 1
"let g:airline#extensions#tabline#formatter = 'unique_tail'
"let g:airline#extensions#tabline#buffers_label = 'bufs'

" vimwiki customisation
let g:vimwiki_global_ext = 0

" pear_tree configuration
let g:pear_tree_ft_disabled = ['TelescopePrompt']
let g:pear_tree_repeatable_expand = 0

" telescope configuration
"   map i_Escape to close telescope
"   map i_Ctrl-Backspace to backspace
"   map i_Ctrl-Q to select horizontal
lua require("telescope").setup{
      \ defaults = {
      \   mappings = {
      \     i = {
      \       ["<Esc>"] = require("telescope.actions").close,
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
let notes_wiki.index = 'the note'

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
let g:chrys_goyo_quiet_mode = 0

command! GoyoQuietMode let g:chrys_goyo_quiet_mode = !g:chrys_goyo_quiet_mode

" configure display during goyo
function! s:goyo_enter()
  if !empty(g:chrys_goyo_quiet_mode)
    return
  endif

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

" use Qdate to set d register to today's date silently
silent Qdate d

