" https://www.reddit.com/r/vim/comments/8w3udw/topnotch_vim_file_backup_history_with_no_plugins/
if exists('g:loaded_gitbackup')
    finish
endif
let g:loaded_gitbackup = 1

augroup custom_backup
    autocmd!
    autocmd BufWritePost * call BackupCurrentFile()
augroup end

if !exists('g:custom_backup_dir')
    let g:custom_backup_dir='~/.vim_gitbackup'
endif
" let s:custom_backup_dir='~/.vim_custom_backups'
function! BackupCurrentFile()
    if !isdirectory(expand(g:custom_backup_dir))
        let cmd = 'mkdir -p ' . g:custom_backup_dir . ';'
        let cmd .= 'cd ' . g:custom_backup_dir . ';'
        let cmd .= 'git init;'
        call system(cmd)
    endif
    if expand('%:t') =~ '\.tmp.*'
        return
    endif
    let file = expand('%:p')
    if file =~ fnamemodify(g:custom_backup_dir, ':t') | return | endif
    let file_dir = g:custom_backup_dir . expand('%:p:h')
    let backup_file = g:custom_backup_dir . file
    let cmd = ''
    if !isdirectory(expand(file_dir))
        let cmd .= 'mkdir -p ' . file_dir . ';'
    endif
    let cmd .= 'cp ' . file . ' ' . backup_file . ';'
    let cmd .= 'cd ' . g:custom_backup_dir . ';'
    let cmd .= 'git add ' . backup_file . ';'
    let cmd .= 'git commit -m "Backup - `date`";'
    " echom cmd
    " call jobstart(cmd)
    " call job_start(cmd)
    silent exec '!' . cmd
    " echom backup_file . ' backed up...'
    redraw!
endfunction
