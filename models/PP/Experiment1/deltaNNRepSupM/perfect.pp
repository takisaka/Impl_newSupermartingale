{true} x := ndet(Real[0,100]);

{0<=x and x<=100} safe := 1;

{0<=x and x<=100 and safe>=-1 and safe<=1} if x <= 1 then
{0<=x and x<=1   and safe>=-1 and safe<=1}   skip
                  else
{1<=x and x<=100 and safe>=-1 and safe<=1}   y1:=x-1;
{1<=x and x<=100 and 0<=y1 and y1<=99 and safe>=-1 and safe<=1}   y2:=x;
{1<=x and x<=100 and 0<=y1 and y1<=99 and 1<=y2 and y2<=100 and safe>=-1 and safe<=1}   y3:=x;

{1<=x and x<=100 and 0<=y1 and y1<=99 and 1<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}  while (y1>=1) do
{1<=x and x<=100 and 1<=y1 and y1<=99 and 0<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}    while (y2 >= y1) do
{1<=x and x<=100 and 1<=y1 and y1<=99 and 1<=y2 and y2<=100 and y3<=100 and y2 >= y1 and safe>=-1 and safe<=1}      y2 := y2 - y1
od;
{1<=x and x<=100 and 1<=y1 and y1<=99 and 0<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}    if (y2 = 0) then
{1<=x and x<=100 and 1<=y1 and y1<=99 and y2=0              and y3<=100 and safe>=-1 and safe<=1}      y3 := y3 - y1
else
{1<=x and x<=100 and 1<=y1 and y1<=99 and 0<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}      skip
fi;
{1<=x and x<=100 and 1<=y1 and y1<=99 and 0<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}    y2 := x;
{1<=x and x<=100 and 1<=y1 and y1<=99 and 1<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}    y1 := y1-1;

/*SlightFailure branch*/
{1<=x and x<=100 and 0<=y1 and y1<=98 and 1<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{1<=x and x<=100 and 0<=y1 and y1<=98 and 1<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}           safe := -1
 else
{1<=x and x<=100 and 0<=y1 and y1<=98 and 1<=y2 and y2<=100 and y3<=100 and safe>=-1 and safe<=1}           skip
 fi

  od
fi;

/* the code is apparently non-terminating if we write refute y2=0 instead.
   if you don't know what this code does, then google "perfect number" */
{safe>=-1 and safe<=1} refute (safe <= 0)


/*
int perfect(int x){
  int y1, y2, y3;

  if(x <= 1) return 0;

  y1=x;
  y2=x;
  y3=x;

  for(y1 = x-1; y1>0; y1=y1-1){
    while(y2 >= y1) y2 = y2 - y1;
    if(y2 == 0)
      y3 = y3 - y1;
    y2 = x;
  }

  return (y3 == 0);
}
*/