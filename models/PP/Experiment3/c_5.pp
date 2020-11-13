$ x >= 0

x := 5;
while true do
  if prob(0.25) then
    x := x - 1
  else
    x := x + 1
  fi;
  [x <= 0] skip
od;
assume false