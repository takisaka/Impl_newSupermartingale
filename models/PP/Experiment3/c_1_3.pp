$ x >= 0 and x <= 1000

x := 500;
[x <= 0] while true do
  if x <= 999 then
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