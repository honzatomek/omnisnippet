" omnisnippet.vim - Vim plugin file for OmniSnippet
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
" TODO:  1) Snippets preview: tags file? ->
"           snippet_name{TAB}filename{TAB}location
"        2) tests of all functions and externalised global settings
"        3) print messages only in verbose mode
"
" NOTES: 1) buffer-local variable of snippet path - what if filetype changed
"           in the same buffer?
"
"########################################################################

" load plugin only once ================================================= {{{1
if exists("g:omnisnippet_plugin_loaded")
  finish
endif

" set plugin location =================================================== {{{1
if !exists("g:omnisnippet_plugin_location")
  let g:omnisnippet_plugin_location = fnamemodify(resolve(expand("<sfile>:p")), ":h:h")
else
  let g:omnisnippet_plugin_location = substitute(g:omnisnippet_plugin_location, "/$", "", "")
endif

" set snippets location ================================================= {{{1
if !exists("g:omnisnippet_snippets_location")
  let g:omnisnippet_snippets_location = g:omnisnippet_plugin_location . "/snippets"
else
  let g:omnisnippet_snippets_location = substitute(g:omnisnippet_snippets_location, "/$", "", "")
endif

" set filetype specific snippet location ================================ {{{1
function! s:OmniSnippet_SetFiletypeSpecifics(filetype)
  echom '[i] OmniSnippet filetype: ' . a:filetype
  if !exists("g:omnisnippet_snippets_" . a:filetype)
    execute "let g:omnisnippet_snippets_" . a:filetype . " =  g:omnisnippet_snippets_location . \"/" . a:filetype . "\""
  else
    execute "let g:omnisnippet_snippets_" . a:filetype . " = substitute(g:omnisnippet_snippets_" . a:filetype . ", \"/$\", \"\", \"\")"
  endif
endfunction

augroup OmniSnippet
  autocmd!
  autocmd FileType * :call <SID>OmniSnippet_SetFiletypeSpecifics(&filetype)
augroup END

" set plugin keymaps ==================================================== {{{1
function! s:OmniSnippet_SetMapping(mode, name, function, keys)
  execute a:mode . 'noremap <silent> <plug>' . a:name . ' :call ' . a:function . '<cr>'
  if !hasmapto('<plug>' . a:name, a:mode) && (mapcheck(a:keys, a:mode) == "")
    execute a:mode . 'map <silent> ' . a:keys . ' <plug>' . a:name
  endif
endfunction

call <SID>OmniSnippet_SetMapping('n', 'OmniSnippet_InsertSnippet', 'omnisnippet#Insert("n")', '<leader>oi')
call <SID>OmniSnippet_SetMapping('v', 'OmniSnippet_InsertSnippet', 'omnisnippet#Insert("v")', '<leader>oi')
call <SID>OmniSnippet_SetMapping('n', 'OmniSnippet_StoreSnippet', 'omnisnippet#Store("n")', '<leader>os')
call <SID>OmniSnippet_SetMapping('v', 'OmniSnippet_StoreSnippet', 'omnisnippet#Store("v")', '<leader>os')

" }}}

let g:omnisnippet_plugin_loaded = 1
" vim: set fdm=marker ft=vim
