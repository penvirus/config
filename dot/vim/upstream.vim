function! ReviewedBy()
    call setline(".", "Reviewed-by: Tzung-Bi Shih <tzungbi@kernel.org>")
endfunction

function! TestedBy()
    call setline(".", "Tested-by: Tzung-Bi Shih <tzungbi@kernel.org>")
endfunction

function! AckedBy()
    call setline(".", "Acked-by: Tzung-Bi Shih <tzungbi@kernel.org>")
endfunction

function! AppliedTo()
    let l:strs = [
        \"> [...]",
        \"",
        \"Applied to",
        \"",
        \"    https://git.kernel.org/pub/scm/linux/kernel/git/chrome-platform/linux.git for-next",
        \"",
        \"Thanks!",
    \]

    call setline('.', l:strs)
endfunction

function! AppliedToFirmware()
    let l:strs = [
        \"> [...]",
        \"",
        \"Applied to",
        \"",
        \"    https://git.kernel.org/pub/scm/linux/kernel/git/chrome-platform/linux.git for-firmware-next",
        \"",
        \"Thanks!",
    \]

    call setline('.', l:strs)
endfunction

command! Rb normal! :call ReviewedBy()<ESC>
command! Tb normal! :call TestedBy()<ESC>
command! Ab normal! :call AckedBy()<ESC>
command! At normal! :call AppliedTo()<ESC>
command! Atf normal! :call AppliedToFirmware()<ESC>
