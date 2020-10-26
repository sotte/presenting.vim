" presenting.vim - presentation for vim

let g:presenting_statusline = get(g:, 'presenting_statusline', '%{b:presenting_page_current}/%{b:presenting_page_total}')
let g:presenting_top_margin = get(g:, 'presenting_top_margin', 0)
let g:presenting_next = get(g:, 'presenting_next', 'n')
let g:presenting_prev = get(g:, 'presenting_prev', 'p')
let g:presenting_quit = get(g:, 'presenting_quit', 'q')

let g:presenting_figlets = get(g:, 'presenting_figlets', 1)
let g:presenting_font_large = get(g:, 'presenting_font_large', 'standard')
let g:presenting_font_small = get(g:, 'presenting_font_small', 'small')

let s:presenting_id = 0

let s:showtabline = &showtabline
augroup PresentingToggleTabline
  autocmd!
  autocmd BufEnter _SHOW_*_ set showtabline=0
  autocmd BufLeave _SHOW_*_ let &showtabline=s:showtabline
augroup END

command! StartPresenting call s:Start()
command! PresentingStart call s:Start()

" Main logic / start the presentation {{{1
function! s:Start()

  " Prevent vimwiki taking control of the presentation's syntax highlighting.
  let l:filetype = (&filetype == 'vimwiki') ? 'markdown' : &filetype

  " make sure we can parse the current filetype
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

  let l:pages = s:Format(l:pages, l:filetype)

  let s:presenting_id += 1
  execute 'silent tabedit _SHOW_'.s:presenting_id.'_'
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
  setlocal signcolumn=no

  if globpath(&rtp, 'syntax/presenting_'.l:filetype.'.vim') == ''
    let &filetype=l:filetype
  else
    let &filetype='presenting_'.l:filetype
  endif

  call s:ShowPage(0)

  " commands and mappings for navigation
  command! -buffer -count=1 PresentingNext call s:NextPage(<count>)
  command! -buffer -count=1 PresentingPrev call s:PrevPage(<count>)
  command! -buffer PresentingExit call s:Exit()

  " Remap <Esc>[ to itself to prevent bad behavior when, for example, <Esc> is used
  " for Quit and arrow keys are used for Next/Prev.
  " See https://stackoverflow.com/a/20458579/510067 for an explanation.
  nnoremap <buffer> <silent> <Esc>[ <Esc>[

  execute 'nnoremap <buffer> <silent> ' . g:presenting_next . ' :PresentingNext<CR>'
  execute 'nnoremap <buffer> <silent> ' . g:presenting_prev . ' :PresentingPrev<CR>'
  execute 'nnoremap <buffer> <silent> ' . g:presenting_quit . ' :PresentingExit<CR>'
endfunction

" Functions for Navigation {{{1
function! s:ShowPage(page_no)
  if a:page_no < 0 || a:page_no >= len(b:pages)
    return
  endif
  let b:page_number = a:page_no
  call s:UpdateStatusLine()

  " replace content of buffer with the next page
  setlocal noreadonly modifiable
  " avoid "--No lines in buffer--" msg by using silent
  silent %delete _
  call append(0, b:pages[b:page_number])
  call append(0, map(range(1,g:presenting_top_margin), '""'))
  normal! gg
  call append(line('$'), map(range(1,winheight('%')-(line('w$')-line('w0')+1)), '""'))
  setlocal readonly nomodifiable
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

" Parsing & Formatting {{{1
function! s:Parse()
  let l:sep = exists('b:presenting_slide_separator') ? b:presenting_slide_separator : b:presenting_slide_separator_default
  return map(split(join(getline(1, '$'), "\n"), l:sep), 'split(v:val, "\n")')
endfunction

function! s:Format(pages, filetype)
  let state = {}

  try
    for i in range(0,len(a:pages)-1)
      let replacement_page = []
      for j in range(0, len(a:pages[i])-1)

        " The {a:filetype}#format() autoload function processes one line of
        " text at a time. All implementations must have the function signature.
        " Args:
        " text (string): This is the current line of text being formatted.
        " last_line (boolean): Flag to indicate if this is the last line of
        "     text on the slide
        " state (dictionary): Some lines may depend on a prior line, such as
        "     numbering and indenting numbered lists. This state information
        "     is passed into {a:filetyepe}#format() through this variable.
        "     The function will use it however it needs to. s:Format() doesn't
        "     care how it's used, but must keep the state variable intact for
        "     each successive call to the autoload function.
        let [new_text, state] = {a:filetype}#format(a:pages[i][j], j == len(a:pages[i])-1, state)
        let replacement_page += new_text
      endfor
      let a:pages[i] = replacement_page
    endfor
  catch /E117/
    " No autoload function. Slide show will have no formatting.
  endtry
  return a:pages
endfunction

" }}}
" vim:ts=2:sw=2:expandtab:foldmethod=marker
