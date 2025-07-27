function! FugitiveExitDiff()
    if BufMenuEnabled()
        for l:winnr in range(1, winnr('$'))
            if empty(getwinvar(l:winnr, 'fugitive_diff_restore'))
                continue
            endif

            " Don't close buf menu's main window.  Otherwise, the whole vim
            " will be closed.
            if win_getid(l:winnr) != g:BufMenuMainWinID
                execute l:winnr 'close'
            endif
        endfor

        call BufMenuSwitchBuf(g:BufMenuCurLineNr)
    endif

    " Show back the git status.
    call FugitiveGitStatus()
endfunction

function! FugitiveViewDiff()
    " Key map from fugitive-vim.  Gvsplitdiff.
    normal dv

    " Hide the git status.
    call FugitiveGitStatus()

    " Save original window-ID.
    let l:winid = win_getid(winnr())

    " Set buffer-specific nmap for exiting diff.
    for l:winnr in range(1, winnr('$'))
        if empty(getwinvar(l:winnr, 'fugitive_diff_restore'))
            continue
        endif

        call win_gotoid(win_getid(l:winnr))
        nnoremap <buffer> <LEADER>df :call FugitiveExitDiff()<CR>
    endfor

    " Go back to original window.
    call win_gotoid(l:winid)
endfunction

function! FugitiveGitStatus()
    for l:winnr in range(1, winnr('$'))
        if empty(getwinvar(l:winnr, 'fugitive_status'))
            continue
        endif

        " The git status is a singleton.  After closing it, it can return.
        execute l:winnr 'close'
        return
    endfor

    let l:width = min([float2nr(&columns / 3), 80])

    execute 'vertical botright G'
    execute 'vertical resize' l:width
    setlocal statusline=%q foldcolumn=0 nonu nowrap winfixwidth
    nnoremap <buffer> <LEADER>df :call FugitiveViewDiff()<CR>
endfunction
nnoremap <LEADER>gs :call FugitiveGitStatus()<CR>
