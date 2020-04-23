" Vim autoload file for omnisnippet
"
"     Plugin :  omnisnippet.vim
"     Author :  Jan Tomek <rpi3.tomek@protonmail.com>
"
" -----------------------------------------------------------------
" set snippets location based on filetype
let s:omnisnippet_snippets_location = g:omnisnippet_snippets_location . "/" . &ft

" create the path if it does not exist
if !isdirectory(s:omnisnippet_snippets_location)
  call mkdir(s:omnisnippet_snippets_location, "p")
  echom "Created non-exsisting snippet directory: " . s:omnisnippet_snippets_location
endif

function! omnisnippet#Read()
  echom "Read from" . s:omnisnippet_snippets_location
endfunction

function! omnisnippet#Write()
  echom "Write" . &ft
endfunction

