" presenting.vim - presentation for vim

au FileType markdown let s:presenting_slide_separator = '\v(^|\n)\ze#{1,2}[^#]'
au FileType mkd      let s:presenting_slide_separator = '\v(^|\n)\ze#+'
au FileType org      let s:presenting_slide_separator = '\v(^|\n)#-{4,}'
au FileType rst      let s:presenting_slide_separator = '\v(^|\n)\~{4,}'
au FileType slide    let s:presenting_slide_separator = '\v(^|\n)\ze\*'

let g:presenting_statusline = get(g:, 'presenting_statusline', '%{b:presenting_page_current}/%{b:presenting_page_total}')
let g:presenting_top_margin = get(g:, 'presenting_top_margin', 0)
let g:presenting_next = get(g:, 'presenting_next', 'n')
let g:presenting_prev = get(g:, 'presenting_prev', 'p')
let g:presenting_quit = get(g:, 'presenting_quit', 'q')

" Main logic / start the presentation {{{
function! s:Start()
  if exists('g:presenting_vim_running')
    echo "presenting.vim is already running. Please quit either presentation."
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
  call s:Format()

  if empty(s:pages)
    echo "No page detected!"
    return
  endif
  let g:presenting_vim_running = 1

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
  execute 'nnoremap <buffer> <silent> ' . g:presenting_next . ' :PresentingNext<CR>'
  execute 'nnoremap <buffer> <silent> ' . g:presenting_prev . ' :PresentingPrev<CR>'
  execute 'nnoremap <buffer> <silent> ' . g:presenting_quit . ' :PresentingExit<CR>'

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
  call append(0, map(range(1,g:presenting_top_margin), '""'))
  execute ":normal! gg"
  call append(line('$'), map(range(1,winheight('%')-(line('w$')-line('w0')+1)), '""'))

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
  setlocal wrap
  setlocal linebreak
  setlocal breakindent
  setlocal nolist
  let s:showtabline = &showtabline
  set showtabline=0
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
  if exists('g:presenting_vim_running')
    unlet g:presenting_vim_running
    bdelete! _SLIDE_
    let &showtabline = s:showtabline
  endif
endfunction

function! s:UpdateStatusLine()
  let b:presenting_page_current = s:page_number + 1
  let b:presenting_page_total = len(s:pages)
  let &l:statusline = g:presenting_statusline
endfunction

" Functions for Navigation }}}

" Parsing & Formatting {{{
function! s:Parse()
  " filetype specific separator
  let l:sep = exists('b:presenting_slide_separator') ? b:presenting_slide_separator : s:presenting_slide_separator
  let s:pages = map(split(join(getline(1, '$'), "\n"), l:sep), 'split(v:val, "\n")')
  let s:max_page_number = len(s:pages) - 1
endfunction

function! s:Format()
  " The {s:filetype}#format() autoload function processes one line of
  " text at a time. Some lines may depend on a prior line, such as
  " numbering and indenting numbered lists. This state information is
  " passed into {s:filetyepe}#format() through the state Dictionary
  " variable. The function will use it however it needs to. s:Format()
  " doesn't care how it's used, but must keep the state variable intact
  " for each successive call to the autoload function.
  let state = {}

  try
    for i in range(0,len(s:pages)-1)
      let replacement_page = []
      for j in range(0, len(s:pages[i])-1)
        let [new_text, state] = {s:filetype}#format(s:pages[i][j], state)
        let replacement_page += new_text
      endfor
      let s:pages[i] = replacement_page
    endfor
  catch /E117/
    echo 'Auto load function '.s:filetype.'#format(text, state) does not exist.'
  endtry
endfunction

" }}}
" vim:ts=2:sw=2:expandtab:foldmethod=marker
