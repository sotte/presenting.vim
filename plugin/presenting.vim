" presenting.vim - presentation for vim

au FileType markdown let b:presenting_slide_separator = '\v(^|\n)\ze#+'
au FileType mkd      let b:presenting_slide_separator = '\v(^|\n)\ze#+'
au FileType org      let b:presenting_slide_separator = '\v(^|\n)#-{4,}'
au FileType rst      let b:presenting_slide_separator = '\v(^|\n)\~{4,}'

if !exists('b:presenting_vim_using')
    let b:presenting_vim_using = 0
endif

" Main logic / start the presentation {{{
command! StartPresenting call s:Start()
function! s:Start()

    if b:presenting_vim_using == 1
        echo "presenting.vim is running. please quit either presentation."
        return
    endif

    let s:page_number = 0
    let s:max_page_number = 0
    let s:pages = []
    let s:filetype = &filetype

    " make sure we can parse the filetype"
    if !exists('b:presenting_slide_separator')
      echom "set b:presenting_slide_separator for \"" . &filetype . "\" filetype to enable Presenting.vim"
      return
    endif

    " actually parse the document into pages
    call s:Parse()

    if empty(s:pages)
        echo "No page detected!"
        return
    endif
    let b:presenting_vim_using = 1

    tabedit _SLIDE_
    call s:ShowPage(0)
    let &filetype=s:filetype
    setlocal statusline=%<

    " commands for the navigation
    command! -buffer PageNext call s:NextPage()
    command! -buffer PagePrev call s:PrevPage()
    command! -buffer ExitPresent call s:Exit()

    " mappings for the navigation
    nnoremap <buffer> <silent> n :PageNext<CR>
    nnoremap <buffer> <silent> p :PagePrev<CR>
    nnoremap <buffer> <silent> q :ExitPresent<CR>

    autocmd BufWinLeave <buffer> call s:Exit()
endfunction
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
    execute ":normal! G$vggd"
    call append(0, s:pages[s:page_number])

    " some options for the buffer
    setlocal readonly
    setlocal nomodifiable
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal nocursorcolumn
    setlocal nocursorline
    setlocal cmdheight=1
    setlocal statusline=%<

    " move cursor to the top
    execute ":normal! gg"
endfunction

function! s:NextPage()
    if s:page_number+1 <= s:max_page_number
        let s:page_number += 1
        call s:ShowPage(s:page_number)
    endif
endfunction

function! s:PrevPage()
    if s:page_number-1 >= 0
        let s:page_number -= 1
        call s:ShowPage(s:page_number)
    endif
endfunction

function! s:Exit()
       if b:presenting_vim_using == 1
           let b:presenting_vim_using = 0
           bdelete! _SLIDE_
       endif
endfunction
" Functions for Navigation }}}
" Parsing {{{
function! s:Parse()
    " filetype specific separator
    let s:pages = map(split(join(getline(1, '$'), "\n"), b:presenting_slide_separator), 'split(v:val, "\n")')
    let s:max_page_number = len(s:pages) - 1
endfunction
" }}}
