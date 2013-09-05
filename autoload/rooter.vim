let s:rooter_patterns = ['.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/']

function! rooter#change_root_directory()
  if s:_is_vurtual_file_system() || !s:_is_normal_file()
    return
  endif

  let root_dir = s:_find_root_directory()
  if empty(root_dir) && g:rooter_change_directory_for_non_project_files
    call s:_change_directory(expand('%:p:h'))
  else
    call s:_change_directory(root_dir)
  endif
endfunction


function! rooter#extend_patterns(list)
  for pat in a:list
    if index(s:rooter_patterns, pat) == -1
      call add(s:rooter_patterns, pat)
    endif
  endfor
endfunction

function! rooter#set_default_patterns()
  let s:rooter_patterns = ['.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/']
endfunction

function! rooter#clear_patterns()
  let s:rooter_patterns = []
endfunction

function! rooter#get_patterns()
  return s:rooter_patterns
endfunction

function! s:_is_vurtual_file_system()
  return match(expand('%:p'), '^\w\+://.*') != -1
endfunction

function! s:_is_normal_file()
  return empty(&buftype)
endfunction


function! s:_find_root_directory()
  for pattern in s:rooter_patterns
    let result = s:_find_in_current_path(pattern)
    if !empty(result)
      return result
    endif
  endfor
  return ''
endfunction

function! s:_find_in_current_path(pattern)
  let dir_current_file = fnameescape(expand('%:p:h'))

  if s:_is_container_dir(a:pattern)
    let match = finddir(expand(a:pattern)[:-3], dir_current_file . ';')
    echom finddir(expand(a:pattern)[:-3], dir_current_file . ';')
    if empty(match)
      return ''
    endif
    return dir_current_file[:stridx(dir_current_file, '/', strlen(match))]
  elseif s:_is_directory(a:pattern)
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

function! s:_is_directory(pattern)
  return stridx(a:pattern, '/') != -1
endfunction

function! s:_is_container_dir(pattern)
  return stridx(a:pattern, '/{}') == strlen(a:pattern) - 3
endfunction

function! s:_change_directory(directory)
  let cmd = g:rooter_use_cd == 1 ? 'cd' : 'lcd'
  let b:rooter_root_directory = fnameescape(a:directory)
  execute ':'.cmd.' '.b:rooter_root_directory
endfunction
