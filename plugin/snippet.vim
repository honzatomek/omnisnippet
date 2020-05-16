" snippet.vim - Vim plugin file for vim-snippet
"#############################################################################
"
"        ee   e e  eeeeeee      eeeee eeeee e  eeeee eeeee eeee eeeee
"        88   8 8  8  8  8      8   " 8   8 8  8   8 8   8 8      8
"        88  e8 8e 8e 8  8 eeee 8eeee 8e  8 8e 8eee8 8eee8 8eee   8e
"         8  8  88 88 8  8         88 88  8 88 88    88    88     88
"         8ee8  88 88 8  8      8ee88 88  8 88 88    88    88ee   88
"
" Plugin:  snippet.vim
" Author:  Jan Tomek <rpi3.tomek@protonmail.com>
" Date:    25.04.2020
" Version: 0.1.0
"
"#############################################################################

" load plugin only once ================================================= {{{1
if exists("g:snippet_plugin_loaded")
  finish
endif

" set verbose mode and print function =================================== {{{1
if !exists("g:snippet_verbose_mode")
  let g:snippet_verbose_mode = 0
endif

let g:snippet_tag_mark = {'o': '[+] ', 'e': '[x] ', 'i': '[i] ', 'q': '[?] ', 'w': '[-] ',}
let g:snippet_tag_name = 'VIM-Snippet: '
function! s:PrintMsg(message, tag)
  if !exists("g:snippet_tag_name")
    let l:tag_name = "VIM-Snippet: "
  else
    let l:tag_name = g:snippet_tag_name
  endif
  if get(g:snippet_tag_mark, a:tag, '') == ''
    let l:tag_mark = '[i] '
  else
    let l:tag_mark = get(g:snippet_tag_mark, a:tag, '')
  endif
  let l:message = l:tag_mark . l:tag_name . a:message

  if g:snippet_verbose_mode == 1
    if a:tag ==? 'o'
      echohl StatusLine
    elseif a:tag ==? 'e'
      echohl ErrorMsg
    elseif a:tag ==? 'i'
      echohl Normal
    elseif a:tag ==? 'q'
      echohl Question
    elseif a:tag ==? 'w'
      echohl WarningMsg
    else
      echohl None
    endif
    echom l:message
    echohl None
  elseif g:snippet_verbose_mode == 2
    if !exists("g:snippet_message_buffer")
      let g:snippet_message_buffer = [[a:message, a:tag]]
    else
      silent! call add(g:snippet_message_buffer,  [a:message, a:tag])
    endif
  endif
endfunction

" set plugin location =================================================== {{{1
if !exists("g:snippet_root")
  let g:snippet_root = fnamemodify(resolve(expand("<sfile>:p")), ":h:h")
  call <SID>PrintMsg("plugin location set to '" . g:snippet_root . "'", 'i')
else
  let g:snippet_root = substitute(g:snippet_root, "/$", "", "")
  call <SID>PrintMsg("plugin custom location set to '" . g:snippet_root . "'", 'i')
endif

" set snippets location ================================================= {{{1
if !exists("g:snippet_directory")
  let g:snippet_directory = g:snippet_root . "/snippets"
  call <SID>PrintMsg("snippet location set to '" . g:snippet_directory . "'", 'i')
else
  let g:snippet_directory = substitute(g:snippet_directory, "/$", "", "")
  call <SID>PrintMsg("snippet custom location set to '" . g:snippet_directory . "'", 'i')
endif

" set filetype specific snippet location ================================ {{{1
function! s:Snippet_SetFiletypeSpecifics(filetype)
  call <SID>PrintMsg("Filetype " . a:filetype, 'i')
  if !exists("g:snippet_" . a:filetype)
    execute "let g:snippet_" . a:filetype . " =  g:snippet_directory . \"/" . a:filetype . "\""
    execute "call <SID>PrintMsg(\"" . a:filetype . " snippets location set to '\" . g:snippet_" . a:filetype . " . \"'\", 'i')"
  else
    execute "let g:snippet_" . a:filetype . " = substitute(g:snippet_" . a:filetype . ", \"/$\", \"\", \"\")"
    execute "call <SID>PrintMsg(\"" . a:filetype . " snippets custom location set to '\" . g:snippet_" . a:filetype . " . \"'\", 'i')"
  endif
endfunction

augroup Snippet
  autocmd!
  autocmd FileType * :call <SID>Snippet_SetFiletypeSpecifics(&filetype)
augroup END

" set plugin keymaps ==================================================== {{{1
function! s:Snippet_SetEntryMapping(mode, name, function, keys)
  execute a:mode . 'noremap <silent> <plug>' . a:name . ' :call ' . a:function . '<cr>'
  call <SID>PrintMsg("(" . a:mode . ") " . a:function . " mapped to <plug>" . a:name, 'i')
  if !hasmapto('<plug>' . a:name, a:mode) && (mapcheck(a:keys, a:mode) == "")
    execute a:mode . 'map <silent> ' . a:keys . ' <plug>' . a:name
    call <SID>PrintMsg("(" . a:mode . ") <plug>" . a:name . " mapped to " . a:keys, 'i')
  endif
endfunction

" <plug>Snippet_InsertSnippetNormal
call <SID>Snippet_SetEntryMapping('n', 'Snippet_InsertNormal', 'snippet#Insert("n")', '<leader>is') "Snippet Insert
" <plug>Snippet_InsertSnippetVisual
call <SID>Snippet_SetEntryMapping('v', 'Snippet_InsertVisual', 'snippet#Insert("v")', '<leader>is') "Snippet Insert Visual Line
" <plug>Snippet_StoreSnippetNormal
call <SID>Snippet_SetEntryMapping('n', 'Snippet_StoreNormal', 'snippet#Store("n")', '<leader>ss') "Snippet Store
" <plug>Snippet_StoreSnippetVisual
call <SID>Snippet_SetEntryMapping('v', 'Snippet_StoreVisual', 'snippet#Store("v")', '<leader>ss') "Snippet Store Visual Line

" Default key mappings for Completion Popup Utilization
if !exists("g:snippet_NextAndComplete") | let g:snippet_NextAndComplete = ['<c-n>', '<c-s-j>'] | endif
if !exists("g:snippet_PrevAndComplete") | let g:snippet_PrevAndComplete = ['<c-p>', '<c-s-k>'] | endif
if !exists("g:snippet_NextDntComplete") | let g:snippet_NextDntComplete = ['<down>', '<kplus>', '<c-j>'] | endif
if !exists("g:snippet_PrevDntComplete") | let g:snippet_PrevDntComplete = ['<up>', '<kminus>', '<c-k>'] | endif
if !exists("g:snippet_PageDown") | let g:snippet_PageDown = ['<pagedown>'] | endif
if !exists("g:snippet_PageUp") | let g:snippet_PageUp = ['<pageup>'] | endif
if !exists("g:snippet_Quit") | let g:snippet_Quit = ['<c-q>', '<left>', '<c-h>'] | endif
if !exists("g:snippet_Complete") | let g:snippet_Complete = ['<cr>', '<kenter>', '<tab>', '<right>', '<c-l>'] | endif

" }}}

if g:snippet_verbose_mode == 2 && exists("g:snippet_message_buffer")
  if len(g:snippet_message_buffer) > 0
    let g:snippet_verbose_mode = 1
    for [message, tag_name] in g:snippet_message_buffer
      call <SID>PrintMsg(message, 'o')
    endfor
    let g:snippet_verbose_mode = 2
    unlet g:snippet_message_buffer
  endif
endif
let g:snippet_plugin_loaded = 1
" vim:fdm=marker:ft=vim
