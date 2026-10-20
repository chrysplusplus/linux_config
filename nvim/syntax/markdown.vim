" Vim syntax file
" Language:     markdown
" Maintainer:   chrysplusplus
" Filenames:    markdown syntax

if exists("b:current_syntax")
  finish
endif

syntax sync minlines=50 linebreaks=1
syntax case ignore
setlocal conceallevel=2

syntax match markdownLineStart "^" nextgroup=@markdownBlock

syntax cluster markdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownUL,markdownOL,markdownCodeBlock
syntax cluster markdownInline contains=markdownLineBreak,markdownImportant,markdownBold,markdownItalic

syntax match markdownH1 "^.\+\n=\+$" contained contains=markdownHeadingRule
syntax match markdownH2 "^.\+\n-\+$" contained contains=markdownHeadingRule

syntax match markdownHeadingRule "^[=-]\+$" contained

syntax region markdownH1 matchgroup=markdownH1Delimiter start=" \{,3}#\s"      end="#*\s*$" keepend display oneline contained
syntax region markdownH2 matchgroup=markdownH2Delimiter start=" \{,3}##\s"     end="#*\s*$" keepend display oneline contained
syntax region markdownH3 matchgroup=markdownH3Delimiter start=" \{,3}###\s"    end="#*\s*$" keepend display oneline contained
syntax region markdownH4 matchgroup=markdownH4Delimiter start=" \{,3}####\s"   end="#*\s*$" keepend display oneline contained
syntax region markdownH5 matchgroup=markdownH5Delimiter start=" \{,3}#####\s"  end="#*\s*$" keepend display oneline contained
syntax region markdownH6 matchgroup=markdownH6Delimiter start=" \{,3}######\s" end="#*\s*$" keepend display oneline contained

syntax match markdownLineBreak "<br>$" display contains=@NoSpell
syntax match markdownLineBreak "\\$" display
syntax match markdownLineBreak " \{2,}$" display

syntax match markdownUL "\%(\t\| \{0,4}\)[-*+] " display contained
syntax match markdownOL "\%(\t\| \{0,4}\)\<\d\+.\s\+" display contained

syntax match markdownLink "\\\@<!\[[^][]*\]([^][()]*)" display contains=markdownLinkText
syntax region markdownLinkText matchgroup=markdownLink start="\[" end="\]" nextgroup=markdownLinkURI keepend display contained concealends
syntax region markdownLinkURI matchgroup=markdownLink start="(" end=")" keepend display contained transparent conceal contains=@NoSpell

syntax region markdownItalic matchgroup=markdownHiddenDelimiter start="\*\S\@=" end="\S\@<=\*\|^$" skip="\\\*" contains=markdownLineStart,markdownEscaped concealends
syntax region markdownItalic matchgroup=markdownHiddenDelimiter start="\w\@<!_\S\@=" end="\S\@<=_\w\@!\|^$" skip="\\_" contains=markdownLineStart,markdownEscaped concealends
syntax region markdownBold matchgroup=markdownHiddenDelimiter start="\*\*\S\@=" end="\S\@<=\*\*\|^$" skip="\\\*" contains=markdownLineStart,markdownEscaped concealends
syntax region markdownBold matchgroup=markdownHiddenDelimiter start="\w\@<!__\S\@=" end="\S\@<=__\w\@!\|^$" skip="\\_" contains=markdownLineStart,markdownEscaped concealends
syntax region markdownImportant matchgroup=markdownHiddenDelimiter start="\*\*\*\S\@=" end="\S\@<=\*\*\*\|^$" skip="\\\*" contains=markdownLineStart,markdownEscaped concealends
syntax region markdownImportant matchgroup=markdownHiddenDelimiter start="\w\@<!___\S\@=" end="\S\@<=___\w\@!\|^$" skip="\\_" contains=markdownLineStart,markdownEscaped concealends
syntax region markdownCode matchgroup=markdownCodeDelimiter start="`\S\@=" end="\S\@<=`\|^$" skip="\\`" keepend concealends contains=markdownLineStart,markdownEscaped,@NoSpell

syntax match markdownDate "\<\%(\d\{4}\|\d\{2}\)-\d\d-\d\d\>" display

syntax match markdownHznRule "^\*\{3,}$" display
syntax match markdownHznRule "^-\{3,}$" display

syntax region markdownCodeBlock matchgroup=markdownCodeDelimiter start="^```$" end="^```$" keepend contains=@NoSpell

syntax region markdownYamlHeader matchgroup=markdownYamlHeader start="\%^---.*$" end="^\.\.\.\s*$" keepend contains=markdownDate,@NoSpell

syntax match markdownEscaped "\\[[*_`]" transparent contains=markdownEscapeDelimiter
syntax match markdownEscapeDelimiter "\\" transparent contained conceal

function! s:define_base_hl()
  highlight default markdownItalic     cterm=italic gui=italic
  highlight default markdownBold       cterm=bold gui=bold
  highlight default markdownImportant  cterm=bold,italic gui=bold,italic

  execute "highlight default markdownHeading"
        \ "ctermfg="..synIDattr(synIDtrans(hlID("Title")), "fg", "cterm")
        \ "cterm=bold"
        \ "guifg="..synIDattr(synIDtrans(hlID("Title")), "fg", "gui")
        \ "gui=bold"
endfunction

highlight default link markdownDelimiter Comment
highlight default link markdownLayout    Identifier
highlight default link markdownHidden    Comment
highlight default link markdownCode      PreProc
highlight default link markdownDate      PreProc

call s:define_base_hl()

highlight default link markdownH1                markdownHeading
highlight default link markdownH2                markdownHeading
highlight default link markdownH3                markdownHeading
highlight default link markdownH4                markdownHeading
highlight default link markdownH5                markdownHeading
highlight default link markdownH6                markdownHeading
highlight default link markdownHeadingRule       markdownDelimiter
highlight default link markdownHeadingDelimiter  markdownDelimiter
highlight default link markdownHznRule           markdownLayout
highlight default link markdownHiddenDelimiter   markdownHidden
highlight default link markdownYamlHeader        markdownHidden
highlight default link markdownLinkText          Underlined

highlight default link markdownH1Delimiter markdownHeadingDelimiter
highlight default link markdownH2Delimiter markdownHeadingDelimiter
highlight default link markdownH3Delimiter markdownHeadingDelimiter
highlight default link markdownH4Delimiter markdownHeadingDelimiter
highlight default link markdownH5Delimiter markdownHeadingDelimiter
highlight default link markdownH6Delimiter markdownHeadingDelimiter

highlight default link markdownCodeBlock     markdownCode
highlight default link markdownCodeDelimiter markdownCode
highlight default link markdownLineBreak     markdownDelimiter
highlight default link markdownUL            markdownLayout
highlight default link markdownOL            markdownLayout

augroup markdown
  autocmd!
  autocmd ColorScheme * call s:define_base_hl()
augroup END

let b:current_syntax = "markdown"

