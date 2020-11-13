{true} x := ndet(Real[0,50]);
{0<=x and x<=50} y := ndet(Real[0,50]);

{0<=x and x<=50 and 0<=y and y<=50} safe := 1;

{0<=x and x<=50 and 0<=y and y<=50 and safe>=-1 and safe<=1}  if x + 1 <= 0 or y + 1 <= 0 then
{safe>=-1 and safe<=1}    skip
  else 

{0<=x and x<=50 and 0<=y and y<=50 and x-y>=2 and safe>=-1 and safe<=1 or 
 0<=x and x<=50 and 0<=y and y<=50 and y-x>=2 and safe>=-1 and safe<=1}  while x - y - 1 >= 2 or y - x - 1 >= 2 do
{0<=x and x<=50 and 0<=y and y<=50 and x-y>=3 and safe>=-1 and safe<=1 or 
 0<=x and x<=50 and 0<=y and y<=50 and y-x>=3 and safe>=-1 and safe<=1}    if x + 1 <= y then
{0<=x and x<=47 and 0<=y and y<=50 and y-x>=3 and safe>=-1 and safe<=1}      x := x + 1
    else 
{0<=x and x<=50 and 0<=y and y<=47 and x-y>=3 and safe>=-1 and safe<=1}      y := y + 1
    fi;

/*SlightFailure branch*/
{0<=x and x<=50 and 0<=y and y<=50 and x-y>=2 and safe>=-1 and safe<=1 or 
 0<=x and x<=50 and 0<=y and y<=50 and y-x>=2 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0<=x and x<=50 and 0<=y and y<=50 and x-y>=2 and safe>=-1 and safe<=1 or 
 0<=x and x<=50 and 0<=y and y<=50 and y-x>=2 and safe>=-1 and safe<=1}           safe := -1
 else
{0<=x and x<=50 and 0<=y and y<=50 and x-y>=2 and safe>=-1 and safe<=1 or 
 0<=x and x<=50 and 0<=y and y<=50 and y-x>=2 and safe>=-1 and safe<=1}           skip
 fi
 
  od
  fi;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
void wise(){
  int x, y;
  if(x<0 || y<0) return;
  while(x-y>2 || y-x>2)
    if(x < y) ++x;
    else ++y;
}
*/