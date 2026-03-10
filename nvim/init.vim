" =======
" Sources
" =======
source ~/.config/nvim/table.vim

" ====================
" table.vim Extensions
" ====================
let s:_table_imap_return = TableExposeFunction("imap_return")
let s:_table_imap_backspace = TableExposeFunction("imap_backspace")
let s:_table_nmap_o = TableExposeFunction("nmap_o")
let s:_table_nmap_O = TableExposeFunction("nmap_O")

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
  inoremap <buffer><expr><silent> <CR> TableIsCursorInTable() ? <SID>table_imap_return() : pumvisible() ? "\<CR>" : "\<C-]>\<Esc>:VimwikiReturn 1 5\<CR>"
  " dispatch o to table.vim and vimwiki
  nmap <buffer><expr> o TableIsCursorInTable() ? <SID>table_nmap_o() : '<Plug>VimwikiListo'
  " dispatch O to table.vim and vimwiki
  nmap <buffer><expr> O TableIsCursorInTable() ? <SID>table_nmap_O() : '<Plug>VimwikiListO'
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

function! s:config_table_mappings()
  " dispatch for pear-tree compatibility
  inoremap <silent><expr> <CR> TableIsCursorInTable() ? <SID>table_imap_return() : "\<Plug>(PearTreeExpand)"
  inoremap <silent><expr> <BS> TableIsCursorInTable() ? <SID>table_imap_backspace() : "\<Plug>(PearTreeBackspace)"
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
  nmap <silent> <Leader>h <CMD>set hlsearch!<CR>
  " \l to toggle colour line
  nmap <silent> <Leader>l <CMD>setl cul!<CR>
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
  nnoremap <M-r> <C-W>r
  nnoremap <M-t> <C-W>t
  nnoremap <M-o> <C-W>o
  nnoremap <M-p> <C-W>p
  nnoremap <M-s> <C-W>s

  " these four double as table navigation so I also use the leader key to
  " 'escape' the table context
  nnoremap <expr> <M-h> TableIsCursorInTable() ? '<Plug>(TableLeftCell)'  : '<C-W>h'
  nnoremap <expr> <M-j> TableIsCursorInTable() ? '<Plug>(TableDownCell)'  : '<C-W>j'
  nnoremap <expr> <M-k> TableIsCursorInTable() ? '<Plug>(TableUpCell)'    : '<C-W>k'
  nnoremap <expr> <M-l> TableIsCursorInTable() ? '<Plug>(TableRightCell)' : '<C-W>l'
  nnoremap <Leader><M-h> <C-W>h
  nnoremap <Leader><M-j> <C-W>j
  nnoremap <Leader><M-k> <C-W>k
  nnoremap <Leader><M-l> <C-W>l

  nnoremap <M-x> <C-W>x
  nnoremap <M-v> <C-W>v
  nnoremap <M-b> <C-W>b

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

function! s:config_misc_mappings()
  " Ctrl-S to save current file in normal and insert mode
  nnoremap <silent> <C-S> <CMD>call SaveCurrentModifiedFile()<CR>
  imap <C-S> <C-O><C-S>

  " Load and make view on F5 and Shift+F5 respectively
  nnoremap <F5> <CMD>call SafeLoadView()<CR>
  nnoremap <F17> <CMD>mkview<BAR>echo 'Created view'<CR>

  " Ctrl-Backspace to Ctrl-W in insert and command mode
  imap <C-H> <C-W>
  cmap <C-H> <C-W>

  " Esc to escape terminal
  tmap <C-[> <C-\><C-N>

  " Q to format paragraph without jumping
  nnoremap Q gwap

  " gy to g<Tab>
  nnoremap gy g<Tab>
endfunction

function! s:config_command_keys()
  " inspired by emacs-keys in the vim manual
  cnoremap <C-A> <Home>
  cnoremap <C-B> <Left>
  cnoremap <C-E> <End>
  cnoremap <C-F> <Right>
  cnoremap <Esc>b <S-Left>
  cnoremap <Esc>f <S-Right>
endfunction

" global mappings
call s:config_misc_mappings()
call s:config_bracket_swapping_mappings()
call s:config_windowing_mappings()
call s:config_leader_mappings()
call s:config_telescope_mappings()
call s:config_table_mappings()
call s:config_command_keys()

" filetype-specific mappings
augroup chrys_ft_mappings
  autocmd!
  autocmd FileType vimwiki call s:config_vimwiki_mappings()
  autocmd FileType cpp call s:config_cpp_mappings()
  autocmd FileType netrw call s:config_netrw_mappings()

  " <C-J> in insert mode in python files refreshes coc
  autocmd FileType python inoremap <buffer> <silent> <C-J> <CMD>call coc#refresh()<CR>

  " restore default backspace mapping for filetypes with pear-tree disabled
  autocmd FileType TelescopePrompt inoremap <buffer> <BS> <BS>
augroup END

" =================
" Tabline Functions
" =================
" s:highlight_if_modified
function! s:highlight_if_modified(tabline)
  return &modified ? '%#Italic#' .. a:tabline .. '%#TabLineFill#*' : a:tabline
endfunction

let g:tabline_defaults = {}

" default tabline renderer
function! g:tabline_defaults.renderer()
  return ' ' .. s:highlight_if_modified('%f') .. ' %='
endfunction

" current directory renderer
function! g:tabline_defaults.directory_detail()
  return '%1* %{fnamemodify(getcwd(), '':t'')} %*'
endfunction

function! DirectoryButton(minwid, nclicks, button, mods)
  top vnew .
endfunction

" current directory button
function! g:tabline_defaults.directory_button()
  return '%@DirectoryButton@%1* %{fnamemodify(getcwd(), '':t'')} %*%X'
endfunction

" tab pages renderer
function! g:tabline_defaults.tab_page_detail()
  return tabpagenr('$') > 1 ? '%1* %{tabpagenr()} / %{tabpagenr(''$'')} %*' : ''
endfunction

" tab pages buttons renderer
function! g:tabline_defaults.tab_page_buttons()
  let inactive_tab = "%%7*%%%dT %d %%T%%*"
  let active_tab = "%%1* %d %%*"
  let active_tabpagenr = tabpagenr()
  let max_tabpagenr = tabpagenr('$')
  if max_tabpagenr == 1
    return ''
  endif

  let tab_pages = map(range(1, max_tabpagenr), {_,v -> printf(inactive_tab, v, v)})
  let tab_pages[active_tabpagenr - 1] = printf(active_tab, active_tabpagenr)
  return join(tab_pages, '')
endfunction

let g:status_lights = {}

let g:status_lights.symbols = {
      \ 'cursorline': '=',
      \ 'digraph':    '~',
      \ 'linebreak':  ']',
      \ 'list':       '¶',
      \ 'spell':      '¤',
      \ 'wrap':       'W',
      \ }

" status lights symbols renderer
function! g:status_lights.symbols_renderer()
  let lights = ''
  for [optname, symbol] in items(g:status_lights.symbols)
    if eval('&' .. optname)
      let lights ..= symbol
    endif
  endfor
  return lights
endfunction

" status lights read mode renderer
function! g:status_lights.readmode_renderer()
  return &scrolloff == 999 ? 'READ' : ''
endfunction

let g:status_lights.flags = {
      \ 'virtualedit': ['ve', {val -> val != ''}],
      \ 'colorcolumn': ['cc', {val -> val != ''}],
      \ 'textwidth':   ['tw', {val -> val != 0}],
      \ 'tabstop':     ['ts', {val -> val != 2}],
      \ 'scrolloff':   ['so', {val -> val != 0 && val != 999}],
      \ }

" status lights flags renderer
function! g:status_lights.flags_renderer()
  let flags = []
  for [optname, data] in items(g:status_lights.flags)
    let [display, Cond] = data
    let optval = eval('&'..optname)
    if Cond(optval)
      call add(flags, printf("%S=%d", display, optval))
    endif
  endfor
  return flags->sort()->join(' ')
endfunction

" status lights filetype renderer
function! g:status_lights.filetype_renderer()
  return &filetype
endfunction

" status lights hlsearch renderer
function! g:status_lights.hlsearch_renderer()
  if ! &hlsearch
    return ''
  endif

  let matches = matchbufline(bufnr(), @/, 1, '$')
  let [_, lnum, byte, _] = getpos('.')
  let counter = 0
  for match in matches
    if lnum < match.lnum
      break
    elseif lnum == match.lnum && byte < match.byteidx
      break
    else
      let counter += 1
    endif
  endfor

  return printf('/%s/[%d/%d]', @/, counter, len(matches))
endfunction

" status lights defaults
let g:status_lights.default_lights = [
      \ g:status_lights.filetype_renderer,
      \ g:status_lights.readmode_renderer,
      \ g:status_lights.flags_renderer,
      \ g:status_lights.symbols_renderer,
      \ g:status_lights.hlsearch_renderer,
      \ ]

function! s:pad(text)
  return len(a:text) > 0 ? a:text .. ' ' : ''
endfunction

" status lights combining renderer
function! g:status_lights.big_renderer()
  let lights = ''
  let renderers = get(w:, "lights_renderers", g:status_lights.default_lights)
  for Light_Renderer in renderers
    let lights ..= s:pad(Light_Renderer())
  endfor
  return lights
endfunction

" status lights customisation
let g:status_lights.known_lights = [
      \ "filetype", "flags", "readmode", "symbols", "hlsearch"
      \ ]

" ConfigureLights(lights)
" configure status lights for the current window
"
" lights should be a list of known names of lights, or a string containing
" known names of lights separated by whitespace
"
" unknown names are ignored
"
" return 1 if any names were unknown for testing purposes, otherwise 0
function! ConfigureLights(lights)
  let lights = type(a:lights) == type('') ? split(a:lights) : a:lights
  let lights_on = []
  let renderers = []
  for name in lights
    if index(g:status_lights.known_lights, name) != -1
      call add(lights_on, name)
      call add(renderers, funcref("g:status_lights." .. name .. "_renderer", g:status_lights))
    endif
  endfor

  let w:lights_on = lights_on
  let w:lights_renderers = renderers
  return len(renderers) != len(lights)
endfunction

" ResetLights()
" reset status lights for the current window to the global default
function! ResetLights()
  unlet! w:lights_on w:lights_renderers
endfunction

" LightOn(light)
" enable known light name in status lights for currrent window
"
" return 0 if light was enabled, otherwise 1
function! LightOn(light)
  if index(g:status_lights.known_lights, a:light) == -1
    return 1
  endif

  if ! exists("w:lights_on")
    let w:lights_on = copy(g:status_lights.known_lights)
  endif

  if index(w:lights_on, a:light) != -1
    return 1
  endif

  call add(w:lights_on, a:light)
  let w:lights_renderers = []
  for name in w:lights_on
    call add(w:lights_renderers, funcref("g:status_lights." .. name .. "_renderer", g:status_lights))
  endfor
  return 0
endfunction

" LightOff(light)
" disable known light name in status lights for currrent window
"
" return 0 if light was disabled, otherwise 1
function! LightOff(light)
  if index(g:status_lights.known_lights, a:light) == -1
    return 1
  endif

  if ! exists("w:lights_on")
    let w:lights_on = copy(g:status_lights.known_lights)
  endif

  let index = index(w:lights_on, a:light)
  if index == -1
    return 1
  endif

  call remove(w:lights_on, index)
  let w:lights_renderers = []
  for name in w:lights_on
    call add(w:lights_renderers, funcref("g:status_lights." .. name .. "_renderer", g:status_lights))
  endfor
  return 0
endfunction

" completion list helper function
function! KnownLights(ArgLead, CmdLine, CursorPos)
  return join(g:status_lights.known_lights, "\n")
endfunction

" use to define custom tablines for specific filetypes.
"
" The filetypes are used as keys in the dictionary and the values should be
" funcrefs that accept no arguments and return a string representing the
" custom tabline. This string can contain statusline fields, as the result is
" evaluated again before being displayed. These functions should assume that
" they are allowed to take up the maximum space possible using %= .
let g:tabline_renderer = {}

" netrw renderer
function! g:tabline_renderer.netrw()
  let tabline = ''

  let cd = get(b:, 'netrw_curdir')
  let tabline ..= ' ' .. cd

  let target = netrw#Expose("netrwmftgt")
  if target != 'n/a'
    let tabline ..= ' (T %6*' .. target .. '%*)%='
  else
    let tabline ..= ' (T none)%='
  endif
  return tabline
endfunction

" help renderer
" could be more intelligent to report the last help term that was searched
" but this will do for now
function! g:tabline_renderer.help()
  let title = expand('%:t:r') "report the name of help file
  return ' ' .. title .. '%='
endfunction

" TelescopePrompt renderer
function! g:tabline_renderer.TelescopePrompt()
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

" vimwiki renderer
function! g:tabline_renderer.vimwiki()
  let page = expand('%:t:r')
  let buf_subdir = vimwiki#vars#get_bufferlocal('subdir')
  let sub_path = substitute(buf_subdir, '\/\|\\', ' -> ', 'g')
  let wikiname = vimwiki#vars#get_wikilocal('name')
  if wikiname == ''
    let wikiname = vimwiki#vars#get_wikilocal('path')
  endif

  let diary_subdir = vimwiki#vars#get_wikilocal('diary_rel_path')
  let diary_index = vimwiki#vars#get_wikilocal('diary_index')
  let index = vimwiki#vars#get_wikilocal('index')

  let tabline = ' ' .. wikiname
  if buf_subdir == diary_subdir && page == diary_index
    let tabline ..= ' Diary'

  elseif buf_subdir == diary_subdir
    let tabline ..= ' Diary: '
    let tabline ..= s:tabline_format_vimwiki_date(page->split('-'))

  elseif page == index
    let tabline = tabline

  else
    let page = substitute(page, '_', ' ', 'g')
    let tabline ..= ' -> ' .. sub_path .. page
  endif

  return s:highlight_if_modified(tabline) .. '%='
endfunction

function! s:check_trailing_space(bufnr)
  let matches = matchbufline(a:bufnr, '\s\+$', 1, '$')
  if empty(matches)
    call setbufvar(a:bufnr, "statusline_trailing_linenr", 0)
  else
    call setbufvar(a:bufnr, "statusline_trailing_linenr", matches[0].lnum)
  endif
  " update the statusline (see CursorHold docs)
  let &ro = &ro
endfunction

function! s:check_branch_state(bufnr)
  let git_dir = FugitiveGitDir(a:bufnr)
  if empty(git_dir)
    return
  endif

  let state_info = getbufvar(a:bufnr, "statusline_branch", {})
  if empty(state_info)
    let state_info.branch_name = FugitiveHead(10, a:bufnr)
    let state_info.git_dir = git_dir
    let state_info.dirty = 0
    call setbufvar(a:bufnr, "statusline_branch", state_info)
  endif

  let branch_status = FugitiveExecute(["status", "--porcelain"], a:bufnr)
  let state_info.dirty = len(branch_status.stdout) > 1
  let &ro = &ro
endfunction

function! s:check_tabs(bufnr)
  let tab_matches = matchbufline(a:bufnr, '\t', 1, '$')
  if len(tab_matches) == 0
    call setbufvar(a:bufnr, "statusline_bad_tab", {})
  else
    call setbufvar(a:bufnr, "statusline_bad_tab", tab_matches[0])
  endif
  let &ro = &ro
endfunction

augroup chrys_statusline
  autocmd!
  " check for trailing spaces in buffer
  autocmd CursorHold * call s:check_trailing_space(bufnr())
  autocmd BufReadPost * call s:check_trailing_space(bufnr())
  autocmd BufEnter * call s:check_trailing_space(bufnr())
  autocmd BufWritePost * call s:check_trailing_space(bufnr())

  " check for branch information
  autocmd CursorHold * call s:check_branch_state(bufnr())
  autocmd BufReadPost * call s:check_branch_state(bufnr())
  autocmd BufEnter * call s:check_branch_state(bufnr())
  autocmd BufWritePost * call s:check_branch_state(bufnr())

  " check for trailing spaces in buffer
  autocmd CursorHold * call s:check_tabs(bufnr())
  autocmd BufReadPost * call s:check_tabs(bufnr())
  autocmd BufEnter * call s:check_tabs(bufnr())
  autocmd BufWritePost * call s:check_tabs(bufnr())

  " filetypes for displaying wordcount
  autocmd FileType text,markdown,help,vimwiki let b:statusline_wordcount = 1
augroup END

let g:statusline_fns = {}

function! g:statusline_fns.trailing()
  let trailing_linenr = get(b:, "statusline_trailing_linenr", 0)
  if trailing_linenr
    return '!\s$ ' .. trailing_linenr
  else
    return ''
  endif
endfunction

function! g:statusline_fns.wordcount()
  if ! get(b:, "statusline_wordcount", 0)
    return ''
  endif

  let info = wordcount()
  if has_key(info, 'visual_words')
    let words = info.visual_words
  else
    let words = info.words
  endif
  return '%3*' .. Pprint_number(words) .. '%1* words '
endfunction

function! g:statusline_fns.branch()
  let state_info = get(b:, "statusline_branch", {})
  if empty(state_info)
    return ''
  elseif state_info.dirty
    return printf("(%s!)", state_info.branch_name)
  else
    return printf("(%s)", state_info.branch_name)
  endif
endfunction

function! g:statusline_fns.bad_tabs()
  if &filetype == 'help'
    return ''
  elseif ! get(b:, "do_warn_tabs", get(g:, "do_warn_tabs", 1))
    return ''
  elseif ! exists("b:statusline_bad_tab")
    return ''
  elseif empty(b:statusline_bad_tab)
    return ''
  else
    let lnum = b:statusline_bad_tab.lnum
    return '!\t ' .. lnum
  endif
endfunction

function! s:pad_warning_highlight(text)
  return len(a:text) > 0 ? '%5* ' .. a:text .. ' %*' : ''
endfunction

function! g:statusline_fns.warnings()
  let warnings = []
  call add(warnings, g:statusline_fns.trailing())
  call add(warnings, g:statusline_fns.bad_tabs())

  let result = join(filter(warnings, "len(v:val) > 0"))
  return s:pad_warning_highlight(result)
endfunction

" CustomStatusline
function! CustomStatusline()
  let statusline = ' '
  let statusline ..= '%*%<'
  let statusline ..= s:highlight_if_modified('%f') .. ' '
  let statusline ..= '%{%g:statusline_fns.branch()%}'
  let statusline ..= '%='
  let statusline ..= '%2*%{%g:status_lights.big_renderer()%}%*'
  let statusline ..= '%1* '
  let statusline ..= '%{%g:statusline_fns.wordcount()%}'
  let statusline ..= 'L %3*%l%1*/%L C %3*%v%1* %p%% %*'
  let statusline ..= '%{%g:statusline_fns.warnings()%}'
  return statusline
endfunction

" QuickfixStatusline
function! QuickfixStatusline()
  "%t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''} %=%-15(%l,%c%V%) %P
  let statusline = ' '
  let statusline ..= "%*%<%t %{exists('w:quickfix_title') ? w:quickfix_title : ''}"
  let statusline ..= '%='
  let statusline ..= '%2*%{&filetype}%* '
  let statusline ..= '%2*%{%g:status_lights.big_renderer()%}%*'
  let statusline ..= '%1* '
  let statusline ..= 'L %3*%l%1*/%L C %3*%c%1* %p%% '
  return statusline
endfunction

function! s:get_tabline_renderer(ft)
  if has_key(g:tabline_renderer, a:ft)
    return 'g:tabline_renderer.' .. a:ft
  else
    return 'g:tabline_defaults.renderer'
  endif
endfunction

" CustomTabline
function! CustomTabline()
  let renderer = s:get_tabline_renderer(&filetype)
  let tabline = ''
  let tabline ..= '%{%g:tabline_defaults.directory_button()%}'
  let tabline ..= '%{%'..renderer..'()%}'
  let tabline ..= '%{%g:tabline_defaults.tab_page_buttons()%}'
  return tabline
endfunction

" GoyoTabline
function! GoyoTabline()
  let renderer = s:get_tabline_renderer(&filetype)
  return '%=%{%'..renderer..'()%}'
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

function! s:define_word(word) abort
  if match(a:word, '[A-Za-z]\+') == -1
    echoerr printf("Cannot define '%s'", a:word)
    return
  endif

  let curl_cmd = "!curl dict.org/d:" .. a:word
  new +set\ bt=nofile
  silent execute "read" curl_cmd
  silent %s/\r//
  silent 1,/^151/-1d _
  silent /^250/,$d _
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

" ReadMode
"   toggle scrolloff setting for using j and k for easy reading
command! ReadMode
      \ if &scrolloff == 999      |
      \   setlocal scrolloff<     |
      \ else                      |
      \   setlocal scrolloff=999  |
      \ endif

" ConfigureLights
"   configure status lights for the current window
command! -complete=custom,KnownLights -nargs=1 ConfigureLights
      \ if ConfigureLights('<args>')  |
      \   echohl ErrorMsg             |
      \   echomsg "Unknown lights"    |
      \   echohl None                 |
      \ endif

" ResetLights
"   reset status lights for the current window
command! ResetLights
      \ call ResetLights()              |
      \ echo "Lights have been reset!"

" LightOn
"   turn light on in status lights for current window
command! -complete=custom,KnownLights -nargs=1 LightOn
      \ if LightOn('<args>')      |
      \   echohl ErrorMsg         |
      \   echomsg "Unknown light" |
      \   echohl None             |
      \ endif

" LightOff
"   turn light off in status lights for current window
command! -complete=custom,KnownLights -nargs=1 LightOff
      \ if LightOff('<args>')     |
      \   echohl ErrorMsg         |
      \   echomsg "Unknown light" |
      \   echohl None             |
      \ endif

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

" =================
" Vim Configuration
" =================
set hidden
set incsearch
set nohlsearch
set number
set relativenumber
set sidescroll=0

" set custom statusline and tabline
set laststatus=3
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
set path+=**
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
augroup chrys_ft_markdown
  autocmd!

  " disable line numbers
  autocmd FileType markdown setlocal nonumber norelativenumber

  " set textwidth for markdown
  autocmd FileType markdown setlocal textwidth=80

  " disable suggestions for markdown
  autocmd FileType markdown let b:coc_suggest_disable = 1

  " set conceallevel for markdown
  autocmd FileType markdown setlocal conceallevel=2

  " set table->plaintext decorators
  autocmd FileType markdown let b:table_plain_before = "```\n"
  autocmd FileType markdown let b:table_plain_after = "\n```"

  " set keywordprg to define a word
  autocmd FileType markdown setlocal keywordprg=:DefineConfirm
augroup END

" quickfix-specific
augroup chrys_ft_qf
  autocmd!
  autocmd FileType qf setlocal statusline=%!QuickfixStatusline()
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
      \ }

augroup chrys_ft_vimwiki
  autocmd!

  " disable line numbers
  autocmd FileType vimwiki setlocal nonumber norelativenumber textwidth=80

  " set textwidth to 80
  autocmd FileType vimwiki setlocal textwidth=80

  " include hyphens and apostrophes in words
  autocmd FileType vimwiki setlocal iskeyword+=-,'

  " Vcd change current directory to wiki root (vimwiki only)
  autocmd FileType vimwiki command! -buffer Vcd call <SID>change_directory_to_vimwiki_root(bufnr())

  " auto update last modified date text
  autocmd FileType vimwiki autocmd BufWrite <buffer> call UpdateModifiedDate('\clast updated\?:', printf(" %S", getreg('d')))

  " TodayHeader jump to header with today's date (vimwiki only)
  autocmd FileType vimwiki command! -buffer TodayHeader call search(printf('^#\+ %s', getreg('d')))

  " fix conflicts with other plugins
  autocmd FileType vimwiki let b:coc_suggest_disable = 1
  autocmd FileType vimwiki let b:pear_tree_map_special_keys = 0

  " set table->plaintext decorators
  autocmd FileType vimwiki let b:table_plain_before = "```\n"
  autocmd FileType vimwiki let b:table_plain_after = "\n```"

  " set keywordprg to define a word
  autocmd FileType vimwiki setlocal keywordprg=:DefineConfirm
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

" ====
" Goyo
" ====

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

" ===============
" Onedark (theme)
" ===============

function! s:configure_onedark()
  let g:onedark_terminal_italics = 1

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
endfunction

autocmd ColorScheme onedark call <SID>configure_onedark()

set termguicolors
colorscheme onedark

