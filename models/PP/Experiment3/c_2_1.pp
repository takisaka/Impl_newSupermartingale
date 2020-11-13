$ x >= 0

x := 5;
[x <= 0] while true do
  if x <= 9 then
    if prob(0.4) then
      x := x - 1
    else
      x := x + 1
    fi
  else
    x := x + 1
  fi
od;
assume false