if exists('g:loaded_rooter') || &cp
  finish
endif
let g:loaded_rooter = 1

" User configuration {{{

if !exists('g:rooter_use_lcd')
  let g:rooter_use_lcd = 0
endif

if !exists('g:rooter_patterns')
  let g:rooter_patterns = ['.git/', '.git', '_darcs/', '.hg/', '.bzr/', '.svn/']
endif

if !exists('g:rooter_merge_default_patterns')
  let g:rooter_merge_default_patterns = 1
endif

if !exists('g:rooter_change_directory_for_non_project_files')
  let g:rooter_change_directory_for_non_project_files = 0
endif

if !exists('g:rooter_default_mappings')
  let g:rooter_default_mappings = 0
endif

" }}}

" Utility {{{

function! s:IsVirtualFileSystem()
  return match(expand('%:p'), '^\w\+://.*') != -1
endfunction

function! s:IsNormalFile()
  return empty(&buftype)
endfunction

function! s:ChangeDirectory(directory)
  let cmd = g:rooter_use_lcd == 1 ? 'lcd' : 'cd'
  execute ':' . cmd . ' ' . fnameescape(a:directory)
endfunction

function! s:IsDirectory(pattern)
  return stridx(a:pattern, '/') != -1
endfunction

function! s:IsContainerDir(pattern)
  return stridx(a:pattern, '/{}') == strlen(a:pattern) - 3
endfunction


" }}}

" Core logic {{{

" Returns the project root directory of the current file, i.e the closest parent
" directory containing the given directory or file, or an empty string if no
" such directory or file is found.
function! s:FindInCurrentPath(pattern)
  let dir_current_file = fnameescape(expand('%:p:h'))

  if s:IsContainerDir(a:pattern)
    let match = finddir(expand(a:pattern)[:-3], dir_current_file . ';')
    if empty(match)
      return ''
    endif
    return dir_current_file[:stridx(dir_current_file, '/', strlen(match))]
  elseif s:IsDirectory(a:pattern)
    let match = finddir(a:pattern, dir_current_file . ';')
    if empty(match)
      return ''
    endif
    return fnamemodify(match, ':p:h:h')
  else
    let match = findfile(a:pattern, dir_current_file . ';')
    if empty(match)
      return ''
    endif
    return fnamemodify(match, ':p:h')
  endif
endfunction

" Returns the root directory for the current file based on the list of
" known SCM directory names.
function! s:FindRootDirectory()
  for pattern in g:rooter_patterns
    let result = s:FindInCurrentPath(pattern)
    if !empty(result)
      return result
    endif
  endfor
  return ''
endfunction

" Changes the current working directory to the current file's
" root directory.
function! s:ChangeToRootDirectory()
  if s:IsVirtualFileSystem() || !s:IsNormalFile()
    return
  endif

  let root_dir = s:FindRootDirectory()
  if empty(root_dir)
    if g:rooter_change_directory_for_non_project_files
      call s:ChangeDirectory(expand('%:p:h'))
    endif
  else
    if exists('+autochdir')
      set noautochdir
    endif
    call s:ChangeDirectory(root_dir)
  endif
endfunction

" }}}

" Mappings and commands {{{

if g:rooter_default_mappings && !hasmapto("<Plug>RooterChangeToRootDirectory")
  map <silent> <unique> <Leader>cd <Plug>RooterChangeToRootDirectory
endif
noremap <unique> <script> <Plug>RooterChangeToRootDirectory <SID>ChangeToRootDirectory
noremap <SID>ChangeToRootDirectory :call <SID>ChangeToRootDirectory()<CR>

command! Rooter :call <SID>ChangeToRootDirectory()

if g:rooter_merge_default_patterns == 1
  call extend(g:rooter_patterns, ['.git/', '.git', '_darcs/', '.hg/', '.bzr/', '.svn/'], 0)
endif

if !exists('g:rooter_manual_only')
  augroup rooter
    autocmd!
    autocmd BufEnter * :Rooter
  augroup END

endif

" }}}

" vim:set ft=vim sw=2 sts=2  fdm=marker et:
