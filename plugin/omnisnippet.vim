" Vim plugin file for omnisnippet
"
"     Plugin :  omnisnippet.vim
"     Author :  Jan Tomek <rpi3.tomek@protonmail.com>
"
" -----------------------------------------------------------------
if exists("b:omnisnippet_plugin")
  finish
endif

"===< global names >======================================================= {{{1
let g:omnisnippet_name = 'omnisnippet'
let g:omnisnippet_snippets = 'snippets'

"===< get/set global variables functions >================================= {{{1
function! s:OmniSnippet_SetGlobalVariable(name, default)
  if !exists('g:' . a:name)
    execute "let g:" . a:name . " = '" . a:default . "'"
  else
    execute 'let tmp = g:' . a:name
    if empty(tmp)
      execute "let g:" . a:name . " = '" . a:default . "'"
    endif
  endif
endfunction

function! s:OmniSnippet_GetGlobalVariable(name)
  if exists('g:' . a:name)
    execute 'let s:' a:name . ' = g:' . a:name
  endif
endfunction

"===< keymaps function >=================================================== {{{1
function! s:OmniSnippet_SetMapping(keys, function_name, mode, args)
  execute a:mode . 'noremap <silent> <buffer> <leader>' . a:keys . ' :call omnisnippet#' . a:function_name . '("' . a:args . '")<CR>'
endfunction

"===< set global variables if not set >==================================== {{{1
" check if plugin installed, otherwise finish
for omnisnippet_path in split(&rtp, ',')
  if split(omnisnippet_path, '/')[-1] ==# g:omnisnippet_name
    call <SID>OmniSnippet_SetGlobalVariable('omnisnippet_plugin_location', omnisnippet_path)
  endif
endfor
if !exists("g:omnisnippet_plugin_location") | finish | endif

" set snippets location
call <SID>OmniSnippet_SetGlobalVariable('omnisnippet_snippets_location', g:omnisnippet_plugin_location . "/" . g:omnisnippet_snippets)

" set keys for keymaps
call <SID>OmniSnippet_SetGlobalVariable('omnisnippet_read_keymap', 'or')
call <SID>OmniSnippet_SetGlobalVariable('omnisnippet_write_keymap', 'ow')

"===< set keymaps >======================================================== {{{1
call <SID>OmniSnippet_SetMapping(g:omnisnippet_read_keymap, 'Read', 'n', 'n')
call <SID>OmniSnippet_SetMapping(g:omnisnippet_read_keymap, 'Read', 'v', 'v')
call <SID>OmniSnippet_SetMapping(g:omnisnippet_write_keymap, 'Write', 'n', 'n')
call <SID>OmniSnippet_SetMapping(g:omnisnippet_write_keymap, 'Write', 'v', 'v')

" }}}
let b:omnisnippet_plugin = 1
" vim: set fdm=marker ft=vim
