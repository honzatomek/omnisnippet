" snippet.vim - Vim plugin file for vim-snippet
"############################################################################"
"                                                                            "
"        ee   e e  eeeeeee      eeeee eeeee e  eeeee eeeee eeee eeeee        "
"        88   8 8  8  8  8      8   " 8   8 8  8   8 8   8 8      8          "
"        88  e8 8e 8e 8  8 eeee 8eeee 8e  8 8e 8eee8 8eee8 8eee   8e         "
"         8  8  88 88 8  8         88 88  8 88 88    88    88     88         "
"         8ee8  88 88 8  8      8ee88 88  8 88 88    88    88ee   88         "
"                                                                            "
" Plugin:  snippet.vim                                                       "
" Author:  Jan Tomek <rpi3.tomek@protonmail.com>                             "
" Date:    25.04.2020                                                        "
" Version: 0.1.0                                                             "
"                                                                            "
"############################################################################"

" load plugin only once ================================================= {{{1
if exists("g:snippet_plugin_loaded")
  finish
endif

" set plugin location =================================================== {{{1
if !exists("g:snippet_plugin_location")
  let g:snippet_plugin_location = fnamemodify(resolve(expand("<sfile>:p")), ":h:h")
else
  let g:snippet_plugin_location = substitute(g:snippet_plugin_location, "/$", "", "")
endif

" set snippets location ================================================= {{{1
if !exists("g:snippet_snippets_location")
  let g:snippet_snippets_location = g:snippet_plugin_location . "/snippets"
else
  let g:snippet_snippets_location = substitute(g:snippet_snippets_location, "/$", "", "")
endif

" set filetype specific snippet location ================================ {{{1
function! s:Snippet_SetFiletypeSpecifics(filetype)
  echom '[i] Snippet filetype: ' . a:filetype
  if !exists("g:snippet_snippets_" . a:filetype)
    execute "let g:snippet_snippets_" . a:filetype . " =  g:snippet_snippets_location . \"/" . a:filetype . "\""
  else
    execute "let g:snippet_snippets_" . a:filetype . " = substitute(g:snippet_snippets_" . a:filetype . ", \"/$\", \"\", \"\")"
  endif
endfunction

augroup Snippet
  autocmd!
  autocmd FileType * :call <SID>Snippet_SetFiletypeSpecifics(&filetype)
augroup END

" set plugin keymaps ==================================================== {{{1
function! s:Snippet_SetMapping(mode, name, function, keys)
  execute a:mode . 'noremap <silent> <plug>' . a:name . ' :call ' . a:function . '<cr>'
  if !hasmapto('<plug>' . a:name, a:mode) && (mapcheck(a:keys, a:mode) == "")
    execute a:mode . 'map <silent> ' . a:keys . ' <plug>' . a:name
  endif
endfunction

call <SID>Snippet_SetMapping('n', 'Snippet_InsertSnippet', 'snippet#Insert("n")', '<leader>oi')
call <SID>Snippet_SetMapping('v', 'Snippet_InsertSnippet', 'snippet#Insert("v")', '<leader>oi')
call <SID>Snippet_SetMapping('n', 'Snippet_StoreSnippet', 'snippet#Store("n")', '<leader>os')
call <SID>Snippet_SetMapping('v', 'Snippet_StoreSnippet', 'snippet#Store("v")', '<leader>os')

" }}}

let g:snippet_plugin_loaded = 1
" vim: set fdm=marker ft=vim
