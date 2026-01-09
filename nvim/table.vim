" File: table.vim
" Author: chrysplusplus
" Description: Inspired by tables in vimwiki but adapted to my own specialist
" use, see below. Table rows (known internally as paragraph-rows) are
" separated; any lines that aren't separated are considered part of the same
" paragraph-row.
"
" | row 1, col 1 | row 1, col 2 | row 1, col 3 |
" |--------------|--------------|--------------|
" | row 2, col 1 | row 2, col 2 | row 2, col 3 |
" |              |              | extended     |
" |--------------|--------------|--------------|
" | row 3, col 1 | row 3, col 2 | row 3, col 3 |
"
" Lots of features to come to bring this implementation in-line with vimwiki's
"
" See https://github.com/vimwiki/vimwiki for original inspiration

" regex patterns used for tables
let s:table_pattern = '^|.*|$'
let s:table_sep_pattern = '^|\(-*|\)\+$'

" s:get_table_info(bufnr, linenr)
"   return table information around a line in a buffer
"   table information contains:
"     bufnr: the buffer containing the table
"     first_linenr: first line of the table
"     last_linenr: last line of the table
"     first_row_separator_linenr: line containing first row separator
"     cols: list of column widths, assuming table is correctly formatted
function! s:get_table_info(bufnr, linenr)
  let lines = getbufline(a:bufnr, 1, '$')
  let current_line = lines[a:linenr - 1]

  let LineIndexInTable = {index -> match(lines[index], s:table_pattern) == 0}

  if match(current_line, s:table_pattern) == -1
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

  let LineIndexIsRowSeparator = {index -> match(lines[index], s:table_sep_pattern) == 0}

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

" s:get_table_pararow_heights(table_info)
"   return list of heights of paragraph-rows in a table
function! s:get_table_pararow_heights(table_info)
  let lines = getbufline(a:table_info.bufnr, a:table_info.first_linenr, a:table_info.last_linenr)
  let row_boundaries = copy(lines)->map({idx,line -> match(line, s:table_sep_pattern) == 0 ? idx : -1})->filter({_,v -> v != -1})
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

" s:get_cursor_table_column(table_info, linenr, columnnr)
"   return column index of cursor in a table
function! s:get_cursor_table_column(table_info, linenr, columnnr)
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

" s:get_cursor_table_pararow(cursor)
"   return paragraph-row index of cursor in a table
function! s:get_cursor_table_pararow(table_info, linenr)
  if empty(a:table_info)
    return -1
  endif

  let table_lines = getbufline(a:table_info.bufnr, a:table_info.first_linenr, a:linenr)
  let index = 0
  let max_index = len(table_lines) - 1
  let separator_line_count = 0
  while index <= max_index
    let current_line = table_lines[index]
    if match(current_line, s:table_sep_pattern) == 0
      let separator_line_count = separator_line_count + 1
    endif

    let index = index + 1
  endwhile

  return separator_line_count
endfunction

" s:get_table_column_bounds(table_info, column_index)
"   return the start and end of the text boundary for a column of a table
"   return [-1,-1] if column has no text boundary
function! s:get_table_column_bounds(table_info, column_index)
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
function! s:get_table_row_separators(lines, first_linenr)
  let separator_linenrs = []
  let index = 0
  let max_index = len(a:lines) - 1
  while index <= max_index
    if match(a:lines[index], s:table_sep_pattern) == 0
      call add(separator_linenrs, a:first_linenr + index)
    endif
    let index = index + 1
  endwhile

  return separator_linenrs
endfunction

" s:get_table_pararow_info(table_info, para_index)
"   return information for a paragraph-cell text boundary of a table
"   information Dictionary contains:
"     before_sep_linenr: line number for the previous row separator, or -1
"     after_sep_linenr:  line number for the next row separator, or -1
"     text_start_linenr: line number for the text start, or -1
"     text_end_linenr:   line number for the text end, or -1
"   return empty Dictionary if para_index is out of bounds
function! s:get_table_pararow_info(table_info, para_index)
  let table_lines = getbufline(a:table_info.bufnr, a:table_info.first_linenr, a:table_info.last_linenr)
  let separator_linenrs = s:get_table_row_separators(table_lines, a:table_info.first_linenr)

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

" s:get_paracell_selection(table_info, row, col)
"   return [start_linenr, start_colnr, end_linenr, end_colnr]
"   return empty list for invalid selections
"   not for exported use
function! s:get_paracell_selection(table_info, row, col)
  let row_heights = s:get_table_pararow_heights(a:table_info)
  if assert_true(a:row >= 0 && a:row < len(row_heights), "row out-of-bounds")
    return []
  elseif assert_true(a:col >= 0 && a:col < len(a:table_info.cols), "col out-of-bounds")
    return []
  endif

  let ExtractParaInfoStartEnd = {info -> [info.text_start_linenr, info.text_end_linenr]}

  let [colnr_first, colnr_last] = s:get_table_column_bounds(a:table_info, a:col)
  if colnr_first == -1
    return []
  endif

  let [linenr_first, linenr_last] = ExtractParaInfoStartEnd(s:get_table_pararow_info(a:table_info, a:row))
  if linenr_first == -1
    return []
  endif

  return [linenr_first, colnr_first, linenr_last, colnr_last]
endfunction

" s:use_selection(selection)
"   enter visual block mode to selection
"   selection should be a list of four numbers
function! s:use_selection(selection) abort
  let [linenr_first, colnr_first, linenr_last, colnr_last] = a:selection
  call setpos('.', [0, linenr_last, colnr_last, 0])
  execute "normal! \<C-V>"
  call setpos('.', [0, linenr_first, colnr_first, 0])
endfunction

" SelectCursorParaCell()
"   select the paragraph-cell in the table containing the cursor
function! SelectCursorParaCell()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = s:get_table_info(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let col = s:get_cursor_table_column(table_info, linenr, columnnr)
  let row = s:get_cursor_table_pararow(table_info, linenr)
  let selection = s:get_paracell_selection(table_info, row, col)
  if !empty(selection)
    call s:use_selection(selection)
  endif
endfunction

" SelectTableColumn()
"   select the table column containing the cursor, including the following
"   column separator
function! SelectTableColumn()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = s:get_table_info(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let column_index = s:get_cursor_table_column(table_info, linenr, columnnr)
  let [colnr_first, colnr_last] = s:get_table_column_bounds(table_info, column_index)
  if colnr_first == -1
    return
  endif

  call s:use_selection([table_info.first_linenr, colnr_first, table_info.last_linenr, colnr_last])
endfunction

" SelectTableParaRow()
"   select the paragraph-row of the table containing the cursor
function! SelectTableParaRow()
  let [_, linenr, columnnr, _] = getpos('.')
  let table_info = s:get_table_info(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let row = s:get_cursor_table_pararow(table_info, linenr)
  let row_info = s:get_table_pararow_info(table_info, row)
  if row_info.text_start_linenr == -1
    return
  endif

  let linenr_first = row_info.text_start_linenr
  let linenr_last = row_info.text_end_linenr
  let table_width = len(getbufoneline(table_info.bufnr, linenr_first))
  call s:use_selection([linenr_first, 1, linenr_last, table_width])
endfunction

" s:list_slice(l, first, last)
"   TODO change to use internal vim function
"   return a copy of l containg the elements between first and last
function! s:list_slice(l, first, last)
  let result = []
  for index in range(a:first, a:last)
    call add(result, a:l[index])
  endfor
  return result
endfunction

" s:transpose(list_of_lists, sublist_len, default)
"   return transposed list of lists, sublist_len is a number that specifies
"   the maximum length of a sublist, default is the default value if index is
"   not found
function! s:transpose(list_of_lists, sublist_len, default)
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

" s:wrap_text(lines, width)
"   return list of lines of paragraph lines wrapped to width
"   any blank lines are interpreted as paragraph breaks, and so persist after
"   wrapping
function! s:wrap_text(lines, width)
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

" s:make_table_row_separators_and_format_string(cols)
"   return row_separator and format string
function! s:make_table_row_separators_and_format_string(cols)
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
  let table_info = s:get_table_info(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let lines = getbufline(table_info.bufnr, table_info.first_linenr, table_info.last_linenr)

  let row_boundaries = []
  call add(row_boundaries, table_info.first_linenr - 1)
  call extend(row_boundaries, s:get_table_row_separators(lines, table_info.first_linenr))
  call add(row_boundaries, table_info.last_linenr + 1)

  let row_contents = []
  for boundary_index in range(len(row_boundaries) - 1)
    let first_index = row_boundaries[boundary_index] - table_info.first_linenr + 1
    let last_index = row_boundaries[boundary_index + 1] - table_info.first_linenr - 1
    call add(row_contents, s:list_slice(lines, first_index, last_index))
  endfor

  for row in row_contents
    call map(row, {_,line -> split(line, "|")})
    for split_line in row
      call map(split_line, {_,column_text -> trim(column_text)})
    endfor
  endfor

  call map(row_contents, {_,row -> s:transpose(row, len(table_info.cols), '')})

  let line_counts = []
  for row in row_contents
    call map(row, {column_index,column -> s:wrap_text(column, table_info.cols[column_index])})
    call add(line_counts, max(map(copy(row), {_,column -> len(column)})))
  endfor

  call map(row_contents, {row_index,row -> s:transpose(row, line_counts[row_index], '')})

  let [row_separator, row_format_string] = s:make_table_row_separators_and_format_string(table_info.cols)
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
  let table_info = s:get_table_info(bufnr(), linenr)
  if empty(table_info)
    return
  endif

  let row = s:get_cursor_table_pararow(table_info, linenr)
  let col = s:get_cursor_table_column(table_info, linenr, columnnr)
  let selection = s:get_paracell_selection(table_info, row, col)
  if empty(selection)
    return
  endif

  let [linenr, colnr, _, _] = selection
  call setpos('.', [0, linenr, colnr, 0])
  startreplace
endfunction

" IncrementTableRowColumn(table_info, row, column)
"   TODO: development
"   return next row,column index pair in the table
"   return [-1,-1] if there is no next paragraph cell
function! IncrementTableRowColumn(table_info, row, column)
  if assert_true(a:row >= 0, "row out-of-bounds")
    return [-1, -1]
  elseif assert_true(a:column >= 0, "col out-of-bounds")
    return [-1, -1]
  endif

  let row_heights = s:get_table_pararow_heights(a:table_info)

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

