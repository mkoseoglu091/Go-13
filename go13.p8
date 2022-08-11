pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- main

function _init()
 -- col change
 poke(0x5f10+1, 128+1)
	poke(0x5f10+2, 128+2)

 -- menuitem
 menuitem(1, "pass", function() pass_player() end)

 -- pointer
 pointer = {}
 pointer.x = 1
 pointer.y = 1
 pointer.sp = 8
 pointer.timer = -10
 pointer.current = 2 // 1=white 2=black
 
 -- board
 b = {}
 b.size = 13
 b.empty = "."
 b.black = "b"
 b.white = "w"
 b.board = {}
 
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
 
 -- black stones
 black = {}
 black.sp = 6
 black.points = 0
 
 -- init and store all neighbors
 all_n = get_all_neighbors()
 
 
end

function _draw()
 
 -- draw map
 cls()
 map()
 
 -- draw turn indicator
 if pointer.current == 1 then spr(white.sp, 60, 0)
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
 
 -- draw pointer
 spr(pointer.sp, (pointer.x-1) * 8 + 12, (pointer.y-1) * 8 + 12)
 
 -- draw score
 print("black: " .. white.points, 10, 0)
 print("white: " .. black.points, 90, 0)
 
end

function _update()
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
   if pointer.current == 1 then
    b.board[flatten(pointer.y, pointer.x)] = b.white
    pass_player() 
    sfx(0)
   else
    b.board[flatten(pointer.y, pointer.x)] = b.black
    pass_player()
    sfx(1)
   end
  end
  
 elseif btnp(🅾️) then
  if b.board[flatten(pointer.y, pointer.x)] == b.black then
   b.board[flatten(pointer.y, pointer.x)] = b.empty
   white.points += 1
   sfx(2)
  elseif b.board[flatten(pointer.y, pointer.x)] == b.white then
   b.board[flatten(pointer.y, pointer.x)] = b.empty
   black.points += 1
   sfx(2)
  end
 end
end
-->8
-- common functions

-- pass to next palyer
function pass_player()
 if pointer.current == 1 then
  pointer.current = 2
 else
  pointer.current = 1
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
-->8
-- stone removal functions

-- get neighbors of point
function get_neighbors(p)
 x, y = unflatten(p)
 possibles = {{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}}
 defs = {}
 for i in all(possibles) do
  if on_board(i[1], i[2]) then
   add(defs, i)
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
-- set -> u_add
-- pop -> deli(x,#x)

__gfx__
0000000099999994499999949999994499999994999999940011100000ddd0007770077700000000000000000000000000000000000000000000000000000000
000000009999999499999994999999949999999499999994012221000d777d007880088707777770000000000000000000000000000000000000000000000000
00700700999999949999999499999994999999949999999412dd2210d76677d07800008707888870000000000000000000000000000000000000000000000000
00077000999999949999999499999994999999949999999412d22215d76777d50000000007800870000000000000000000000000000000000000000000000000
00077000999999949999999499999994999999949999999412222215d77777d50000000007800870000000000000000000000000000000000000000000000000
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
0101000017220192201b2201d2201d220185001820018100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000017320193201b3201d3201d320185000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000011420154201c4202542024420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
