" File: chrysline.vim
" Author: chrysplusplus
" Description: Customise statusline and tabline in vim

" CustomStatusline()
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
  let statusline = ' '
  let statusline ..= "%*%<%t %{exists('w:quickfix_title') ? w:quickfix_title : ''}"
  let statusline ..= '%='
  let statusline ..= '%2*%{&filetype}%* '
  let statusline ..= '%2*%{%g:status_lights.big_renderer()%}%*'
  let statusline ..= '%1* '
  let statusline ..= 'L %3*%l%1*/%L C %3*%c%1* %p%% '
  return statusline
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
function! FocusTabline()
  let renderer = s:get_tabline_renderer(&filetype)
  return '%=%{%'..renderer..'()%}'
endfunction

" ConfigureLights
" Configure status lights for the current window
command! -complete=custom,KnownLights -nargs=1 ConfigureLights
      \ if ConfigureLights('<args>')  |
      \   echohl ErrorMsg             |
      \   echomsg "Unknown lights"    |
      \   echohl None                 |
      \ endif

" ResetLights
" Reset status lights for the current window
command! ResetLights
      \ call ResetLights()              |
      \ echo "Lights have been reset!"

" LightOn
" Turn light on in status lights for current window
command! -complete=custom,KnownLights -nargs=1 LightOn
      \ if LightOn('<args>')      |
      \   echohl ErrorMsg         |
      \   echomsg "Unknown light" |
      \   echohl None             |
      \ endif

" LightOff
" Turn light off in status lights for current window
command! -complete=custom,KnownLights -nargs=1 LightOff
      \ if LightOff('<args>')     |
      \   echohl ErrorMsg         |
      \   echomsg "Unknown light" |
      \   echohl None             |
      \ endif

" =================
" Tabline Renderers
" =================

let g:tabline_defaults = {}

function! g:tabline_defaults.renderer() "-> String"
  " default tabline renderer
  return ' ' .. s:highlight_if_modified('%f') .. ' %='
endfunction

function! g:tabline_defaults.directory_detail() "-> String"
  " current directory renderer
  " TODO check if used
  return '%1* %{fnamemodify(getcwd(), '':t'')} %*'
endfunction

function! DirectoryButton(minwid, nclicks, button, mods)
  " handler for DirectoryButton
  top vnew .
endfunction

function! g:tabline_defaults.directory_button() "-> String"
  " current directory button
  return '%@DirectoryButton@%1* %{fnamemodify(getcwd(), '':t'')} %*%X'
endfunction

function! g:tabline_defaults.tab_page_detail() "-> String"
  " tab pages renderer
  " TODO check if used
  return tabpagenr('$') > 1 ? '%1* %{tabpagenr()} / %{tabpagenr(''$'')} %*' : ''
endfunction

function! g:tabline_defaults.tab_page_buttons() "-> String"
  " tab page buttons renderer
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

" g:tabline_renderer
" Mapping of filetype strings to custom tabline renderers
"
" The filetypes are used as string keys in the dictionary and the values
" should be funcrefs that accept no arguments and return a string representing
" the custom tabline. This string can contain statusline fields, as the result
" is evaluated again before being displayed. These functions should assume
" that they are allowed to take up the maximum space possible using %= .
let g:tabline_renderer = {}

function! g:tabline_renderer.netrw() "-> String"
  " netrw renderer
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

function! g:tabline_renderer.help() "-> String"
  " help renderer
  let title = expand('%:t:r') "report the name of help file
  return ' ' .. title .. '%='
endfunction

function! g:tabline_renderer.TelescopePrompt() "-> String"
  " telescope-prompt renderer
  return '%='
endfunction

function! g:tabline_renderer.vimwiki() "-> String"
  " vimwiki renderer
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

" =============
" Status Lights
" =============

let g:status_lights = {}

let g:status_lights.symbols = {
      \ 'cursorline': '=',
      \ 'digraph':    '~',
      \ 'linebreak':  ']',
      \ 'list':       '¶',
      \ 'spell':      '¤',
      \ 'wrap':       'W',
      \ }

function! g:status_lights.symbols_renderer() "-> String"
  " symbols light
  let lights = ''
  for [optname, symbol] in items(g:status_lights.symbols)
    if eval('&' .. optname)
      let lights ..= symbol
    endif
  endfor
  return lights
endfunction

function! g:status_lights.tablemode_renderer() "-> String"
  " table mode light
  return exists("b:table_mode") ? 'TABLE' : ''
endfunction

augroup statuslights_tablemode_update
  " hook to table mode autocmds to update statusline
  autocmd User TableModeEnable let &ro = &ro
  autocmd User TableModeDisable let &ro = &ro
augroup END

let g:status_lights.flags = {
      \ 'virtualedit': ['ve', {val -> val != ''}],
      \ 'colorcolumn': ['cc', {val -> val != ''}],
      \ 'textwidth':   ['tw', {val -> val != 0}],
      \ 'tabstop':     ['ts', {val -> val != 2}],
      \ 'scrolloff':   ['so', {val -> val != 0 && val != 999}],
      \ }

function! g:status_lights.flags_renderer() "-> String"
  " flags light
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

function! g:status_lights.filetype_renderer() "-> String"
  " filetype light
  return &filetype
endfunction

function! g:status_lights.hlsearch_renderer() "-> String"
  " hlsearch light
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

let g:status_lights.default_lights = [
      \ g:status_lights.filetype_renderer,
      \ g:status_lights.tablemode_renderer,
      \ g:status_lights.flags_renderer,
      \ g:status_lights.symbols_renderer,
      \ g:status_lights.hlsearch_renderer,
      \ ]

function! g:status_lights.big_renderer() "-> String"
  " status lights combining renderer
  let lights = ''
  let renderers = get(w:, "lights_renderers", g:status_lights.default_lights)
  for Light_Renderer in renderers
    let lights ..= s:pad(Light_Renderer())
  endfor
  return lights
endfunction

" ===========================
" Status Lights Customisation
" ===========================

let g:status_lights.known_lights = [
      \ "filetype", "flags", "readmode", "tablemode", "symbols", "hlsearch"
      \ ]

" ConfigureLights(lights)
" Configure status lights for the current window
"
" Lights should be a list of known names of lights, or a string containing
" known names of lights separated by whitespace (see
" g:status_lights.known_lights for accepted values)
"
" Unknown names are ignored
"
" Return 1 if any names were unknown for testing purposes, otherwise 0
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
" Reset status lights for the current window to the global default
function! ResetLights()
  unlet! w:lights_on w:lights_renderers
endfunction

" LightOn(light)
" Enable known light name in status lights for currrent window
"
" Return 0 if light was enabled, otherwise 1
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
" Disable known light name in status lights for currrent window
"
" Return 0 if light was disabled, otherwise 1
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

" KnownLights(ArgLead, CmdLine, CursorPos)
" Provide completion list for known lights in command mode
function! KnownLights(ArgLead, CmdLine, CursorPos)
  return join(g:status_lights.known_lights, "\n")
endfunction

" ==========
" Statusline
" ==========

function! s:check_trailing_space(bufnr)
  " update per-buffer trailing space information
  if getbufvar(a:bufnr, "statusline_no_trailing", 0)
    call setbufvar(a:bufnr, "statusline_trailing_linenr", 0)
    return
  endif

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
  " update per-buffer git-branch information
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
  " update per-buffer tab character information
  if getbufvar(a:bufnr, "statusline_no_tabs", 0)
    call setbufvar(a:bufnr, "statusline_bad_tab", {})
    return
  endif

  let tab_matches = matchbufline(a:bufnr, '\t', 1, '$')
  if len(tab_matches) == 0
    call setbufvar(a:bufnr, "statusline_bad_tab", {})
  else
    call setbufvar(a:bufnr, "statusline_bad_tab", tab_matches[0])
  endif
  let &ro = &ro
endfunction

augroup statuslights_update_checks
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

function! g:statusline_fns.trailing() "-> String"
  " warning about trialing spaces
  let trailing_linenr = get(b:, "statusline_trailing_linenr", 0)
  if trailing_linenr
    return '!\s$ ' .. trailing_linenr
  else
    return ''
  endif
endfunction

function! g:statusline_fns.wordcount() "-> String"
  " display wordcount
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

function! g:statusline_fns.branch() "-> String"
  " display git-branch information
  let state_info = get(b:, "statusline_branch", {})
  if empty(state_info)
    return ''
  elseif state_info.dirty
    return printf("(%s!)", state_info.branch_name)
  else
    return printf("(%s)", state_info.branch_name)
  endif
endfunction

function! g:statusline_fns.bad_tabs() "-> String"
  " warning about usage of tab characters
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

function! g:statusline_fns.warnings() "-> String"
  " combine warnings
  let warnings = []
  call add(warnings, g:statusline_fns.trailing())
  call add(warnings, g:statusline_fns.bad_tabs())

  let result = join(filter(warnings, "len(v:val) > 0"))
  return s:pad_warning_highlight(result)
endfunction

" =========
" Functions
" =========

function! s:get_tabline_renderer(ft) "-> String"
  " return renderer name for given filetype
  if has_key(g:tabline_renderer, a:ft)
    return 'g:tabline_renderer.' .. a:ft
  else
    return 'g:tabline_defaults.renderer'
  endif
endfunction

function! s:highlight_if_modified(tabline) " -> String"
  " return highglight string for modified files
  return &modified ? '%#Italic#' .. a:tabline .. '%#TabLineFill#*' : a:tabline
endfunction

function! s:pad(text) "-> String"
  " return padded text
  return len(a:text) > 0 ? a:text .. ' ' : ''
endfunction

function! s:pad_warning_highlight(text) "-> String"
  " return highlight string for warnings
  return len(a:text) > 0 ? '%5* ' .. a:text .. ' %*' : ''
endfunction

function! s:tabline_strip_leading_zeroes(value) "-> String"
  " return string stripped of leading zeroes
  return a:value =~ "^0" ? a:value[1:] : a:value
endfunction

function! s:tabline_format_vimwiki_date(date) "-> String"
  " return formatted date for vimwiki tablines
  let year = a:date[0]
  let month_nr = s:tabline_strip_leading_zeroes(a:date[1])
  let month = vimwiki#vars#get_global('diary_months')->get(month_nr)
  let day = s:tabline_strip_leading_zeroes(a:date[2])
  return day .. ' ' .. month .. ' ' .. year
endfunction

