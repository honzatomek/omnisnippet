" Vim autoload file for omnisnippet
"
"     Plugin :  omnisnippet.vim
"     Author :  Jan Tomek <rpi3.tomek@protonmail.com>
"
" -----------------------------------------------------------------
" ===< set filetype-dependent variables >================================== {{{1
" snippets location
let s:omnisnippet_snippets_location = g:omnisnippet_snippets_location . "/" . &ft
let s:omnisnippet_snippets_extension = expand("%:e")

" create the path if it does not exist
function! omnisnippet#OmniSnippet_CheckDir(snippet_path) " ================ {{{1
    if !isdirectory(a:snippet_path)
        call mkdir(a:snippet_path, "p")
        echom '[+] Created non-exsisting snippet directory: ' . a:snippet_path
    endif
endfunction

function! omnisnippet#Read(mode) " ======================================== {{{1
    if !isdirectory(s:omnisnippet_snippets_location)
        echom '[-] No snippets stored for the current filetype: ' . &ft
        return
    endif

    let l:snippets = globpath(s:omnisnippet_snippets_location, "**/*." . s:omnisnippet_snippets_extension, 0, 1)
    if len(l:snippets) == 0
        echom '[-] No snippets stored for the current filetype: ' . &ft
        return
    endif
    call omnisnippet#OmniSnippet_StoreDefaults()

    setlocal completefunc=omnisnippet#OmniSnippet_Complete
    let &completeopt="menu,menuone,preview"

    inoremap <buffer><silent><expr> <CR>     omnisnippet#OmniSnippet_MapEnter()
    inoremap <buffer><silent><expr> <kEnter> omnisnippet#OmniSnippet_MapEnter()
    inoremap <buffer><silent><expr> <C-Y>    omnisnippet#OmniSnippet_MapCtrlY()
    inoremap <buffer><silent><expr> <ESC>    omnisnippet#OmniSnippet_MapEsc()

    normal! o
    normal! k
    startinsert
    call feedkeys("\<c-x>\<c-u>")
endfunction

function! omnisnippet#Write(mode ) range " ================================ {{{1
    if a:mode ==# "n"
        let l:snippet = getline(1, "$")
    elseif a:mode ==# "v"
        let l:snippet = getline("'<", "'>")
    else
        let l:snippet = getline(1, "$")
    endif

    let l:snippet = split(substitute(join(l:snippet, "\r"), "\v(^(\r|\s)+|(\r|\s)+$)", "", ""), "\r")

    let l:indent = match(l:snippet[0], "\\S")
    for l:i in range(len(l:snippet))
        if l:snippet[l:i][: l:indent] =~ "\\s*"
            let l:snippet[ l:i ] = strpart(l:snippet[ l:i ], l:indent)
        endif
    endfor

    let l:cwd = getcwd()

    call omnisnippet#OmniSnippet_CheckDir(s:omnisnippet_snippets_location)
    execute ":cd " . s:omnisnippet_snippets_location

    let l:snippet_name = omnisnippet#GetInput()
    if l:snippet_name == "" | return | endif
    if fnamemodify(l:snippet_name, ':e') !=# s:omnisnippet_snippets_extension
        let l:snippet_name .= "." . s:omnisnippet_snippets_extension
    endif

    call omnisnippet#OmniSnippet_CheckDir(fnamemodify(l:snippet_name, ":h"))
    silent call writefile(l:snippet, l:snippet_name, "s")
    echom '[+] ' . l:snippet_name . ' written.'

    execute ":cd " . l:cwd
endfunction

function! omnisnippet#GetInput() " ======================================== {{{1
    silent call inputsave()
    let l:retVal = input('Input Snippet Name: ', '', 'file')
    silent call inputrestore()
    return l:retVal
endfunction

" custom omnicomplete function
function! omnisnippet#OmniSnippet_Complete(findstart, base) " ============= {{{1
    if a:findstart
        return 1
    else
        let l:items = omnisnippet#OmniSnippet_GetSnippets()
        return l:items
    endif
endfunction

function! omnisnippet#OmniSnippet_GetSnippets() " ========================= {{{1
    let l:snippets = []
    call extend(l:snippets, globpath(s:omnisnippet_snippets_location, "*." . s:omnisnippet_snippets_extension, 0, 1))
    call extend(l:snippets, globpath(s:omnisnippet_snippets_location, "*/*." . s:omnisnippet_snippets_extension, 0, 1))
    call extend(l:snippets, globpath(s:omnisnippet_snippets_location, "*/**/*." . s:omnisnippet_snippets_extension, 0, 1))
    if len(l:snippets) <= 0
        return
    else
        call map(l:snippets, "substitute(v:val, \"" . escape(s:omnisnippet_snippets_location, '.*()|') . "/\", \"\", \"\")")
        return l:snippets
    endif
endfunction

function! omnisnippet#OmniSnippet_InsertSnippet() " ======================= {{{1
" replace completion result from the function above with the contents of the
" file
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

    " restore defaults
    call omnisnippet#OmniSnippet_RestoreDefaults()
endfunction

function! omnisnippet#OmniSnippet_StoreDefaults() " ======================= {{{1
    if !empty(&completefunc)
        let s:omnisnippet_completefunc_backup = &completefunc
    endif
    if !empty(&completeopt)
        let s:omnisnippet_completeopt_backup = &completeopt
    endif

    setlocal completefunc=omnisnippet#OmniSnippet_Complete
    let &completeopt="menu,menuone,preview"

    let s:omnisnippet_mappings_backup = omnisnippet#Save_mappings(['<CR>', '<kEnter>', '<C-Y>', '<Esc>', '<C-N>'], 'i', 0)
    echom '[+] Defaults stored.'
endfunction

function! omnisnippet#OmniSnippet_RestoreDefaults() " ===================== {{{1
    if exists("s:omnisnippet_completefunc_backup")
        let &completefunc = s:omnisnippet_completefunc_backup
    endif
    if exists("s:omnisnippet_completeopt_backup")
        let &completeopt = s:omnisnippet_completeopt_backup
    endif
    if exists("s:omnisnippet_mappings_backup")
        if !empty("s:omnisnippet_mappings_backup")
            call omnisnippet#Restore_mappings(s:omnisnippet_mappings_backup)
        endif
    endif
    echom '[+] Defaults restored.'
endfunction

function! omnisnippet#Save_mappings(keys, mode, global) abort " =========== {{{1
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

function! omnisnippet#Restore_mappings(mappings) abort " ================== {{{1
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

function! omnisnippet#OmniSnippet_MapCtrlY() " ============================ {{{1
    if !pumvisible()
        return "\<C-Y>"
    else
        return "\<ESC>:call omnisnippet#OmniSnippet_InsertSnippet()\<CR>"
    endif
endfunction

function! omnisnippet#OmniSnippet_MapEnter() " ============================ {{{1
    if !pumvisible()
        return "\<CR>"
    else
        return "\<CR>\<ESC>:call omnisnippet#OmniSnippet_InsertSnippet()\<CR>"
    endif
endfunction

function! omnisnippet#OmniSnippet_MapEsc() " ============================== {{{1
    if !pumvisible()
        return "\<ESC>"
    else
        return "\<ESC>:normal dd\<CR>:call omnisnippet#OmniSnippet_RestoreDefaults()\<CR>"
    endif
endfunction

" }}}

" vim:set ft=vim:set fdm=marker:
