pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- main



-- title screen
function init_title()
 initglobal()
 mode = 0 -- title screen
end

-- draw title
function draw_title()
 draw_title_screen()
 print("hold 🅾️ to start", 16, 54, 0)
end

-- update title
function update_title()
 if btn(🅾️) then
  init_game()
 end
end

-- game
function init_game()
 mode = 2

 -- menuitem
 menuitem(1, "pass", function() pass_player() end)

 
 
 -- board
 b = {}
 b.size = 13
 b.empty = "."
 b.black = "b"
 b.white = "w"
 b.board = {}
 b.board2 = {"."}
 b.board3 = {".."}
 b.board_temp = {"..."}
 b.scoremap = {}
 
 -- pointer
 pointer = {}
 pointer.x = 1
 pointer.y = 1
 pointer.sp = 8
 pointer.timer = -10
 pointer.current = b.black
 
 -- create board as string
 for x=1,13 do
  for y=1,13 do
   add(b.board, b.empty)
  end
 end
 
 -- white stones
 white = {}
 white.sp = 7
 white.points = 0
 white.final = 0
 white.pass = false
 
 -- black stones
 black = {}
 black.sp = 6
 black.points = 0
 black.final = 0
 black.pass = false
 
 -- init and store all neighbors
 all_n = get_all_neighbors()

 -- info message timer
 info_timer = 0
 show_info = false
 
 -- scoring
 scoring = false
 scoring_start = false

 -- debug
 debug = ""
 
end

function draw_game()
 
 -- draw map
 cls()
 map()
 
 -- draw turn indicator
 if pointer.current == b.white then spr(white.sp, 60, 0)
 else spr(black.sp, 60, 0) end
 
 -- draw board
 for i,p in  pairs(b.board) do
  if p == b.black then
   x, y = unflatten(i)
   spr(black.sp, (y-1)*8+12, (x-1)*8+12)
  elseif p == b.white then
   x, y = unflatten(i)
   spr(white.sp, (y-1)*8+12, (x-1)*8+12)
  end
 end
 
 -- if game going on
 if scoring == false then
  -- draw pointer
  spr(pointer.sp, (pointer.x-1) * 8 + 12, (pointer.y-1) * 8 + 12)
  
  
  -- draw captured stones
  print("black: " .. black.points, 10, 1, 7)
  print("white: " .. white.points, 85, 1, 7)
 end
 

 -- show info
 if show_info then
  spr(64, 28, 36, 9, 2)
  print("❎ to place stone", 30, 38, 0)
  print(" - or p to pass")
 end
 
 -- scoring
 if scoring == true then
  -- show area
  for i,p in  pairs(b.scoremap) do
   if p == b.black then
    x, y = unflatten(i)
    spr(10, (y-1)*8+12, (x-1)*8+12)
   elseif p == b.white then
    x, y = unflatten(i)
    spr(11, (y-1)*8+12, (x-1)*8+12)
   end
  end
  -- show final score
  print("black: " .. black.final, 10, 1, 7)
  print("white: " .. white.final, 85, 1, 7)
  spr(112, 0, 120, 16, 1)
  print("❎play again 🅾️continue playing", 2, 122, 0)
 end
 
end

function update_game()
 -- if scoreing starts
 if black.pass and white.pass then
  scoring = true
  if scoring_start == false then
   scoring_start = true
   score_game()
  end
 end
 
 if scoring == true then
  -- scoring actions
  if btnp(❎) then
   _init()
  elseif btnp(🅾️) then
   scoring = false
   scoring_start = false
   black.pass = false
   white.pass = false
   copy_tab(b.board, b.scoremap)
  end
  
  
 else
  -- info box
  if show_info then info_timer += 1 end
  if info_timer > 45 then show_info = false info_timer = 0 end
 
  -- pointer motion
  pointer.timer += 1
  if (pointer.timer > 10) then pointer.timer = -10 end
  if (pointer.timer < 0) then pointer.sp = 8 else pointer.sp = 9 end
  
  -- pointer control
  if btnp(⬅️) and pointer.x > 1 then pointer.x -= 1
  elseif btnp(➡️) and pointer.x < 13 then pointer.x += 1
  elseif btnp(⬆️) and pointer.y > 1 then pointer.y -= 1
  elseif btnp(⬇️) and pointer.y < 13 then pointer.y += 1
  elseif btnp(❎) then
   
   if b.board[flatten(pointer.y, pointer.x)] == b.empty then
    -- save board state to check for ko
    copy_tab(b.board, b.board_temp)
    if pointer.current == b.white then
     b.board[flatten(pointer.y, pointer.x)] = b.white
     sc = 0
     sc = remove_dead(b.black)
     illegal = remove_dead(b.white)
     if illegal == 0 then
      -- check ko
      if not same_tab(b.board, b.board3) then
   		  white.points += sc
       pass_player() 
       sfx(0)
       copy_tab(b.board2, b.board3)
       copy_tab(b.board, b.board2)
   		  white.pass = false
   		  copy_tab(b.board, b.scoremap)
   		 else
       -- ko
       copy_tab(b.board_temp, b.board)
      end
     end
    else
     b.board[flatten(pointer.y, pointer.x)] = b.black
     sc = 0
     sc = remove_dead(b.white)
     illegal = remove_dead(b.black)
     if illegal == 0 then
      -- check ko
      if not same_tab(b.board, b.board3) then
   		  black.points += sc
       pass_player() 
       sfx(0)
       copy_tab(b.board2, b.board3)
       copy_tab(b.board, b.board2)
   		  black.pass = false
   		  copy_tab(b.board, b.scoremap)
   		 else
       -- ko
       copy_tab(b.board_temp, b.board)
      end
     end
    end
   end
   
  elseif btnp(🅾️) then
   show_info = true
  end
 end 
end


-- pico 8 functions
function _init()
 -- col change
 poke(0x5f10+1, 128+1)
	poke(0x5f10+2, 128+2)
	
	-- music
 music()
 init_title()
end

function _draw()
 if mode == 0 then
  draw_title()
 else
  draw_game()
 end
end

function _update()
 if mode == 0 then
  update_title()
 else
  update_game()
 end
end
-->8
-- common functions

-- pass to next palyer
function pass_player()
 if pointer.current == b.white then
  white.pass = true
  pointer.current = b.black
 else
  black.pass = true
  pointer.current = b.white
 end
end

-- check if point is on board
function on_board(x, y)
 if (x>0) and (x<14) and (y>0) and (y<14) then
  return true
 else
  return false
 end
end

-- flatten coordinate
function flatten(x,y)
 return b.size * (x-1) + y
end

-- unflatten coordinate
function unflatten(fc)
 x = flr(fc / 13) + 1
 y = fc % 13
 if y == 0 then y = 13 x=x-1 end
 return x,y
end

-- unique add
function u_add(tab, val)
 for x in all(tab) do
  if x == val then return false end
 end
 add(tab, val)
 return true
end

-- check if element in table
function contains(tab, val)
 for i in all(tab) do
  if i == val then return true end
 end
 return false
end

-- reverse col
function reverse_col(col)
 if col==b.black then return b.white
 else return b.black end
end

-- compare boards
function same_tab(t1, t2)
 if count(t1) != count(t2) then return false end
 for i=1, count(t1) do
  if t1[i] != t2[i] then
   return false
  end
 end
 return true
end

-- copy table
function copy_tab(t1, t2)
 for i=1, count(t1) do
  t2[i] = t1[i]
 end
end
-->8
-- stone removal functions

-- get neighbors of point
function get_neighbors(p)
 x, y = unflatten(p)
 possibles = {{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}}
 defs = {}
 for i in all(possibles) do
  if on_board(i[1], i[2]) then
   add(defs, flatten(i[1], i[2]))
  end
 end
 return defs
end

-- get all neighbors
function get_all_neighbors()
 temp = {}
 for i=1,#b.board do
  add(temp, get_neighbors(i))
 end
 return temp
end

-- find reach
-- returns chain of stones
-- returns reach all reach points
function find_reach(fc)
 col = b.board[fc]
 chain = {}
 u_add(chain, fc)
 reach = {}
 frontier = {}
 u_add(frontier, fc)
 
 while #frontier > 0 do
  current_fc = deli(frontier, #frontier)
  u_add(chain, current_fc)
  for fn in all(all_n[current_fc]) do
   if b.board[fn] == col and not contains(chain, fn) then
    u_add(frontier, fn)
   elseif b.board[fn] != col then
    u_add(reach, fn)
   end
  end
 end
 return chain, reach
end

-- check if a stone group is dead
-- return true if stone needs to be removed
function check_dead(fc)
 if b.board[fc] == b.empty then return false end
 col = reverse_col(b.board[fc])
 chain, reach = find_reach(fc)
 for p in all(reach) do
  if b.board[p] == b.empty then -- opponent
   return false
  end
 end
	return true
end

-- remove dead stones
function remove_dead(col)
 to_remove = {}
 for p=1,#b.board do
  if b.board[p] == col then
   if check_dead(p) then
    u_add(to_remove, p)
   end
  end
 end
 score = #to_remove
 for i in all(to_remove) do
  b.board[i] = b.empty
 end
 return score
end


-->8
-- scoring
-- if both players pass score!
-- find all chains of empty area
-- for each, check reach
-- if reach is all one col
 -- award them to col

function score_game()
 black_area = {}
 white_area = {}
 for i=1, #b.board do
  if b.board[i] == b.empty then
   chain, reach = find_reach(i)
   -- check if reach is all same
   if match_col(reach, b.white) then
    u_add(white_area, i)
   elseif match_col(reach, b.black) then
    u_add(black_area, i)
   end
  end
 end
 for x in all(black_area) do
  b.scoremap[x] = b.black
 end
 for y in all(white_area) do
  b.scoremap[y] = b.white
 end
 
 black.final = black.points
 white.final = white.points
 for p in all(b.scoremap) do
  if p == b.black then black.final += 1
  elseif p == b.white then white.final += 1 end
 end
end

-- function check col
function match_col(tab, col)
 for p in all(tab) do
  if b.board[p] != col then return false end
 end
 return true
end
-->8
-- image compress

-- image compressor for title screen

-- main program ---------------
function draw_title_screen()
 cls()
 --info()
 t="/aml?g-gqdqd-gqdqdqd-/aw.?5dq,?g-????g/bd.qd-/ay.?5/bg.dqd????5/bd.dq,/aj.?qdq,5/bg.dqd/az.?q/bf.dq,??/bf.qdq,/ai.?gqd-?5/bg.dq,/az.?q/bd.dqd-?/bh.qdq,/ah.?5dqd-?/bg.qd-/az.?g/bd.qdq,?g/bf.qdq,qd-/ai.?qdqd??/bg.qd/az.?q/bd.dq,???g/be.qdq,?gqd/ai.?gqdq,??/bf.qdq,/ay.?gqdqdqdq,????5/bd.dqd????5dq,/ah.?5dqd-??g/bf.qd/az.?qdqdq,/av.?qd-/ah.?gqdqd/ah.?5dqdqdq,/ay.?gqdqd/ak.?gqdq,/ag.?gqd/ah.?5dqdq,/ag.?gqdqdqd/az.?5dqdq,/aj.?5dqd-/ag.?5dq,/ah.?qdqd-/ag.?qdqdqd-/a1.?qdqd/al.?qdqd/ah.?qd-/ah.?gqdqd/af.?5dqdqdq,/az.?5dqdq,/aj.?5dqdq,??5d???gqd/ah.?5dqdq,??5/bd.dqd/a2.?qdqd/af.?5dqdq,qdqd-gqdqd??qdq,/ah.?qdqd????/bd.qdq,/a1.?gqdq,????qdqdqd-gqdq,5dqd-??gqd-/ah.?gqdq,???g/bd.qdq,/az.?5dqd-?/bd.qd-?5dqd-?5dqd??5dqd/ah.?5dqd-???5/be.dqd/az.?qdq,??qdqdqdq,??qdqd??qdq,??5dq,/ah.?qdqd????5/be.dqd/ay.?gqd-????gqdqd???gqdq,??qd-???qd-/ah.?gqdq,/aj.?5dqdq,/ax.?5dqd?????gqdq,??5dqd-???-????gqd/ah.?5dqd-/am.?qdq,/ax.?qdq,????qdqd-???qdqd/ah.?5dq,/ah.?qdqd/an.?qd-/ax.?gqd-????gqdqd???gqdq,/ah.?qd-/ah.?gqdq,/an.?qd-/aw.?5dqd????5dqdq,??5dqd-/ag.?qdqd-/ag.?5dqd-/an.?gqd/ax.?qdq,????qdqd????qdqd???g/bd.qd-/ag.?qdqd/an.?qdq,/aw.?gqd-????gqdq,????/bg.qdq,/ag.?gqdq,5d/aj.?5dqd-/aw.?5dqd????5dqd-????g/bg.qd/ah.?5dqd-?qd/ah.?qdqdqd/ax.?5dq,???gqdq,????5/bf.dqd-/ai.?qdqd?g/bg.qdq,/ax.?5dq,5d-gqd-???/bg.qd-/aj.?gqd-???/bg.qd-/ay.?5dqdq,5dqd???g/bf.qd/al.?5dqd????/bg.qd/az.?5dq,??qdq,???g/bd.qd-/ao.?qdq,????/bf.qdq,/a5.?gqd-????gqdqdq,/aq.?gqd-?????/bf.qd/a6.?5dq,?????gqd-/at.?gq,/ag.?g/bd.qdq,/a6.?qd-/a3.?5d-/ah.?gqdqdqdq,/a8.?qd/a4.?5,/ai.?gqdqdq,/a9.?gq,/ata?-/a&h?-???-/ala?goqtdaetdaqtd/aga?sqdutqdqdqtqeqp+/aea?teqdqdueqeqeqdqe+/aca?ouqeudqeqeqdqeudue+/aca?teqdqtqdqeudqdqdup/aba?o!tdqtudueqtqdqtqdtr/aba?t@deqdqeqdqdqtqtd!i</a.a?o!y@i/bf.qd!y@i</a.a?t/bi.@y@+/a.a?s/bi.y@yr/a.a?o!/bi.y@i</a.a?t/bi.@y@+/aaa?t/bh.@y@i</aaa?s/bi.y@+/aaa?o!/bh.y@yr/aba?o!/bh.y@+/aca?o!/bg.y@i</aw.?1@<?1@</a@.?o!/bf.y@yr/ax.?@y@<@y@</a@.?o!/bf.y@+/ay.?@y[?@y[/a#.?o!/be.y@iuuu/ax.?u<??u<`y]/a!.?oqt@y@y@y@dquu/az.?`y]??1@y]/a#.?dqdqdqduuu[/aw.?@y?1@y]??1@u/a$.?/ah.u[/aw.?`y@y?1@u???w[/aia?`yv<?w[/aoa?5u??o/bz.qd</a5.?s/bz.y@+/a5.?o!/bz.y@+/a4.?s/bz.y@yr/a4.?o!y@i/bx.qd!yr/a3.?sy@yry@y@yry@y@@!y@yry@y@i!y@yry@y@t@y@yfq@yry@y@t@y@t@i</a2.?o!y@i!y@y@t@y@%y@!y@i!y@y@t@y@i!y@yry@y@qdq@i!y@y@t@y@t@i</a1.?sy@yr/bd.dqdy@y@/bj.qdqtdqda/be.qdqy@+/a1.?o!y@%yy@vzf!y@yz@yy@yry@y@i!y@yry@y@i!y@ydq0y@t@y@yry@yry@+/az.?s@qdq@ydy0y@yy@yzv@y@i!y@yfq@y@%yy@y@t@y@%yy@yry@y@i!y@i!yr/ax.?]sdy@yuu@y@yuy@qd!i!y@yry@y@qdq@yz@yy@yry@yz@yy@yry@y@i!y@i!yr/av.?0y@u!yvu@yuu@y@yvufy@qdqdqdqtdqdaq@y@ydqdqdq@y@y/bf.dqt@i</at.?dyvyuyvu!uvy@uvyuuvu@ufqy@t@y@ydq0y@@yv@y@t@y@@yv@y@t@y@yry@y@t@i</ar.?ou@uvu@y@y@yuu!u!yvuvu!y@yyry@y@ydy@y@@!y@yry@y@@qy@y@t@y@yry@yry@+/ar.?svyuu@y!yuu!yvuuy@yuy@u@y@qi!y@y@t@y@yry@y@i!y@y@i!y@yry@y@i!y@yry@+/aq.?ty!y!yvu@y@u@yvuvu!y@yvyvu!/bs.qd!yr/aq.?s!y@u@u@yvyvyuy@yuy@u!yvy@yfqy@y@i!y@y@t@y@y@t@y@yry@y@i!y@y@t@y@i!yr/ap.?trvuvy@u@u@y@u@y@y@u@yvu!y@qi!y@y@t@y@yry@y@yry@y@i!yzv@tdy@yry@y@t@i</ao.?syr@yuuvuuy!uvuuy@yuy@y@y!yt@t@y@yry@y@i!y@y@i!y@y@t@@yvfqdy@yry@yry@i</an.?t@yr0u@uvuvu@y!y@yuuvu@y@ud!y@/bk.dq0y@yvdqd/bd.dqy@+/an.?sy@y@dq0y@y!y@u@yvy@y@yfqd!y@yry@y@t@y@yry@y@yry@y@yr%y@!qdq@y@i!y@i!y@+/am.?t@y@y@y@dqdyvuvy@y!yfqdqy@y@y@yry@@yy@y@i!y@y@i!y@y@i!%yy@q0y@y@t@y@i!yr/am.?s/be.y@i/bd.qdq/be.y@i!%y@yy@y@t@y@y@t@y@y@t@y@y@t@y@y@t@y@t@yr/al.?o!/bo.y@dy@y@y/bp.dqt@i</al.?t/bo.@yryz@yv@y@i!y@y@yry@y@i!y@y@yry@y@i!y@yry@i</ak.?s/bo.y@i!yz@!y@y@t@y@y@i!y@y@i!y@y@i!y@y@i!y@yry@+/ak.?o!/bo.y@t@yry@y@yry@y@y@t@y@y@t@y@y@t@y@y@t@y@i!y@+/ak.?t/bo.@yry@i!y@y@i!y@y@yry@y@yry@y@y@t@y@y@t@y@i!yr/ak.?s/bo.y@i/bs.qdqt@yr/ak.?s/bn.y@yr/bu.y@i</aj.?o!/bn.y@i!/bu.y@i</aj.?o!/bm.y@yr/bv.y@+/ak.?t/bm.@y@i!/bv.y@+/ak.?t/bm.@yr/bv.y@yr/ak.?s/bm.y@i/bw.qd</ak.?s/bl.y@yr/a).u[/al.?s/bl.y@+/a,.?s/bk.y@i</a<.?s/bj.y@yr/a?.?s/bj.y@+/a.a?st/bh.@y@d</aba?d!/bg.y@d</ada?oq/bf.y@duuu/a#.?gqd/a1.?sdqy@y@y@iqduuuuu/a@.?qdqd?gqd/av.?uuuqdqdqdq/ag.u</a!.?gqdq,qdqd/au.?w/ap.u/a#.?gqd[gqdq,/au.?w/an.u[/a$.?wu<?gqd[/aw.?/aj.u[/a(.?qd-wu</ana?5dqd-/aqa?qdqd/ara?qdq</ara?uu/a+b?o"
 bit6to8(t, 24576)
end--main()

-- init global variables ------

function initglobal()
 chr6x,asc6x={},{}
 local b6=".abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()`~-_=+[]{};':,<>?"
 local i,c
  for i=0,63 do
   c=sub(b6,i+1,i+1)
   chr6x[i]=c asc6x[c]=i
  end  
 compressdepth=2
end--initglobal()

-- functions ------------------

-- convert integer a to char-6
function chr6(a)
 local r=chr6x[a]
 if (r=="" or r==nil) r="."
 return r
end--chr6(.)

-- test bit #b in a
function btst(a,b)
local r=false
 if (band(a,2^b)>0) r=true
 return r
end--btst(..)

-- return asc-6 of string a
-- from character position b
function fnca(a,b)
local r=asc6x[sub(a,b,b)]
 if (r=="" or r==nil) r=0
 return r
end--fnca(..)

-- return string a repeats of b
function strng(a,b)
local i,r=0,""
 for i=1,a do
  r=r..b
 end
 return r
end--strng(..)

-- convert compressed 6-bit
-- string to 8-bit binary
-- memory
function bit6to8(t,m)
local i,d,e,f,n,p=0,0,0,0,0,1
 repeat
  if sub(t,p,p)=="/" then
   d=fnca(t,p+1)
   e=fnca(t,p+2)+64*fnca(t,p+3)
   t=sub(t,1,p-1)..strng(e,sub(t,p+4,p+4+d-1))..sub(t,p+d+4)
   p+=d*e-1
  end
  p+=1
  until p>=#t
   p=1 d=0 e=0
   for i=1,#t do
    c=fnca(t,i)
    for n=0,5 do
     if (btst(c,n)) e+=2^d
     d+=1
     if (d==8) poke(m+f,e) d=0 e=0 f+=1
  end
 end
end--bit6to8(..)

-- convert 8-bit binary memory
-- area to compressed 6-bit
-- clipboard ready sourcecode
function bit8to6clip(i,m)
 bit8to6(i,m,0)
end--bit8to6clip(...)

-- convert 8-bit binary memory
-- area to compressed 6-bit
-- string or save to clipboard
function bit8to6(i,m,f)
local j,k,l,p,n,c,t=0,0,0,0,0,0,""
 m+=i-1
 for j=i,m do
  p=peek(j)
  for k=0,7 do
   if (btst(p,k)) c+=2^l
    l+=1 if (l==6 or (j==m and k==7)) t=t..chr6(c) c=0 l=0
   end
  end
 for i=1,compressdepth do
  j=1
  repeat
   c=sub(t,j,j+i-1) d=sub(t,j,j)
   n=0 p=j
    if d=="/" then
     j+=i+3
    else
     repeat
      ok=1
      if (c==sub(t,p,p+i-1)) n+=1 p+=i ok=0
       until ok==1 or n==4095
      end
      if n>0 and n!=nil then
       a="/"..chr6(i)..chr6(n%64)..chr6(flr(n/64))..c
      if #a<i*n then
       t=sub(t,1,j-1)..a..sub(t,j+i*n)
       j+=#a-1
      end
     end
     j+=1
    until j>#t-i
 end
 if f==0 then
  printh("t=\""..t.."\"\n","@clip")
 else
  return t
 end
end


__gfx__
0000000099999994499999949999994499999994999999940011100000ddd0007770077700000000000000000000000000000000000000000000000000000000
000000009999999499999994999999949999999499999994012221000d777d007880088707777770000000000000000000000000000000000000000000000000
00700700999999949999999499999994999999949999999412dd2210d76677d0780000870788887000b0b0000080800000000000000000000000000000000000
00077000999999949999999499999994999999949999999412d22215d76777d50000000007800870000b00000008000000000000000000000000000000000000
00077000999999949999999499999994999999949999999412222215d77777d5000000000780087000b0b0000080800000000000000000000000000000000000
007007009999999499999994999999949999999499999994012221550d777d557800008707888870000000000000000000000000000000000000000000000000
0000000099999994999999949999999499999944499999940011155000ddd5507880088707777770000000000000000000000000000000000000000000000000
00000000444444444444444444444444444444444444444400055500000555007770077700000000000000000000000000000000000000000000000000000000
33333333099999949999999999999990000000003333333304405333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999949999999999999990999999990333333340405333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999949999999999999990999999994033333344005333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999949999999999999990999999994403333300005333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999949999999999999990999999994440333355555333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999949999999999999990999999994440533333333333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999949999999999999990999999994440533333333333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999940000000099999990444444444440533333333333000000000000000000000000000000000000000000000000000000000000000000000000
30444444099999990000000000000000999999904440533344444444000000000000000000000000000000000000000000000000000000000000000000000000
33044444099999990999999999999990999999904440533344444444000000000000000000000000000000000000000000000000000000000000000000000000
33304444099999990999999999999990999999904440533344444444000000000000000000000000000000000000000000000000000000000000000000000000
33330000099999990999999999999990999999904440533300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333555099999990999999999999990999999904440533355555555000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999990999999999999990999999904440533333333333000000000000000000000000000000000000000000000000000000000000000000000000
33333333099999990999999999999990999999904440533333333333000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000999999499999990000000004440533333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff500000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5
5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
__map__
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1022141414141414141414141414231500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010101010101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010101010101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010104050101010104050101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010103020101010103020101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010101010101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010104050101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010103020101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010101010101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010104050101010104050101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010103020101010103020101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010101010101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011010101010101010101010101132500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1021121212121212121212121212242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1020262626262626262626262626261600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000b2100d2100f2101121011210185001820018100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000b3100d3100f3101131011310185000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000541015410104100d4100c410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00200d0200d0200d0200d0200d0000d00014010140001a0301a03000000140001401000000190301903000000000000000000000140100000017030170300000000000000000000014010140100000000000
010b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034010000000000000000
010b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028010280100000000000
010b00000c0530000000000000003c015000000000000000246250000000000000003c0150000000000000003c0150000024625000000c053000000c00000000246250000000000000003c015330000c05300000
__music__
03 03040506

