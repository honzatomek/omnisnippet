" Vim autoload file for omnisnippet
"
"     Plugin :  omnisnippet.vim
"     Author :  Jan Tomek <rpi3.tomek@protonmail.com>
"
" -----------------------------------------------------------------
" set snippets location based on filetype
let s:omnisnippet_snippets_location = g:omnisnippet_snippets_location . "/" . &ft
let s:omnisnippet_snippets_extension = expand("%:e")

" create the path if it does not exist
function! s:OmniSnippet_CheckDir()
  if !isdirectory(s:omnisnippet_snippets_location)
    call mkdir(s:omnisnippet_snippets_location, "p")
    echom "Created non-exsisting snippet directory: " . s:omnisnippet_snippets_location
  endif
endfunction

function! omnisnippet#Read()
  if !isdirectory(s:omnisnippet_snippets_location)
    echom "[-] No snippets stored for the current filetype: " . &ft
    return
  endif

  let l:snippets = globpath(s:omnisnippet_snippets_location, "*." . s:omnisnippet_snippets_extension, 0, 1)
  if len(l:snippets) == 0
    echom "[-] No snippets stored for the current filetype: " . &ft
    return
  else
    call map(l:snippets, "fnamemodify(v:val, \":t\")")
  endif
  echom "[+] Available snippets: " . join(l:snippets, ", ")
  if !empty(&completefunc)
    let ofunc_backup = &completefunc
  else
    let ofunc_backup = ""
  endif
  " if !empty(&completeopt)
    " let l:ofuncopt_backup = &completeopt
  " else
    " let l:ofuncopt_backup = ""
  " endif

  setlocal completefunc=omnisnippet#OmniSnippet_Complete
  " setlocal completeopt=menu,menuone,preview,noinsert

  let l:tmpBufferMappings = omnisnippet#Save_mappings(['<CR>', '<kEnter>', '<C-Y>'], 'i', 0)
  inoremap <buffer><silent><expr> <CR>     omnisnippet#OmniSnippet_MapEnter()
  inoremap <buffer><silent><expr> <kEnter> omnisnippet#OmniSnippet_MapEnter()
  inoremap <buffer><silent><expr> <C-Y>    omnisnippet#OmniSnippet_MapCtrlY()

  startinsert
  call feedkeys("\<c-x>\<c-u>")

  call omnisnippet#Restore_mappings(l:tmpBufferMappings)

  " let &completefunc = ofunc_backup
  " let &completeopt = l:ofuncopt_backup
endfunction

function! omnisnippet#Write()
  call <SID>OmniSnippet_CheckDir()
  echom "Write" . &ft
endfunction

" custom omnicomplete function
function! omnisnippet#OmniSnippet_Complete(findstart, base)
  if a:findstart
    return 1
  else
    let l:snippets = globpath(s:omnisnippet_snippets_location, "*." . s:omnisnippet_snippets_extension, 0, 1)
    call map(l:snippets, "fnamemodify(v:val, \":t\")")
    return l:snippets
  endif
endfunction

" replace completion result from the function above with th contents of the
" file
function! omnisnippet#OmniSnippet_InsertSnippet()
  " save unnamed register
  let l:tmpUnnamedReg = @

  " remove empty line if exists
  if len(getline('.')) == 0
    normal! ddk
  endif

  " get filename from current line and set path
  let l:filename = s:omnisnippet_snippets_location . "/" . getline('.')

  " check if the file is readable and put it
  if filereadable(l:filename)
    execute "read " . l:filename
    normal! kdd
  else
    normal! <C-Y>
  endif

  " restore unnamed register
  let @@ = l:tmpUnnamedReg
endfunction

function! omnisnippet#OmniSnippet_MapCtrlY()
  if !pumvisible()
    return "\<C-Y>"
  else
    return "\<ESC>:call omnisnippet#OmniSnippet_InsertSnippet()\<CR>"
  endif
endfunction

function! omnisnippet#OmniSnippet_MapEnter()
  if !pumvisible()
    return "\<CR>"
  else
    return "\<CR>\<ESC>:call omnisnippet#OmniSnippet_InsertSnippet()\<CR>"
  endif
endfunction

function! omnisnippet#Save_mappings(keys, mode, global) abort
  " From: https://vi.stackexchange.com/questions/7734/how-to-save-and-restore-a-mapping
  let mappings = {}

  if a:global
    for l:key in a:keys
      let buf_local_map = maparg(l:key, a:mode, 0, 1)

      sil! exe a:mode.'unmap <buffer> '.l:key

      let map_info        = maparg(l:key, a:mode, 0, 1)
      let mappings[l:key] = !empty(map_info)
            \     ? map_info
            \     : {
            \ 'unmapped' : 1,
            \ 'buffer'   : 0,
            \ 'lhs'      : l:key,
            \ 'mode'     : a:mode,
            \ }

      call Restore_mappings({l:key : buf_local_map})
    endfor

  else
    for l:key in a:keys
      let map_info        = maparg(l:key, a:mode, 0, 1)
      let mappings[l:key] = !empty(map_info)
            \     ? map_info
            \     : {
            \ 'unmapped' : 1,
            \ 'buffer'   : 1,
            \ 'lhs'      : l:key,
            \ 'mode'     : a:mode,
            \ }
    endfor
  endif

  return mappings
endfunction

function! omnisnippet#Restore_mappings(mappings) abort
  " From: https://vi.stackexchange.com/questions/7734/how-to-save-and-restore-a-mapping
  for mapping in values(a:mappings)
    if !has_key(mapping, 'unmapped') && !empty(mapping)
      exe     mapping.mode
            \ . (mapping.noremap ? 'noremap   ' : 'map ')
            \ . (mapping.buffer  ? ' <buffer> ' : '')
            \ . (mapping.expr    ? ' <expr>   ' : '')
            \ . (mapping.nowait  ? ' <nowait> ' : '')
            \ . (mapping.silent  ? ' <silent> ' : '')
            \ .  mapping.lhs
            \ . ' '
            \ . substitute(mapping.rhs, '<SID>', '<SNR>'.mapping.sid.'_', 'g')

    elseif has_key(mapping, 'unmapped')
      sil! exe mapping.mode.'unmap '
            \ .(mapping.buffer ? ' <buffer> ' : '')
            \ . mapping.lhs
    endif
  endfor
endfunction

