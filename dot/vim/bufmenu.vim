let g:BufMenuEnabled = v:false
let g:BufMenuName = 'buf_menu'
let g:BufMenuList = []
let g:BufMenuDict = {}

" Mark current display buf in the menu.
"
" @linenr: A line number in the buf menu.
function! BufMenuMarkCur(linenr)
    let g:BufMenuCurLineNr = a:linenr
    call win_execute(g:BufMenuWinID, 'match BufMenuCur /\%' . a:linenr . 'l/')
endfunction

" Switch current display buf.
"
" @linenr: A line number in the buf menu.
function! BufMenuSwitchBuf(linenr)
    let found = v:false
    for [k, v] in items(g:BufMenuDict)
        if v['bufmenu_linenr'] == a:linenr
            let found = v:true
            break
        endif
    endfor
    if !found
        return
    endif

    let g:BufMenuLastUsedLineNr = g:BufMenuCurLineNr
    call BufMenuMarkCur(a:linenr)
    call win_execute(g:BufMenuMainWinID, 'buffer ' . k)
    call win_gotoid(g:BufMenuMainWinID)
endfunction

" Switch to next buf.
function! BufMenuNextBuf()
    if !g:BufMenuEnabled
        return
    endif

    let linenr = g:BufMenuCurLineNr + 1
    if linenr > line('$', g:BufMenuWinID)
        let linenr = 1
    endif

    call BufMenuSwitchBuf(linenr)
endfunction

" Switch to previous buf.
function! BufMenuPreviousBuf()
    if !g:BufMenuEnabled
        return
    endif

    let linenr = g:BufMenuCurLineNr - 1
    if linenr <= 0
        let linenr = line('$', g:BufMenuWinID)
    endif

    call BufMenuSwitchBuf(linenr)
endfunction

" Find the line number in the buf menu by the given buf number.
"
" Returns the line number in the buf menu; 0 on failure.
"
" @bufnr: The buf nr.
function! BufMenuFind(bufnr)
    for line in getbufline(g:BufMenuName, 1, '$')
        for v in values(g:BufMenuDict)
            if v['bufnr'] == a:bufnr
                return v['bufmenu_linenr']
            endif
        endfor
    endfor

    return 0
endfunction

" Switch to last used buf.
function! BufMenuSwitchLastUsed()
    if !exists('g:BufMenuLastUsedLineNr')
        return
    endif

    call BufMenuSwitchBuf(g:BufMenuLastUsedLineNr)
endfunction

" Sync buf menu and main window ID.
function! BufMenuSync()
    let bufnr = winbufnr(g:BufMenuMainWinID)

    call BufMenuReload()

    let linenr = BufMenuFind(bufnr)
    if linenr == 0
        return
    endif

    call BufMenuMarkCur(linenr)
endfunction

" Delete cur buf.
function! BufMenuDeleteBuf()
    let bufnr = winbufnr(g:BufMenuMainWinID)
    let buf = getbufinfo(bufnr)[0]
    let i = index(g:BufMenuList, buf.name)
    call remove(g:BufMenuList, i)
    call remove(g:BufMenuDict, buf.name)

    if empty(g:BufMenuList)
        execute 'qall'
    endif

    call BufMenuNextBuf()
    execute 'bwipeout ' . bufnr

    call BufMenuSync()
endfunction

function! BufMenuOpenCWD()
    let bufnr = winbufnr(g:BufMenuMainWinID)
    let info = getbufinfo(bufnr)[0]
    let dir = fnamemodify(info['name'], ':p:h')

    execute 'edit ' . dir
    call BufMenuSync()
endfunction

function! BufMenuDeinit()
    if !g:BufMenuEnabled || expand('<afile>') != g:BufMenuMainWinID
        return
    endif

    call win_execute(g:BufMenuWinID, 'qall!')
    unlet g:BufMenuMainWinID
    unlet g:BufMenuWinID
    unlet g:BufMenuCurLineNr
endfunction

" Reload the buf menu.
function! BufMenuReload()
    call setbufvar(g:BufMenuName, '&modifiable', 1)
    call deletebufline(g:BufMenuName, 1, '$')

    let width = winwidth(g:BufMenuWinID)

    let i = 1
    for file in g:BufMenuList
        let rel_path = g:BufMenuDict[file]['relative_path']

        if len(rel_path) > width
            let rel_path = '...' . rel_path[-(width - 3):]
        endif

        call setbufline(g:BufMenuName, i, rel_path)
        let g:BufMenuDict[file]['bufmenu_linenr'] = i
        let i += 1
    endfor

    call setbufvar(g:BufMenuName, '&modifiable', 0)
endfunction

" Add a file to the menu.  Skip if duplicate.
function! BufMenuAddFile(file)
    let buf = getbufinfo(a:file)[0]

    if has_key(g:BufMenuDict, buf.name)
        return
    endif

    let g:BufMenuList += [buf.name]
    let g:BufMenuDict[buf.name] = {
        \'bufnr': buf.bufnr,
        \'relative_path': fnamemodify(buf.name, ':~:.'),
        \'bufmenu_linenr': 0,
    \}

    call BufMenuSync()
endfunction

" Check if a new file is editing.  If yes, add to the menu.
function! BufMenuCheckEdit()
    let last_cmd = split(histget(':'))

    if len(last_cmd) != 2 || last_cmd[0] != 'e'
        return
    endif

    let file = last_cmd[1]
    if !filereadable(file)
        return
    endif

    call BufMenuAddFile(file)
endfunction

" Init buf menu module.
function! BufMenuInit()
    if g:BufMenuEnabled
        return
    endif
    let g:BufMenuEnabled = v:true
    let g:BufMenuMainWinID = win_getid()

    let width = min([float2nr(winwidth('%') / 5), 80])
    execute 'vertical topleft ' . width . 'vsplit ' . g:BufMenuName
    let g:BufMenuWinID = win_getid()
    setlocal buftype=nofile bufhidden=wipe statusline=%q foldcolumn=0
    setlocal nobuflisted nonu nowrap winfixwidth
    highlight BufMenuCur cterm=bold ctermfg=231 ctermbg=57
    nnoremap <buffer> <CR> :call BufMenuSwitchBuf(line('.'))<CR>

    for file in argv()
        let file = fnamemodify(file, ':~:.')
        let found = v:false

        for buf in getbufinfo()
            if fnamemodify(buf.name, ':~:.') == file
                let found = v:true
                break
            endif
        endfor
        if !found
            continue
        endif

        let g:BufMenuList += [buf.name]
        let g:BufMenuDict[buf.name] = {
            \'bufnr': buf.bufnr,
            \'relative_path': file,
            \'bufmenu_linenr': 0,
        \}
    endfor

    call BufMenuSync()
    call win_gotoid(g:BufMenuMainWinID)

    autocmd BufWinEnter * call BufMenuCheckEdit()
    autocmd WinClosed * call BufMenuDeinit()

    nnoremap <LEADER>bs :call BufMenuSwitchLastUsed()<CR>
    nnoremap <LEADER>bn :call BufMenuAddFile(expand('%'))<CR>
    nnoremap <LEADER>bd :call BufMenuDeleteBuf()<CR>
    nnoremap <LEADER>bo :call BufMenuOpenCWD()<CR>
    nnoremap <C-L> :call BufMenuNextBuf()<CR>
    nnoremap <C-H> :call BufMenuPreviousBuf()<CR>
endfunction
nnoremap <LEADER>bm :call BufMenuInit()<CR>
