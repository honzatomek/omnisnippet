" GREP Operator, based on Learn Vim Script the Hard Way
"
" Author: Jan Tomek <rpi3.tomek@protonmail.com>
" Date:   21.4.2020

"--------------------------------------------------------<key mappings>--- {{{1
" set operator function and call it with g@, mode is sent automatically as arg
nnoremap          <leader>g     :set operatorfunc=<SID>GrepOperator<cr>g@
" for visual no movement tracking needed, send visual mode as argument
vnoremap          <leader>g     :<c-u>call <SID>GrepOperator(visualmode())<cr>

"-----------------------------------------------------<global settings>--- {{{1
" open quickfix window in vertical split (1), horizontal (0)
if !exists("g:grep_operator_vertical")
    let g:grep_operator_vertical = 1
endif

" set default quickfix window size, 60 for vertical, 10 for horizontal
if !exists("g:grep_operator_quickfix_size")
    if g:grep_operator_vertical
        let g:grep_operator_quickfix_size = 60
    else
        let g:grep_operator_quickfix_size = 10
    endif
endif

" set default quickfix window position
" possible positions
let g:grep_operator_positions = ["leftabove", "lefta", "aboveleft", "abo",
                                \"rightbelow", "rightb", "belowright", "bel",
                                \"topleft", "to", "botright", "bo"]
if !exists("g:grep_operator_position")
    let g:grep_operator_position = "botright"
elseif index(g:grep_operator_positions, g:grep_operator_position) == -1
    let g:grep_operator_position = "botright"
endif

" set default of quickfix to nowrap mode
if !exists("g:grep_operator_wrap")
    let g:grep_operator_wrap = 0
endif

"-------------------------------------------------------<grep function>--- {{{1
function! s:GrepOperator(type)
    " save current text in the unnamed register into variable
    let l:saved_unnamed_register = @@

    " check for selection type
    if a:type ==# 'v'           " visual mode - chars
        normal! `<v`>y
    elseif a:type ==# 'char'    " character mode from movement
        normal! `[y`]
    else                        " visual line and visual block - do nothing
        return
    endif

    " silently execute grep and redir output do vim quickfix buffer
    silent execute "grep! -R " . shellescape(@@) . " ."
    " redraw to fix display
    redraw!
    " open quickfix window
    if g:grep_operator_vertical
        execute "vertical " . g:grep_operator_position . " copen " . string(g:grep_operator_quickfix_size)
    else
        execute g:grep_operator_position . " copen " . string(g:grep_operator_quickfix_size)
    endif

    " set quickfix window wrapping
    if g:grep_operator_wrap
        setlocal wrap
    else
        setlocal nowrap
    endif
    " wincmd L
    " silent execute "vertical resize " . string(g:grep_operator_quickfix_width)
    " setlocal nowrap

    " restore previously yanked text back into the unnamed register
    let @@ = l:saved_unnamed_register
endfunction

