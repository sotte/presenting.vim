" These autoload modules perform custom formatting for the different
" filetypes. (This particular one is for markdown files.) These modules
" must implement the ...#format() function. See the comment in
" plugin/presenting.vim's s:Format() function for details.

function! markdown#format(text, last_line, state)
  " Initialize the state variable with defaults, if missing.
  let l:state = extend(a:state, {'comment':0, 'code':0, 'bullet_nums':[0], 'indent':0, 'table':[]}, 'keep')
  let new_text = []


  " Finish a table. We don't know it's done until processing the next line.
  if a:text !~? '\s*|\([^|]\+|\)\+$' && l:state.table != []
    let new_text += s:FinishTable(l:state.table)
    let l:state.table = []
  endif


  " Code Blocks - Indent. Precede and follow with horzontal line
  " Keep the ``` lines if a language is specified for highlighting.
  if !l:state.comment && a:text =~? '^\s*```'
    if !l:state.code
      let l:state.code = a:text =~? '```\s*\w' ? 1 : 2
      let new_text += ['    '.repeat('▄', &columns-8)]
      let new_text += l:state.code == 1 ? [substitute(a:text, '^\s*', '    ', '')] : ['']
    else
      let new_text += l:state.code == 1 ? [substitute(a:text, '^\s*', '    ', '')] : ['']
      let new_text += ['    '.repeat('▀', &columns-8)]
      let l:state.code = 0
    endif

  " Avoid formatting inside a code block by having this at the top
  elseif l:state.code
    let new_text += ['    '.a:text]


  " Remove commented lines.
  elseif a:text =~? '<!--'
    let uncommented = substitute(a:text, '<!--.\{-}\($\|-->\)','','')
    if uncommented != ''
      let new_text += [uncommented]
    endif
    let l:state.comment = a:text !~? '-->'

  " Do not remove --> outside of a comment
  elseif l:state.comment && a:text =~? '-->'
    let uncommented = substitute(a:text, '.*-->','','')
    if uncommented != ''
      let new_text += [uncommented]
    endif
    let l:state.comment = 0

  elseif l:state.comment
    " Do nothing. new_text is already set to [].


  " Tables - Render with box drawing characters.
  elseif a:text =~? '\s*|\([^|]\+|\)\+$'
    if l:state.table == []
      let l:state.table = [
        \ substitute(substitute(substitute(substitute(a:text, '^\s*|', '┏', ''), '|\s*$', '┓', ''), '|', '┳', 'g'), '[^┏┓┳]', '━', 'g'),
        \ substitute(a:text, '|', '┃', 'g')
      \ ]
    elseif a:text =~? '\s*|\(-\+|\)\+$'
      let l:state.table += [
        \ substitute(substitute(substitute(substitute(a:text, '^\s*|', '┣', ''), '|\s*$', '┫', ''), '|', '╋', 'g'), '-', '━', 'g')
      \ ]
    else
      let l:state.table += [substitute(a:text, '|', '┃', 'g') ]
    endif


  " Checkboxes - Replace with Unicode squares
  elseif a:text =~? '^\s*[*-] \[[ xX]\]'
    let tmp = substitute(a:text, '[*-] \[ \]',    '□', '')
    let tmp = substitute(tmp,    '[*-] \[[xX]\]', '■', '')
    let new_text += [tmp]


  " Bullet Lists - Replace with Unicode bullet
  elseif a:text =~? '^\s*[*-]'
    let new_text += [substitute(a:text, '^\s*\zs[*-] ', '• ', '')]


  " Numbered Lists - Renumber, with indentation
  elseif a:text =~? '^\s*\d\+\.'
    if match(a:text, '\s*\zs\d\+\.') > l:state.indent
      let l:state.bullet_nums += [0]
    elseif match(a:text, '\s*\zs\d\+\.') < l:state.indent
      let l:state.bullet_nums = l:state.bullet_nums[0:-2]
    endif
    let l:state.indent = match(a:text, '\s*\zs\d\+\.')
    let l:state.bullet_nums[-1] += 1
    let new_text += [substitute(a:text, '^\s*\zs\d\+', l:state.bullet_nums[-1], '')]


  " Headings
  elseif a:text =~? '^#\{1,4}[^#]'
    let level = strchars(matchstr(a:text, '^#\+'))
    if level < 4 && g:presenting_figlets && g:presenting_figlets_executable
      " Headings - Centered for figlet and #, ##, ###
      let font = level == 1 ? g:presenting_font_large : g:presenting_font_small
      let figlet = split(system('figlet -w '.&columns.' -f '.font.' '.shellescape(substitute(a:text,'^#\+s*','',''))), "\n")
      let new_text += s:Center(figlet, '«h'.level.'»')
    else
      " Headings - Centered for the rest
      let new_text += s:Center([substitute(a:text,'^'.repeat('#', level).'\s*','','')], '«h4»')
    endif


  " Quote Blocks - Wrap and Left Border
  elseif a:text =~? '^\s*>'
    let l:text = substitute(a:text, '^\s*>\s*', '', '')
    while strchars(l:text) > &columns - 8
      let s = strridx(strcharpart(l:text,0,&columns-10),' ')
      let new_text += ['  ▐ '.strcharpart(l:text,0,s)]
      let l:text = strcharpart(l:text,s+1)
    endwhile
    let new_text += ['  ▐ '.l:text]


  " Return text as is.
  else
    let new_text += [a:text]

  endif

  " Finish the table if it's the last thing on the slide.
  if a:last_line && l:state.table != []
    let new_text += s:FinishTable(l:state.table)
    let l:state.table = []
  endif

  " Reset bullet number on unnumbered lines.
  if a:text !~? '^\s*\d\+\.'
    let l:state.bullet_nums = [0]
  endif

  return [new_text, l:state]
endfunction

function! s:Center(text, prefix)
  let max_width = max(map(copy(a:text), 'strchars(v:val)'))
  let centered = map(copy(a:text), 'a:prefix.repeat(" ",(&columns-max_width)/2).v:val')
  return centered
endfunction

function! s:FinishTable(text)
  let l:text = extend(a:text, [ substitute( substitute( substitute(a:text[0], '┏', '┗', ''), '┓', '┛', ''), '┳', '┻', 'g') ] )
  let l:text = s:Center(l:text, '«tr»')
  let l:text[1] = substitute(l:text[1], '^«tr»', '«th»', '')
  return l:text
endfunction

" vim:ts=2:sw=2:expandtab
