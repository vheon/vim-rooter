if exists('g:loaded_rooter') || &cp
  finish
endif
let g:loaded_rooter = 1

if exists('+autochdir')
  set noautochdir
endif

" User configuration {{{

if !exists('g:rooter_use_cd')
  let g:rooter_use_cd = 0
endif

if !exists('g:rooter_change_directory_for_non_project_files')
  let g:rooter_change_directory_for_non_project_files = 0
endif

" }}}


" Mappings and commands {{{

noremap <unique> <script> <Plug>(rooter-change-root-directory) <SID>ChangeRootDirectory
noremap <SID>ChangeRootDirectory :call rooter#change_root_directory()<CR>

command! Rooter :call rooter#change_root_directory()

if !exists('g:rooter_manual_only')
  augroup rooter
    autocmd!
    autocmd BufEnter * call rooter#change_root_directory()
  augroup END
endif

" }}}

" vim:set ft=vim sw=2 sts=2  fdm=marker et:
