const s:FugitiveStatusVar = 'fugitive_status'
const s:FugitiveDiffVar = 'fugitive_diff_restore'
const s:FugitiveNoteVar = 'fugitive_note'
const s:FugitiveCommitVar = 'fugitive_commit'
const s:GitNoteBufName = 'git_note'

function! s:_FindWinNr(var)
    for l:winnr in range(1, winnr('$'))
        if !empty(getwinvar(l:winnr, a:var))
            return l:winnr
        endif
    endfor

    return -1
endfunction

function! FugitiveExitDiff()
    if BufMenuEnabled()
        for l:winnr in range(1, winnr('$'))
            if empty(getwinvar(l:winnr, s:FugitiveDiffVar))
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
        if empty(getwinvar(l:winnr, s:FugitiveDiffVar))
            continue
        endif

        call win_gotoid(win_getid(l:winnr))
        nnoremap <buffer> <LEADER>df :call FugitiveExitDiff()<CR>
    endfor

    " Go back to original window.
    call win_gotoid(l:winid)
endfunction

function! FugitiveGitStatus()
    let l:winnr = s:_FindWinNr(s:FugitiveStatusVar)
    if l:winnr != -1
        " The git status is a singleton.  After closing it, it can return.
        execute l:winnr 'close'
        return
    endif

    let l:width = min([float2nr(&columns / 3), 80])

    execute 'vertical botright G'
    execute 'vertical resize' l:width
    setlocal statusline=%q foldcolumn=0 nonu nowrap winfixwidth
    nnoremap <buffer> <LEADER>df :call FugitiveViewDiff()<CR>
    nnoremap <buffer> <LEADER>cc :call FugitiveCommit()<CR>
endfunction
nnoremap <LEADER>gs :call FugitiveGitStatus()<CR>

function! FugitiveGitNote()
    let l:winnr = s:_FindWinNr(s:FugitiveNoteVar)
    if l:winnr != -1
        " The git note is a singleton.  After closing it, it can return.
        execute l:winnr 'close'
        return
    endif

    let l:gs_winnr = s:_FindWinNr(s:FugitiveStatusVar)
    let l:cc_winnr = s:_FindWinNr(s:FugitiveCommitVar)
    if l:gs_winnr != -1
        call win_gotoid(win_getid(l:gs_winnr))
        execute 'horizontal belowright new' s:GitNoteBufName
    elseif l:cc_winnr != -1
        call win_gotoid(win_getid(l:cc_winnr))
        execute 'horizontal belowright new' s:GitNoteBufName
    else
        let l:width = min([float2nr(&columns / 3), 80])
        execute 'vertical botright' l:width .. 'vnew' s:GitNoteBufName
    endif

    setlocal statusline=%q foldcolumn=0 nonu nowrap winfixwidth
    set filetype=gitcommit buftype=nofile
    call setwinvar(win_getid(), s:FugitiveNoteVar, v:true)
endfunction
nnoremap <LEADER>gn :call FugitiveGitNote()<CR>

function! FugitiveCommit()
    execute 'horizontal belowright Git commit -s'
    call setwinvar(win_getid(), s:FugitiveCommitVar, v:true)

    let l:bufnr = bufnr(s:GitNoteBufName)
    if l:bufnr != -1
        call append(0, getbufline(l:bufnr, 1, '$'))
    endif
endfunction
