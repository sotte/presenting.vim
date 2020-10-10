" These autoload modules perform custom formatting for the different
" filetypes. (This particular one is for markdown files.) These modules
" must implement the ...#format() function. See the comment in
" plugin/presenting.vim's s:Format() function for details.

function! markdown#format(text, state)
  " Initialize the state variable with defaults, if missing.
  let l:state = extend(a:state, {'in_comment':0, 'in_code':0, 'bullet_nums':[0], 'indent':0}, 'keep')

  if a:text =~? '<!--'    " Start of comment
    let new_text = substitute(a:text, '<!--.\{-}\($\|-->\)','','')
    let new_text = new_text == '' ? [] : new_text
    let l:state.in_comment = a:text !~? '-->'

  elseif a:text =~? '-->'    " End of comment
    let new_text = substitute(a:text, '.*-->','','')
    let new_text = new_text == '' ? [] : new_text
    let l:state.in_comment = 0

  elseif l:state.in_comment    " Full-line interior of comment
    let new_text = []

  elseif a:text =~? '^\s*```'    " Wrap code blocks with a horzontal line
    let l:state.in_code = !l:state.in_code
    let new_text = '    '.repeat('━', winwidth(0)-8)

  elseif l:state.in_code    " Indent code block contents
    let new_text = '    '.a:text

  elseif a:text =~? '^[*-] \[ \]'    " Unchecked Box
    let new_text = substitute(a:text,  '^[*-] \[ \]', '□', '')

  elseif a:text =~? '^[*-] \[x\]'    " Checked Box
    let new_text = substitute(a:text,  '^[*-] \[x\]', '■', '')

  elseif a:text =~? '^\s*[*-]'    " Bulleted Lists
    let new_text = substitute(a:text, '^\s*\zs[*-] ', '∙ ', '')

  elseif a:text =~? '^\s*\d\+\.'    " Numbered Lists
    if match(a:text, '\s*\zs\d\+\.') > l:state.indent
      let l:state.bullet_nums += [0]
    elseif match(a:text, '\s*\zs\d\+\.') < l:state.indent
      let l:state.bullet_nums = l:state.bullet_nums[0:-2]
    endif
    let l:state.indent = match(a:text, '\s*\zs\d\+\.')
    let l:state.bullet_nums[-1] += 1
    let new_text = substitute(a:text, '^\s*\zs\d\+', l:state.bullet_nums[-1], '')

  elseif a:text =~? '^#\{1,3}[^#]' && g:presenting_figlets && executable('figlet')    " Replace h1, h2 and h3 text with figlets
    let level = strchars(matchstr(a:text, '^#\+'))
    let font = level == 1 ? g:presenting_font_large : g:presenting_font_small
    let new_text = split(system('figlet -w '.winwidth(0).' -f '.font.' '.shellescape(substitute(a:text,'^#\+s*','',''))), "\n")

    let w = max(map(copy(new_text), 'strchars(v:val)'))
    call map(new_text, '"#".level.repeat(" ",(winwidth(0)-w)/2).v:val')

  elseif a:text =~? '^#\{1,4}[^#]'    " Center h4 text (and h1-h3 if no figlets) on the window.
    let level = strchars(matchstr(a:text, '^#\+'))
    let l:text = substitute(a:text,'^#\+s*','','')
    let new_text = '#'.level.repeat(' ', (winwidth(0)-strchars(l:text))/2) . l:text

  elseif a:text =~? '^\s*>'    " Wrap and prefix quoted blocks.
    let new_text = []
    let l:text = substitute(a:text, '^\s*>\s*', '', '')
    while strchars(l:text) > winwidth(0) - 8
      let s = strridx(strcharpart(l:text,0,winwidth(0)-10),' ')
      let new_text += ['  ┃ '.strcharpart(l:text,0,s)]
      let l:text = strcharpart(l:text,s+1)
    endwhile
    let new_text += ['  ┃ '.l:text]

  else " Return the text as is.
    let new_text = a:text

  endif

  if a:text !~? '^\s*\d\+\.' " Reset bullet number
    let l:state.bullet_nums = [0]
  endif

  return [new_text, l:state]
endfunction

" vim:ts=2:sw=2:expandtab
