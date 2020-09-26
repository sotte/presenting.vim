" These autoload modules perform custom formatting for the different
" filetypes. (This particular one is for markdown files.) These modules
" must implement the ...#format() function. See the comment in
" plugin/presenting.vim's s:Format() function for details.
"
" The ...#set_filetype() function can optionally be implemented here as well.
" Its purpose is to set the filetype of the slide show buffer. If not
" implemented, the filetype of the original file (markdown in this case) will
" be used.


function! markdown#set_filetype()
  set filetype=presenting_markdown
endfunction

function! markdown#format(text, state)
  let l:state = s:InitializeState(a:state)

  if a:text =~? '^\s*```' " Wrap code blocks with a horzontal line
    let l:state.in_code_block = !l:state.in_code_block
    let new_text = ['    '.repeat('━', winwidth(0)-8)]

  elseif l:state.in_code_block " Indent code block contents
    let new_text = ['    '.a:text]

  elseif a:text =~? '^[*-] \[ \]' " Unchecked Box
    let new_text = [substitute(a:text,  '^[*-] \[ \]', '☐', '')]

  elseif a:text =~? '^[*-] \[x\]' " Checked Box
    let new_text = [substitute(a:text,  '^[*-] \[x\]', '☑︎', '')]

  elseif a:text =~? '^\s*[*-]' " Bulleted Lists
    let new_text = [substitute(a:text, '^\s*\zs[*-] ', '∙ ', '')]

  elseif a:text =~? '^\s*\d\+\.' " Numbered Lists
    if match(a:text, '\s*\zs\d\+\.') > l:state.indent
      let l:state.bullet_nums += [0]
    elseif match(a:text, '\s*\zs\d\+\.') < l:state.indent
      let l:state.bullet_nums = l:state.bullet_nums[0:-2]
    endif
    let l:state.indent = match(a:text, '\s*\zs\d\+\.')
    let l:state.bullet_nums[-1] += 1
    let new_text = [substitute(a:text, '^\s*\zs\d\+', l:state.bullet_nums[-1], '')]

  elseif a:text =~? '^#\{1,3}\ze[^#]' && g:presenting_figlets  && executable('figlet') " Replace h1, h2 and h3 text with figlets
    let font = a:text =~? '^##' ? g:presenting_font_small : g:presenting_font_large
    let new_text = split(system('figlet -w '.winwidth(0).' -f '.font.' '.shellescape(substitute(a:text,'^#\+s*','',''))), "\n")

    let w = max(map(copy(new_text), 'strchars(v:val)'))
    call map(new_text, 'repeat(" ",(winwidth(0)-w)/2).v:val')

  elseif a:text =~? '^#\{1,4}\ze[^#]' " Center h4 text (and h1-h3 if no figlets) on the window.
    let l:text = substitute(a:text,'^#\+s*','','')
    let new_text = [repeat(' ', (winwidth(0)-strchars(l:text))/2) . l:text]

  elseif a:text =~? '^\s*>' " Wrap and prefix quoted blocks.
    let new_text = []
    let l:text = substitute(a:text, '^\s*>\s*', '', '')
    while strchars(l:text) > winwidth(0) - 8
      let s = strridx(strcharpart(l:text,0,winwidth(0)-10),' ')
      let new_text += ['  ┃ '.strcharpart(l:text,0,s)]
      let l:text = strcharpart(l:text,s+1)
    endwhile
    let new_text += ['  ┃ '.l:text]

  else " Return the text as is.
    let new_text = [a:text]

  endif

  if a:text !~? '^\s*\d\+\.' " Reset bullet number
    let l:state.bullet_nums = [0]
  endif

  return [new_text, l:state]
endfunction

function! s:InitializeState(state)
  return extend(a:state, #{bullet_nums:[0], in_code_block:0, indent:0}, 'keep')
endfunction

" vim:ts=2:sw=2:expandtab
