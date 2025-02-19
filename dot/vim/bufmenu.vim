let g:BufMenuEnabled = 0
let g:BufMenuName = 'buf_menu'

function! BufMenuToBuf(line)
    return split(trim(a:line), '\t')[0]
endfunction

function! BufMenuMarkCur(nr)
    let g:BufMenuCurBufNr = a:nr
    call win_execute(g:BufMenuWinID, 'match BufMenuCur /\%' . a:nr . 'l/')
endfunction

function! BufMenuSwitchBuf(nr)
    if a:nr <= 1
        return
    endif

    call BufMenuMarkCur(a:nr)
    let name = BufMenuToBuf(getbufoneline(g:BufMenuName, a:nr))

    let g:BufMenuLastUsedBufNr = winbufnr(g:BufMenuMainWinID)
    call win_execute(g:BufMenuMainWinID, 'buffer ' . name)
    call win_gotoid(g:BufMenuMainWinID)
endfunction

function! BufMenuNextBuf()
    if !g:BufMenuEnabled
        return
    endif

    let g:BufMenuCurBufNr += 1
    if g:BufMenuCurBufNr > line('$', g:BufMenuWinID)
        let g:BufMenuCurBufNr = 2
    endif

    call BufMenuSwitchBuf(g:BufMenuCurBufNr)
endfunction

function! BufMenuPreviousBuf()
    if !g:BufMenuEnabled
        return
    endif

    let g:BufMenuCurBufNr -= 1
    if g:BufMenuCurBufNr <= 1
        let g:BufMenuCurBufNr = line('$', g:BufMenuWinID)
    endif

    call BufMenuSwitchBuf(g:BufMenuCurBufNr)
endfunction

function! BufMenuFind(nr)
    let i = 2
    for line in getbufline(g:BufMenuName, 2, '$')
        if BufMenuToBuf(line) == a:nr
            return i
        endif

        let i += 1
    endfor

    return -1
endfunction

function! BufMenuSwitchLastUsed()
    if !exists('g:BufMenuLastUsedBufNr')
        return
    endif

    let nr = BufMenuFind(g:BufMenuLastUsedBufNr)
    if nr == -1
        return
    endif

    call BufMenuSwitchBuf(nr)
endfunction

function! BufMenuSaveLastUsedBuf()
    if !g:BufMenuEnabled || win_getid() != g:BufMenuMainWinID
	return
    endif

    let g:BufMenuLastUsedBufNr = winbufnr(g:BufMenuMainWinID)
endfunction

function! BufMenuSelect(init)
    if a:init
        let bufnr = winbufnr(g:BufMenuMainWinID)
    else
        if !g:BufMenuEnabled || win_getid() != g:BufMenuMainWinID
            return
        endif

	let bufnr = expand('<abuf>')
    endif

    call BufMenuReload()

    let nr = BufMenuFind(bufnr)
    if nr == -1
        return
    endif

    call BufMenuMarkCur(nr)
endfunction

function! BufMenuDeleteBuf()
    let bufnr = winbufnr(g:BufMenuMainWinID)
    call BufMenuNextBuf()
    execute 'bwipeout ' . bufnr
    call BufMenuReload()
endfunction

function! BufMenuDeinit()
    if !g:BufMenuEnabled || expand('<afile>') != g:BufMenuMainWinID
        return
    endif

    call win_execute(g:BufMenuWinID, 'qall')
    unlet g:BufMenuMainWinID
    unlet g:BufMenuWinID
    unlet g:BufMenuCurBufNr
endfunction

function! BufMenuReload()
    call setbufvar(g:BufMenuName, '&modifiable', 1)
    call deletebufline(g:BufMenuName, 1, '$')

    let width = winwidth(g:BufMenuWinID)
    call setbufline(g:BufMenuName, 1, printf("%3s\t%s", "Buf", "File"))

    let i = 2
    for buf in getbufinfo()
        if bufname(buf['bufnr']) == g:BufMenuName
            continue
        endif

        let str = printf("%3s\t", buf['bufnr'])
	let fname = fnamemodify(buf['name'], ':~:.')

        " the first tab == 8 columns
	if 8 + len(fname) > width
	    let fname = '...' . fname[-(width - 8 - 3):]
	endif
	let str .= fname

        call setbufline(g:BufMenuName, i, str)
        let i += 1
    endfor

    call setbufvar(g:BufMenuName, '&modifiable', 0)
endfunction

function! BufMenuInit()
    if g:BufMenuEnabled
        return
    endif
    let g:BufMenuEnabled = 1
    let g:BufMenuMainWinID = win_getid()

    let st = '(Main) ' . getwinvar(g:BufMenuMainWinID, '&statusline')
    call setwinvar(g:BufMenuMainWinID, '&statusline', st)

    let width = min([float2nr(winwidth('%') / 5), 80])
    execute 'vertical topleft ' . width . 'vsplit ' . g:BufMenuName
    let g:BufMenuWinID = win_getid()
    setlocal buftype=nofile bufhidden=wipe statusline=%q foldcolumn=0
    setlocal nobuflisted nonu nowrap winfixwidth
    highlight BufMenuCur cterm=bold ctermfg=231 ctermbg=57
    nnoremap <buffer> <CR> :call BufMenuSwitchBuf(line('.'))<CR>

    call BufMenuSelect(1)
    call win_gotoid(g:BufMenuMainWinID)

    autocmd BufCreate,BufReadPost * call BufMenuReload()
    autocmd BufWinLeave * call BufMenuSaveLastUsedBuf()
    autocmd BufWinEnter * call BufMenuSelect(0)
    autocmd WinClosed * call BufMenuDeinit()

    nnoremap <LEADER>bs :call BufMenuSwitchLastUsed()<CR>
    nnoremap <LEADER>bn :call BufMenuNextBuf()<CR>
    nnoremap <LEADER>bp :call BufMenuPreviousBuf()<CR>
    nnoremap <LEADER>bd :call BufMenuDeleteBuf()<CR>
endfunction
nnoremap <LEADER>bm :call BufMenuInit()<CR>

function! BufMenuAutoInit()
    if argc() != 0
	return
    endif

    call BufMenuInit()
endfunction

autocmd VimEnter * call BufMenuAutoInit()
