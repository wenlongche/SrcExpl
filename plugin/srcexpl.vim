
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Plugin Name: SrcExpl (Source Explorer)                                       "
" Abstract:    A (G)Vim plugin for exploring the source code based on "tags",  "
"              and it works like the context window of "Source Insight".       "
" Authors:     Wenlong Che <wenlong.che@gmail.com>                             "
"              Jonathan Lai <laiks.jonathan@gmail.com>                         "
" Homepage:    http://www.vim.org/scripts/script.php?script_id=2179            "
" GitHub:      https://github.com/wesleyche/SrcExpl                            "
" Version:     5.3                                                             "
" Last Change: September 10th, 2013                                            "
" Licence:     This program is free software; you can redistribute it and / or "
"              modify it under the terms of the GNU General Public License as  "
"              published by the Free Software Foundation; either version 2, or "
"              any later version.                                              "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NOTE: Below graph shows my work platform with some Vim plugins,              "
"       including 'Source Explorer', 'Taglist' and 'NERD tree'. And I usually  "
"       use my another plugin called 'trinity.vim' to manage them.             "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" +----------------------------------------------------------------------------+
" | File  Edit  Tools  Syntax  Buffers  Window  Help                           |
" +----------------+-----------------------------------------+-----------------+
" |-demo.c---------|                                         |-/home/myprj/----|
" |function        | 1 void foo(void)     /* function 1 */   ||~ src/          |
" |  foo           | 2 {                                     || `-demo.c       |
" |  bar           | 3 }                                     |`-tags           |
" |                | 4 void bar(void)     /* function 2 */   |                 |
" |~ .----------.  | 5 {                                     |~ .-----------.  |
" |~ | Tag List |\ | 6 }        .-------------.              |~ | NERD Tree |\ |
" |~ .----------. ||~           | Edit Window |\             |~ .-----------. ||
" |~ \___________\||~           .-------------. |            |~ \____________\||
" |~               |~           \______________\|            |~                |
" +-__Tag_List__---+-demo.c----------------------------------+-_NERD_tree_-----+
" |Source Explorer v5.3           .-----------------.                          |
" |~                              | Source Explorer |\                         |
" |~                              .-----------------. |                        |
" |~                              \__________________\|                        |
" |-Source_Explorer------------------------------------------------------------|
" |:TrinityToggleAll                                                           |
" +----------------------------------------------------------------------------+

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" The_setting_example_in_my_vimrc_file:-)                                      "
"                                                                              "
" // The switch of the Source Explorer                                         "
" nmap <F8> :SrcExplToggle<CR>
"                                                                              "
" // Set the height of Source Explorer window                                  "
" let g:SrcExpl_winHeight = 8
"                                                                              "
" // Set 100 ms for refreshing the Source Explorer                             "
" let g:SrcExpl_refreshTime = 100
"                                                                              "
" // Set "Enter" key to jump into the exact definition context                 "
" let g:SrcExpl_jumpKey = "<ENTER>"
"                                                                              "
" // Set "Space" key for back from the definition context                      "
" let g:SrcExpl_gobackKey = "<SPACE>"
"                                                                              "
" // In order to avoid conflicts, the Source Explorer should know what plugins "
" // except itself are using buffers. And you need add their buffer names into "
" // below listaccording to the command ":buffers!"                            "
" let g:SrcExpl_pluginList = [
"         \ "__Tag_List__",
"         \ "_NERD_tree_"
"     \ ]
"                                                                              "
" // Enable/Disable the local definition searching, and note that this is not  "
" // guaranteed to work, the Source Explorer doesn't check the syntax for now. "
" // It only searches for a match with the keyword according to command 'gd'   "
" let g:SrcExpl_searchLocalDef = 1
"                                                                              "
" // Do not let the Source Explorer update the tags file when opening          "
" let g:SrcExpl_isUpdateTags = 0
"                                                                              "
" // Use 'Exuberant Ctags' with '--sort=foldcase -R .' or '-L cscope.files' to "
" //  create/update a tags file                                                "
" let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."
"                                                                              "
" // Set "<F12>" key for updating the tags file artificially                   "
" let g:SrcExpl_updateTagsKey = "<F12>"
"                                                                              "
" // Set "<F3>" key for displaying the previous definition in the jump list    "
" let g:SrcExpl_prevDefKey = "<F3>"
"                                                                              "
" // Set "<F4>" key for displaying the next definition in the jump list        "
" let g:SrcExpl_nextDefKey = "<F4>"
"                                                                              "
" Just_change_above_of_them_by_yourself:-)                                     "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Avoid reloading {{{

if exists('loaded_srcexpl')
    finish
endif

let loaded_srcexpl = 1
let s:save_cpo = &cpoptions

" }}}

" Vim version control {{{

" The Vim version control for running the Source Explorer

if v:version < 700
    echohl ErrorMsg
        echo "Require Vim 7.0 or above for running the Source Explorer."
    echohl None
    finish
endif

set cpoptions&vim

" }}}

" User interfaces {{{

" User interface for opening the Source Explorer

command! -nargs=0 -bar SrcExpl
    \ call <SID>SrcExpl()

" User interface for closing the Source Explorer

command! -nargs=0 -bar SrcExplClose
    \ call <SID>SrcExpl_Close()

" User interface for switching the Source Explorer

command! -nargs=0 -bar SrcExplToggle
    \ call <SID>SrcExpl_Toggle()

" User interface for changing the height of the Source Explorer window
if !exists('g:SrcExpl_winHeight')
    let g:SrcExpl_winHeight = 8
endif

" User interface for setting the update time interval for each refreshing
if !exists('g:SrcExpl_refreshTime')
    let g:SrcExpl_refreshTime = 100
endif

" User interface to jump into the exact definition context
if !exists('g:SrcExpl_jumpKey')
    let g:SrcExpl_jumpKey = '<CR>'
endif

" User interface to go back from the definition context
if !exists('g:SrcExpl_gobackKey')
    let g:SrcExpl_gobackKey = '<SPACE>'
endif

" User interface for handling the conflicts between the
" Source Explorer and other plugins
if !exists('g:SrcExpl_pluginList')
    let g:SrcExpl_pluginList = [
            \ "__Tag_List__",
            \ "_NERD_tree_"
        \ ]
endif

" User interface to enable local declaration searching
" according to command 'gd'
if !exists('g:SrcExpl_searchLocalDef')
    let g:SrcExpl_searchLocalDef = 1
endif

" User interface to control if update the 'tags' file when loading
" the Source Explorer, 0 for false, others for true
if !exists('g:SrcExpl_isUpdateTags')
    let g:SrcExpl_isUpdateTags = 1
endif

" User interface to create a 'tags' file using exact ctags
" utility, 'ctags --sort=foldcase -R .' as default
if !exists('g:SrcExpl_updateTagsCmd')
    let g:SrcExpl_updateTagsCmd = 'ctags --sort=foldcase -R .'
endif

" User interface to update tags file artificially
if !exists('g:SrcExpl_updateTagsKey')
    let g:SrcExpl_updateTagsKey = ''
endif

" User interface to display the previous definition in the jump list
if !exists('g:SrcExpl_prevDefKey')
    let g:SrcExpl_prevDefKey = ''
endif

" User interface to display the next definition in the jump list
if !exists('g:SrcExpl_nextDefKey')
    let g:SrcExpl_nextDefKey = ''
endif

" }}}

" Global variables {{{

" Mark list
let g:SrcExpl_markList = []

" Plugin name
let s:SrcExpl_pluginName = 'Source Explorer'

" Plugin version
let s:SrcExpl_pluginVer = 5.3

" Buffer name
let s:SrcExpl_bufName = 'Source_Explorer'

" Window name
let s:SrcExpl_winName = 'SrcExpl'

" Window variable
let s:SrcExpl_winVar = -1

" Debugging log path
let s:SrcExpl_logPath = '~/srcexpl.log'

" Debugging switch
let s:SrcExpl_isDebug = 0

" Runing switch flag
let s:SrcExpl_isRunning = 0

" Set the highlight color
hi SrcExpl_HighLight term=bold guifg=Black guibg=Magenta ctermfg=Black ctermbg=Magenta

" }}}

" SrcExpl_PrevDef() {{{

" Display the previous definition in the jump list

function! g:SrcExpl_PrevDef()

    call <SID>SrcExpl_JumpDef(1)

endfunction " }}}

" SrcExpl_NextDef() {{{

" Display the next definition in the jump list

function! g:SrcExpl_NextDef()

    call <SID>SrcExpl_JumpDef(2)

endfunction " }}}

" SrcExpl_GetVer() {{{

" Gets the Source Explorer version

function! g:SrcExpl_GetVer()

    return s:SrcExpl_pluginVer

endfunction " }}}

" SrcExpl_GetWin() {{{

" Gets the Source Explorer window number (> 0), and

" -1 means the Source Explorer window had been closed

function! g:SrcExpl_GetWin()

    if getwinvar(s:SrcExpl_winVar, s:SrcExpl_winName) == 1
        return s:SrcExpl_winVar
    endif

    let srcexpl_win = -1
    let i = 0

    while i < winnr("$")
        let i = i + 1
        if getwinvar(i, s:SrcExpl_winName) == 1
            let srcexpl_win = i
            break
        endif
    endwhile

    let s:SrcExpl_winVar = srcexpl_win
    " call <SID>SrcExpl_Debug("s:SrcExpl_winVar is ". s:SrcExpl_winVar)
    return srcexpl_win

endfunction " }}}

" SrcExpl_UpdateTags() {{{

" Update tags file with the 'ctags' utility

function! g:SrcExpl_UpdateTags()

    " Go to the current work directory
    silent! exe "cd " . expand('%:p:h')
    " Get the amount of all files named 'tags'
    let l:tmp = len(tagfiles())

    " No tags file or not found one
    if l:tmp == 0
        " Ask user if or not create a tags file
        echohl Question
            \ | let l:tmp = <SID>SrcExpl_GetInput("\nSrcExpl: "
                \ . "The 'tags' file was not found in your PATH.\n"
            \ . "Create one in the current directory now? (y)es/(n)o?") |
        echohl None
        " They do
        if l:tmp == "y" || l:tmp == "yes"
            " We tell user where we create a tags file
            echohl Question
                echo "SrcExpl: Creating 'tags' file in (". expand('%:p:h') . ")"
            echohl None
            " Call the external 'ctags' utility program
            exe "!" . g:SrcExpl_updateTagsCmd
            " Rejudge the tags file if existed
            if !filereadable("tags")
                " Tell them what happened
                call <SID>SrcExpl_ReportErr("Execute 'ctags' utility program failed")
                return -1
            endif
        " They don't
        else
            echo ""
            return -2
        endif
    " More than one tags file
    elseif l:tmp > 1
        call <SID>SrcExpl_ReportErr("More than one tags file in your PATH")
        return -3
    " Found one successfully
    else
        " Is the tags file in the current directory ?
        if tagfiles()[0] ==# "tags"
            " Prompt the current work directory
            echohl Question
                echo "SrcExpl: Updating 'tags' file in (". expand('%:p:h') . ")"
            echohl None
            " Call the external 'ctags' utility program
            exe "!" . g:SrcExpl_updateTagsCmd
        " Up to other directories
        else
            " Prompt the whole path of the tags file
            echohl Question
                echo "SrcExpl: Updating 'tags' file in (". tagfiles()[0][:-6] . ")"
            echohl None
            " Store the current word directory at first
            let l:tmp = getcwd()
            " Go to the directory that contains the old tags file
            silent! exe "cd " . tagfiles()[0][:-5]
            " Call the external 'ctags' utility program
            exe "!" . g:SrcExpl_updateTagsCmd
           " Go back to the original work directory
           silent! exe "cd " . l:tmp
        endif
    endif

    return 0

endfunction " }}}

" SrcExpl_GoBack() {{{

" Move the cursor to the previous location according to the mark history

function! g:SrcExpl_GoBack()

    " If the cursor is not in the edit window
    if <SID>SrcExpl_WinActive() || <SID>SrcExpl_AdaptPlugins()
        return -1
    endif

    " Just go back to the previous position
    return <SID>SrcExpl_GetMarkList()

endfunction " }}}

" SrcExpl_Jump() {{{

" Jump to the edit window and point to the definition

function! g:SrcExpl_Jump()

    " Only do the operation on the Source Explorer window is valid
    if !<SID>SrcExpl_WinActive()
        return -1
    endif

    " Do we get the definition already?
    if bufname("%") == s:SrcExpl_bufName
        " No such definition
        if s:SrcExpl_status == 0
            return -2
        " Multiple definitions
        elseif s:SrcExpl_status == 2
            " If point to the jump list head, just avoid that
            if line(".") == 1
                return -3
            endif
        endif
    endif

    " Do not refresh when jumping to the edit window
    if g:SrcExpl_searchLocalDef != 0
        let s:SrcExpl_isJumped = 1
    endif
    " Indeed go back to the edit window
    silent! exe s:SrcExpl_editWin . "wincmd w"
    " Set the mark for recording the current position
    call <SID>SrcExpl_SetMarkList()

    " We got multiple definitions
    if s:SrcExpl_status == 2
        " Select the exact one and jump to its context
        call <SID>SrcExpl_SelToJump(0)
        " Set the mark for recording the current position
        call <SID>SrcExpl_SetMarkList()
        return 0
    endif

    " Open the buffer using edit window
    exe "edit " . s:SrcExpl_currMark[0]
    " Jump to the context line of that symbol
    call cursor(s:SrcExpl_currMark[1], s:SrcExpl_currMark[2])
    " Match the symbol of definition
    call <SID>SrcExpl_MatchExpr()
    " Set the mark for recording the current position
    call <SID>SrcExpl_SetMarkList()

    " We got one local definition
    if s:SrcExpl_status == 3
        " Get the cursor line number
        let s:SrcExpl_csrLine = line(".")
        " Try to tag the symbol again
        let l:expr = '\<' . s:SrcExpl_symbol . '\>' . '\C'
        " Try to tag something
        call <SID>SrcExpl_TagSth(l:expr)
    endif

    return 0

endfunction " }}}

" SrcExpl_Refresh() {{{

" Refresh the Source Explorer window and update the status

function! g:SrcExpl_Refresh()

    " Tab page must be invalid
    if s:SrcExpl_tabPage != tabpagenr()
        return -1
    endif

    " If the cursor is not in the edit window
    if <SID>SrcExpl_WinActive() || <SID>SrcExpl_AdaptPlugins()
        return -2
    endif

    " Avoid errors of multi-buffers
    if &modified
        call <SID>SrcExpl_ReportErr("This modified file is not saved")
        return -3
    endif

    " Get the edit window number
    let s:SrcExpl_editWin = winnr()

    " Get the symbol under the cursor
    if <SID>SrcExpl_GetSymbol()
        return -4
    endif

    let l:expr = '\<' . s:SrcExpl_symbol . '\>' . '\C'

    " Try to Go to local declaration
    if g:SrcExpl_searchLocalDef != 0
        if !<SID>SrcExpl_GoDecl(l:expr)
            let s:SrcExpl_lastSymbol = s:SrcExpl_symbol
            return 0
        endif
    endif

    " Try to tag something when necessary
    if s:SrcExpl_symbol !=# s:SrcExpl_lastSymbol || s:SrcExpl_lastSymbol ==# ""
        call <SID>SrcExpl_TagSth(l:expr)
        let s:SrcExpl_lastSymbol = s:SrcExpl_symbol
    endif

    return 0

endfunction " }}}

" SrcExpl_JumpDef() {{{

" Display the previous or next definition in the jump list

function! <SID>SrcExpl_JumpDef(dir)

    " Multiple definitions
    if s:SrcExpl_status == 2
        " Do not refresh when jumping to the edit window
        if g:SrcExpl_searchLocalDef != 0
            let s:SrcExpl_isJumped = 1
        endif
        " Indeed go back to the edit window
        silent! exe s:SrcExpl_editWin . "wincmd w"
        " Set the mark for recording the current position
        call <SID>SrcExpl_SetMarkList()
        " Select the exact one and jump to its context
        call <SID>SrcExpl_SelToJump(a:dir)
        " Set the mark for recording the current position
        call <SID>SrcExpl_SetMarkList()
    " One definition or local definition
    elseif s:SrcExpl_status == 1 || s:SrcExpl_status == 3
        call <SID>SrcExpl_ReportErr("No more definitions")
    endif

endfunction " }}}

" SrcExpl_Debug() {{{

" Log the supplied debug information along with the time

function! <SID>SrcExpl_Debug(log)

    " Debug switch is on
    if s:SrcExpl_isDebug == 1
        " Log file path is valid
        if s:SrcExpl_logPath != ''
            " Output to the log file
            exe "redir >> " . s:SrcExpl_logPath
            " Add the current time
            silent echon strftime("%H:%M:%S") . ": " . a:log . "\r\n"
            redir END
        endif
    endif

endfunction " }}}

" SrcExpl_WinGo() {{{

" Goes to the Source Explorer window

function! <SID>SrcExpl_WinGo()

    let srcexpl_win = g:SrcExpl_GetWin()
    if srcexpl_win == -1
        let srcexpl_win = bufwinnr(s:SrcExpl_bufName)
        if srcexpl_win == -1
            return 0
        endif
    endif

    exe 'silent! ' . srcexpl_win . 'wincmd w'

    return 1

endfunction " }}}

" SrcExpl_WinNew() {{{

" Opens the Source Explorer window
function! <SID>SrcExpl_WinNew(wincmd)

    let srcexpl_win = g:SrcExpl_GetWin()
    if srcexpl_win != -1
        return 0
    endif

    exe 'silent! botright ' . string(g:SrcExpl_winHeight) . 'split ' . a:wincmd
    let srcexpl_win = winnr("$")
    call setwinvar(srcexpl_win, s:SrcExpl_winName, 1)
    let s:SrcExpl_Window = srcexpl_win
    " Keep the height of Source Explorer window although it could be resized
    exe 'set winfixheight'
    return 1

endfunction "  }}}

" SrcExpl_WinEdit() {{{

" Edits the Source Explorer window

function! <SID>SrcExpl_WinEdit(wincmd)

    if <SID>SrcExpl_WinGo() == 0
       call <SID>SrcExpl_WinNew(a:wincmd)
    endif

    exe 'silent! edit ' . a:wincmd
    return 1

endfunction " }}}

" SrcExpl_WinActive() {{{

" Returns if on the Source Explorer window

function! <SID>SrcExpl_WinActive()

    if getwinvar(0, s:SrcExpl_winName) == 1
        return 1
    endif
    return 0

endfunction " }}}

" SrcExpl_WinDelete() {{{

" Closes the Source Explorer window

function! <SID>SrcExpl_WinDelete()

    if <SID>SrcExpl_WinGo() == 0
        return 0
    endif

    exe 'silent! close'
    return 1

endfunction " }}}

" SrcExpl_WinPrompt() {{{

" Tell users there is no tag found in their PATH

function! <SID>SrcExpl_WinPrompt(prompt)

    " Do the Source Explorer existed already?
    let l:bufnum = bufnr(s:SrcExpl_bufName)
    " Not existed, create a new buffer
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = s:SrcExpl_bufName
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif

    " Reopen the Source Explorer idle window
    call <SID>SrcExpl_WinEdit(l:wcmd)
    " Done
    if <SID>SrcExpl_WinActive()
        " First make it modifiable
        setlocal modifiable
        " Not show its name on the buffer list
        setlocal nobuflisted
        " No exact file
        setlocal buftype=nofile
        " Report the reason why the Source Explorer
        " can not point to the definition
        " Delete all lines in buffer.
        1,$d _
        " Go to the end of the buffer put the buffer list
        $
        " Display the version of the Source Explorer
        put! = a:prompt
        " Cancel all the highlighted words
        match none
        " Delete the extra trailing blank line
        $ d _
        " Make it unmodifiable again
        setlocal nomodifiable
        " Go back to the edit window
        silent! exe s:SrcExpl_editWin . "wincmd w"
    endif

endfunction " }}}

" SrcExpl_WinEnter() {{{

" Operation when 'WinEnter' event happens

function! <SID>SrcExpl_WinEnter()

    " In the Source Explorer window
    if <SID>SrcExpl_WinActive()
        if has("gui_running")
            " Delete the SrcExplGoBack item in Popup menu
            silent! nunmenu 1.01 PopUp.&SrcExplGoBack
        endif
        " Unmap the go-back key
        if maparg(g:SrcExpl_gobackKey, 'n') ==
            \ ":call g:SrcExpl_GoBack()<CR>"
            exe "nunmap " . g:SrcExpl_gobackKey
        endif
        " Do the mapping for 'double-click'
        if maparg('<2-LeftMouse>', 'n') == ''
            nnoremap <silent> <2-LeftMouse>
                \ :call g:SrcExpl_Jump()<CR>
        endif
        " Map the user's key to jump into the exact definition context
        if g:SrcExpl_jumpKey != ""
            exe "nnoremap " . g:SrcExpl_jumpKey .
                \ " :call g:SrcExpl_Jump()<CR>"
        endif
    " In other plugin windows
    elseif <SID>SrcExpl_AdaptPlugins()
        if has("gui_running")
            " Delete the SrcExplGoBack item in Popup menu
            silent! nunmenu 1.01 PopUp.&SrcExplGoBack
        endif
        " Unmap the go-back key
        if maparg(g:SrcExpl_gobackKey, 'n') ==
            \ ":call g:SrcExpl_GoBack()<CR>"
            exe "nunmap " . g:SrcExpl_gobackKey
        endif
        " Unmap the exact mapping of 'double-click'
        if maparg("<2-LeftMouse>", "n") ==
                \ ":call g:SrcExpl_Jump()<CR>"
            nunmap <silent> <2-LeftMouse>
        endif
        " Unmap the jump key
        if maparg(g:SrcExpl_jumpKey, 'n') ==
            \ ":call g:SrcExpl_Jump()<CR>"
            exe "nunmap " . g:SrcExpl_jumpKey
        endif
    " In the edit window
    else
        if has("gui_running")
            " You can use SrcExplGoBack item in Popup menu
            " to go back from the definition
            silent! nnoremenu 1.01 PopUp.&SrcExplGoBack
                \ :call g:SrcExpl_GoBack()<CR>
        endif
        " Map the user's key to go back from the definition context
        if g:SrcExpl_gobackKey != ""
            exe "nnoremap " . g:SrcExpl_gobackKey .
                \ " :call g:SrcExpl_GoBack()<CR>"
        endif
        " Unmap the exact mapping of 'double-click'
        if maparg("<2-LeftMouse>", "n") ==
                \ ":call g:SrcExpl_Jump()<CR>"
            nunmap <silent> <2-LeftMouse>
        endif
        " Unmap the jump key
        if maparg(g:SrcExpl_jumpKey, 'n') ==
            \ ":call g:SrcExpl_Jump()<CR>"
            exe "nunmap " . g:SrcExpl_jumpKey
        endif
    endif

endfunction " }}}

" SrcExpl_WinClose() {{{

" Close the Source Explorer window

function! <SID>SrcExpl_WinClose()

    call <SID>SrcExpl_WinDelete()

endfunction " }}}

" SrcExpl_WinOpen() {{{

" Open the Source Explorer window under the bottom of Vim,
" and set the buffer's attribute of the Source Explorer

function! <SID>SrcExpl_WinOpen()

    " Get the edit window number
    let s:SrcExpl_editWin = winnr()

    " Get the tab page number
    let s:SrcExpl_tabPage = tabpagenr()

    " Prompt the plugin name and its version
    call <SID>SrcExpl_WinPrompt(s:SrcExpl_pluginName . ' v' . string(s:SrcExpl_pluginVer))

endfunction " }}}

" SrcExpl_AdaptPlugins() {{{

" The Source Explorer window will not work when the cursor on the

" window of other plugins, such as 'Taglist', 'NERD tree' etc.

function! <SID>SrcExpl_AdaptPlugins()

    " Traversal the list of other plugins
    for item in g:SrcExpl_pluginList
        " If they acted as a split window
        if bufname("%") ==# item
            " Just avoid this operation
            return -1
        endif
    endfor

    " Aslo filter the Quickfix window
    if &buftype ==# "quickfix"
        return 0
    endif

    " Safe
    return 0

endfunction " }}}

" SrcExpl_ReportErr() {{{

" Output the message when we get an error situation

function! <SID>SrcExpl_ReportErr(err)

    " Highlight the error prompt
    echohl ErrorMsg
        echo "SrcExpl: " . a:err
    echohl None

endfunction " }}}

" SrcExpl_SetMarkList() {{{

" Set a new mark for back to the previous position

function! <SID>SrcExpl_SetMarkList()

    " Add one new mark into the tail of Mark List
    call add(g:SrcExpl_markList, [expand("%:p"), line("."), col(".")])

endfunction " }}}

" SrcExpl_GetMarkList() {{{

" Get the mark for back to the previous position

function! <SID>SrcExpl_GetMarkList()

    " If or not the mark list is empty
    if !len(g:SrcExpl_markList)
        call <SID>SrcExpl_ReportErr("Mark stack is empty")
        return -1
    endif

    " Avoid the same situation
    if get(g:SrcExpl_markList, -1)[0] == expand("%:p")
      \ && get(g:SrcExpl_markList, -1)[1] == line(".")
      \ && get(g:SrcExpl_markList, -1)[2] == col(".")
        " Remove the latest mark
        call remove(g:SrcExpl_markList, -1)
        " Get the latest mark again
        return <SID>SrcExpl_GetMarkList()
    endif

    " Load the buffer content into the edit window
    exe "edit " . get(g:SrcExpl_markList, -1)[0]
    " Jump to the context position of that symbol
    call cursor(get(g:SrcExpl_markList, -1)[1], get(g:SrcExpl_markList, -1)[2])
    " Remove the latest mark now
    call remove(g:SrcExpl_markList, -1)

    return 0

endfunction " }}}

" SrcExpl_SelToJump() {{{

" Select one of multi-definitions, and jump to there

function! <SID>SrcExpl_SelToJump(dir)

    let l:error = 0
    let l:index = 0
    let l:fpath = ""
    let l:excmd = ""
    let l:expr  = ""

    " If or not in the Source Explorer window
    if !<SID>SrcExpl_WinActive()
        call <SID>SrcExpl_WinGo()
    endif

    if a:dir == 1 " Pref def
        if line(".") <= 2 " Prompt
            let l:error = 1
            call cursor(1, 1)
            call <SID>SrcExpl_MatchExpr()
            call <SID>SrcExpl_ColorExpr()
        else " Jump list
            call cursor(line(".") - 1, 1)
            let l:list = getline(".")
        endif
    elseif a:dir == 2 " Next def
        let l:temp = line(".") + 1
        if line(".") == 1 " Prompt
            call cursor(l:temp, 1)
            let l:list = getline(".")
        else " Jump list
            call cursor(l:temp, 1)
            if l:temp == line(".")
                let l:list = getline(".")
            else " Exceed the defs' max
                let l:error = 2
            endif
        endif
    else " Normal click
        let l:list = getline(".")
    endif

    if l:error != 0 " Invalid
        silent! exe s:SrcExpl_editWin . "wincmd w"
        call <SID>SrcExpl_ReportErr("No more definitions")
        return
    else " Go ahead
        call <SID>SrcExpl_ColorLine()
    endif

    " Traverse the prompt string until get the file path
    while !((l:list[l:index] == ']')
      \ && (l:list[l:index + 1] == ':'))
        let l:index += 1
    endwhile
    " Offset
    let l:index += 3

    " Get the whole file path of the exact definition
    while !((l:list[l:index] == ' ')
      \ && (l:list[l:index + 1] == '['))
        let l:fpath = l:fpath . l:list[l:index]
        let l:index += 1
    endwhile
    " Offset
    let l:index += 2

    " Traverse the prompt string until get the symbol
    while !((l:list[l:index] == ']')
      \ && (l:list[l:index + 1] == ':'))
        let l:index += 1
    endwhile
    " Offset
    let l:index += 3

    " Get the Ex command string
    while l:list[l:index] != ''
        let l:excmd = l:excmd . l:list[l:index]
        let l:index += 1
    endwhile

    " Indeed go back to the edit window
    silent! exe s:SrcExpl_editWin . "wincmd w"
    " Open the file containing the definition context
    exe "edit " . l:fpath

    " Modify the Ex Command to locate the tag exactly
    let l:expr = substitute(l:excmd, '/^', '/^\\C', 'g')
    let l:expr = substitute(l:expr,  '\*',  '\\\*', 'g')
    let l:expr = substitute(l:expr,  '\[',  '\\\[', 'g')
    let l:expr = substitute(l:expr,  '\]',  '\\\]', 'g')
    " Use Ex Command to jump to the exact position of the definition
    silent! exe l:expr

    " Match the symbol
    call <SID>SrcExpl_MatchExpr()

endfunction " }}}

" SrcExpl_SetCurrMark() {{{

" Save the current buf-win file path, line number and column number

function! <SID>SrcExpl_SetCurrMark()

    " Store the curretn position for exploring
    let s:SrcExpl_currMark = [expand("%:p"), line("."), col(".")]

endfunction " }}}

" SrcExpl_ColorLine() {{{

" Highlight current line

function! <SID>SrcExpl_ColorLine()

    " Highlight this
    exe 'match SrcExpl_HighLight /.\%' . line(".") . 'l/'
    redraw

endfunction " }}}

" SrcExpl_ColorExpr() {{{

" Highlight the symbol of definition

function! <SID>SrcExpl_ColorExpr()

    " Highlight this
    exe 'match SrcExpl_HighLight "\%' . line(".") . 'l\%' .
        \ col(".") . 'c\k*"'

endfunction " }}}

" SrcExpl_MatchExpr() {{{

" Match the symbol of definition

function! <SID>SrcExpl_MatchExpr()

    call search("$", "b")
    let s:SrcExpl_symbol = substitute(s:SrcExpl_symbol,
        \ '\\', '\\\\', '')
    call search('\<' . s:SrcExpl_symbol . '\>' . '\C')

endfunction " }}}

" SrcExpl_ListMultiDefs() {{{

" List multiple definitions into the Source Explorer active window

function! <SID>SrcExpl_ListMultiDefs(list, len)

    " The Source Explorer existed already ?
    let l:bufnum = bufnr(s:SrcExpl_bufName)
    " Not existed, create a new buffer
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = s:SrcExpl_bufName
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif

    " Is the tags file in the current directory ?
    if tagfiles()[0] ==# "tags"
        " We'll get the operating system environment
        " in order to judge the slash type
        if s:SrcExpl_isWinOS == 1
            " With the backward slash
            let l:path = expand('%:p:h') . '\'
        else
            " With the forward slash
            let l:path = expand('%:p:h') . '/'
        endif
    else
        let l:path = ''
    endif

    " Reopen the Source Explorer idle window
    call <SID>SrcExpl_WinEdit(l:wcmd)
    " Done
    if <SID>SrcExpl_WinActive()
        " Reset the attribute of the Source Explorer
        setlocal modifiable
        " Not show its name on the buffer list
        setlocal nobuflisted
        " No exact file
        setlocal buftype=nofile
        " Delete all lines in buffer
        1,$d _
        " Get the tags dictionary array
        " Begin build the jump list for exploring the tags
        put! = '[Jump List]: '. s:SrcExpl_symbol . ' (' . a:len . ') '
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_ColorExpr()
        " Loop key & index
        let l:indx = 0
        " Loop for listing each tag from tags file
        while 1
            " First get each tag list
            let l:dict = get(a:list, l:indx, {})
            " There is one tag
            if l:dict != {}
                " Go to the end of the buffer put the buffer list
                $
                " We should avoid the './' or '.\' in the whole file path
                if l:dict['filename'][0] == '.'
                    put! ='[File Path]: ' . l:path . l:dict['filename'][2:]
                        \ . ' ' . '[Ex Command]: ' . l:dict['cmd']
                else
                    " Generated by 'ctags --sort=foldcase -R .'
                    if len(l:path) == 0
                        put! ='[File Path]: ' . l:path . l:dict['filename']
                            \ . ' ' . '[Ex Command]: ' . l:dict['cmd']
                    " Generated by 'ctags -L cscope.files'
                    else
                        put! ='[File Path]: ' . l:dict['filename']
                            \ . ' ' . '[Ex Command]: ' . l:dict['cmd']
                    endif
                endif
            " Traversal finished
            else
                break
            endif
            let l:indx += 1
        endwhile
    endif

    " Delete the extra trailing blank line
    $ d _
    " Move the cursor to the top of the Source Explorer window
    exe "normal! " . "gg"
    " Back to the first line
    setlocal nomodifiable
    " Go back to the edit window
    silent! exe s:SrcExpl_editWin . "wincmd w"

endfunction " }}}

" SrcExpl_ViewOneDef() {{{

" Display the definition of the symbol into the Source Explorer active window

function! <SID>SrcExpl_ViewOneDef(fpath, excmd)

    let l:expr = ""

    " The tags file is in the current directory and it
    " should be generated by 'ctags --sort=foldcase -R .'
    if tagfiles()[0] ==# "tags" && a:fpath[0] == '.'
        call <SID>SrcExpl_WinEdit(expand('%:p:h') . '/' . a:fpath)
    " Up to other directories
    else
        call <SID>SrcExpl_WinEdit(a:fpath)
    endif

    " Indeed back to the Source Explorer active window
    if <SID>SrcExpl_WinActive()
        " Modify the Ex Command to locate the tag exactly
        let l:expr = substitute(a:excmd, '/^', '/^\\C', 'g')
        let l:expr = substitute(l:expr,  '\*',  '\\\*', 'g')
        let l:expr = substitute(l:expr,  '\[',  '\\\[', 'g')
        let l:expr = substitute(l:expr,  '\]',  '\\\]', 'g')
        " Execute Ex command according to the parameter
        silent! exe l:expr

        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_ColorExpr()
        " Set the current buf-win attribute
        call <SID>SrcExpl_SetCurrMark()

        " Not highlight the word that had been searched.
        " Because execute Ex command will active a search event
        let l:hlsearch = &hlsearch
        set nohlsearch
        " Refresh all the screen
        redraw
        " Resotre the original setting for the highlight
        let &hlsearch = l:hlsearch

        " Go back to the edit window
        silent! exe s:SrcExpl_editWin . "wincmd w"
    endif

endfunction " }}}

" SrcExpl_TagSth() {{{

" Just try to find the tag under the cursor

function! <SID>SrcExpl_TagSth(expr)

    let l:len = -1

    " Is the symbol valid ?
    if a:expr != '\<\>\C'
        " We get the tag list of the expression
        let l:list = taglist(a:expr)
        " Then get the length of taglist
        let l:len = len(l:list)
    else
        call <SID>SrcExpl_WinPrompt(s:SrcExpl_pluginName . ' v' . string(s:SrcExpl_pluginVer))
        " Should be regarded as 'no definition'
        let s:SrcExpl_status = 0
        return
    endif

    " One tag
    if l:len == 1
        " Get dictionary to load tag's file path and ex command
        let l:dict = get(l:list, 0, {})
        call <SID>SrcExpl_ViewOneDef(l:dict['filename'], l:dict['cmd'])
        " One definition
        let s:SrcExpl_status = 1
    " Multiple tags
    elseif l:len > 1
        call <SID>SrcExpl_ListMultiDefs(l:list, l:len)
        " Multiple definitions
        let s:SrcExpl_status = 2
    " No tag
    else
        call <SID>SrcExpl_WinPrompt('Definition Not Found')
        " No definition
        let s:SrcExpl_status = 0
    endif

endfunction " }}}

" SrcExpl_GoDecl() {{{

" Search the local declaration using 'gd' command

function! <SID>SrcExpl_GoDecl(expr)

    " Get the original cursor position
    let l:oldline = line(".")
    let l:oldcol = col(".")

    " Try to search the local declaration
    if searchdecl(a:expr, 0, 1) != 0
        " Search failed
        return -1
    endif

    " Get the new cursor position
    let l:newline = line(".")
    let l:newcol = col(".")
    " Go back to the original cursor position
    call cursor(l:oldline, l:oldcol)

    " Preview the context
    call <SID>SrcExpl_WinEdit(expand("%:p"))
    " Indeed in the Source Explorer active window
    if <SID>SrcExpl_WinActive()
        " Go to the new cursor position
        call cursor(l:newline, l:newcol)
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_ColorExpr()
        " Set the current buf-win attribute
        call <SID>SrcExpl_SetCurrMark()
        " Refresh all the screen
        redraw
        " Go back to the edit window
        silent! exe s:SrcExpl_editWin . "wincmd w"
        " We got a local definition
        let s:SrcExpl_status = 3
    endif

    return 0

endfunction " }}}

" SrcExpl_GetSymbol() {{{

" Get the valid symbol under the current cursor

function! <SID>SrcExpl_GetSymbol()

    " Get the current character under the cursor
    let l:cchar = getline(".")[col(".") - 1]
    " Get the current word under the cursor
    let l:cword = expand("<cword>")

    " Judge that if or not the character is invalid,
    " because only 0-9, a-z, A-Z, and '_' are valid
    if l:cchar =~ '\w' && l:cword =~ '\w'
        " If the key word symbol has been explored
        " just now, we will not explore that again
        if s:SrcExpl_symbol ==# l:cword
            " Not in Local definition searching mode
            if g:SrcExpl_searchLocalDef == 0
                return -1
            else
                " Do not refresh when jumping to the edit window
                if s:SrcExpl_isJumped == 1
                    " Get the cursor line number
                    let s:SrcExpl_csrLine = line(".")
                    " Reset the jump flag
                    let s:SrcExpl_isJumped = 0
                    return -2
                endif
                " The cursor is not moved actually
                if s:SrcExpl_csrLine == line(".")
                    return -3
                endif
            endif
        endif
        " Get the cursor line number
        let s:SrcExpl_csrLine = line(".")
        " Get the symbol word under the cursor
        let s:SrcExpl_symbol = l:cword
    " Invalid character
    else
        if s:SrcExpl_symbol == ''
            return -4 " Second, third ...
        else " First
            let s:SrcExpl_symbol = ''
        endif
    endif

    return 0

endfunction " }}}

" SrcExpl_GetInput() {{{

" Get the word inputed by user on the command line window

function! <SID>SrcExpl_GetInput(note)

    " Be sure synchronize
    call inputsave()
    " Get the input content
    let l:input = input(a:note)
    " Save the content
    call inputrestore()
    " Tell the Source Explorer
    return l:input

endfunction " }}}

" SrcExpl_GetEditWin() {{{

" Get the edit window number

function! <SID>SrcExpl_GetEditWin()

    let l:i = 1
    let l:j = 1

    " Loop for searching the edit window
    while 1
        " Traverse the plugin list for each sub-window
        for item in g:SrcExpl_pluginList
            if bufname(winbufnr(l:i)) ==# item
                break
            else
                let l:j += 1
            endif
        endfor

        if j >= len(g:SrcExpl_pluginList)
          \ && getbufvar(winbufnr(l:i), '&buftype') !=# "quickfix"
            " We've found one
            return l:i
        else
            let l:i += 1
        endif

        if l:i > winnr("$")
            " Not found
            return -1
        else
            " Try the next one
            let l:j = 0
        endif
    endwhile

endfunction " }}}

" SrcExpl_CleanUp() {{{

" Clean up the rubbish and free the mapping resources

function! <SID>SrcExpl_CleanUp()

    " GUI version only
    if has("gui_running")
        " Delete the SrcExplGoBack item in Popup menu
        silent! nunmenu 1.01 PopUp.&SrcExplGoBack
    endif

    " Make the 'double-click' for nothing
    if maparg('<2-LeftMouse>', 'n') != ''
        nunmap <silent> <2-LeftMouse>
    endif

    " Unmap the jump key
    if maparg(g:SrcExpl_jumpKey, 'n') ==
        \ ":call g:SrcExpl_Jump()<CR>"
        exe "nunmap " . g:SrcExpl_jumpKey
    endif

    " Unmap the go-back key
    if maparg(g:SrcExpl_gobackKey, 'n') ==
        \ ":call g:SrcExpl_GoBack()<CR>"
        exe "nunmap " . g:SrcExpl_gobackKey
    endif

    " Unmap the update-tags key
    if maparg(g:SrcExpl_updateTagsKey, 'n') ==
        \ ":call g:SrcExpl_UpdateTags()<CR>"
        exe "nunmap " . g:SrcExpl_updateTagsKey
    endif

    " Unmap the previous key
    if maparg(g:SrcExpl_prevDefKey, 'n') ==
        \ ":call g:SrcExpl_PrevDef()<CR>"
        exe "nunmap " . g:SrcExpl_prevDefKey
    endif

    " Unmap the next key
    if maparg(g:SrcExpl_nextDefKey, 'n') ==
        \ ":call g:SrcExpl_NextDef()<CR>"
        exe "nunmap " . g:SrcExpl_nextDefKey
    endif

    " Unload the autocmd group
    silent! autocmd! SrcExpl_AutoCmd

endfunction " }}}

" SrcExpl_Init() {{{

" Initialize the Source Explorer properties

function! <SID>SrcExpl_Init()

    " We'll get the operating system environment in order to
    " judge the slash type (backward or forward)
    if has("win16") || has("win32") || has("win64")
        let s:SrcExpl_isWinOS = 1
    else
        let s:SrcExpl_isWinOS = 0
    endif

    " Have we jumped to the edit window ?
    let s:SrcExpl_isJumped = 0
    " Line number of the current cursor
    let s:SrcExpl_csrLine = 0
    " The ID of edit window
    let s:SrcExpl_editWin = 0
    " The tab page number
    let s:SrcExpl_tabPage = 0
    " Source Explorer status:
    " 0: Definition not found
    " 1: Only one definition
    " 2: Multiple definitions
    " 3: Local declaration
    let s:SrcExpl_status = 0
    " The mark for the current position
    let s:SrcExpl_currMark = []
    " The key word symbol for exploring
    let s:SrcExpl_symbol = ''
    " The last symbol for exploring
    let s:SrcExpl_lastSymbol = ''

    " Auto change current work directory
    exe "set autochdir"
    " Let Vim find the possible tags file
    exe "set tags=tags;"
    " Set the actual update time according to user's requirement
    " 100 milliseconds by default
    exe "set updatetime=" . string(g:SrcExpl_refreshTime)

    " Open all the folds
    if has("folding")
        " Open this file at first
        exe "normal " . "zR"
        " Let it works during the whole editing session
        exe "set foldlevelstart=" . "99"
    endif

    " We must get the edit window number
    let l:tmp = <SID>SrcExpl_GetEditWin()
    " Not found
    if l:tmp < 0
        " Can not find the edit window
        call <SID>SrcExpl_ReportErr("Edit Window Not Found")
        return -1
    endif
    " Jump to the edit window
    silent! exe l:tmp . "wincmd w"

    if g:SrcExpl_isUpdateTags != 0
        " Update the tags file right now
        if g:SrcExpl_UpdateTags()
            return -2
        endif
    endif

    if g:SrcExpl_updateTagsKey != ""
        exe "nnoremap " . g:SrcExpl_updateTagsKey .
            \ " :call g:SrcExpl_UpdateTags()<CR>"
    endif

    if g:SrcExpl_prevDefKey != ""
        exe "nnoremap " . g:SrcExpl_prevDefKey .
            \ " :call g:SrcExpl_PrevDef()<CR>"
    endif

    if g:SrcExpl_nextDefKey != ""
        exe "nnoremap " . g:SrcExpl_nextDefKey .
            \ " :call g:SrcExpl_NextDef()<CR>"
    endif

    " Then we set the routine function when the event happens
    augroup SrcExpl_AutoCmd
        autocmd!
        au! CursorHold * nested call g:SrcExpl_Refresh()
        au! WinEnter * nested call <SID>SrcExpl_WinEnter()
    augroup end

    return 0

endfunction " }}}

" SrcExpl_Toggle() {{{

" The user interface function to open / close the Source Explorer

function! <SID>SrcExpl_Toggle()

    " Not yet running
    if s:SrcExpl_isRunning == 0
        " Initialize the properties
        if <SID>SrcExpl_Init()
            return -1
        endif
        " Create the window
        call <SID>SrcExpl_WinOpen()
        " We change the flag to true
        let s:SrcExpl_isRunning = 1
    else
        " Not in the exact tab page
        if s:SrcExpl_tabPage != tabpagenr()
            call <SID>SrcExpl_ReportErr("Not support multiple tab pages")
            return -2
        endif
        " Close the window
        call <SID>SrcExpl_WinClose()
        " Do the cleaning work
        call <SID>SrcExpl_CleanUp()
        " We change the flag to false
        let s:SrcExpl_isRunning = 0
    endif

    return 0

endfunction " }}}

" SrcExpl_Close() {{{

" The user interface function to close the Source Explorer

function! <SID>SrcExpl_Close()

    " Already running
    if s:SrcExpl_isRunning == 1
        " Not in the exact tab page
        if s:SrcExpl_tabPage != tabpagenr()
            call <SID>SrcExpl_ReportErr("Not support multiple tab pages")
            return -1
        endif
        " Do the cleaning work
        call <SID>SrcExpl_CleanUp()
        " Close the window
        call <SID>SrcExpl_WinClose()
        " We change the flag to false
        let s:SrcExpl_isRunning = 0
    else
        " Tell users the reason
        call <SID>SrcExpl_ReportErr("Source Explorer is close")
        return -2
    endif

    return 0

endfunction " }}}

" SrcExpl() {{{

" The user interface function to open the Source Explorer

function! <SID>SrcExpl()

    " Not yet running
    if s:SrcExpl_isRunning == 0
        " Initialize the properties
        if <SID>SrcExpl_Init()
            return -1
        endif
        " Create the window
        call <SID>SrcExpl_WinOpen()
        " We change the flag to true
        let s:SrcExpl_isRunning = 1
    else
        " Not in the exact tab page
        if s:SrcExpl_tabPage != tabpagenr()
            call <SID>SrcExpl_ReportErr("Not support multiple tab pages")
            return -2
        endif
        " Already running
        call <SID>SrcExpl_ReportErr("Source Explorer is running")
        return -3
    endif

    return 0

endfunction " }}}

" Avoid side effects {{{

set cpoptions&
let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" vim:foldmethod=marker:tabstop=4
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

