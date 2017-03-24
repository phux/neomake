" vim: ts=4 sw=4 et

function! neomake#makers#ft#elm#EnabledMakers() abort
    return ['elmMake']
endfunction

function! neomake#makers#ft#elm#elmMake() abort
    return {
        \ 'exe': 'elm-make',
        \ 'args': ['--report=json', '--output=' . neomake#utils#DevNull()],
        \ 'process_output': function('neomake#makers#ft#elm#ElmMakeProcessOutput')
        \ }
endfunction

function! neomake#makers#ft#elm#ElmMakeProcessOutput(context) abort
    " output will be a List, containing a JSON string of an array of objects
    if a:context.output[0][0] !=# '['
        return []
    endif
    let l:decoded = neomake#utils#JSONdecode(a:context.output[0])
    if type(l:decoded) == type([])
        let l:errors = []
        for item in l:decoded
            if get(item, 'type', '') ==# 'warning'
                let l:code = 'W'
            else
                let l:code = 'E'
            endif

            let l:compiler_error = item['tag']
            let l:message = item['overview']
            let l:region_start = item['region']['start']
            let l:region_end = item['region']['end']
            let l:row = l:region_start['line']
            let l:col = l:region_start['column']
            let l:length = l:region_end['column'] - l:region_start['column']

            let l:error = {
                        \ 'text': l:compiler_error . ' : ' . l:message,
                        \ 'type': l:code,
                        \ 'lnum': l:row,
                        \ 'col': l:col,
                        \ 'length': l:length,
                        \ }
            call add(l:errors, l:error)
        endfor
        return l:errors
    else
        return []
    endif
endfunction
