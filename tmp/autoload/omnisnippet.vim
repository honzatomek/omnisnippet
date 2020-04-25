" Vim autoload file for omnisnippet
"
"     Plugin :  omnisnippet.vim
"     Author :  Jan Tomek <rpi3.tomek@protonmail.com>
"
" -----------------------------------------------------------------
" set snippets location based on filetype
if &ft ==# 'permas_dat'
    let s:omnisnippet_snippets_location = g:omnisnippet_plugin_location . "/dat_entries"
    let s:omnisnippet_snippets_extension = expand("%:e")

    " let s:omnisnippet_completefunc_backup = ""
    " let s:omnisnippet_completeopt_backup = ""
    " let s:omnisnippet_mappings_backup = ""
else
    finish
endif

" create the path if it does not exist
function! s:OmniSnippet_CheckDir() " ====================================== {{{1
    if !isdirectory(s:omnisnippet_snippets_location)
        call mkdir(s:omnisnippet_snippets_location, "p")
        echom "Created non-exsisting snippet directory: " . s:omnisnippet_snippets_location
    endif
endfunction

function! omnisnippet#Read(mode) " ======================================== {{{1
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
        let s:omnisnippet_completefunc_backup = &completefunc
    endif
    if !empty(&completeopt)
        let s:omnisnippet_completeopt_backup = &completeopt
    endif

    setlocal completefunc=omnisnippet#OmniSnippet_Complete
    let &completeopt="menu,menuone,preview"

    let s:omnisnippet_mappings_backup = omnisnippet#Save_mappings(['<CR>', '<kEnter>', '<C-Y>', '<Esc>'], 'i', 0)
    inoremap <buffer><silent><expr> <CR>     omnisnippet#OmniSnippet_MapEnter()
    inoremap <buffer><silent><expr> <kEnter> omnisnippet#OmniSnippet_MapEnter()
    inoremap <buffer><silent><expr> <C-Y>    omnisnippet#OmniSnippet_MapCtrlY()
    inoremap <buffer><silent><expr> <ESC>    omnisnippet#OmniSnippet_MapEsc()

    normal! o
    normal! k
    startinsert
    call feedkeys("\<c-x>\<c-u>")
endfunction

function! omnisnippet#Write(mode) range " ================================= {{{1
    "   echom 'Mode: ' . a:mode
    call <SID>OmniSnippet_CheckDir()

    if a:mode ==# "n"
        let l:snippet = getline(1, "$")
    elseif a:mode ==# "v"
        let l:snippet = getline("'<", "'>")
    else
        let l:snippet = getline(1, "$")
    endif

    let l:snippet = split(substitute(join(l:snippet, "\r"), "\v(^(\r|\s)+|(\r|\s)+$)", "", ""), "\r")
    echo l:snippet

    let l:indent = match(l:snippet[0], "\\S")
    echom "Indent: " . l:indent
    for l:i in range(len(l:snippet))
        if l:snippet[l:i][: l:indent] =~ "\\s*"
            let l:snippet[ l:i ] = strpart(l:snippet[ l:i ], l:indent)
        endif
    endfor
    echo l:snippet

    "   let l:snippet_name = l:snippet[0][match(l:snippet[0], "\\$")+1 : match(l:snippet[0], "\\s")]
    "   echo l:snippet_name

    let l:cwd = getcwd()
    echom s:omnisnippet_snippets_location
    execute ":cd " . s:omnisnippet_snippets_location

    let l:snippet_name = omnisnippet#GetInput()
    if l:snippet_name !~ "\v.*\." . s:omnisnippet_snippets_extension
        let l:snippet_name .= "." . s:omnisnippet_snippets_extension
    endif
    echom "Writing " . &ft . " snippet: " . l:snippet_name
    silent call writefile(l:snippet, l:snippet_name)

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
        " let l:snippets = globpath(s:omnisnippet_snippets_location, "*." . s:omnisnippet_snippets_extension, 0, 1)
        " call map(l:snippets, "fnamemodify(v:val, \":t\")")
        let l:snippets = omnisnippet#OmniSnippet_Dat()
        return l:snippets
    endif
endfunction

" replace completion result from the function above with the contents of the
" file
function! omnisnippet#OmniSnippet_InsertSnippet() " ======================= {{{1
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
        return "\<ESC>:normal ddo\<CR>:call omnisnippet#OmniSnippet_RestoreDefaults()\<CR>"
    endif
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

function s:Map(list, expr) " ============================================== {{{1
    let l:list = deepcopy(a:list)
    call map(l:list, a:expr)
    return l:list
endfunction

function s:GetMinItem(dict) " ============================================= {{{1
    let l:dict = <SID>Map(a:dict, "search(v:val, 'nb')")
    call filter(l:dict, "v:val > 0")
    if len(l:dict) == 0
        return ["none", 0]
    else
        let l:idx = min(l:dict)
        call filter(l:dict, "v:val == " . l:idx)
        return [keys(l:dict)[0], values(l:dict)[0]]
    endif
endfunction

function s:IsInside(dict) " =============================================== {{{1
    let l:dict = deepcopy(a:dict)

    call filter(l:dict, "search(v:val[0], 'nbW') > search(v:val[1], 'nbW')")

    call map(l:dict, "[search(v:val[0], 'nbW'), search(v:val[1], 'nW')]")
    call filter(l:dict, "v:val[0] > 0 || v:val[1] > 0")
    if len(l:dict) == 0
        return "none"
    else
        " call map(l:dict, "v:val[1] - v:val[0]")
        " call filter(l:dict, "v:val > 0")
        call map(l:dict, "v:val[0] < line('.') && v:val[1] > line('.')")
        call filter(l:dict, "v:val")
        if len(l:dict) == 0
            return "none"
        else
            return keys(l:dict)[0]
        endif
    endfunction

    function! omnisnippet#OmniSnippet_Dat()
        let l:header = {"component": ['\v\c^\s*\$enter\s+component', '\v\c^\s*\$exit\s+component'],
                    \"material": ['v\c^\s*\$enter\s+material', '\v\c^\s*\$exit\s+material']}

        let l:closest_header = s:IsInside(l:header)
        echom "Closest Header: " . l:closest_header
        if l:closest_header ==# "none"
            " let l:items = globpath(s:omnisnippet_snippets_location, "**/*." . s:omnisnippet_snippets_extension . "*", 0, 1)
            let l:items = globpath(s:omnisnippet_snippets_location, "*." . s:omnisnippet_snippets_extension . "*", 0, 1)
            call extend(l:items, globpath(s:omnisnippet_snippets_location, "*/*." . s:omnisnippet_snippets_extension . "*", 0, 1))
            call extend(l:items, globpath(s:omnisnippet_snippets_location, "*/**/*." . s:omnisnippet_snippets_extension . "*", 0, 1))

        else
            let l:omnisnippet_snippets_location = s:omnisnippet_snippets_location . "/" . l:closest_header
            let l:variant_names = globpath(l:omnisnippet_snippets_location, "*/", 0, 1)
            call map(l:variant_names, "fnamemodify(v:val[:-2], ':t')")

            let l:variant = {}
            for l:v in l:variant_names
                call extend(l:variant, {l:v : ['\v\c^\s*\$' . l:v , '\v\c^\s*\$end\s+' . l:v]})
            endfor

            echom "Available Variants: " . join(values(l:variant), " ")

            let l:closest_variant = s:IsInside(l:variant)
            echom "Closest Variant: " . l:closest_variant

            if l:closest_variant ==# "none"
                let l:items = globpath(l:omnisnippet_snippets_location, "*" . s:omnisnippet_snippets_extension . "*", 0, 1)
                call map(l:items, "substitute(v:val, \"" . escape(s:omnisnippet_snippets_location, '.*()|') . "/\", \"\", \"\")")
            else
                let l:omnisnippet_snippets_location .= "/" . l:closest_variant
                let l:items = globpath(l:omnisnippet_snippets_location, "*" . s:omnisnippet_snippets_extension . "*", 0, 1)
            endif
        endif
        call map(l:items, "substitute(v:val, \"" . escape(s:omnisnippet_snippets_location, '.*()|') . "/\", \"\", \"\")")
        return l:items
    endfunction

