" presenting.vim - presentation for vim

au FileType markdown let b:presenting_slide_separator_default = '\v(^|\n)\ze#+'
au FileType mkd      let b:presenting_slide_separator_default = '\v(^|\n)\ze#+'
au FileType org      let b:presenting_slide_separator_default = '\v(^|\n)#-{4,}'
au FileType rst      let b:presenting_slide_separator_default = '\v(^|\n)\~{4,}'
au FileType slide    let b:presenting_slide_separator_default = '\v(^|\n)\ze\*'

if !exists('g:presenting_statusline')
  let g:presenting_statusline =
    \ '%{b:presenting_page_current}/%{b:presenting_page_total}'
endif

if !exists('g:presenting_top_margin')
  let g:presenting_top_margin = 0
endif

" Main logic / start the presentation {{{
function! s:Start()
  " make sure we can parse the current filetype
  let l:filetype = &filetype
  if !exists('b:presenting_slide_separator') && !exists('b:presenting_slide_separator_default')
    echom "set b:presenting_slide_separator for \"" . l:filetype . "\" filetype to enable Presenting.vim"
    return
  endif

  " Parse the document into pages
  let l:pages = s:Parse()

  if empty(l:pages)
    echo "No page detected!"
    return
  endif

  " avoid '"_SLIDE_" [New File]' msg by using silent
  execute 'silent tabedit _SLIDE_'.localtime().'_'
  let b:pages = l:pages
  let b:page_number = 0
  let b:max_page_number = len(b:pages) - 1

  " some options for the buffer
  setlocal buftype=nofile
  setlocal cmdheight=1
  setlocal nocursorcolumn nocursorline
  setlocal nofoldenable
  setlocal nonumber norelativenumber
  setlocal noswapfile
  setlocal wrap
  setlocal linebreak
  setlocal breakindent
  setlocal nolist
  let &filetype=l:filetype

  call s:ShowPage(0)
  call s:UpdateStatusLine()

  " commands for the navigation
  command! -buffer -count=1 PresentingNext call s:NextPage(<count>)
  command! -buffer -count=1 PresentingPrev call s:PrevPage(<count>)
  command! -buffer PresentingExit call s:Exit()

  " mappings for the navigation
  nnoremap <buffer> <silent> n :PresentingNext<CR>
  nnoremap <buffer> <silent> p :PresentingPrev<CR>
  nnoremap <buffer> <silent> q :PresentingExit<CR>
endfunction

command! StartPresenting call s:Start()
command! PresentingStart call s:Start()
" }}}

" Functions for Navigation {{{
function! s:ShowPage(page_no)
  if a:page_no < 0 || a:page_no >= len(b:pages)
    return
  endif
  let b:page_number = a:page_no

  " replace content of buffer with the next page
  setlocal noreadonly modifiable
  " avoid "--No lines in buffer--" msg by using silent
  silent %delete _
  call append(0, b:pages[b:page_number])
  call append(0, map(range(1,g:presenting_top_margin), '""'))
  execute ":normal! gg"
  call append(line('$'), map(range(1,winheight('%')-(line('w$')-line('w0')+1)), '""'))
  setlocal readonly nomodifiable

  call s:UpdateStatusLine()

  " move cursor to the top
  execute ":normal! gg"
endfunction

function! s:NextPage(count)
  let b:page_number = min([b:page_number+a:count, b:max_page_number])
  call s:ShowPage(b:page_number)
endfunction

function! s:PrevPage(count)
  let b:page_number = max([b:page_number-a:count, 0])
  call s:ShowPage(b:page_number)
endfunction

function! s:Exit()
  bwipeout!
endfunction

function! s:UpdateStatusLine()
  let b:presenting_page_current = b:page_number + 1
  let b:presenting_page_total = len(b:pages)
  let &l:statusline = g:presenting_statusline
endfunction

" Functions for Navigation }}}

" Parsing {{{
function! s:Parse()
  let l:sep = exists('b:presenting_slide_separator') ? b:presenting_slide_separator : b:presenting_slide_separator_default
  return map(split(join(getline(1, '$'), "\n"), l:sep), 'split(v:val, "\n")')
endfunction
" }}}
" vim:ts=2:sw=2:expandtab
