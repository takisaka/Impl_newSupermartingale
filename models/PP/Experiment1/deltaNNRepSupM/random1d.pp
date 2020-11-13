{true} max := ndet(Real[0,50]);

{0<=max and max<=50} safe := 1;

{0<=max and max<=50 and safe>=-1 and safe<=1} if max + 1 >= 0 then
{1<=max and max<=50 and safe>=-1 and safe<=1}  a := 0;
{1<=max and max<=50 and a = 0 and safe>=-1 and safe<=1}  x := 1;
{1<=max and max<=50 and 1 <= x and x <= max+1 and 0-x <= a and a <= x and safe>=-1 and safe<=1}  while x <= max do
{1<=max and max<=50 and 1 <= x and x <= max   and 0-x <= a and a <= x and safe>=-1 and safe<=1}    if prob(0.5) then
{1<=max and max<=50 and 1 <= x and x <= max   and 0-x <= a and a <= x and safe>=-1 and safe<=1}      a := a + 1
    else
{1<=max and max<=50 and 1 <= x and x <= max   and 0-x <= a and a <= x and safe>=-1 and safe<=1}      a := a - 1
    fi;
{1<=max and max<=50 and 1 <= x and x <= max   and 0-x-1 <= a and a <= x+1 and safe>=-1 and safe<=1}    x := x + 1;

/*SlightFailure branch*/
{1<=max and max<=50 and 2 <= x and x <= max+1 and 0-x <= a and a <= x and safe>=-1 and safe<=1}         if prob(0.0001) then 
{1<=max and max<=50 and 2 <= x and x <= max+1 and 0-x <= a and a <= x and safe>=-1 and safe<=1}           safe := -1
 else
{1<=max and max<=50 and 2 <= x and x <= max+1 and 0-x <= a and a <= x and safe>=-1 and safe<=1}           skip
 fi

  od
else
{safe>=-1 and safe<=1}  skip
fi;

{safe>=-1 and safe<=1} refute (safe <= 0)

/* original code below */
/*

int random1d() {
  int a,x,max;
  if (max>0) {
  a=0;
  x=1;
  while (x<=max) {
    if (random()) a=a+1; else a=a-1;
    x=x+1;
  }
  }

}
*/