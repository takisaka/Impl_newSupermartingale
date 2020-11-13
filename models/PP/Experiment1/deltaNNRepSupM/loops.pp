{true} x := ndet(Real[0,50]);
{0<=x and x<=50} y := ndet(Real[0,50]);
{0<=x and x<=50 and 0<=y and y<=50} n := ndet(Real[1,50]);

{0<=x and x<=50 and 0<=y and y<=50 and 1<=n and n<=50} safe := 1;

{0<=x and  x<=50 and 0<=y and y<=50 and 1<=n and n<=50 and safe>=-1 and safe<=1} x := n;
{0<=x and  x<=50 and 0<=y and y<=50 and 1<=n and n<=50 and safe>=-1 and safe<=1} if x >= 0 then
{-1<=x and x<=50 and 0<=y and y<=50 and 1<=n and n<=50 and safe>=-1 and safe<=1}  while x >= 0 do
{0<=x and  x<=50 and 0<=y and y<=50 and 1<=n and n<=50 and safe>=-1 and safe<=1}    y := 1;
{0<=x and  x<=50 and y=1            and 1<=n and n<=50 and safe>=-1 and safe<=1}    if y + 1 <= x then
{0<=x and  x<=50 and 1<=y and y<=98 and 1<=n and n<=50 and safe>=-1 and safe<=1}      while y + 1 <= x do
{0<=x and  x<=50 and 1<=y and y<=49 and 1<=n and n<=50 and safe>=-1 and safe<=1}       y := 2 * y 
      od
    else
{0<=x and  x<=2  and y=1            and 1<=n and n<=50 and safe>=-1 and safe<=1}      skip
    fi;
{0<=x and  x<=50 and 1<=y and y<=98 and 1<=n and n<=50 and safe>=-1 and safe<=1}    x := x - 1;

/*SlightFailure branch*/
{-1<=x and x<=49 and 1<=y and y<=98 and 1<=n and n<=50 and safe>=-1 and safe<=1}   if prob(0.0001) then 
{-1<=x and x<=49 and 1<=y and y<=98 and 1<=n and n<=50 and safe>=-1 and safe<=1}     safe := -1
  else
{-1<=x and x<=49 and 1<=y and y<=98 and 1<=n and n<=50 and safe>=-1 and safe<=1}     skip
  fi 
  od
else
{safe>=-1 and safe<=1}  skip
fi;

{safe>=-1 and safe<=1} refute (safe <= 0)

/* original code below */
/*
void loops(){

  int n;  // n > 0 
  int x, y;
  
  x = n;
  if(x >= 0)
    while(x >= 0){
      y = 1;
      if(y < x)
        while(y < x)
          y = 2*y;
      x = x - 1;
    }

}
*/