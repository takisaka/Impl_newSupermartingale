x := Geom(0.5);
while x >= 1 do
  x := x - 1
od;
if prob(0.5) then
  while true do
    x := x - 1
  od
else
  skip
fi;
[true]