" omnisnippet.vim - Vim autoload file for OmniSnippet
"
"        ___                  _ ____        _                  _
"       / _ \ _ __ ___  _ __ (_) ___| _ __ (_)_ __  _ __   ___| |_
"      | | | | '_ ` _ \| '_ \| \___ \| '_ \| | '_ \| '_ \ / _ \ __|
"      | |_| | | | | | | | | | |___) | | | | | |_) | |_) |  __/ |_
"       \___/|_| |_| |_|_| |_|_|____/|_| |_|_| .__/| .__/ \___|\__|
"                                            |_|   |_|
"
" Plugin:  omnisnippet.vim
" Author:  Jan Tomek <rpi3.tomek@protonmail.com>
" Date:    25.04.2020
" Version: 0.1.0
"
"
"########################################################################

" load autoload script only once ======================================== {{{1
if exists("g:omnisnippet_autoload_loaded")
  finish
endif

" function! omnisnippet#Insert(mode) range ============================== {{{1
function! omnisnippet#Insert(mode) range
  execute "let b:omnisnippet_snippet_ftlocation = g:omnisnippet_snippets_" . &filetype
  " check if any snippets are stored for the current filetype
  if !isdirectory(b:omnisnippet_snippet_ftlocation)
    echom '[-] OmniSnippet: no snippets directory for ' . &filetype . ' filetype.'
    return
  elseif len(globpath(b:omnisnippet_snippet_ftlocation, "**/*.*", 0, 1)) == 0
    echom '[-] OmniSnippet: no snippets stored for ' . &filetype . ' filetype.'
    return
  endif

  silent! call omnisnippet#StoreDefaults()
  setlocal completefunc=omnisnippet#Complete
  let &completeopt = 'menuone,preview'

  inoremap <buffer> <silent> <expr> <cr>     omnisnippet#MapEnter()
  inoremap <buffer> <silent> <expr> <kEnter> omnisnippet#MapEnter()
  inoremap <buffer> <silent> <expr> <c-y>    omnisnippet#MapCtrlY()
  inoremap <buffer> <silent> <expr> <esc>    omnisnippet#MapEsc()

  normal! o
  normal! k

  startinsert
  call feedkeys("\<c-x>\<c-u>")
endfunction

" function! omnisnippet#Complete(findstart, base) ======================= {{{1
function! omnisnippet#Complete(findstart, base)
  if a:findstart
    return 1
  else
    let l:items = omnisnippet#GetSnippets()
    return l:items
  endif
endfunction

" function! omnisnippet#GetSnippets() =================================== {{{1
function! omnisnippet#GetSnippets()
  let l:snippets = []
  silent! call extend(l:snippets, globpath(b:omnisnippet_snippet_ftlocation, "*.*", 0, 1))
  silent! call extend(l:snippets, globpath(b:omnisnippet_snippet_ftlocation, "*/*.*", 0, 1))
  silent! call extend(l:snippets, globpath(b:omnisnippet_snippet_ftlocation, "*/**/*.*", 0, 1))
  silent! call map(l:snippets, "substitute(v:val, \"" . escape(b:omnisnippet_snippet_ftlocation, '.*()|') . "/\", \"\", \"\")")
  return l:snippets
endfunction

" function! omnisnippet#InsertSnippet() ================================= {{{1
function! omnisnippet#InsertSnippet()
  " replace completion result with the contents of the snippet
  " save unnamed register
  let l:tmpUnnamedReg = @
  " remove empty line if it exists
  if len(getline(".")) == 0
    normal! ddk
  endif
  " get the filename from current line and set path
  let l:filename = b:omnisnippet_snippet_ftlocation . "/" . getline(".")
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
  silent! call omnisnippet#RestoreDefaults()
endfunction

" function! omnisnippet#Store(mode) range =============================== {{{1
function! omnisnippet#Store(mode) range
  " set filetype specific location for snippets to be read from
  execute "let b:omnisnippet_snippet_ftlocation = g:omnisnippet_snippets_" . &filetype
  " store the whole file or just selected lines as a snippet
  " check mode
  if a:mode ==# "n"  " normal mode
    let l:snippet = getline(1, "$")
  elseif a:mode ==# "v"  " visual mode
    let l:snippet = getline("'<", "'>")
  else
    echom '[-] OmniSnippet: this mode (' . a:mode . ') invocation of omnisnippet#Store(mode) is not supported'
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
  if !isdirectory(b:omnisnippet_snippet_ftlocation)
    silent! call mkdir(b:omnisnippet_snippet_ftlocation, "p")
    echom "[+] OmniSnippet: created the Snippets directory  " . b:omnisnippet_snippet_ftlocation
  endif
  " change path to the snippets directory for autocompletion purposes
  silent! execute ":cd " . b:omnisnippet_snippet_ftlocation
  " get snippet name
  let l:snippet_name = omnisnippet#GetUserInput('Input Snippet Name: ', '', 'file')
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

" function! omnisnippet#GetUserInput(prompt, default, completion) ======= {{{1
function! omnisnippet#GetUserInput(prompt, default, completion)
    silent! call inputsave()
    let l:retVal = input(a:prompt, a:default, a:completion)
    silent! call inputrestore()
    return l:retVal
endfunction

" function! omnisnippet#StoreDefaults() ================================= {{{1
function! omnisnippet#StoreDefaults()
  if !empty(&completefunc)
    let b:omnisnippet_completefunc_backup = &completefunc
  endif
  if !empty(&completeopt)
    let b:omnisnippet_completeopt_backup = &completeopt
  endif
  let b:omnisnippet_mappings_backup = omnisnippet#SaveMappings(['<cr>', '<kenter>', '<c-y>', '<esc>'], 'i', 0)
  echom '[+] OmniSnippet: defaults backed up.'
endfunction

" function! omnisnippet#RestoreDefaults() =============================== {{{1
function! omnisnippet#RestoreDefaults()
  if exists("b:omnisnippet_completefunc_backup")
    let &completefunc = b:omnisnippet_completefunc_backup
  endif
  if exists("b:omnisnippet_completeopt_backup")
    let &completeopt = b:omnisnippet_completeopt_backup
  endif
  if exists("b:omnisnippet_mappings_backup")
    call omnisnippet#RestoreMappings(b:omnisnippet_mappings_backup)
  endif
  echom '[+] OmniSnippet: defaults restored'
endfunction

" function! omnisnippet#SaveMappinngs(keys, mode, global) abort ========= {{{1
function! omnisnippet#SaveMappinngs(keys, mode, global) abort
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

" function! omnisnippet#RestoreMappings(mappings) abort ================= {{{1
function! omnisnippet#RestoreMappings(mappings) abort
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

" function! omnisnippet#MapCtrlY() ====================================== {{{1
function! omnisnippet#MapCtrlY()
    if !pumvisible()
        return "\<C-Y>"
    else
        return "\<ESC>:call omnisnippet#InsertSnippet()\<CR>"
    endif
endfunction

" function! omnisnippet#MapEnter() ====================================== {{{1
function! omnisnippet#MapEnter()
    if !pumvisible()
        return "\<CR>"
    else
        return "\<CR>\<ESC>:call omnisnippet#InsertSnippet()\<CR>"
    endif
endfunction

" function! omnisnippet#MapEsc() ======================================== {{{1
function! omnisnippet#MapEsc() " ======================================== {{{1
    if !pumvisible()
        return "\<ESC>"
    else
        return "\<ESC>:normal dd\<CR>:call omnisnippet#RestoreDefaults()\<CR>"
    endif
endfunction

" }}}

let g:omnisnippet_autoload_loaded = 1
finish
" vim: set fdm=marker ft=vim
