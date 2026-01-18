" =========
" Functions
" =========

" regex patterns used for tables
let g:table_pattern = '^|.*|$'
let g:table_sep_pattern = '^|\(-*|\)\+$'

" GetTableInfo(bufnr, linenr)
"   return table information around a line in a buffer
"   table information contains:
"     bufnr: the buffer containing the table
"     first_linenr: first line of the table
"     last_linenr: last line of the table
"     first_row_separator_linenr: line containing first row separator
"     cols: list of column widths, assuming table is correctly formatted
function! GetTableInfo(bufnr, linenr)
  let lines = getbufline(a:bufnr, 1, '$')
  let current_line = lines[a:linenr - 1]

  let LineIndexInTable = {index -> match(lines[index], g:table_pattern) == 0}

  if match(current_line, g:table_pattern) == -1
    return {}
  endif

  let first_index = -1
  for index in range(a:linenr - 1, 1, -1) " adjust linenr -> index
    if !LineIndexInTable(index)
      let first_index = index + 1
      break
    endif
  endfor

  if first_index == -1
    let first_index = 0
  endif

  let last_index = -1
  for index in range(a:linenr - 1, len(lines) - 1)
    if !LineIndexInTable(index)
      let last_index = index - 1
      break
    endif
  endfor

  if last_index == -1
    let last_index = len(lines) - 1
  endif

  let LineIndexIsRowSeparator = {index -> match(lines[index], g:table_sep_pattern) == 0}

  let first_row_separator_index = -1
  for index in range(first_index, last_index)
    if LineIndexIsRowSeparator(index)
      let first_row_separator_index = index
      break
    endif
  endfor

  if first_row_separator_index == -1
    return {} " table MUST have at least one row separator
  endif

  let table_cols = map(split(lines[first_row_separator_index], '|'), {_,txt -> len(txt) - 2})

  let table_info = {}
  let table_info.bufnr = a:bufnr
  let table_info.first_linenr = first_index + 1
  let table_info.last_linenr = last_index + 1
  let table_info.first_row_separator_linenr = first_row_separator_index + 1
  let table_info.cols = table_cols
  return table_info
endfunction

" GetTableParaRowHeights(table_info)
"   return list of heights of paragraph-rows in a table
function! GetTableParaRowHeights(table_info)
  let lines = getbufline(a:table_info.bufnr, a:table_info.first_linenr, a:table_info.last_linenr)
  let row_boundaries = copy(lines)->map({idx,line -> match(line, g:table_sep_pattern) == 0 ? idx : -1})->filter({_,v -> v != -1})
  call insert(row_boundaries, -1, 0)
  call add(row_boundaries, len(lines))

  let heights = []
  for index in range(0, len(row_boundaries) - 2)
    let boundary_start = row_boundaries[index]
    let boundary_end = row_boundaries[index + 1]
    let height = boundary_end - boundary_start - 1
    call add(heights, height != -1 ? height: 0)
  endfor

  return heights
endfunction

" GetCursorTableColumn(table_info, linenr, columnnr)
"   return column index of cursor in a table
function! GetCursorTableColumn(table_info, linenr, columnnr)
  if empty(a:table_info)
    return -1
  endif

  let column_index = 0
  let max_column_index = len(a:table_info.cols) - 1
  let separator_offset = 1
  while column_index <= max_column_index
    let column_width = a:table_info.cols[column_index]
    let separator_offset = separator_offset + column_width + 3
    if a:columnnr < separator_offset
      return column_index
    endif

    let column_index = column_index + 1
  endwhile

  return max_column_index
endfunction

" GetCursorTableParaRow(cursor)
"   return paragraph-row index of cursor in a table
function! GetCursorTableParaRow(table_info, linenr)
  if empty(a:table_info)
    return -1
  endif

  let table_lines = getbufline(a:table_info.bufnr, a:table_info.first_linenr, a:linenr)
  let index = 0
  let max_index = len(table_lines) - 1
  let separator_line_count = 0
  while index <= max_index
    let current_line = table_lines[index]
    if match(current_line, g:table_sep_pattern) == 0
      let separator_line_count = separator_line_count + 1
    endif

    let index = index + 1
  endwhile

  return separator_line_count
endfunction

" GetTableColumnBounds(table_info, column_index)
"   return the start and end of the text boundary for a column of a table
"   return [-1,-1] if column has no text boundary
function! GetTableColumnBounds(table_info, column_index)
  if assert_true(a:column_index < len(a:table_info.cols), 'column index out-of-bounds')
    return [-1,-1]
  endif

  let separator_offset = 1
  let current_col_index = 0
  while current_col_index < a:column_index
    let separator_offset = separator_offset + a:table_info.cols[current_col_index] + 3
    let current_col_index = current_col_index + 1
  endwhile

  let colnr_first = separator_offset + 2
  let colnr_last = separator_offset + a:table_info.cols[a:column_index] + 1

  " if column width is negative, which can happen when two column separators
  " are adjacent, the calculations break; but we can detect this by checking
  " if the last column is less than the first, in which case we'll early
  " return an invalid bound
  if colnr_last <= colnr_first
    return [-1, -1]
  endif

  return [colnr_first, colnr_last]
endfunction

" not for exported use
" TODO maybe remove and replace usage with row heights
" so the same algorithm can be used for columns and rows
function! GetTableRowSeparators(lines, first_linenr)
  let separator_linenrs = []
  let index = 0
  let max_index = len(a:lines) - 1
  while index <= max_index
    if match(a:lines[index], g:table_sep_pattern) == 0
      call add(separator_linenrs, a:first_linenr + index)
    endif
    let index = index + 1
  endwhile

  return separator_linenrs
endfunction

" GetTableParaRowInfo(table_info, para_index)
"   return information for a paragraph-cell text boundary of a table
"   information Dictionary contains:
"     before_sep_linenr: line number for the previous row separator, or -1
"     after_sep_linenr:  line number for the next row separator, or -1
"     text_start_linenr: line number for the text start, or -1
"     text_end_linenr:   line number for the text end, or -1
"   return empty Dictionary if para_index is out of bounds
function! GetTableParaRowInfo(table_info, para_index)
  let table_lines = getbufline(a:table_info.bufnr, a:table_info.first_linenr, a:table_info.last_linenr)
  let separator_linenrs = GetTableRowSeparators(table_lines, a:table_info.first_linenr)

  if a:para_index < 0
    return {}
  elseif a:para_index > len(separator_linenrs)
    return {}
  endif

  if len(separator_linenrs) == 0
    return {}
  endif

  if a:para_index == 0 && separator_linenrs[0] == a:table_info.first_linenr
    let info = {}
    let info.before_sep_linenr = -1
    let info.after_sep_linenr = separator_linenrs[0]
    let info.text_start_linenr = -1
    let info.text_end_linenr = -1
    return info
  endif

  if a:para_index == 0
    let info = {}
    let info.before_sep_linenr = -1
    let info.after_sep_linenr = separator_linenrs[0]
    let info.text_start_linenr = a:table_info.first_linenr
    let info.text_end_linenr = separator_linenrs[0] - 1
    return info
  endif

  let last_sep_linenr = separator_linenrs[len(separator_linenrs) - 1]
  if a:para_index == len(separator_linenrs) && last_sep_linenr == a:table_info.last_linenr
    let info = {}
    let info.before_sep_linenr = last_sep_linenr
    let info.after_sep_linenr = -1
    let info.text_start_linenr = -1
    let info.text_end_linenr = -1
    return info
  endif

  if a:para_index == len(separator_linenrs)
    let info = {}
    let info.before_sep_linenr = last_sep_linenr
    let info.after_sep_linenr = -1
    let info.text_start_linenr = last_sep_linenr + 1
    let info.text_end_linenr = a:table_info.last_linenr
    return info
  endif

  let before_sep_linenr = separator_linenrs[a:para_index - 1]
  let after_sep_linenr = separator_linenrs[a:para_index]
  if before_sep_linenr + 1 == after_sep_linenr
    let info = {}
    let info.before_sep_linenr = before_sep_linenr
    let info.after_sep_linenr = after_sep_linenr
    let info.text_start_linenr = -1
    let info.text_end_linenr = -1
    return info
  endif

  let info = {}
  let info.before_sep_linenr = before_sep_linenr
  let info.after_sep_linenr = after_sep_linenr
  let info.text_start_linenr = before_sep_linenr + 1
  let info.text_end_linenr = after_sep_linenr - 1
  return info
endfunction

" GetParaCellSelection(table_info, row, col)
"   return [start_linenr, start_colnr, end_linenr, end_colnr]
"   return empty list for invalid selections
"   not for exported use
function! GetParaCellSelection(table_info, row, col)
  let row_heights = GetTableParaRowHeights(a:table_info)
  if assert_true(a:row >= 0 && a:row < len(row_heights), "row out-of-bounds")
    return []
  elseif assert_true(a:col >= 0 && a:col < len(a:table_info.cols), "col out-of-bounds")
    return []
  endif

  let ExtractParaInfoStartEnd = {info -> [info.text_start_linenr, info.text_end_linenr]}

  let [colnr_first, colnr_last] = GetTableColumnBounds(a:table_info, a:col)
  if colnr_first == -1
    return []
  endif

  let [linenr_first, linenr_last] = ExtractParaInfoStartEnd(GetTableParaRowInfo(a:table_info, a:row))
  if linenr_first == -1
    return []
  endif

  return [linenr_first, colnr_first, linenr_last, colnr_last]
endfunction

" UseSelection(selection)
"   enter visual block mode to selection
"   selection should be a list of four numbers
function! UseSelection(selection) abort
  let [linenr_first, colnr_first, linenr_last, colnr_last] = a:selection
  call setpos('.', [0, linenr_last, colnr_last, 0])
  execute "normal! \<C-V>"
  call setpos('.', [0, linenr_first, colnr_first, 0])
endfunction

" SelectCursorParaCell()
"   select the paragraph-cell in the table containing the cursor
function! SelectCursorParaCell()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = GetTableInfo(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let col = GetCursorTableColumn(table_info, linenr, columnnr)
  let row = GetCursorTableParaRow(table_info, linenr)
  let selection = GetParaCellSelection(table_info, row, col)
  if !empty(selection)
    call UseSelection(selection)
  endif
endfunction

" SelectTableColumn()
"   select the table column containing the cursor, including the following
"   column separator
function! SelectTableColumn()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = GetTableInfo(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let column_index = GetCursorTableColumn(table_info, linenr, columnnr)
  let [colnr_first, colnr_last] = GetTableColumnBounds(table_info, column_index)
  if colnr_first == -1
    return
  endif

  call UseSelection([table_info.first_linenr, colnr_first, table_info.last_linenr, colnr_last])
endfunction

" SelectTableParaRow()
"   select the paragraph-row of the table containing the cursor
function! SelectTableParaRow()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = GetTableInfo(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let row = GetCursorTableParaRow(table_info, linenr)
  let row_info = GetTableParaRowInfo(table_info, row)
  if row_info.text_start_linenr == -1
    return
  endif

  let linenr_first = row_info.text_start_linenr
  let linenr_last = row_info.text_end_linenr
  let table_width = len(getbufoneline(table_info.bufnr, linenr_first))
  call UseSelection([linenr_first, 1, linenr_last, table_width])
endfunction

" ListSlice(l, first, last)
"   return a copy of l containg the elements between first and last
function! ListSlice(l, first, last)
  let result = []
  for index in range(a:first, a:last)
    call add(result, a:l[index])
  endfor
  return result
endfunction

" TransposeAndJoin(list_of_lists, sublist_len)
"   return transposed list of lists, sublist_len is a number that specifies
"   the maximum length of a sublist, default is the default value if index is
"   not found
function! Transpose(list_of_lists, sublist_len, default)
  if empty(a:list_of_lists)
    return a:list_of_lists
  endif

  let transposed = []
  for index in range(a:sublist_len)
    let new_elem = []
    for sublist in a:list_of_lists
      call add(new_elem, get(sublist, index, a:default))
    endfor
    call add(transposed, new_elem)
  endfor
  return transposed
endfunction

" WrapText(lines, width)
"   return list of lines of paragraph lines wrapped to width
"   any blank lines are interpreted as paragraph breaks, and so persist after
"   wrapping
function! WrapText(lines, width)
  let paragraphs = []
  let current_paragraph = ''
  for line in a:lines
    if empty(line)
      call add(paragraphs, current_paragraph)
      call add(paragraphs, '') " use empty string to represent paragraph break
      let current_paragraph = ''
      continue
    endif

    if empty(current_paragraph)
      let current_paragraph = line
    else
      let current_paragraph = join([current_paragraph, line])
    endif
  endfor

  if !empty(current_paragraph)
    call add(paragraphs, current_paragraph)
  endif

  call map(paragraphs, {_,paragraph -> empty(paragraph) ? paragraph : split(paragraph)})
  call flatten(paragraphs)

  let lines = []
  let current_line = ''
  let is_new_paragraph = 0
  for word in paragraphs
    if empty(word) && empty(current_line)
      let is_new_paragraph = 1
      continue
    elseif empty(word)
      call add(lines, current_line)
      let current_line = ''
      let is_new_paragraph = 1
      continue
    endif

    if is_new_paragraph
      call add(lines, '')
      let is_new_paragraph = 0
    endif

    if len(word) + len(current_line) + 1 > a:width
      call add(lines, current_line)
      let current_line = word
    elseif empty(current_line)
      let current_line = word
    else
      let current_line = join([current_line, word])
    endif
  endfor

  if !empty(current_line)
    call add(lines, current_line)
  endif

  return lines
endfunction

" MakeTableRowSeparatorAndFormatString(cols)
"   return row_separator and format string
function! MakeTableRowSeparatorAndFormatString(cols)
  let row_separator = '|'
  let row_format_string = '|'
  for column_width in a:cols
    let row_separator = row_separator .. repeat('-', column_width + 2) .. '|'
    let row_format_string = row_format_string .. ' %-' .. column_width .. 'S |'
  endfor
  return [row_separator, row_format_string]
endfunction

" FormatTable()
"   format the current table, wrapping paragraph-cells based off the width of
"   the first row separator
function! FormatTable()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = GetTableInfo(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let lines = getbufline(table_info.bufnr, table_info.first_linenr, table_info.last_linenr)

  let row_boundaries = []
  call add(row_boundaries, table_info.first_linenr - 1)
  call extend(row_boundaries, GetTableRowSeparators(lines, table_info.first_linenr))
  call add(row_boundaries, table_info.last_linenr + 1)

  let row_contents = []
  for boundary_index in range(len(row_boundaries) - 1)
    let first_index = row_boundaries[boundary_index] - table_info.first_linenr + 1
    let last_index = row_boundaries[boundary_index + 1] - table_info.first_linenr - 1
    call add(row_contents, ListSlice(lines, first_index, last_index))
  endfor

  for row in row_contents
    call map(row, {_,line -> split(line, "|")})
    for split_line in row
      call map(split_line, {_,column_text -> trim(column_text)})
    endfor
  endfor

  call map(row_contents, {_,row -> Transpose(row, len(table_info.cols), '')})

  let line_counts = []
  for row in row_contents
    call map(row, {column_index,column -> WrapText(column, table_info.cols[column_index])})
    call add(line_counts, max(map(copy(row), {_,column -> len(column)})))
  endfor

  call map(row_contents, {row_index,row -> Transpose(row, line_counts[row_index], '')})

  let [row_separator, row_format_string] = MakeTableRowSeparatorAndFormatString(table_info.cols)
  let Printf = function("printf", [row_format_string])
  for row in row_contents
    if !empty(row)
      call map(row, {_,line -> call(Printf, line)})
    endif
  endfor

  let lines = []
  let last_index = len(row_contents) - 1
  for index in range(len(row_contents))
    let row = row_contents[index]
    if !empty(row)
      call extend(lines, row)
    endif
    if index != last_index
      call add(lines, row_separator)
    endif
  endfor

  call deletebufline(table_info.bufnr, table_info.first_linenr, table_info.last_linenr)
  call appendbufline(table_info.bufnr, table_info.first_linenr - 1, lines)
endfunction

" StartTableInsert()
"   enter table insert mode
function! StartTableInsert()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = GetTableInfo(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let row = GetCursorTableParaRow(table_info, linenr)
  let col = GetCursorTableColumn(table_info, linenr, columnnr)
  let selection = GetParaCellSelection(table_info, row, col)
  if empty(selection)
    return
  endif

  let [linenr, colnr, _, _] = selection
  call setpos('.', [0, linenr, colnr, 0])
  startreplace
endfunction

" IncrementTableRowColumn(table_info, row, column)
"   return next row,column index pair in the table
"   return [-1,-1] if there is no next paragraph cell
function! IncrementTableRowColumn(table_info, row, column)
  if assert_true(a:row >= 0, "row out-of-bounds")
    return [-1, -1]
  elseif assert_true(a:column >= 0, "col out-of-bounds")
    return [-1, -1]
  endif

  let row_heights = GetTableParaRowHeights(a:table_info)

  let cell_areas = []
  for height in row_heights
    let areas = copy(a:table_info.cols)->map({_,width -> width * height})
    call extend(cell_areas, areas)
  endfor

  let column_count = len(a:table_info.cols)
  let next_cell_index = a:row * column_count + a:column + 1
  let max_cell_index = len(row_heights) * column_count
  while next_cell_index < max_cell_index
    if cell_areas[next_cell_index] == 0
      let next_cell_index = next_cell_index + 1
      continue
    endif

    return [next_cell_index / column_count, next_cell_index % column_count]
  endwhile

  return [-1, -1]
endfunction

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

" ========
" Commands
" ========

" SelectCursorParaCell
"   select the paragraph-cell in the table containing the cursor
command! SelectCursorParaCell call SelectCursorParaCell()

" SelectTableColumn
"   select the paragraph-cell in the table containing the cursor
command! SelectTableColumn call SelectTableColumn()

" SelectTableParaRow
"   select the paragraph-cell in the table containing the cursor
command! SelectTableParaRow call SelectTableParaRow()

" StartTableInsert
"   start replace mode at beginning of paragraph-cell
command! StartTableInsert call StartTableInsert()

" FormatTable
"   format table to width of current line
command! FormatTable call FormatTable()

" CopyCWDToClipboard
"   copy current working directory to clipboard
command! CopyCWDToClipboard call setreg("*", getcwd())

" ToggleQuickfixList
"   toggle visibility of quickfix list window
command! ToggleQuickfixList call s:toggle_quickfix_list()

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

" TODO: move into vimwiki autocmd group
" Vcd
"   change directory to wiki root
command! Vcd call ChangeDirectoryToWikiRoot(bufnr())

" ClipHTMLToMarkdown
" ClipMarkdownToHTML
"   commands for converting clipboard buffer to/from markdown
"   (for now this is linux only)
command! ClipHTMLToMarkdown !~/scripts/clip_html_to_markdown.sh
command! ClipMarkdownToHTML !~/scripts/clip_markdown_to_html.sh

" UndoLastClose
"   re-open last closed window in vertical
command! UndoLastClose call UndoLastClose()

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

" Q to format paragraph (similar to vim)
nnoremap Q <CMD>FormatParagraph<CR>

" J to join lines without jumping (sets last mark)
nnoremap J m'J`'

" Bracket swapping
nnoremap <silent> <Leader>r( m'%r)`'r(
nnoremap <silent> <Leader>r) m'%r)`'r(
nnoremap <silent> <Leader>r[ m'%r]`'r[
nnoremap <silent> <Leader>r] m'%r]`'r[
nnoremap <silent> <Leader>r{ m'%r}`'r{
nnoremap <silent> <Leader>r} m'%r}`'r{

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

" Alt + - to 'zoom' current window (Ctr-W _)
nnoremap <M--> <C-W>_<C-W><bar>

" Alt + = to 'equalise' windows
nnoremap <M-=> <C-W>=

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
" \pp to close quickfix list
nnoremap <silent> <Leader>pp <CMD>pclose<cr>
" \pl to close locations list
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

" \tt to format table
nnoremap <silent> <Leader>tt <CMD>FormatTable<CR>

" \ti to start table insert
nnoremap <silent> <Leader>ti <CMD>StartTableInsert<CR>

" \tc to select current paragraph-cell
nnoremap <silent> <Leader>tc <CMD>SelectCursorParaCell<CR>
vnoremap <silent> <Leader>tc :<C-U>SelectCursorParaCell<CR>
onoremap <silent> <Leader>tc :<C-U>SelectCursorParaCell<CR>

" \tC to select current column
nnoremap <silent> <Leader>tC <CMD>SelectTableColumn<CR>
vnoremap <silent> <Leader>tC :<C-U>SelectTableColumn<CR>
onoremap <silent> <Leader>tC :<C-U>SelectTableColumn<CR>

" \tR to select current paragraph-row
nnoremap <silent> <Leader>tR <CMD>SelectTableParaRow<CR>
vnoremap <silent> <Leader>tR :<C-U>SelectTableParaRow<CR>
onoremap <silent> <Leader>tR :<C-U>SelectTableParaRow<CR>

" filetype mappings
augroup chrys_map
  autocmd!
  autocmd FileType vimwiki call s:config_vimwiki_mappings()
  autocmd FileType cpp call s:config_cpp_mappings()
  " TODO: move?
  autocmd FileType python inoremap <silent><expr> <C-J> coc#refresh()
  autocmd FileType netrw call s:config_netrw_mappings()
augroup END

" =====================
" General Configuration
" =====================

" filetype specific configuration
"   TODO: split?
"   disable line numbers in vimwiki
"   set textwidth and wrapping settings for markdown and vimwiki
"   disable suggestions for vimwiki
"   fix key mapping conflict with vimwiki and pear-tree
"   add command for link tag hierarchy
"   set conceallevel for markdown
augroup chrys_filetype
  autocmd!
  autocmd FileType vimwiki setlocal nonumber norelativenumber textwidth=80
  autocmd FileType markdown setlocal nonumber norelativenumber textwidth=80 conceallevel=2
  autocmd FileType vimwiki let b:coc_suggest_disable = 1
  autocmd FileType vimwiki let b:pear_tree_map_special_keys = 0
  autocmd FileType markdown let b:coc_suggest_disable = 1
  autocmd FileType vimwiki command! -buffer -nargs=1 -complete=custom,vimwiki#tags#complete_tags
        \ ChryswikiGenerateTagLinks call call("vimwiki#tags#generate_tags", extend([1], vimwiki#tags#get_tags()->filter('v:val =~ "'..<f-args>..'"')))
augroup END

" set configuration for :make
call ResetMakeBuildDir()

" open quickfix window if :make yields errors
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

autocmd User AirlineAfterInit call ChrysAirlineInit()

" vimwiki customisation
let g:vimwiki_global_ext = 0
let g:vimwiki_table_auto_fmt = 0

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

