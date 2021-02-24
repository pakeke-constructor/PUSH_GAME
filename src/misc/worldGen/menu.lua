

local s = [[
##################..............
#...l..p.^^..^..^#..............
#^w.pp...p..^..^.#..............
#..^...p......^p.#..............
#..p....^l..^..^^#..............
#...p.l......^l..#..............
#..l.^...^.^....^#..............
#.....^.....^.^..#..............
#l.^lp..^....^.l.#..............
#..^.l.p.&^..^..^#..............
#.pl...^..p..^^..#..............
#.p.^.p^^..^...^.###############
#..l.^..l.p^^....#.............#
#####..^...^.#####.pp.......pp.#
#....^.^.@..^..^.#.............#
#.^^..^.^.^...^..#......X......#
##################.............#
.................#.pp.......pp.#
.................#.............#
.................###############
]]


local k = {}

for line in s:gmatch("[^\n]+") do
    local n = {}
    for i=1,line:len() do
        table.insert(n, line:sub(i,i))
    end
    table.insert(k,n)
end

return k


