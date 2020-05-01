" snippet.vim - Vim autoload file for vim-snippet
"
"  ee   e e  eeeeeee      eeeee eeeee e  eeeee eeeee eeee eeeee
"  88   8 8  8  8  8      8   " 8   8 8  8   8 8   8 8      8
"  88  e8 8e 8e 8  8 eeee 8eeee 8e  8 8e 8eee8 8eee8 8eee   8e
"   8  8  88 88 8  8         88 88  8 88 88    88    88     88
"   8ee8  88 88 8  8      8ee88 88  8 88 88    88    88ee   88
"
" Plugin:  snippet.vim
" Author:  Jan Tomek <rpi3.tomek@protonmail.com>
" Date:    25.04.2020
" Version: 0.1.0
"
"
"########################################################################

" load autoload script only once ======================================== {{{1
if exists("g:snippet_autoload_loaded")
  finish
endif

" function! snippet#Insert(mode) range ================================== {{{1
function! snippet#Insert(mode) range
  execute "let b:snippet_ftlocation = g:snippet_snippets_" . &filetype
  " check if any snippets are stored for the current filetype
  if !isdirectory(b:snippet_ftlocation)
    echom '[-] Snippet: no snippets directory for ' . &filetype . ' filetype.'
    return
  elseif len(globpath(b:snippet_ftlocation, "**/*.*", 0, 1)) == 0
    echom '[-] Snippet: no snippets stored for ' . &filetype . ' filetype.'
    return
  endif

  silent! call snippet#SetDefaults(['<cr>', '<kEnter>', '<c-y>', '<c-x>'])

  setlocal completefunc=snippet#Complete
  let &completeopt = 'menuone,preview'

  inoremap <buffer> <silent> <expr> <cr>     snippet#MapEnter()
  inoremap <buffer> <silent> <expr> <kEnter> snippet#MapEnter()
  inoremap <buffer> <silent> <expr> <c-y>    snippet#MapCtrlY()
  " inoremap <buffer> <silent> <expr> <esc>    snippet#MapEsc()
  inoremap <buffer> <silent> <expr> <c-x>    snippet#MapCtrlX()

  " let l:bufwinnr = bufwinnr("%")
  " silent! execute "vertical botright copen 60"
  " silent! execute "cclose"
  " silent! execute l:bufwinnr . "wincmd w"

  normal! o
  normal! k

  startinsert
  call feedkeys("\<c-x>\<c-u>")
endfunction

" function! snippet#Complete(findstart, base) =========================== {{{1
function! snippet#Complete(findstart, base)
  if a:findstart
    return 1
  else
    echom '[i] Snippet: snippet#Complete() called'
    let l:items = snippet#GetSnippets()
    return l:items
  endif
endfunction

" function! snippet#GetSnippets() ======================================= {{{1
function! snippet#GetSnippets()
  let l:snippets = []
  silent! call extend(l:snippets, globpath(b:snippet_ftlocation, "*.*", 0, 1))
  silent! call extend(l:snippets, globpath(b:snippet_ftlocation, "*/*.*", 0, 1))
  silent! call extend(l:snippets, globpath(b:snippet_ftlocation, "*/**/*.*", 0, 1))
	" word		the text that will be inserted, mandatory
	" info		more information about the item, can be displayed in a
			" preview window
  silent! call map(l:snippets, "{\"word\": substitute(v:val, \"" . escape(b:snippet_ftlocation, '.*()|') . "/\", \"\", \"\"), \"menu\": join(readfile(v:val, '', 1), \"\n\"),\"info\": join(readfile(v:val), \"\n\"),}")

  " silent! call map(l:snippets, "substitute(v:val, \"" . escape(b:snippet_ftlocation, '.*()|') . "/\", \"\", \"\")")
  return l:snippets
endfunction

" function! snippet#InsertSnippet() ===================================== {{{1
function! snippet#InsertSnippet()
  " replace completion result with the contents of the snippet
  " save unnamed register
  let l:tmpUnnamedReg = @
  " remove empty line if it exists
  if len(getline(".")) == 0
    normal! ddk
  endif
  " get the filename from current line and set path
  let l:filename = b:snippet_ftlocation . "/" . getline(".")
  " check if the file is readable and insert it
  if filereadable(l:filename)
    silent! execute "read " . l:filename
    normal! kdd
  else
    normal! <c-y>
  endif
  " restore unnamed register
  let @@ = l:tmpUnnamedReg
  " restore backed-up defaults
"   silent! call snippet#RestoreDefaults()
  call snippet#RestoreDefaults()
endfunction

" function! snippet#Store(mode) range =================================== {{{1
function! snippet#Store(mode) range
  " set filetype specific location for snippets to be read from
  execute "let b:snippet_ftlocation = g:snippet_snippets_" . &filetype
  " store the whole file or just selected lines as a snippet
  " check mode
  if a:mode ==# "n"  " normal mode
    let l:snippet = getline(1, "$")
  elseif a:mode ==# "v"  " visual mode
    let l:snippet = getline("'<", "'>")
  else
    echom '[-] Snippet: this mode (' . a:mode . ') invocation of snippet#Store(mode) is not supported'
    return
  endif
  " trim empty lines at beginning and end of the snippet
  let l:snippet = split(substitute(join(l:snippet, "\r"), "\v(^(\r(\r|\s)*\r)|(\r(\r|\s)*\r\s*$)", "", ""), "\r")
  " undo indent of the snippet
  let l:indent = match(l:snippet[0], "\\S")
  call map(l:snippet, 'v:val[:' . l:indent . '] =~# "\\s*" ? strpart(v:val, ' . l:indent . ') : v:val')
  " store current working directory
  let l:cwd = getcwd()
  " check if the snippets directory exists for current filetype, creates it if
  " not
  if !isdirectory(b:snippet_ftlocation)
    silent! call mkdir(b:snippet_ftlocation, "p")
    echom "[+] Snippet: created the Snippets directory  " . b:snippet_ftlocation
  endif
  " change path to the snippets directory for autocompletion purposes
  silent! execute ":cd " . b:snippet_ftlocation
  " get snippet name
  let l:snippet_name = snippet#GetUserInput('Input Snippet Name: ', '', 'file')
  if l:snippet_name ==# "" | return | endif
  " if no file extension has been input, add current file extension
  if fnamemodify(l:snippet_name, ":e") ==# ""
    let l:snippet_name .= '.' . expand("%:e")
  endif
  " check if the snippet path exists, if not, create it
  if !isdirectory(l:snippet_name)
    silent! call mkdir(fnamemodify(l:snippet_name, ":h"), "p")
  endif
  " write the file and wait for finish
  echo l:snippet
  silent! call writefile(l:snippet, l:snippet_name, "s")
  " change the path back
  silent! execute ":cd " . l:cwd
endfunction

" function! snippet#GetUserInput(prompt, default, completion) =========== {{{1
function! snippet#GetUserInput(prompt, default, completion)
    silent! call inputsave()
    let l:retVal = input(a:prompt, a:default, a:completion)
    silent! call inputrestore()
    return l:retVal
endfunction

" function! snippet#SetDefaults(mappings) =============================== {{{1
function! snippet#SetDefaults(mappings)
  if !empty(&completefunc)
    execute "let b:snippet_completefunc_backup = '" . &completefunc . "'"
  endif
  if !empty(&completeopt)
    execute "let b:snippet_completeopt_backup = '" . &completeopt . "'"
  endif
  let b:snippet_mappings_backup = snippet#SaveMappings(a:mappings, 'i', 0)

  let g:snippet_current_filetype = &filetype

  augroup Snippet_Preview
    autocmd!
"     autocmd BufWinEnter * if &previewwindow | echom '[i] Snippet: Created Preview' | endif
    autocmd BufWinEnter * if &previewwindow | setlocal nowrap nonumber nofoldenable | endif
    autocmd BufWinEnter * if &previewwindow && exists("g:snippet_current_filetype") | execute "setlocal filetype=" . g:snippet_current_filetype | endif

    autocmd BufWinEnter * if &previewwindow | execute ":wincmd L" | endif
    autocmd BufWinEnter * if &previewwindow | execute ":vertical resize 60" | endif
    autocmd BufWinEnter * if &previewwindow | execute "let g:snippet_preview_bufwinnr = " . bufwinnr(bufnr("%")) | endif
  augroup END

  echom '[+] Snippet: defaults backed up.'
endfunction

" function! snippet#RestoreDefaults() =================================== {{{1
function! snippet#RestoreDefaults()
  if exists("b:snippet_completefunc_backup")
    execute "setlocal completefunc=" . b:snippet_completefunc_backup
  else
    execute "setlocal completefunc="
  endif
  if exists("b:snippet_completeopt_backup")
    execute "setlocal completeopt=" . b:snippet_completeopt_backup
  else
    execute "setlocal completeopt="
  endif
  if exists("b:snippet_mappings_backup")
    call snippet#RestoreMappings(b:snippet_mappings_backup)
  endif

  augroup Snippet_Preview
    autocmd!
  augroup END

  if exists("g:snippet_preview_bufwinnr")
    silent! execute g:snippet_preview_bufwinnr . "close!"
  endif

  unlet g:snippet_current_filetype

  echom '[+] Snippet: defaults restored'
endfunction

" function! snippet#SaveMappinngs(keys, mode, global) abort ============= {{{1
function! snippet#SaveMappinngs(keys, mode, global) abort
" From: https://vi.stackexchange.com/questions/7734/how-to-save-and-restore-a-mapping
  let mappings = {}

  if a:global
    for l:key in a:keys
      let buf_local_map = maparg(l:key, a:mode, 0, 1)

      silent! execute a:mode.'unmap <buffer> '.l:key

      let map_info        = maparg(l:key, a:mode, 0, 1)
      let mappings[l:key] = !empty(map_info)
                          \ ? map_info
                          \ : {'unmapped' : 1,
                          \    'buffer'   : 0,
                          \    'lhs'      : l:key,
                          \    'mode'     : a:mode,}

      call Restore_mappings({l:key : buf_local_map})
    endfor

  else
    for l:key in a:keys
      let map_info        = maparg(l:key, a:mode, 0, 1)
      let mappings[l:key] = !empty(map_info)
                          \ ? map_info
                          \ : {'unmapped' : 1,
                          \    'buffer'   : 1,
                          \    'lhs'      : l:key,
                          \    'mode'     : a:mode,}
    endfor
  endif

  return mappings
endfunction

" function! snippet#RestoreMappings(mappings) abort ===================== {{{1
function! snippet#RestoreMappings(mappings) abort
" From: https://vi.stackexchange.com/questions/7734/how-to-save-and-restore-a-mapping
  for mapping in values(a:mappings)
    if !has_key(mapping, 'unmapped') && !empty(mapping)
      execute mapping.mode
         \ . (mapping.noremap ? 'noremap   ' : 'map ')
         \ . (mapping.buffer  ? ' <buffer> ' : '')
         \ . (mapping.expr    ? ' <expr>   ' : '')
         \ . (mapping.nowait  ? ' <nowait> ' : '')
         \ . (mapping.silent  ? ' <silent> ' : '')
         \ .  mapping.lhs
         \ . ' '
         \ . substitute(mapping.rhs, '<SID>', '<SNR>'.mapping.sid.'_', 'g')

    elseif has_key(mapping, 'unmapped')
      silent! execute mapping.mode.'unmap '
            \ .(mapping.buffer ? ' <buffer> ' : '')
            \ . mapping.lhs
    endif
  endfor
endfunction

" function! snippet#MapCtrlY() ========================================== {{{1
function! snippet#MapCtrlY()
    if !pumvisible()
        return "\<C-Y>"
    else
        return "\<ESC>:call snippet#InsertSnippet()\<CR>"
    endif
endfunction

" function! snippet#MapEnter() ========================================== {{{1
function! snippet#MapEnter()
    if !pumvisible()
        return "\<CR>"
    else
        return "\<CR>\<ESC>:call snippet#InsertSnippet()\<CR>"
    endif
endfunction

" function! snippet#MapEsc() ============================================ {{{1
function! snippet#MapEsc()
    if !pumvisible()
        return "\<ESC>"
    else
        return "\<ESC>:normal dd\<CR>:call snippet#RestoreDefaults()\<CR>"
    endif
endfunction

" function! snippet#MapCtrlX() ========================================== {{{1
function! snippet#MapCtrlX()
    if !pumvisible()
        return "\<C-X>"
    else
        return "\<ESC>:normal dd\<CR>:call snippet#RestoreDefaults()\<CR>"
    endif
endfunction

" }}}

let g:snippet_autoload_loaded = 1
finish
" vim: set fdm=marker ft=vim
