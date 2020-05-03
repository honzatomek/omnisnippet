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
  let g:snippet_verbose_mode = 2
endif

function! s:PrintMsg(message)
  if g:snippet_verbose_mode == 1
    echom a:message
  elseif g:snippet_verbose_mode == 2
    if !exists("g:snippet_message_buffer")
      let g:snippet_message_buffer = [a:message]
    else
      silent! call extend(g:snippet_message_buffer, [a:message])
    endif
  endif
endfunction

" set plugin location =================================================== {{{1
if !exists("g:snippet_plugin_location")
  let g:snippet_plugin_location = fnamemodify(resolve(expand("<sfile>:p")), ":h:h")
  call <SID>PrintMsg("[+] Snippet: plugin location set to '" . g:snippet_plugin_location . "'")
else
  let g:snippet_plugin_location = substitute(g:snippet_plugin_location, "/$", "", "")
  call <SID>PrintMsg("[+] Snippet: plugin custom location set to '" . g:snippet_plugin_location . "'")
endif

" set snippets location ================================================= {{{1
if !exists("g:snippet_snippets_location")
  let g:snippet_snippets_location = g:snippet_plugin_location . "/snippets"
  call <SID>PrintMsg("[+] Snippet: snippet location set to '" . g:snippet_snippets_location . "'")
else
  let g:snippet_snippets_location = substitute(g:snippet_snippets_location, "/$", "", "")
  call <SID>PrintMsg("[+] Snippet: snippet custom location set to '" . g:snippet_snippets_location . "'")
endif

" set filetype specific snippet location ================================ {{{1
function! s:Snippet_SetFiletypeSpecifics(filetype)
  call <SID>PrintMsg("[+] Snippet: Filetype " . a:filetype)
  if !exists("g:snippet_snippets_" . a:filetype)
    execute "let g:snippet_snippets_" . a:filetype . " =  g:snippet_snippets_location . \"/" . a:filetype . "\""
    execute "call <SID>PrintMsg(\"[+] Snippet: " . a:filetype . " snippets location set to '\" . g:snippet_snippets_" . a:filetype . " . \"'\")"
  else
    execute "let g:snippet_snippets_" . a:filetype . " = substitute(g:snippet_snippets_" . a:filetype . ", \"/$\", \"\", \"\")"
    execute "call <SID>PrintMsg(\"[+] Snippet: " . a:filetype . " snippets custom location set to '\" . g:snippet_snippets_" . a:filetype . " . \"'\")"
  endif
  if g:snippet_verbose_mode == 2
    for l:mes in g:snippet_message_buffer
      echom l:mes
    endfor
    unlet g:snippet_message_buffer
  endif
endfunction

augroup Snippet
  autocmd!
  autocmd FileType * :call <SID>Snippet_SetFiletypeSpecifics(&filetype)
augroup END

" set plugin keymaps ==================================================== {{{1
function! s:Snippet_SetEntryMapping(mode, name, function, keys)
  execute a:mode . 'noremap <silent> <plug>' . a:name . ' :call ' . a:function . '<cr>'
  if !hasmapto('<plug>' . a:name, a:mode) && (mapcheck(a:keys, a:mode) == "")
    execute a:mode . 'map <silent> ' . a:keys . ' <plug>' . a:name
  endif
endfunction

" <plug>Snippet_InsertSnippetNormal
call <SID>Snippet_SetEntryMapping('n', 'Snippet_InsertSnippetNormal', 'snippet#Insert("n")', '<leader>si') "Snippet Insert
" <plug>Snippet_InsertSnippetVisual
call <SID>Snippet_SetEntryMapping('v', 'Snippet_InsertSnippetVisual', 'snippet#Insert("v")', '<leader>si') "Snippet Insert
" <plug>Snippet_StoreSnippetNormal
call <SID>Snippet_SetEntryMapping('n', 'Snippet_StoreSnippetNormal', 'snippet#Store("n")', '<leader>ss') "Snippet Store
" <plug>Snippet_StoreSnippetVisual
call <SID>Snippet_SetEntryMapping('v', 'Snippet_StoreSnippetVisual', 'snippet#Store("v")', '<leader>ss') "Snippet Store

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

let g:snippet_plugin_loaded = 1
" vim:fdm=marker:ft=vim
