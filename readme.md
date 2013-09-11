**SrcExpl**
===========

SrcExpl (Source Explorer) is a source code explorer that provides context for the currently
selected keyword by displaying the function or type definition or declaration
in a separate window. This plugin aims to recreate the context window available
in the IDE known as "Source Insight".

Features
========

* Display definitions and declarations of various languages supported
      by ctags and various types including functions, macros, structures,
      arrays, methods, classes, and variables.
* Jump to the displayed context in the Source Explorer window using the mouse or
      your own key mapping.
* Jump back from the context location with the mouse context menu or your
      own key mapping.
* Automatically list all definitions if multiple definitions for a keyword
      is found.
* Automatically create and update the tags file.

Installation
============
1. Ensure ctags is installed on your system and that VIM can use it.
2. Place the Source Explorer files in your Vim directory (such as ~/.vim) 
   or have it installed by a bundle manager like Vundle or NeoBundle.
3. Open the Source Explorer window with *:SrcExpl* or *:SrcExplToggle* or map these
   commands to keys in your .vimrc.

Requirements
------------
Source Explorer requires:
* Vim 7.0 or higher
* ctags

Screenshots
===========

One Declaration Found
---------------------
![One Declaration Found](http://i.imgur.com/bbGVO.jpg)

Multiple Declarations Found
---------------------------
![Multiple Declarations Found](http://i.imgur.com/77HeV.jpg)

Local Declaration Found
-----------------------
![Local Declaration Found](http://i.imgur.com/dQXqL.jpg)

Settings Example
================
```vim
" // The switch of the Source Explorer 
nmap <F8> :SrcExplToggle<CR> 

" // Set the height of Source Explorer window 
let g:SrcExpl_winHeight = 8 

" // Set 100 ms for refreshing the Source Explorer 
let g:SrcExpl_refreshTime = 100 

" // Set "Enter" key to jump into the exact definition context 
let g:SrcExpl_jumpKey = "<ENTER>" 

" // Set "Space" key for back from the definition context 
let g:SrcExpl_gobackKey = "<SPACE>" 

" // In order to avoid conflicts, the Source Explorer should know what plugins
" // except itself are using buffers. And you need add their buffer names into
" // below listaccording to the command ":buffers!"
let g:SrcExpl_pluginList = [ 
        \ "__Tag_List__", 
        \ "_NERD_tree_" 
    \ ] 

" // Enable/Disable the local definition searching, and note that this is not 
" // guaranteed to work, the Source Explorer doesn't check the syntax for now. 
" // It only searches for a match with the keyword according to command 'gd' 
let g:SrcExpl_searchLocalDef = 1 

" // Do not let the Source Explorer update the tags file when opening 
let g:SrcExpl_isUpdateTags = 0 

" // Use 'Exuberant Ctags' with '--sort=foldcase -R .' or '-L cscope.files' to 
" // create/update the tags file 
let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ." 

" // Set "<F12>" key for updating the tags file artificially 
let g:SrcExpl_updateTagsKey = "<F12>" 

" // Set "<F3>" key for displaying the previous definition in the jump list 
let g:SrcExpl_prevDefKey = "<F3>" 

" // Set "<F4>" key for displaying the next definition in the jump list 
let g:SrcExpl_nextDefKey = "<F4>" 
```

Changelog
=========
```vim
5.3
- Fix a bug when operating the Quickfix window after closing the Source Explorer window.
- Handle the case when the cursor is located at the Quickfix window as same as other
  external plugins.

5.2
- Add the fast way for displaying the previous or next definition in the jump list.
  The new feature is similar with the commands called cprev and cnext for operating
  the Quickfix list. You can add below config lines in your .vimrc or just update your
  Trinity to v2.1.
    1. " // Set "<F3>" key for displaying the previous definition in the jump list 
       let g:SrcExpl_prevDefKey = "<F3>" 
    2. " // Set "<F4>" key for displaying the next definition in the jump list 
       let g:SrcExpl_nextDefKey = "<F4>" 
- Fix a bug when clicking the default prompt line in the Source Explorer window.

5.1
- Added two APIs for serving other plugins:
    1. SrcExpl_GetWin(), getting the Source Explorer window number for those plugins
       based on multiple windows.
    2. SrcExpl_GetVer(), getting the Source Explorer version for the forward compatibility.
- Added debug/logging functions for the internal development.

5.0
- Replaced use of preview window with a named buffer.
- Moved to github.
- Added documentation.
```
