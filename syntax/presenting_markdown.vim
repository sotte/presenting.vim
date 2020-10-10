runtime! syntax/markdown.vim

setlocal conceallevel=3 concealcursor=nvic

syntax match presentingHeadingDelimiter /^#[1-4]/ conceal
syntax match presentingH1 /^#1.*/ contains=presentingHeadingDelimiter
syntax match presentingH2 /^#2.*/ contains=presentingHeadingDelimiter
syntax match presentingH3 /^#3.*/ contains=presentingHeadingDelimiter
syntax match presentingH4 /^#4.*/ contains=presentingHeadingDelimiter
syntax match presentingOrderedListMarker /^\s*\d\+\./
syntax match presentingListMarker /^\s*∙/
syntax match presentingCheckboxMarker /^\s*[■□]/
syntax match presentingCodeDelimiter /━/ containedin=markdownCodeBlock
syntax match presentingBlockQuote /┃/

highlight default link presentingH1 markdownH1
highlight default link presentingH2 markdownH2
highlight default link presentingH3 markdownH3
highlight default link presentingH4 markdownH4
highlight default link presentingOrderedListMarker markdownOrderedListMarker
highlight default link presentingListMarker markdownListMarker
highlight default link presentingCheckboxMarker markdownListMarker
highlight default link presentingCodeDelimiter markdownCodeDelimiter
highlight default link presentingBlockQuote markdownBlockquote
