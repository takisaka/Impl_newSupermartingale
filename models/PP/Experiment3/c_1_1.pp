$ x >= 0 and x <= 10

x := 5;
[x <= 0] while true do
  if x <= 9 then
    if prob(0.4) then
      x := x - 1
    else
      x := x + 1
    fi
  else
    skip
  fi
od;
assume false