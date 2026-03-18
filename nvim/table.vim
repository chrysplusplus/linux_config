" File: table.vim
" Author: chrysplusplus
" Description: Create tables with wrapping cell text
"
" Inspired by tables in vimwiki and other projects, but adapted to my own
" needs. Rather then every line being a row of the table, rows are separated
" clearly and columns wrap text according to their widths — just like the wrap
" text feature in popular spreadsheet programs. (This is not a spreadsheet
" package.)
"
" Example table:
"
" |--------------|--------------|--------------------------------------|
" | row 1, col 1 | row 1, col 2 | row 1, col 3                         |
" |--------------|--------------|--------------------------------------|
" | row 2, col 1 | row 2, col 2 | row 2, col 3                         |
" |              |              |                                      |
" |              |              | second paragraph                     |
" |--------------|--------------|--------------------------------------|
" | row 3, col 1 | row 3, col 2 | row 3, col 3                         |
" |--------------|--------------|--------------------------------------|
"
" Lots of features to come to bring this implementation in-line with vimwiki's
"
" See https://github.com/vimwiki/vimwiki for original inspiration
"
" See https://github.com/chrysplusplus/linux_config for an example
" configuration using this script.
"
" Usage:
"
" To use this script, source it from your initrc; no need for a plugin
" manager.
"
" To create a table, open a file and type the following line (without the
" leading comment mark and indentation, of course):
"
" |10|10|10|
"
" This is called a make string. Note that there is no whitespace at the end of
" the line. When you hit Enter (or if you exit insert mode on the same line),
" the script will replace this line with a table that looks like this:
"
" |------------|------------|------------|
" | #          |            |            |
" |------------|------------|------------|
"
" Where '#' represents the cursor position. When you type a make string and
" hit Enter, the script positions your cursor so that you can immediately
" start typing in the table. Unlike other table scripts, if you hit Enter
" while typing in a cell, it won't move your cursor down to the next row, but
" rather will split the line at the cursor and move the rest of the line down
" to the next line, expanding the table as necessary. For example, if I have
" the following table ('#' once again representing the cursor position):
"
" |------------|------------|------------|
" | one line   | two#lines  |            |
" |------------|------------|------------|
"
" When I hit Enter, it results in the following:
"
" |------------|------------|------------|
" | one line   | two        |            |
" |            |#lines      |            |
" |------------|------------|------------|
"
" If we exit insert mode at this point, the table will look like it did before
" we hit Enter. This is because the formatting wraps the text of each
" paragraph in the cell. If we hit Enter again, we get:
"
" |------------|------------|------------|
" | one line   | two        |            |
" |            |            |            |
" |            |#lines      |            |
" |------------|------------|------------|
"
" Now that "two" and "lines" are separated by a blank line (i.e. there is
" nothing between the pipes '|' others than spaces), they are considered
" separated paragraphs. So, when we format the table (either by leaving insert
" mode, or if auto formatting is disabled by calling the FormatTable command),
" the blank line is kept.
"
" We can get back to the initial table by backspacing twice and then typing a
" space. Try it for yourself. When the cursor is at the beginning of the text
" area for a table column and we hit the backspace, the script joins the
" current line with the previous line in the table column, just like you'd
" expect when typing text outside of the table.
"
" This behaviour seems to be unique to this script. Most scripts implementing
" markdown-like tables in vim would see this as a table with three columns, no
" header, and three rows; whereas this script sees a table with three columns
" and one row.
"
" Going on from here, you can insert rows and columns using the InsertRow and
" InsertColumn commands respectively. The ResizeTableColumn command can be
" used to change the width of columns in the table, but you can also edit the
" first of the table to achieve the same effect.
"
" Happy writing!
"
" This behaviour of this script can be customised with the following
" variables:
"
" Customisation Variable: g:table_auto_format, b:table_auto_format
"
" If non-zero, the script auto-formats tables when leaving insert mode. Can be
" also enabled for individual buffers by setting b:table_auto_format
"
" Defaults to 1
"
" Customisation Variable: g:table_inhibit_leader_keys
"
" If non-zero, the script will not map leader keys for table operations, which
" may be desired if the mappings would conflict, or the user wants to use
" custom mappings. See the Mappings section for which plug keys are available.
" These can be mapped as follows:
"
" :nmap tti <Plug>(TableCellInsert)
"
" This would map 'tti' to enter insert mode at the end of text in the table
" cell under the cursor.
"
" Defaults to 0
"
" Customisation Variable: g:table_inhibit_text_objects
"
" If non-zero, the script will not map keys for table text objects, which may
" be desired if the mappings would conflict, or the user wants to use custom
" mappings. See the Mappings section for which text objects are available. It
" is recommended to create mappings for all three modes, for example:
"
" :nnoremap ttic <Plug>(TableSelectCell)
" :vnoremap ic <Plug>(VTableSelectCell)
" :onoremap ic <Plug>(OTableSelectCell)
"
" This would map 'ttic' in normal mode to select the table cell under the
" cursor in visual-block mode, enter this selection in visual mode, and use
" the selection when an operator is pending (for example, 'dic' would be
" mapped to block delete the table cell.)
"
" Please note the prefix on each plug key. Normal mode mappings don't use a
" prefix, but visual mode and operator mode mappings use V and O respectively.
" It would be incorrect to map a plug key in the wrong mode, as this could
" have unintended side-effects and unknown behaviour. Please take care when
" mapping keys in vim.
"
" Defaults to 0
"
" Customisation Variable: g:table_inhibit_navigation_keys
"
" If non-zero, the script will not map keys for navigating the table, which
" are the H, J, K and L keys, analogous to typical vim movement, just with the
" shift key held! Inhibiting this behaviour may be desired if the mappings
" would conflict, which they almost certainly do -- which is why this script
" was reimplemented to be modal -- or the user prefers custom mappings. See
" the Mappings section for the available plug-mappings. For example:
"
" :nnoremap <Leader>th <Plug>(TableLeftCell)
" :nnoremap <Leader>tl <Plug>(TableRightCell)
" :nnoremap <Leader>tj <Plug>(TableDownCell)
" :nnoremap <Leader>tk <Plug>(TableUpCell)
"
" These commands would map the movement keys to have <Leader>t as a prefix,
" which was the mapping that this script used to use.
"
" Defaults to 0
"
" Customisation Variable: g:table_jump_to_end
"
" If non-zero, the jump commands for moving between cells in a table will go
" to the end of the text, rather than the beginning, which is the default
" behaviour.
"
" Originally, the jump commands were implemented to move to the end of the
" cell text, but I changed this due to my own personal preferences, and since
" I can't really justify removing the old cold, I added this variable to
" switch back to the old behaviour.
"
" My main reason for this change in behaviour was because I use these commands
" to read through my tables, and it was pretty frustrating having to
" left-brace my way to the beginning. Nore that <Leader>ti exists to enter
" insert mode at the end of the cell text.
"
" Defaults to 0
"
" Customisation Variable: b:table_plain_before, b:table_plain_after
"
" When set for a particular buffer, these strings are used to wrap the
" plaintext representation of a table when the TableToPlain and PlainToTable
" commands are used.
"
" A particularly useful example might be for markdown, where it is helpful to
" wrap a plaintext table in a code block, so use "```\n" and "\n```" for
" before and after respectively.
"
" Note: these lines are checked by PlainToTable and removed from the buffer if
" found. The motivation here is for these commands to act as the reverse of
" each other, so there should be no change to the buffer if you TableToPlain
" and then PlainToTable.
"
" Defaults to ""
"
" TODO: Document autocmd hooks

" ================
" Script Constants
" ================

let s:table_pattern = '^|.*|$'
let s:table_sep_pattern = '^|\(-*|\)\+$'
let s:table_make_pattern = '^|\(\d\+|\)\+$'

let s:min_column_width = 5

" ===================
" Vim Interaction API
" ===================

function! s:au_insert_enter()
  " callback for InsertEnter autocommand
  if ! get(b:, "table_auto_format", get(g:, "table_auto_format", 1))
    return
  elseif get(b:, "table_working", 0)
    return
  endif

  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if s:matches(line, s:table_make_pattern)
    return
  elseif s:matches(line, s:table_sep_pattern)
    return
  elseif ! s:matches(line, s:table_pattern)
    return
  endif

  let this_col_idx = s:col_idx_from_line(line, colnr)
  let header = s:find_first_sep(linenr)
  let cols = s:cols_on_line(header)
  let max_col_idx = s:max_col_idx_from_line(getline(header))
  if this_col_idx > max_col_idx
    return
  endif

  let b:table_wrap_colnr = 1
  for col_idx in range(0, this_col_idx)
    let column_width = cols[col_idx]
    let b:table_wrap_colnr += column_width + 3
  endfor

  let b:table_wrap_colnr -= 1
endfunction

function! s:au_insert_leave()
  " callback for InsertLeave autocommand
  if ! get(b:, "table_auto_format", get(g:, "table_auto_format", 1))
    return
  elseif get(b:, "table_working", 0)
    return
  endif

  if exists("b:table_wrap_colnr")
    unlet b:table_wrap_colnr
  endif

  let current_line = getline('.')
  if s:matches(current_line, s:table_make_pattern)
    let b:table_working = 1
    call s:plug_make()
  elseif s:matches(current_line, s:table_pattern)
    call s:format_table_at_cursor()
  endif
endfunction

function! s:imap_return() "-> mapping
  " key mapping evaluator for CR
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)

  if s:matches(line, s:table_make_pattern)
    let b:table_working = 1
    return "\<Esc>\<Plug>(TableMake)i"
  elseif colnr == 1
    return "\<CR>"
  elseif colnr == strcharlen(line) + 1
    return "\<CR>"
  elseif linenr == 1
    return "\<CR>"
  elseif ! s:matches(getline(linenr + 1), s:table_pattern)
    return "\<CR>"
  elseif s:matches(line, s:table_sep_pattern)
    return "\<Esc>\<Plug>(TableThisCell)i"
  elseif s:matches(line, s:table_pattern)
    let b:table_working = 1
    return "\<Esc>\<Plug>(TableSplitLine)i"
  else
    return "\<CR>"
  endif
endfunction

function! s:imap_tab() "-> mapping
  " key mapping evaluator for Tab
  let current_line = getline('.')
  if s:matches(current_line, s:table_pattern)
    return "\<Esc>\<Plug>(TableNextCell)i"
  else
    return "\<Tab>"
  endif
endfunction

function! s:imap_stab() "-> mapping
  " key mapping evaluator for S-Tab
  let current_line = getline('.')
  if s:matches(current_line, s:table_pattern)
    return "\<Esc>\<Plug>(TablePrevCell)i"
  else
    return "\<S-Tab>"
endfunction

function! s:imap_backspace() "-> mapping
  " key mapping evaluator for Backspace
  let linenr = line('.')
  let line = getline(linenr)
  let cursor_is_at_col_start = s:is_cursor_at_col_start()
  if linenr == 1
    return "\<BS>"
  elseif ! s:matches(line, s:table_pattern)
    return "\<BS>"
  elseif s:matches(line, s:table_make_pattern)
    return "\<BS>"
  elseif s:matches(line, s:table_sep_pattern)
    return "\<BS>"
  elseif ! cursor_is_at_col_start
    return "\<BS>"
  elseif s:matches(getline(linenr - 1), s:table_sep_pattern)
    return ""
  else
    let b:table_working = 1
    return "\<Esc>\<Plug>(TableJoinLine)i"
  endif

endfunction

function! s:imap_space() "-> mapping
  " key mapping evaluator for Space
  if ! exists("b:table_wrap_colnr")
    return "\<C-]>\<Space>"
  endif

  let [linenr, colnr] = s:cursor_pos()
  let in_table = s:matches(getline(linenr), s:table_pattern)
  if in_table && colnr >= b:table_wrap_colnr
    let b:table_working = 1
    return "\<C-]>\<Esc>\<Plug>(TableSplitLine)i"
  elseif in_table
    return "\<C-]>\<Space>"
  else
    unlet b:table_wrap_colnr
    return "\<C-]>\<Space>"
  endif
endfunction

function! s:nmap_left_curly() "-> mapping
  " key mapping for {
  let [linenr, colnr] = s:cursor_pos()
  if colnr == 1
    return "{"
  elseif s:matches(getline(linenr), s:table_pattern)
    return "\<Plug>(TablePrevParagraph)"
  else
    return "{"
  endif
endfunction

function! s:nmap_right_curly() "-> mapping
  " key mapping for }
  let [linenr, colnr] = s:cursor_pos()
  if colnr == 1
    return "}"
  elseif s:matches(getline(linenr), s:table_pattern)
    return "\<Plug>(TableNextParagraph)"
  else
    return "}"
  endif
endfunction

function! s:nmap_o() "-> mapping
  " key mapping for o
  let line = getline('.')
  if s:matches(line, s:table_sep_pattern)
    return "\<Plug>(TableInsertRowBelow)"
  elseif s:matches(line, s:table_pattern)
    return "\<Plug>(TableOpenBelow)"
  else
    return "o"
  endif
endfunction

function! s:nmap_O() "-> mapping
  " key mapping for O
  let line = getline('.')
  if s:matches(line, s:table_sep_pattern)
    return "\<Plug>(TableInsertRowAbove)"
  elseif s:matches(line, s:table_pattern)
    return "\<Plug>(TableOpenAbove)"
  else
    return "O"
  endif
endfunction

function! s:nmap_I() "-> mapping
  " key mapping evaluator for I
  if s:matches(getline('.'), s:table_pattern)
    return "\<Plug>(TableLineInsert)"
  else
    return "I"
  endif
endfunction

function! s:nmap_A() "-> mapping
  " key mapping evaluator for A
  if s:matches(getline('.'), s:table_pattern)
    return "\<Plug>(TableLineAppend)"
  else
    return "A"
  endif
endfunction

function! s:imap_ctrl_w() "-> mapping
  " key mapping evaluator for Ctrl-W
  let linenr = line('.')
  let line = getline(linenr)
  let cursor_is_at_col_start = s:is_cursor_at_col_start()
  if linenr == 1
    return "\<C-W>"
  elseif ! s:matches(line, s:table_pattern)
    return "\<C-W>"
  elseif s:matches(line, s:table_make_pattern)
    return "\<C-W>"
  elseif s:matches(line, s:table_sep_pattern)
    return "\<C-W>"
  elseif ! cursor_is_at_col_start
    return "\<C-W>"
  elseif s:matches(getline(linenr - 1), s:table_sep_pattern)
    return ""
  else
    let b:table_working = 1
    return "\<Esc>\<Plug>(TableJoinLine)i"
  endif

endfunction

function! s:plug_make()
  " handler for make operation
  let linenr = line('.')
  let cols = split(getline('.'), '|')
  let line = s:line_from_cols(cols)
  let sep = substitute(line, ' ', '-', 'g')

  call setline(linenr, sep)
  call append(linenr, [line, sep])
  call setcursorcharpos(linenr + 1, 3)

  unlet b:table_working
endfunction

function! s:plug_this_cell()
  " handler for this_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  let next_bot_sep = s:find_next_sep(linenr)
  let col_idx = s:col_idx_from_line(line, colnr)
  let new_linenr = s:find_prev_non_empty_by_col_idx(next_bot_sep, col_idx)
  call setcursorcharpos(new_linenr, 0)
  call s:move_cursor_to_col_text_end(col_idx)
endfunction

function! s:plug_next_cell()
  " handler for next_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let current_line = getline(linenr)
  let next_col_idx = s:col_idx_from_line(current_line, colnr) + 1

  if next_col_idx > s:max_col_idx_from_line(current_line)
    let next_col_idx = 0
    let this_bot_sep = s:find_next_sep(linenr)
    let next_bot_sep = s:find_next_sep(this_bot_sep)
  else
    let next_bot_sep = s:find_next_sep(linenr)
  endif

  if next_bot_sep == -1
    let last_sep = s:find_last_sep(linenr)
    let cols = s:cols_on_line(linenr)
    let line = s:line_from_cols(cols)
    let sep = substitute(line, ' ', '-', 'g')
    call append(last_sep, [line, sep])
    call setcursorcharpos(last_sep + 1, 3)
  else
    let new_linenr = s:find_prev_non_empty_by_col_idx(next_bot_sep, next_col_idx)
    call setcursorcharpos(new_linenr, 0)
    call s:move_cursor_to_col_text_end(next_col_idx)
  endif
endfunction

function! s:plug_prev_cell()
  " handler for prev_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let current_line = getline(linenr)
  let prev_col_idx = s:col_idx_from_line(current_line, colnr) - 1

  if prev_col_idx < 0
    let prev_col_idx = s:max_col_idx_from_line(current_line)
    let prev_bot_sep = s:find_prev_sep(linenr)
  else
    let prev_bot_sep = s:find_next_sep(linenr)
  endif

  if prev_bot_sep != s:find_first_sep(linenr)
    let new_linenr = s:find_prev_non_empty_by_col_idx(prev_bot_sep, prev_col_idx)
    call setcursorcharpos(new_linenr, 0)
    call s:move_cursor_to_col_text_end(prev_col_idx)
  else
    " prevent the cursor from wandering when it repeated leaves insert mode
    call setcursorcharpos(linenr, colnr + 1)
  endif
endfunction

function! s:plug_split_line()
  " handler for split_line operation
  let [linenr, colnr] = s:cursor_pos()
  let current_line = getline(linenr)
  let col_idx = s:col_idx_from_line(current_line, colnr)

  let header = s:find_first_sep(linenr)
  if header == linenr
    call s:maybe_unlet_b_table_working()
    return
  elseif col_idx > s:max_col_idx_from_line(getline(header))
    call s:maybe_unlet_b_table_working()
    return
  endif

  let column_width = s:cols_on_line(header)[col_idx]
  let format_string = ' %-' .. column_width .. 'S '

  let [before_text, after_text] = s:split_col_text(linenr, colnr)
  let before_text = printf(format_string, trim(before_text))
  let after_text = printf(format_string, trim(after_text))

  call s:change_col_text(linenr, col_idx, before_text)
  let next_linenr = linenr + 1
  let next_text = after_text
  while ! s:matches(getline(next_linenr), s:table_sep_pattern)
    let old_text = s:col_text_on_line(next_linenr, col_idx)
    call s:change_col_text(next_linenr, col_idx, next_text)
    let next_text = old_text
    let next_linenr += 1
  endwhile

  if ! empty(trim(next_text)) || linenr + 1 == next_linenr
    let split_line = split(substitute(getline(next_linenr), '-', ' ', 'g'), '|')
    let split_line[col_idx] = next_text
    call append(next_linenr - 1, '|' .. join(split_line, '|') .. '|')
  endif

  call setcursorcharpos(linenr + 1, 0)
  call s:move_cursor_to_col_text_start(col_idx)
  call s:maybe_unlet_b_table_working()
endfunction

function! s:plug_join_line()
  " handler for join_line operation
  let [linenr, colnr] = s:cursor_pos()
  let current_line = getline(linenr)
  let col_idx = s:col_idx_from_line(current_line, colnr)

  let header = s:find_first_sep(linenr)
  if header == linenr
    call s:maybe_unlet_b_table_working()
    return
  elseif col_idx > s:max_col_idx_from_line(getline(header))
    call s:maybe_unlet_b_table_working()
    return
  endif

  let column_width = s:cols_on_line(header)[col_idx]
  let format_string = ' %-' .. column_width .. 'S '

  call setcursorcharpos(linenr - 1, 0)
  call s:move_cursor_to_col_text_end(col_idx)
  let [restore_linenr, restore_colnr] = s:cursor_pos()

  let prev_col_text = trim(s:col_text_on_line(linenr - 1, col_idx))
  let this_col_text = trim(s:col_text_on_line(linenr, col_idx))
  let new_text = printf(format_string, prev_col_text .. this_col_text)
  call s:change_col_text(linenr - 1, col_idx, new_text)

  let next_linenr = linenr + 1
  while ! s:matches(getline(next_linenr), s:table_sep_pattern)
    let col_text = s:col_text_on_line(next_linenr, col_idx)
    call s:change_col_text(next_linenr - 1, col_idx, col_text)
    let next_linenr += 1
  endwhile

  let column_width = len(s:col_text_on_line(next_linenr, col_idx))
  call s:change_col_text(next_linenr - 1, col_idx, repeat(' ', column_width))

  call setcursorcharpos(restore_linenr, restore_colnr)
  call s:maybe_unlet_b_table_working()
endfunction

function! s:plug_cell_insert()
  " handler for cell_insert operation
   let [linenr, colnr] = s:cursor_pos()
   let line = getline(linenr)
   if ! s:matches(line, s:table_pattern)
     return
   endif

   let col_idx = s:col_idx_from_line(line, colnr)
   let bot_sep = s:find_next_sep(linenr)
   let new_linenr = s:find_prev_non_empty_by_col_idx(bot_sep, col_idx)
   call setcursorcharpos(new_linenr, 0)
   call s:move_cursor_to_col_text_end(col_idx)
   startinsert
endfunction

function! s:plug_select_cell()
  " handler for select_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, colnr)
  let start_linenr = s:find_prev_sep(linenr) + 1
  let end_linenr = s:find_next_sep(linenr) - 1
  let start_byte = match(getline(start_linenr), '|', 0, col_idx + 1) + 2
  let end_byte = match(getline(end_linenr), '|', 0, col_idx + 2) - 2

  call setpos(".", [0, start_linenr, start_byte + 1, 0])
  execute "normal" "\<C-v>"
  call setpos(".", [0, end_linenr, end_byte + 1, 0])
endfunction

function! s:plug_select_col()
  " handler for select_col operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, colnr)
  let start_linenr = s:find_first_sep(linenr)
  let end_linenr = s:find_last_sep(linenr)
  let start_byte = match(getline(start_linenr), '|', 0, col_idx + 1) + 2
  let end_byte = match(getline(end_linenr), '|', 0, col_idx + 2) - 2

  call setpos(".", [0, start_linenr, start_byte + 1, 0])
  execute "normal" "\<C-v>"
  call setpos(".", [0, end_linenr, end_byte + 1, 0])
endfunction

function! s:plug_select_row()
  " handler for select_row operation
  let linenr = line('.')
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let start_linenr = s:find_prev_sep(linenr) + 1
  let end_linenr = s:find_next_sep(linenr) - 1
  let end_byte = len(getline(end_linenr))

  call setpos(".", [0, start_linenr, 1, 0])
  execute "normal" "\<C-v>"
  call setpos(".", [0, end_linenr, end_byte, 0])
endfunction

function! s:plug_left_cell()
  " handler for left_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, colnr)
  if col_idx == 0
    return
  endif

  let col_idx -= 1

  if get(g:, 'table_jump_to_end', 0)
    let bot_sep = s:find_next_sep(linenr)
    if bot_sep == -1
      return
    endif

    let new_linenr = s:find_prev_non_empty_by_col_idx(bot_sep, col_idx)

    call setcursorcharpos(new_linenr, 0)
    call s:move_cursor_to_col_text_end(col_idx)
  else
    let top_sep = s:find_prev_sep(linenr)
    if top_sep == -1
      return
    endif

    let new_linenr = top_sep + 1
    call setcursorcharpos(new_linenr, 0)
    call s:move_cursor_to_col_text_start(col_idx)
  endif
endfunction

function! s:plug_right_cell()
  " handler for right_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, colnr)
  let bot_sep = s:find_next_sep(linenr)
  if bot_sep == -1
    return
  endif

  let max_col_idx = s:max_col_idx_from_line(getline(bot_sep))
  if col_idx == max_col_idx
    return
  endif

  let col_idx += 1

  if get(g:, 'table_jump_to_end', 0)
    let new_linenr = s:find_prev_non_empty_by_col_idx(bot_sep, col_idx)
    call setcursorcharpos(new_linenr, 0)
    call s:move_cursor_to_col_text_end(col_idx)
  else
    let top_sep = s:find_prev_sep(linenr)
    call setcursorcharpos(top_sep + 1, 0)
    call s:move_cursor_to_col_text_start(col_idx)
  endif
endfunction

function! s:plug_down_cell()
  " handler for down_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, colnr)
  let this_bot_sep = s:find_next_sep(linenr)
  if this_bot_sep == -1
    return
  endif

  let last_sep = s:find_last_sep(this_bot_sep)
  if this_bot_sep == last_sep
    return
  endif

  if get(g:, 'table_jump_to_end', 0)
    let next_bot_sep = s:find_next_sep(this_bot_sep)
    let new_linenr = s:find_prev_non_empty_by_col_idx(next_bot_sep, col_idx)
    call setcursorcharpos(new_linenr, 0)
    call s:move_cursor_to_col_text_end(col_idx)
  else
    call setcursorcharpos(this_bot_sep + 1, 0)
    call s:move_cursor_to_col_text_start(col_idx)
  endif
endfunction

function! s:plug_up_cell()
  " handler for up_cell operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, colnr)
  let prev_sep = s:find_prev_sep(linenr)
  if prev_sep == -1
    return
  endif

  let first_sep = s:find_first_sep(prev_sep)
  if prev_sep == first_sep
    return
  endif

  if get(g:, 'table_jump_to_end', 0)
    let new_linenr = s:find_prev_non_empty_by_col_idx(prev_sep, col_idx)
    call setcursorcharpos(new_linenr, 0)
    call s:move_cursor_to_col_text_end(col_idx)
  else
    let prev_prev_sep = s:find_prev_sep(prev_sep)
    call setcursorcharpos(prev_prev_sep + 1, 0)
    call s:move_cursor_to_col_text_start(col_idx)
  endif
endfunction

function! s:plug_next_paragraph()
  "handler for next_paragraph operation
  let [cur_linenr, cur_colnr] = s:cursor_pos()
  let line = getline(cur_linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, cur_colnr)
  let end_linenr = s:find_next_sep(cur_linenr)
  if end_linenr == -1
    return
  endif

  let linenr = cur_linenr
  while linenr + 1 != end_linenr
    let is_this_line_blank = empty(trim(s:col_text_on_line(linenr, col_idx)))
    let is_next_line_blank = empty(trim(s:col_text_on_line(linenr + 1, col_idx)))

    if is_next_line_blank && ! is_this_line_blank
      let linenr += 1
      break
    endif

    let linenr += 1
  endwhile

  call setcursorcharpos(linenr, 0)
  call s:move_cursor_to_col_text_end(col_idx)
endfunction

function! s:plug_prev_paragraph()
  "handler for prev_paragraph operation
  let [cur_linenr, cur_colnr] = s:cursor_pos()
  let line = getline(cur_linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, cur_colnr)
  let end_linenr = s:find_prev_sep(cur_linenr)
  if end_linenr == -1 " TODO goto top of table instead of silently failing
    return
  endif

  let linenr = cur_linenr
  while linenr - 1 != end_linenr
    let is_this_line_blank = empty(trim(s:col_text_on_line(linenr, col_idx)))
    let is_prev_line_blank = empty(trim(s:col_text_on_line(linenr - 1, col_idx)))

    if is_prev_line_blank && ! is_this_line_blank
      let linenr -= 1
      break
    endif

    let linenr -= 1
  endwhile

  call setcursorcharpos(linenr, 0)
  call s:move_cursor_to_col_text_start(col_idx)
endfunction

function! s:plug_open_above()
  " handler for open_above operation
  let [linenr, colnr] = s:cursor_pos()
  let current_line = getline(linenr)
  if s:cursor_is_out_of_bounds(linenr, colnr)
    return
  endif

  let col_idx = s:col_idx_from_line(current_line, colnr)

  let column_width = s:cols_on_line(s:find_prev_sep(linenr))[col_idx]
  let next_text = s:col_text_on_line(linenr, col_idx)
  let next_linenr = linenr + 1
  call s:change_col_text(linenr, col_idx, repeat(' ', column_width + 2))
  while ! s:matches(getline(next_linenr), s:table_sep_pattern)
    let old_text = s:col_text_on_line(next_linenr, col_idx)
    call s:change_col_text(next_linenr, col_idx, next_text)
    let next_text = old_text
    let next_linenr += 1
  endwhile

  if ! empty(trim(next_text)) || linenr + 1 == next_linenr
    let split_line = split(substitute(getline(next_linenr), '-', ' ', 'g'), '|')
    let split_line[col_idx] = next_text
    call append(next_linenr - 1, '|' .. join(split_line, '|') .. '|')
  endif

  call setcursorcharpos(linenr, 0)
  call s:move_cursor_to_col_text_start(col_idx)
  startinsert
endfunction

function! s:plug_open_below()
  " handler for open_below operation
  let [linenr, colnr] = s:cursor_pos()
  let current_line = getline(linenr)
  if s:cursor_is_out_of_bounds(linenr, colnr)
    return
  endif

  let col_idx = s:col_idx_from_line(current_line, colnr)

  let column_width = s:cols_on_line(s:find_prev_sep(linenr))[col_idx]
  let next_text = repeat(' ', column_width + 2)
  let next_linenr = linenr + 1
  while ! s:matches(getline(next_linenr), s:table_sep_pattern)
    let old_text = s:col_text_on_line(next_linenr, col_idx)
    call s:change_col_text(next_linenr, col_idx, next_text)
    let next_text = old_text
    let next_linenr += 1
  endwhile

  if ! empty(trim(next_text)) || linenr + 1 == next_linenr
    let split_line = split(substitute(getline(next_linenr), '-', ' ', 'g'), '|')
    let split_line[col_idx] = next_text
    call append(next_linenr - 1, '|' .. join(split_line, '|') .. '|')
  endif

  call setcursorcharpos(linenr + 1, 0)
  call s:move_cursor_to_col_text_start(col_idx)
  startinsert
endfunction

function! s:plug_insert_row_above()
  " handler for insert_row_above operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  let col_idx = s:col_idx_from_line(line, colnr)
  let prev_sep = s:find_prev_sep(linenr)
  if prev_sep == -1
    call append(linenr - 1, [line, substitute(line, '-', ' ', 'g')])
    call setcursorcharpos(linenr - 1, 0)
    call s:move_cursor_to_col_text_start(col_idx)
    startinsert
  else
    call append(prev_sep, [substitute(line, '-', ' ', 'g'), line])
    call setcursorcharpos(prev_sep + 1, 0)
    call s:move_cursor_to_col_text_start(col_idx)
    startinsert
  endif
endfunction

function! s:plug_insert_row_below()
  " handler for insert_row_below operation
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  let col_idx = s:col_idx_from_line(line, colnr)
  call append(linenr, [substitute(line, '-', ' ', 'g'), line])
  call setcursorcharpos(linenr + 1, 0)
  call s:move_cursor_to_col_text_start(col_idx)
  startinsert
endfunction

function! s:plug_line_insert()
  " handler for line_insert operation
  let [linenr, colnr] = s:cursor_pos()
  let col_idx = s:col_idx_from_line(getline(linenr), colnr)
  call setcursorcharpos(linenr, 0)
  call s:move_cursor_to_col_text_start(col_idx)
  startinsert
endfunction

function! s:plug_line_append()
  " handler for line_append operation
  let [linenr, colnr] = s:cursor_pos()
  let col_idx = s:col_idx_from_line(getline(linenr), colnr)
  call setcursorcharpos(linenr, 0)
  call s:move_cursor_to_col_text_end(col_idx)
  startinsert
endfunction

function! s:plug_table_begin()
  " handler for table_begin operation
  let linenr = line('.')
  if ! s:matches(getline(linenr), s:table_pattern)
    return
  endif

  let first_sep = s:find_first_sep(linenr)
  if first_sep == 1
    let first_sep = 2
  endif

  call setcursorcharpos(first_sep - 1, 0)
endfunction

function! s:plug_table_end()
  " handler for table_end operation
  let linenr = line('.')
  if ! s:matches(getline(linenr), s:table_pattern)
    return
  endif

  let last_sep = s:find_last_sep(linenr)
  if last_sep == line('$')
    let last_sep -= 1
  endif

  call setcursorcharpos(last_sep + 1, 0)
endfunction


" =========
" Functions
" =========

function! s:align_columns(lines) "-> List[String]
  " return lines with columns aligned to a consistent column width
  if empty(a:lines)
    return a:lines
  endif

  let cols = map(split(a:lines[0], '|'), "strcharlen(v:val)")
  for line in a:lines
    let split_line = split(line, '|')
    for col_idx in range(len(cols))
      let length = strcharlen(split_line[col_idx])
      if length > cols[col_idx]
        let cols[col_idx] = length
      endif
    endfor
  endfor

  let row_separator = '|'
  let row_format_string = '|'
  for column_width in cols
    let row_separator ..= repeat('-', column_width) .. '|'
    let row_format_string ..= '%-' .. column_width .. 'S|'
  endfor

  let PrintLine = function("printf", [row_format_string])

  let new_lines = []
  for line in a:lines
    if s:matches(line, s:table_sep_pattern)
      call add(new_lines, row_separator)
    else
      let split_line = split(line, '|')
      call add(new_lines, call(PrintLine, split_line))
    endif
  endfor

  return new_lines
endfunction

function! s:cell_containing(linenr, colnr) "-> [Number, Number]
  " return the row_idx and col_idx of the cell containing the given point
  let col_idx = s:col_idx_from_line(getline(a:linenr), a:colnr)
  let row_idx = 0
  let this_sep = s:find_next_sep(s:find_first_sep(a:linenr))
  let last_sep = s:find_last_sep(a:linenr)

  while this_sep != last_sep
    if this_sep > a:linenr
      break
    endif
    let row_idx += 1
    let this_sep = s:find_next_sep(this_sep)
  endwhile
  return [row_idx, col_idx]
endfunction

function! s:change_col_text(linenr, col_idx, text)
  " change column text on given line
  let split_line = split(getline(a:linenr), '|')
  let split_line[a:col_idx] = a:text
  call setline(a:linenr, '|' .. join(split_line, '|') .. '|')
endfunction

function! s:col_idx_from_line(line, colnr) "-> Number
  " return the index of the table column containing colnr
  let end_byte = byteidx(a:line, a:colnr - 1)
  return count(a:line[:end_byte], '|') - 1
endfunction

function! s:col_text_on_line(linenr, col_idx) "-> String
  " return the trimmed text in a table column
  return split(getline(a:linenr), '|')[a:col_idx]
endfunction

function! s:cols_on_line(linenr) "->  List[Number]
  " return column widths from table header
  let header = getline(s:find_first_sep(a:linenr))
  return map(split(header, '|'), "len(v:val) - 2")
endfunction

function! s:cursor_is_out_of_bounds(linenr, colnr)
  " return non-zero value if given cursor is not within bounds of a table
  let current_line = getline(a:linenr)
  let col_idx = s:col_idx_from_line(current_line, a:colnr)
  let header = s:find_first_sep(a:linenr)
  if header == a:linenr
    return 1
  elseif col_idx > s:max_col_idx_from_line(getline(header))
    return 1
  else
    return 0
  endif
endfunction

function! s:cursor_pos() "-> [Number, Number]
  " return [linenr, colnr] of cursor
  let [_, linenr, colnr, _, _] = getcursorcharpos()
  return [linenr, colnr]
endfunction

function! s:find_first_sep(linenr) "-> Number
  " return linenr of first separator of the table
  let old_linenr = a:linenr
  let linenr = s:find_prev_sep(a:linenr)
  while linenr != -1
    let old_linenr = linenr
    let linenr = s:find_prev_sep(linenr)
  endwhile
  return old_linenr
endfunction

function! s:find_last_sep(linenr) "-> Number
  " return linenr of last separator of the table
  let old_linenr = a:linenr
  let linenr = s:find_next_sep(a:linenr)
  while linenr != -1
    let old_linenr = linenr
    let linenr = s:find_next_sep(linenr)
  endwhile
  return old_linenr
endfunction

function! s:find_next_sep(linenr) "-> Number
  " return linenr of next separator of the table
  let linenr = a:linenr + 1
  while s:matches(getline(linenr), s:table_pattern)
    if s:matches(getline(linenr), s:table_sep_pattern)
      return linenr
    endif
    let linenr += 1
  endwhile
  return -1
endfunction

function! s:find_prev_sep(linenr) "-> Number
  " return linenr of previous separator of the table
  let linenr = a:linenr - 1
  while s:matches(getline(linenr), s:table_pattern)
    if s:matches(getline(linenr), s:table_sep_pattern)
      return linenr
    endif
    let linenr -= 1
  endwhile
  return -1
endfunction

function! s:find_prev_non_empty_by_col_idx(linenr, col_idx) "-> Number
  " return linenr of previous non-empty line in a given col
  let linenr = a:linenr - 1
  while empty(trim(s:col_text_on_line(linenr, a:col_idx)))
    let linenr -= 1
  endwhile
  return linenr
endfunction

function! s:format_table_at_cursor()
  " format the table located at the cursor
  let [cur_linenr, cur_colnr] = s:cursor_pos()
  let formatter = s:create_table_formatter(cur_linenr, cur_colnr)
  if empty(formatter)
    return
  endif

  let [cur_row_idx, cur_col_idx] = s:cell_containing(cur_linenr, cur_colnr)
  let max_col_idx = s:max_col_idx_from_line(getline(formatter.first_sep))
  if cur_col_idx > max_col_idx
    let cur_col_idx = max_col_idx
  endif

  let rows = []
  let this_sep = formatter.first_sep
  while this_sep != formatter.last_sep
    let next_sep = s:find_next_sep(this_sep)

    let row = formatter.collect_row(this_sep, next_sep)
    call map(row, "formatter.remove_column_trailing_empty_lines(v:val)")
    call map(row, {idx, col -> formatter.wrap_column(col, idx)})
    call add(rows, row)

    let this_sep = next_sep
  endwhile

  let lines = formatter.format_rows(rows)
  let lines = s:align_columns(lines)

  call deletebufline(bufnr(), formatter.first_sep, formatter.last_sep)
  call append(formatter.first_sep - 1, lines)
  call s:move_cursor_to_cell(formatter.first_sep, cur_row_idx, cur_col_idx)
endfunction

function! s:insert_col_at_cursor(column_width)
  " insert a new column after the column containing the cursor
  if a:column_width < s:min_column_width
    redraw
    echohl ErrorMsg
    echomsg "Invalid column width"
    echohl None
    return
  endif

  let [linenr, colnr] = s:cursor_pos()
  let current_line = getline(linenr)
  if ! s:matches(current_line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(current_line, colnr)
  let first_sep = s:find_first_sep(linenr)
  let last_sep = s:find_last_sep(linenr)

  let lines = getline(first_sep, last_sep)
  for line_index in range(len(lines))
    let line = lines[line_index]
    let ins_byte = match(line, '|', 0, col_idx + 2)
    if s:matches(line, s:table_sep_pattern)
      let line = line[:ins_byte - 1] .. '|' .. repeat('-', a:column_width + 2) .. line[ins_byte:]
    else
      let line = line[:ins_byte - 1] .. '|' .. repeat(' ', a:column_width + 2) .. line[ins_byte:]
    endif
    let lines[line_index] = line
  endfor

  call deletebufline(bufnr(), first_sep, last_sep)
  call append(first_sep - 1, lines)
  call setcursorcharpos(linenr, colnr)
endfunction

function! s:insert_row_at_cursor()
  " insert a new row below the row containing the cursor
  let linenr = line('.')
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let bot_sep = s:find_next_sep(linenr)
  let bot_sep_line = getline(bot_sep)
  call append(bot_sep, [substitute(bot_sep_line, '-', ' ', 'g'), bot_sep_line])
endfunction

function! s:is_cursor_at_col_start() "-> bool
  " return true if cursor is at the start of a table column
  return search('| \%#', 'bn') != 0
endfunction

function! s:line_from_cols(cols) "-> String
  " create a blank table lines with specified column widths
  let line = "|"
  for column_width in a:cols
    let column_width = max([column_width, s:min_column_width])
    let line ..= repeat(' ', column_width + 2) .. "|"
  endfor
  return line
endfunction

function! s:matches(expr, pattern) "-> bool
  " return if expr matches pattern
  return match(a:expr, a:pattern) != -1
endfunction

function! s:max_col_idx_from_line(line) "-> Number
  " return maxiumum column index for a given line
  return count(a:line, '|') - 2
endfunction

function! s:maybe_unlet_b_table_working()
  " unset b:table_working if it was set
  if exists("b:table_working")
    unlet b:table_working
  endif
endfunction

function! s:move_cursor_to_cell(linenr, row_idx, col_idx)
  " move cursor to the end of text of the give cell
  let first_sep = s:find_first_sep(a:linenr)
  let last_sep = s:find_last_sep(a:linenr)

  let row_idx = a:row_idx
  let this_bot_sep = first_sep
  while row_idx >= 0
    let this_bot_sep = s:find_next_sep(this_bot_sep)
    let row_idx -= 1
  endwhile

  let new_linenr = s:find_prev_non_empty_by_col_idx(this_bot_sep, a:col_idx)
  call setcursorcharpos(new_linenr, 0)
  call s:move_cursor_to_col_text_end(a:col_idx)
endfunction

function! s:move_cursor_to_col_text_end(col_idx)
  " move cursor to the end of text in a given table column
  call search(printf('^|\(.\{-}|\)\{%d} .\{-}\zs\s*|',  a:col_idx))
endfunction

function! s:move_cursor_to_col_text_start(col_idx)
  " move cursor to the start of text in a given table column
  call search(printf('^|\(.\{-}|\)\{%d} \zs', a:col_idx))
endfunction

function! s:remove_column_trailing_empty_lines(column) "-> List[String]
  let result = []
  let empty_count = 0
  for paragraph in a:column
    if empty(paragraph)
      let empty_count += 1
    elseif empty_count > 0
      call extend(result, repeat([''], empty_count))
      let empty_count = 0
      call add(result, paragraph)
    else
      call add(result, paragraph)
    endif
  endfor
  return result
endfunction

function! s:resize_table_at_cursor(...)
  " interactively prompt the user for the new column width of the column
  " containing the cursor
  let [linenr, colnr] = s:cursor_pos()
  let line = getline(linenr)
  if ! s:matches(line, s:table_pattern)
    return
  endif

  let col_idx = s:col_idx_from_line(line, colnr)
  let header = s:find_first_sep(linenr)
  let cols = s:cols_on_line(header)

  if a:0 > 0
    let usr_column_width = str2nr(a:1)
  else
    let opts = {}
    let opts.prompt = "Column Width: "
    let opts.default = cols[col_idx]
    let opts.cancelreturn = cols[col_idx]
    call inputsave()
    let usr_column_width = str2nr(input(opts))
    call inputrestore()
  endif

  if usr_column_width < s:min_column_width
    redraw
    echohl ErrorMsg
    echomsg "Invalid column width"
    echohl None
    return
  elseif usr_column_width == cols[col_idx]
    redraw
    echo "Column Width: " .. usr_column_width
    return
  endif

  let cols[col_idx] = usr_column_width
  let new_header_line = '|'
  for column_width in cols
    let new_header_line ..= repeat('-', column_width + 2) .. '|'
  endfor

  call setline(header, new_header_line)
  call s:format_table_at_cursor()
endfunction

function! s:split_col_text(linenr, colnr) "-> [String, String]
  " return the text from the specified line split at the specified column
  let before = split(slice(getline(a:linenr), 0, a:colnr), '|')[-1]
  let after = split(slice(getline(a:linenr), a:colnr), '|')[0]
  return [before, after]
endfunction

function! s:table_mode_toggle()
  if ! get(b:, "table_mode", 0)
    let b:table_mode = 1
    doautocmd User TableModeEnable
    echo "Table Mode enabled"
  else
    unlet b:table_mode
    doautocmd User TableModeDisable
    echo "Table Mode disabled"
  endif
endfunction

" ====================
" Formatting Functions
" ====================

function! s:create_table_formatter(cur_linenr, cur_colnr) "-> Dictionary
  " return dictionary representing a formatter object
  " return empty dictionary if cur_linenr is not in the table
  let line = getline(a:cur_linenr)
  if ! s:matches(line, s:table_pattern)
    return {}
  elseif s:matches(line, s:table_make_pattern)
    return {}
  endif

  let first_sep = s:find_first_sep(a:cur_linenr)
  let last_sep = s:find_last_sep(a:cur_linenr)
  if first_sep == last_sep
    return {}
  endif

  let cols = s:cols_on_line(first_sep)
  call map(cols, "max([v:val, s:min_column_width])")

  let formatter = {
        \ 'cur_linenr': a:cur_linenr,
        \ 'cur_colnr': a:cur_colnr,
        \ 'first_sep': first_sep,
        \ 'last_sep': last_sep,
        \ 'cols': cols,
        \ 'collect_row': function("<SID>formatter_collect_row"),
        \ 'wrap_column': function("<SID>formatter_wrap_column"),
        \ 'remove_column_trailing_empty_lines': function("<SID>remove_column_trailing_empty_lines"),
        \ 'format_rows': function("<SID>formatter_format_rows"),
        \ 'row_range': function("<SID>formatter_row_range"),
        \ 'wrap_lines_to_width': function("<SID>formatter_wrap_lines_to_width")
        \}

  return formatter
endfunction

function! s:create_bare_table_formatter(column_widths) "-> Dictionary
  " return dictionary representing a formatter object to format a table to the
  " specified column widths
  "
  " does not fully implement formatter objects and is intended for building a
  " table from a data structure rather than parsing one from a text buffer
  return {
        \ 'cols': a:column_widths,
        \ 'wrap_lines_to_width': function("<SID>formatter_wrap_lines_to_width"),
        \ 'wrap_column': function("<SID>formatter_wrap_column"),
        \ 'format_rows': function("<SID>formatter_format_rows")
        \ }
endfunction

function! s:formatter_row_range() dict " -> List[[Number, Number]]
  " return a ranged-list of elements for the start and end separator line
  " numbers for each in the formatter's table
  let elems = []
  let prev_sep = self.first_sep
  let this_sep = s:find_next_sep(prev_sep)
  call add(elems, [prev_sep, this_sep])
  while this_sep != self.last_sep
    let prev_sep = this_sep
    let this_sep = s:find_next_sep(prev_sep)
    call add(elems, [prev_sep, this_sep])
  endwhile
  return elems
endfunction

function! s:formatter_collect_row(this_sep, next_sep) dict "-> List[List[String]]
  let max_col_idx = s:max_col_idx_from_line(getline(self.first_sep))

  let row = []
  let buffers = []
  for i in range(0, max_col_idx)
    call add(row, [])
    call add(buffers, '')
  endfor

  for linenr in range(a:this_sep + 1, a:next_sep - 1)
    let split_line = split(getline(linenr), '|')
    for col_idx in range(0, max_col_idx)
      let column = row[col_idx]

      if col_idx >= len(split_line)
        call add(column, buffers[col_idx])
        let buffers[col_idx] = ''
        continue
      endif

      let text = trim(split_line[col_idx])
      if empty(text)
        call add(column, buffers[col_idx])
        let buffers[col_idx] = ''
      elseif empty(buffers[col_idx]) && linenr > a:this_sep + 1
        call add(column, '')
        let buffers[col_idx] = text
      elseif empty(buffers[col_idx])
        let buffers[col_idx] = text
      else
        let buffers[col_idx] ..= ' ' .. text
      endif
    endfor
  endfor

  for col_idx in range(0, max_col_idx)
    call add(row[col_idx], buffers[col_idx])
  endfor

  return row
endfunction

function! s:formatter_wrap_lines_to_width(lines, width) " -> List[String]
  let result = []
  for paragraph in a:lines
    let line_buffer = ''
    for word in split(paragraph, ' ')
      if empty(line_buffer)
        let line_buffer = word
      elseif strcharlen(line_buffer) + strcharlen(word) + 1 <= a:width
        let line_buffer ..= ' ' .. word
      else
        call add(result, line_buffer)
        let line_buffer = word
      endif
    endfor
    call add(result, line_buffer)
  endfor
  return result
endfunction

function! s:formatter_wrap_column(column, col_idx) dict "-> List[String]
  let column_width = self.cols[a:col_idx]
  return self.wrap_lines_to_width(a:column, column_width)
endfunction

function! s:formatter_format_rows(rows) dict "-> List[String]
  " return formatted rows as lines to be inserted into the buffer
  let lines = []

  let row_separator = '|'
  let row_format_string = '|'
  for column_width in self.cols
    let row_separator ..= repeat('-', column_width + 2) .. '|'
    let row_format_string ..= ' %-' .. column_width .. 'S |'
  endfor

  let PrintLine = function("printf", [row_format_string])

  call add(lines, row_separator)
  for row in a:rows
    let max_lines = 0
    for column in row
      let max_index = len(column) - 1
      if max_index > max_lines
        let max_lines = max_index
      endif
    endfor

    for line_index in range(0, max_lines)
      let line = []
      for col_idx in range(len(self.cols))
        call add(line, get(row[col_idx], line_index, ''))
      endfor
      call add(lines, call(PrintLine, line))
    endfor
    call add(lines, row_separator)
  endfor

  return lines
endfunction

" ===================
" Converter Functions
" ===================

function! s:table_at_cursor_to_plaintext()
  " converts the table at the cursor to its plaintext equivalent
  let [linenr, colnr] = s:cursor_pos()
  let formatter = s:create_table_formatter(linenr, colnr)
  if empty(formatter)
    return
  endif

  let table = []
  for sep_pair in formatter.row_range()
    let [this_sep, next_sep] = sep_pair
    let row = formatter.collect_row(this_sep, next_sep)
    call map(row, "formatter.remove_column_trailing_empty_lines(v:val)")
    call map(row, "formatter.wrap_lines_to_width(v:val, &tw)")
    call add(table, row)
  endfor

  if empty(table)
    return
  endif

  let table_headers = []
  for cell in table[0]
    if len(cell) != 1
      let table_headers = []
      break
    else
      call add(table_headers, cell[0])
    endif
  endfor

  let before_fmt = get(b:, "table_plain_before", "")
  let after_fmt = get(b:, "table_plain_after", "")

  let lines = []

  if stridx(before_fmt, "\n") != -1
    let begin_cmd = printf("!TBEGIN %s", join(formatter.cols))
    call extend(lines, split(before_fmt, "\n"))
    call extend(lines, [begin_cmd, ""])
  else
    let begin_cmd = printf("%s!TBEGIN %s", before_fmt, join(formatter.cols))
    call extend(lines, [begin_cmd, ""])
  endif

  for row_i in range(len(table))
    let row = table[row_i]
    if ! empty(table_headers) && row_i == 0 && len(table) > 1
      continue
    endif

    let row_cmd = printf("!TROW %d", row_i)
    call extend(lines, [row_cmd, ""])
    for cell_i in range(len(row))
      let cell = row[cell_i]
      let cell_cmd = empty(table_headers) ? "!TCELL" : "!TCELL " .. table_headers[cell_i]
      call extend(lines, [cell_cmd, ""])
      call extend(lines, cell)
      call add(lines, "")
    endfor
  endfor

  if stridx(after_fmt, "\n") != -1
    call add(lines, "!TEND")
    call extend(lines, split(after_fmt, "\n"))
  else
    let end_cmd = printf("!TEND%s", after_fmt)
    call add(lines, end_cmd)
  endif

  call deletebufline(bufnr(), formatter.first_sep, formatter.last_sep)
  call append(formatter.first_sep - 1, lines)
  call setcursorcharpos(formatter.first_sep, 0)
endfunction

function! s:plaintext_range_at_cursor() " -> [Number, Number, Number, Number]
  " return the range of a plaintext table around the cursor in the following
  " form:
  "
  " [region_start, table_start, table_end, region_end]
  "
  " return empty list if region is invalid
  let before_fmt_str = get(b:, "table_plain_before", "")
  if stridx(before_fmt_str, "\n") != -1
    let before_fmt = split(before_fmt_str, "\n")
  else
    let before_fmt = [before_fmt_str]
  endif

  let after_fmt_str = get(b:, "table_plain_after", "")
  if stridx(after_fmt_str, "\n") != -1
    let after_fmt = split(after_fmt_str, "\n")
  else
    let after_fmt = [after_fmt_str]
  endif

  let table_start = search("!TBEGIN", 'bn')
  let table_end = search("!TEND", 'n')
  if table_start == 0 || table_end == 0
    return []
  elseif table_start >= table_end
    return []
  endif

  let region_start = table_start
  while region_start - 1 > 0
    let prev_line = getline(region_start - 1)
    let match_found = 0
    for line in before_fmt
      if prev_line == line
        let region_start -= 1
        let match_found = 1
        break
      endif
    endfor

    if ! match_found
      break
    endif
  endwhile

  let region_end = table_end
  while region_end + 1 <= line('$')
    let next_line = getline(region_end + 1)
    let match_found = 0
    for line in after_fmt
      if next_line == line
        let region_end += 1
        let match_found = 1
        break
      endif
    endfor

    if ! match_found
      break
    endif
  endwhile

  return [region_start, table_start, table_end, region_end]
endfunction

function! s:parse_plaintext_region(table_start, table_end) " -> Dictionary
  " return table data structure parsed from plaintext lines
  "
  " Dictionary has keys:
  "   column_widths List[Number, ...]
  "   table         [...]

  let stbegin        = 0  " !TBEGIN -> stwidth
  let stwidth        = 1  " \n -> strowfirst
  let strowfirst     = 2  " !TROW -> strownumfirst
  let strownumfirst  = 3  " >0 -> strcellfirst ; -> strcell
  let stcellfirst    = 4  " !TCELL -> strcellhdrfirst
  let stcellhdrfirst = 5  " \n -> strcelltxtfirst
  let stcelltxtfirst = 6  " ^!TCELL -> stcellfirst ; ^!TROW -> strow ; ^!TEND -> stdone
  let strow          = 7  " !TROW -> strownum
  let strownum       = 8  " -> strcell
  let stcell         = 9  " !TCELL -> strhdr
  let stcellhdr      = 10 " \n -> stcelltxt
  let stcelltxt      = 11 " ^!TCELL -> stcell ; ^!TROW -> strow ; ^!TEND -> stdone
  let stdone         = 12

  let column_widths = []
  let table = []
  let word_buf = []

  let state = stbegin
  for linenr in range(a:table_start, a:table_end)
    let line = getline(linenr)
    let split_line = split(line)
    let first_word = empty(line) ? '' : split_line[0]

    if state == stwidth && empty(line)
      let state = strowfirst

    elseif state == stcellhdrfirst && empty(line)
      call add(table[0], [join(word_buf, ' ')])
      let state = stcelltxtfirst
      let word_buf = []

    elseif state == stcelltxtfirst && first_word == "!TCELL"
      let state = stcellfirst

    elseif state == stcelltxtfirst && first_word == "!TROW"
      let state = strow

    elseif state == stcelltxtfirst && first_word == "!TEND"
      let state = stdone
      break

    elseif state == stcelltxtfirst
      call add(table[-1][-1], line)
      continue

    elseif state == stcellhdr && empty(line)
      let state = stcelltxt

    elseif state == stcelltxt && first_word == "!TCELL"
      let state = stcell

    elseif state == stcelltxt && first_word == "!TROW"
      let state = strow

    elseif state == stcelltxt && first_word == "!TEND"
      let state = stdone
      break

    elseif state == stcelltxt
      call add(table[-1][-1], line)
      continue
    endif

    for word in split_line
      let as_num = str2nr(word)
      if state == stbegin && word == "!TBEGIN"
        let state = stwidth

      elseif state == stwidth
        let min_width = s:min_column_width
        call add(column_widths, as_num > min_width ? as_num : min_width)

      elseif state == strowfirst && word == "!TROW"
        let state = strownumfirst

      elseif state == strownumfirst && as_num > 0
        let state = stcellfirst
        call add(table, [])
        call add(table, [])

      elseif state == strownumfirst
        let state = stcell
        call add(table, [])

      elseif state == stcellfirst && word == "!TCELL"
        let state = stcellhdrfirst
        let word_buf = []
        call add(table[-1], [])

      elseif state == stcellhdrfirst
        call add(word_buf, word)

      elseif state == strow && word == "!TROW"
        let state = strownum

      elseif state == strownum
        let state = stcell
        call add(table, [])

      elseif state == stcell && word == "!TCELL"
        let state = stcellhdr
        call add(table[-1], [])
      endif
    endfor
  endfor

  if state != stdone
    return {}
  endif

  for row in table
    for col_i in range(len(row))
      let cell = row[col_i]
      let paragraphs = []
      let len_cell = len(cell)
      for line_i in range(len_cell)
        let line = cell[line_i]
        if empty(line) && empty(paragraphs)
          continue
        elseif empty(line) && line_i + 1 == len_cell
        elseif empty(line)
          call add(paragraphs, '')
        elseif empty(paragraphs)
          call add(paragraphs, line)
        elseif empty(paragraphs[-1])
          call add(paragraphs, line)
        else
          let paragraphs[-1] ..= ' ' .. line
        endif
      endfor

      let row[col_i] = paragraphs
    endfor
  endfor

  return {'column_widths': column_widths, 'table': table}
endfunction

function! s:plaintext_at_cursor_to_table()
  " converts the plaintext at the cursor to its table equivalent
  " parsing states
  let range = s:plaintext_range_at_cursor()
  if empty(range)
    return
  endif

  let [region_start, table_start, table_end, region_end] = range
  let parsed = s:parse_plaintext_region(table_start, table_end)
  if empty(parsed)
    return
  endif

  let formatter = s:create_bare_table_formatter(parsed.column_widths)
  for row in parsed.table
    call map(row, "formatter.wrap_column(v:val, v:key)")
  endfor

  let lines = formatter.format_rows(parsed.table)
  call deletebufline(bufnr(), region_start, region_end)
  call append(region_start - 1, lines)
  call setcursorcharpos(region_start, 0)
endfunction

function! s:fancy_table_at_cursor()
  " converts table at cursor to a fancy table
  let [cur_linenr, cur_colnr] = s:cursor_pos()
  let formatter = s:create_table_formatter(cur_linenr, cur_colnr)
  if empty(formatter)
    return
  endif

  for linenr in range(formatter.first_sep, formatter.last_sep)
    let line = getline(linenr)
    if linenr == formatter.first_sep
      execute string(linenr)..'s/^|/┌/'
      execute string(linenr)..'s/|$/┐/'
      execute string(linenr)..'s/|/┬/g'
      execute string(linenr)..'s/-/─/g'
    elseif linenr == formatter.last_sep
      execute string(linenr)..'s/^|/└/'
      execute string(linenr)..'s/|$/┘/'
      execute string(linenr)..'s/|/┴/g'
      execute string(linenr)..'s/-/─/g'
    elseif s:matches(line, s:table_sep_pattern)
      execute string(linenr)..'s/^|/├/'
      execute string(linenr)..'s/|$/┤/'
      execute string(linenr)..'s/|/┼/g'
      execute string(linenr)..'s/-/─/g'
    else
      execute string(linenr)..'s/|/│/g'
    endif
  endfor

  call setcursorcharpos(cur_linenr, cur_colnr)
endfunction

function! s:unfancy_table_at_cursor()
  " converts a fancy table back to a regular table
  let [cur_linenr, cur_colnr] = s:cursor_pos()

  let table_start = search('^┌[─┬]\+┐$', 'bn')
  let table_end   = search('^└[─┴]\+┘$', 'n')
  if table_start == 0 || table_end == 0
    return
  elseif table_start >= table_end
    return
  endif

  for linenr in range(table_start, table_end)
    let line = getline(linenr)
    if linenr == table_start
      execute string(linenr)..'s/┌/|/'
      execute string(linenr)..'s/┐/|/'
      execute string(linenr)..'s/┬/|/g'
      execute string(linenr)..'s/─/-/g'
    elseif linenr == table_end
      execute string(linenr)..'s/└/|/'
      execute string(linenr)..'s/┘/|/'
      execute string(linenr)..'s/┴/|/g'
      execute string(linenr)..'s/─/-/g'
    elseif s:matches(line, '^├[─┼]\+┤$')
      execute string(linenr)..'s/├/|/'
      execute string(linenr)..'s/┤/|/'
      execute string(linenr)..'s/┼/|/g'
      execute string(linenr)..'s/─/-/g'
    else
      execute string(linenr)..'s/│/|/g'
    endif
  endfor

  call setcursorcharpos(cur_linenr, cur_colnr)
endfunction

" ============
" Autocommands
" ============

function! s:au_table_mode_enable()
  augroup table_edit
    autocmd!
    autocmd InsertEnter <buffer> call <SID>au_insert_enter()
    autocmd InsertLeave <buffer> call <SID>au_insert_leave()
  augroup END

  call s:key_mappings()
  call s:leader_key_mappings()
  call s:text_object_key_mappings()
  call s:nav_key_mappings()
  call s:commands()
endfunction

function! s:au_table_mode_disable()
  augroup table_edit
    autocmd!
  augroup END

  call s:no_key_mappings()
  call s:no_leader_key_mappings()
  call s:no_text_object_key_mappings()
  call s:no_nav_key_mappings()
  call s:no_commands()
endfunction

augroup table_mode
  autocmd!
  autocmd User TableModeEnable call <SID>au_table_mode_enable()
  autocmd User TableModeDisable call <SID>au_table_mode_disable()
augroup END

" ========
" Mappings
" ========

" TODO add some documentation, since the customisation section points here

nnoremap <silent> <Plug>(TableMake) <CMD>call <SID>plug_make()<CR>
nnoremap <silent> <Plug>(TableNextCell) <CMD>call <SID>plug_next_cell()<CR>
nnoremap <silent> <Plug>(TablePrevCell) <CMD>call <SID>plug_prev_cell()<CR>
nnoremap <silent> <Plug>(TableThisCell) <CMD>call <SID>plug_this_cell()<CR>
nnoremap <silent> <Plug>(TableSplitLine) <CMD>call <SID>plug_split_line()<CR>
nnoremap <silent> <Plug>(TableJoinLine) <CMD>call <SID>plug_join_line()<CR>
nnoremap <silent> <Plug>(TableCellInsert) <CMD>call <SID>plug_cell_insert()<CR>
nnoremap <silent> <Plug>(TableSelectCell) <CMD>call <SID>plug_select_cell()<CR>
vnoremap <silent> <Plug>(VTableSelectCell) :<C-U>call <SID>plug_select_cell()<CR>
onoremap <silent> <Plug>(OTableSelectCell) :<C-U>call <SID>plug_select_cell()<CR>
nnoremap <silent> <Plug>(TableSelectCol) <CMD>call <SID>plug_select_col()<CR>
vnoremap <silent> <Plug>(VTableSelectCol) :<C-U>call <SID>plug_select_col()<CR>
onoremap <silent> <Plug>(OTableSelectCol) :<C-U>call <SID>plug_select_col()<CR>
nnoremap <silent> <Plug>(TableSelectRow) <CMD>call <SID>plug_select_row()<CR>
vnoremap <silent> <Plug>(VTableSelectRow) :<C-U>call <SID>plug_select_row()<CR>
onoremap <silent> <Plug>(OTableSelectRow) :<C-U>call <SID>plug_select_row()<CR>
nnoremap <silent> <Plug>(TableLeftCell) <CMD>call <SID>plug_left_cell()<CR>
nnoremap <silent> <Plug>(TableRightCell) <CMD>call <SID>plug_right_cell()<CR>
nnoremap <silent> <Plug>(TableDownCell) <CMD>call <SID>plug_down_cell()<CR>
nnoremap <silent> <Plug>(TableUpCell) <CMD>call <SID>plug_up_cell()<CR>
nnoremap <silent> <Plug>(TableNextParagraph) <CMD>call <SID>plug_next_paragraph()<CR>
nnoremap <silent> <Plug>(TablePrevParagraph) <CMD>call <SID>plug_prev_paragraph()<CR>
nnoremap <silent> <Plug>(TableOpenAbove) <CMD>call <SID>plug_open_above()<CR>
nnoremap <silent> <Plug>(TableOpenBelow) <CMD>call <SID>plug_open_below()<CR>
nnoremap <silent> <Plug>(TableInsertRowAbove) <CMD>call <SID>plug_insert_row_above()<CR>
nnoremap <silent> <Plug>(TableInsertRowBelow) <CMD>call <SID>plug_insert_row_below()<CR>
nnoremap <silent> <Plug>(TableLineInsert) <CMD>call <SID>plug_line_insert()<CR>
nnoremap <silent> <Plug>(TableLineAppend) <CMD>call <SID>plug_line_append()<CR>
nnoremap <silent> <Plug>(TableBegin) <CMD>call <SID>plug_table_begin()<CR>
nnoremap <silent> <Plug>(TableEnd) <CMD>call <SID>plug_table_end()<CR>

function! s:key_mappings()
  inoremap <buffer> <silent> <expr> <CR> <SID>imap_return()
  inoremap <buffer> <silent> <expr> <Tab> <SID>imap_tab()
  inoremap <buffer> <silent> <expr> <S-Tab> <SID>imap_stab()
  inoremap <buffer> <silent> <expr> <BS> <SID>imap_backspace()
  inoremap <buffer> <silent> <expr> <Space> <SID>imap_space()
  nnoremap <buffer> <silent> <expr> { <SID>nmap_left_curly()
  nnoremap <buffer> <silent> <expr> } <SID>nmap_right_curly()
  nnoremap <buffer> <silent> <expr> o <SID>nmap_o()
  nnoremap <buffer> <silent> <expr> O <SID>nmap_O()
  nnoremap <buffer> <silent> <expr> I <SID>nmap_I()
  nnoremap <buffer> <silent> <expr> A <SID>nmap_A()
  nnoremap <buffer> <silent> [{ <Plug>(TableBegin)
  nnoremap <buffer> <silent> ]} <Plug>(TableEnd)
  inoremap <buffer> <silent> <expr> <C-w> <SID>imap_ctrl_w()
endfunction

function! s:no_key_mappings()
  iunmap <buffer> <CR>
  iunmap <buffer> <Tab>
  iunmap <buffer> <S-Tab>
  iunmap <buffer> <BS>
  iunmap <buffer> <Space>
  nunmap <buffer> {
  nunmap <buffer> }
  nunmap <buffer> o
  nunmap <buffer> O
  nunmap <buffer> I
  nunmap <buffer> A
  nunmap <buffer> [{
  nunmap <buffer> ]}
  iunmap <buffer> <C-w>
endfunction

function! s:leader_key_mappings()
  if ! get(g:, "table_inhibit_leader_keys", 0)
    nnoremap <buffer> <silent> <Leader>tt <CMD>FormatTable<CR>
    nnoremap <buffer> <silent> <Leader>ti <Plug>(TableCellInsert)
    nnoremap <buffer> <silent> <Leader>tr <CMD>ResizeTableColumn<CR>
  endif
endfunction

function! s:no_leader_key_mappings()
  if ! get(g:, "table_inhibit_leader_keys", 0)
    nunmap <buffer> <Leader>tt
    nunmap <buffer> <Leader>ti
    nunmap <buffer> <Leader>tr
  endif
endfunction

function! s:text_object_key_mappings()
  if ! get(g:, "table_inhibit_text_objects", 0)
    nnoremap <buffer> <silent> <Leader>tc <Plug>(TableSelectCell)
    vnoremap <buffer> <silent> <Leader>tc <Plug>(VTableSelectCell)
    onoremap <buffer> <silent> <Leader>tc <Plug>(OTableSelectCell)
    nnoremap <buffer> <silent> <Leader>tC <Plug>(TableSelectCol)
    vnoremap <buffer> <silent> <Leader>tC <Plug>(VTableSelectCol)
    onoremap <buffer> <silent> <Leader>tC <Plug>(OTableSelectCol)
    nnoremap <buffer> <silent> <Leader>tR <Plug>(TableSelectRow)
    vnoremap <buffer> <silent> <Leader>tR <Plug>(VTableSelectRow)
    onoremap <buffer> <silent> <Leader>tR <Plug>(OTableSelectRow)
  endif
endfunction

function! s:no_text_object_key_mappings()
  if ! get(g:, "table_inhibit_text_objects", 0)
    nunmap <buffer> <Leader>tc
    vunmap <buffer> <Leader>tc
    ounmap <buffer> <Leader>tc
    nunmap <buffer> <Leader>tC
    vunmap <buffer> <Leader>tC
    ounmap <buffer> <Leader>tC
    nunmap <buffer> <Leader>tR
    vunmap <buffer> <Leader>tR
    ounmap <buffer> <Leader>tR
  endif
endfunction

function! s:nav_key_mappings()
  if ! get(g:, "table_inhibit_navigation_keys", 0)
    nnoremap <buffer> <silent> H <Plug>(TableLeftCell)
    nnoremap <buffer> <silent> L <Plug>(TableRightCell)
    nnoremap <buffer> <silent> J <Plug>(TableDownCell)
    nnoremap <buffer> <silent> K <Plug>(TableUpCell)
  endif
endfunction

function! s:no_nav_key_mappings()
  if ! get(g:, "table_inhibit_navigation_keys", 0)
    nunmap <buffer> H
    nunmap <buffer> L
    nunmap <buffer> J
    nunmap <buffer> K
  endif
endfunction

if ! get(g:, "table_inhibit_mode_toggle_key", 0)
  nnoremap <silent> t<CR> <CMD>TableMode<CR>
endif

" ========
" Commands
" ========

function! s:commands()
  command! -buffer FormatTable call <SID>format_table_at_cursor()
  command! -buffer -nargs=? ResizeTableColumn call <SID>resize_table_at_cursor(<args>)
  command! -buffer InsertRow call <SID>insert_row_at_cursor()
  command! -buffer -nargs=1 InsertColumn call <SID>insert_col_at_cursor(<args>)

  " TODO consider these commands as extensions
  command! -buffer TableToPlain call <SID>table_at_cursor_to_plaintext()
  command! -buffer PlainToTable call <SID>plaintext_at_cursor_to_table()
  command! -buffer -bang FancyTable
        \ if empty(<q-bang>)                    |
        \   call <SID>fancy_table_at_cursor()   |
        \ else                                  |
        \   call <SID>unfancy_table_at_cursor() |
        \ endif
endfunction

function! s:no_commands()
  delcommand -buffer FormatTable
  delcommand -buffer ResizeTableColumn
  delcommand -buffer InsertRow
  delcommand -buffer InsertColumn
  delcommand -buffer TableToPlain
  delcommand -buffer PlainToTable
  delcommand -buffer FancyTable
endfunction

command! TableMode call <SID>table_mode_toggle()

" ==========
" Extensions
" ==========

" TableExposeVariable(variable_name)
"   use for extending this script
"   return the value of an internal script variable
function! TableExposeVariable(variable_name) "-> variable
  if !has_key(s:, a:variable_name)
    echoerr "Unknown key '" .. a:variable_name .. "'"
    return 0
  endif
  return get(s:, a:variable_name)
endfunction

" TableExposeFunction(function_name)
"   use for extending this script
"   return a funcref to an internal script function
function! TableExposeFunction(function_name) "-> funcref
  let Funcref = function("s:" .. a:function_name)
  if Funcref == 0
    echoerr "Unknown function '" .. a:function_name .. "'"
    return  0
  endif
  return Funcref
endfunction

" TableIsCursorInTable()
"   return non-zero if cursor is located in a table
"
"   useful for creating mappings that do different things inside a table and
"   outside the table, or if a mapping in this script conflicts with another
"   plugin
function! TableIsCursorInTable()
  return s:matches(getline('.'), s:table_pattern)
endfunction

