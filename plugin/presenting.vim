" presenting.vim - presentation for vim

au FileType markdown let s:presenting_slide_separator = '\v(^|\n)\ze#+'
au FileType mkd      let s:presenting_slide_separator = '\v(^|\n)\ze#+'
au FileType org      let s:presenting_slide_separator = '\v(^|\n)#-{4,}'
au FileType rst      let s:presenting_slide_separator = '\v(^|\n)\~{4,}'
au FileType slide    let s:presenting_slide_separator = '\v(^|\n)\ze\*'

if !exists('g:presenting_vim_using')
  let g:presenting_vim_using = 0
endif

if !exists('g:presenting_statusline')
  let g:presenting_statusline =
    \ '%{b:presenting_page_current}/%{b:presenting_page_total}'
endif

" Main logic / start the presentation {{{
function! s:Start()
  if g:presenting_vim_using == 1
    echo "presenting.vim is running. please quit either presentation."
    return
  endif

  " make sure we can parse the current filetype
  let s:filetype = &filetype
  if !exists('b:presenting_slide_separator') && !exists('s:presenting_slide_separator')
    echom "set b:presenting_slide_separator for \"" . &filetype . "\" filetype to enable Presenting.vim"
    return
  endif

  " actually parse the document into pages
  let s:page_number = 0
  let s:max_page_number = 0
  let s:pages = []
  call s:Parse()

  if empty(s:pages)
    echo "No page detected!"
    return
  endif
  let g:presenting_vim_using = 1

  " avoid '"_SLIDE_" [New File]' msg by using silent
  silent tabedit _SLIDE_
  call s:ShowPage(0)
  let &filetype=s:filetype
  call s:UpdateStatusLine()

  " commands for the navigation
  command! -buffer -count=1 PresentingNext call s:NextPage(<count>)
  command! -buffer -count=1 PresentingPrev call s:PrevPage(<count>)
  command! -buffer PresentingExit call s:Exit()

  " mappings for the navigation
  nnoremap <buffer> <silent> n :PresentingNext<CR>
  nnoremap <buffer> <silent> p :PresentingPrev<CR>
  nnoremap <buffer> <silent> q :PresentingExit<CR>

  autocmd BufWinLeave <buffer> call s:Exit()
endfunction

command! StartPresenting call s:Start()
command! PresentingStart call s:Start()
" }}}

" Functions for Navigation {{{
function! s:ShowPage(page_no)
  if a:page_no < 0
    return
  endif
  if len(s:pages) < a:page_no+1
    return
  endif
  let s:page_number = a:page_no

  " replace content of buffer with the next page
  setlocal noreadonly
  setlocal modifiable
  " avoid "--No lines in buffer--" msg by using silent
  silent %delete _
  call append(0, s:pages[s:page_number])

  " some options for the buffer
  setlocal buftype=nofile
  setlocal cmdheight=1
  setlocal nocursorcolumn
  setlocal nocursorline
  setlocal nofoldenable
  setlocal nomodifiable
  setlocal nonumber
  setlocal norelativenumber
  setlocal noswapfile
  setlocal readonly
  call s:UpdateStatusLine()

  " move cursor to the top
  execute ":normal! gg"
endfunction

function! s:NextPage(count)
  let s:page_number += a:count
  if s:page_number > s:max_page_number
    let s:page_number = s:max_page_number
  endif
  call s:ShowPage(s:page_number)
endfunction

function! s:PrevPage(count)
  let s:page_number -= a:count
  if s:page_number < 0
    let s:page_number = 0
  endif
  call s:ShowPage(s:page_number)
endfunction

function! s:Exit()
  if g:presenting_vim_using == 1
    let g:presenting_vim_using = 0
    bdelete! _SLIDE_
  endif
endfunction

function! s:UpdateStatusLine()
  let b:presenting_page_current = s:page_number + 1
  let b:presenting_page_total = len(s:pages)
  let &l:statusline = g:presenting_statusline
endfunction

" Functions for Navigation }}}

" Parsing {{{
function! s:Parse()
  " filetype specific separator
  let l:sep = exists('b:presenting_slide_separator') ? b:presenting_slide_separator : s:presenting_slide_separator
  let s:pages = map(split(join(getline(1, '$'), "\n"), l:sep), 'split(v:val, "\n")')
  let s:max_page_number = len(s:pages) - 1
endfunction
" }}}
" vim:ts=2:sw=2:expandtab
