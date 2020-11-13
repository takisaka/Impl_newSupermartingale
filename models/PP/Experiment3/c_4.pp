$ x >= 0

x := Unif(0, 1);
while true do
  if prob(0.25) then
    x := 2 * x
  else
    x := 0.5 * x
  fi;
  [x >= 1] skip
od