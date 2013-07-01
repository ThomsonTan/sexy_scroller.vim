" smooth_scroller.vim by joeytwiddle
" Inspired by smooth_scroll.vim by Terry Ma

if !has("float")
  echo "smooth_scroller requires the +float feature, which is missing"
  finish
endif

let w:oldState = winsaveview()

augroup Smooth_Scroller
  autocmd!
  autocmd CursorMoved * call s:CheckForJump()
augroup END

function! s:CheckForJump()
  let w:newState = winsaveview()
  " if w:newState["topline"] != w:oldState["topline"] || w:newState["leftcol"] != w:oldState["leftcol"] || w:newState["lnum"] != w:oldState["lnum"] || w:newState["col"] != w:oldState["col"]
  if s:differ("topline") || s:differ("leftcol") || s:differ("lnum") || s:differ("col")
    "call winrestview(w:oldState)
    call s:smooth_scroll(w:oldState, w:newState)
  endif
  let w:oldState = w:newState
endfunction

function! s:differ(str)
  return abs( w:newState[a:str] - w:oldState[a:str] ) > 1
endfunction

function! s:smooth_scroll(start, end)
  let pi = acos(-1)
  "echo "Going from ".start["topline"]." to ".end["topline"]
  "redraw
  let startTime = reltime()
  let totalTime = 300.0   " MUST BE A FLOAT!
  let current = copy(a:start)
  while 1
    let elapsed = s:get_ms_since(startTime)
    let thruTime = elapsed * 1.0 / totalTime
    if elapsed >= totalTime
      let thruTime = 1.0
    endif
    " Easing
    let thru = 0.5 - 0.5 * cos(pi * thruTime)
    let notThru = 1.0 - thru
    let current["topline"] = float2nr( notThru*a:start["topline"] + thru*a:end["topline"] + 0.5 )
    let current["leftcol"] = float2nr( notThru*a:start["leftcol"] + thru*a:end["leftcol"] + 0.5 )
    let current["lnum"] = float2nr( notThru*a:start["lnum"] + thru*a:end["lnum"] + 0.5 )
    let current["col"] = float2nr( notThru*a:start["col"] + thru*a:end["col"] + 0.5 )
    "echo "thruTime=".printf('%g',thruTime)." thru=".printf('%g',thru)." notThru=".printf('%g',notThru)." topline=".current["topline"]." leftcol=".current["leftcol"]." lnum=".current["lnum"]." col=".current["col"]
    call winrestview(current)
    redraw
    if elapsed >= totalTime
      break
    endif
    exec "sleep 15m"
  endwhile
  call winrestview(a:end)
endfunction

function! s:get_ms_since(time)
  let cost = split(reltimestr(reltime(a:time)), '\.')
  return str2nr(cost[0])*1000 + str2nr(cost[1])/1000.0
endfunction

