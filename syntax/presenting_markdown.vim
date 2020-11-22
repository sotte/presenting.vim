runtime! syntax/markdown.vim

setlocal conceallevel=3 concealcursor=nvic

syntax match presentingHeadingMarker /^«h[1-4]»/ conceal
syntax match presentingH1 /^«h1».*/ contains=presentingHeadingMarker
syntax match presentingH2 /^«h2».*/ contains=presentingHeadingMarker
syntax match presentingH3 /^«h3».*/ contains=presentingHeadingMarker
syntax match presentingH4 /^«h4».*/ contains=presentingHeadingMarker
highlight default link presentingH1 markdownH1
highlight default link presentingH2 markdownH2
highlight default link presentingH3 markdownH3
highlight default link presentingH4 markdownH4

syntax match presentingOrderedListMarker /^\s*\d\+\./
syntax match presentingListMarker /^\s*•/
syntax match presentingCheckboxMarker /^\s*[■□]/
highlight default link presentingOrderedListMarker markdownOrderedListMarker
highlight default link presentingListMarker markdownListMarker
highlight default link presentingCheckboxMarker markdownListMarker

syntax match presentingCodeDelimiter /[▄▀]/ containedin=markdownCodeBlock
highlight default link presentingCodeDelimiter markdownCodeDelimiter

syntax match presentingBlockQuote /▐/
highlight default link presentingBlockQuote markdownBlockquote

syntax match presentingTableEdges /[┃━┏┓┗┛┳┻┣╋┫]/ containedin=markdownCodeBlock
syntax match presentingTableHeaderMarker /^«th»/ conceal
syntax match presentingTableRowMarker /^«tr»/ conceal
syntax match presentingTableHeader /^«th».*$/ contains=presentingTableEdges,presentingTableHeaderMarker
syntax match presentingTableRow /^«tr».*$/ contains=presentingTableEdges,presentingTableRowMarker
highlight default link presentingTableEdges markdownRule
highlight default link presentingTableHeader markdownH1
highlight default link presentingTableRow Normal
