" present.vim - presentation for vim

if !exists('g:presen_vim_using')
    let g:presen_vim_using = 0
endif

command! StartPresent call s:Start()

function! s:Start()

    if g:presen_vim_using == 1
        echo "present.vim is running. please quit either presentation."
        return
    endif

    let s:page_number = 0
    let s:max_page_number = 0
    let s:pages = []

    setl readonly
    call s:ParseRST()
    setl noreadonly

    if empty(s:pages)
        echo "No page detected!"
        return
    endif
    let g:presen_vim_using = 1

    tabe _Slide_
    setl readonly
    call s:ShowPage(0)

    setf rst

    command! -buffer PageNext call s:NextPage()
    command! -buffer PagePrev call s:PrevPage()
    command! -buffer ExitPresent call s:Exit()

    nnoremap <buffer> <silent> n :PageNext<CR>
    nnoremap <buffer> <silent> p :PagePrev<CR>
    nnoremap <buffer> <silent> q :ExitPresent<CR>

    autocmd BufWinLeave <buffer> call s:Exit()
endfunction

function! s:ShowPage(page_no)
    if a:page_no < 0
        return
    endif
    if len(s:pages) < a:page_no+1
        return
    endif
    let s:page_number = a:page_no
    setl noreadonly
    execute ":normal G$vggd"
    call append(0, s:pages[s:page_number])
    setl readonly
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
       if g:presen_vim_using == 1
           let g:presen_vim_using = 0
           bdelete! _Slide_
       endif
endfunction


function! s:ParseRST()
    let s:pages =  map(split(join(getline(1, '$'), "\n"), '\v(^|\n)\~{4,}'), 'split(v:val, "\n")')
    let s:max_page_number = len(s:pages) - 1
endfunction
