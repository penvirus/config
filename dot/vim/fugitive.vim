function! FugitiveExitDiff()
    if BufMenuEnabled()
        for l:winnr in range(1, winnr('$'))
            if !empty(getwinvar(l:winnr, 'fugitive_diff_restore'))
                if win_getid(l:winnr) != g:BufMenuMainWinID
                    execute l:winnr . 'close'
                endif
            endif
        endfor

        call BufMenuSwitchBuf(g:BufMenuCurLineNr)
    endif

    " Show the git status
    call FugitiveGitStatus()
endfunction

function! FugitiveViewDiff()
    normal dv
    " Hide the git status
    call FugitiveGitStatus()

    let l:orig_winid = win_getid(winnr())

    for l:winnr in range(1, winnr('$'))
        if !empty(getwinvar(l:winnr, 'fugitive_diff_restore'))
            call win_gotoid(win_getid(l:winnr))
            "autocmd! BufWinLeave <buffer> call FugitiveExitDiff()
            nnoremap <buffer> <LEADER>df :call FugitiveExitDiff()<CR>
        endif
    endfor

    call win_gotoid(l:orig_winid)
endfunction

function! FugitiveGitStatus()
    for l:winnr in range(1, winnr('$'))
        if !empty(getwinvar(l:winnr, 'fugitive_status'))
            execute l:winnr . 'close'
            return
        endif
    endfor

    let l:width = min([float2nr(&columns / 3), 80])

    execute 'vertical botright G'
    execute 'vertical resize ' . l:width
    setlocal statusline=%q foldcolumn=0 nonu nowrap winfixwidth
    nnoremap <buffer> <LEADER>df :call FugitiveViewDiff()<CR>
endfunction
nnoremap <LEADER>gs :call FugitiveGitStatus()<CR>
