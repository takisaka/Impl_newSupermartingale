{true} N := ndet(Real[0,50]);

{0<=N and N<=50} safe := 1;

{0<=N and N<=50 and safe>=-1 and safe<=1} x := 0;
{0<=N and N<=50 and x=0 and safe>=-1 and safe<=1} y := 0;
{0<=N and N<=50 and x=0 and y=0 and safe>=-1 and safe<=1} i := 0;

{0<=N and N<=50 and 0<=i and i<=N   and 0-i <= x and x <= i   and 0-i <= y and y <= i   and safe>=-1 and safe<=1} while i + 1 <= N do
{0<=N and N<=50 and 0<=i and i<=N-1 and 0-i <= x and x <= i   and 0-i <= y and y <= i   and safe>=-1 and safe<=1}  i := i + 1;
{0<=N and N<=50 and 1<=i and i<=N   and 1-i <= x and x <= i-1 and 1-i <= y and y <= i-1 and safe>=-1 and safe<=1}  if prob(0.5) then
{0<=N and N<=50 and 1<=i and i<=N   and 1-i <= x and x <= i-1 and 1-i <= y and y <= i-1 and safe>=-1 and safe<=1}    if prob(0.5) then
{0<=N and N<=50 and 1<=i and i<=N   and 1-i <= x and x <= i-1 and 1-i <= y and y <= i-1 and safe>=-1 and safe<=1}      x := x + 1
    else
{0<=N and N<=50 and 1<=i and i<=N   and 1-i <= x and x <= i-1 and 1-i <= y and y <= i-1 and safe>=-1 and safe<=1}      x := x - 1
    fi
  else
{0<=N and N<=50 and 1<=i and i<=N   and 1-i <= x and x <= i-1 and 1-i <= y and y <= i-1 and safe>=-1 and safe<=1}    if prob(0.5) then
{0<=N and N<=50 and 1<=i and i<=N   and 1-i <= x and x <= i-1 and 1-i <= y and y <= i-1 and safe>=-1 and safe<=1}      y := y + 1
    else
{0<=N and N<=50 and 1<=i and i<=N   and 1-i <= x and x <= i-1 and 1-i <= y and y <= i-1 and safe>=-1 and safe<=1}      y := y - 1
    fi
  fi;

/*SlightFailure branch*/
{0<=N and N<=50 and 1<=i and i<=N   and 0-i <= x and x <= i   and 0-i <= y and y <= i   and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0<=N and N<=50 and 1<=i and i<=N   and 0-i <= x and x <= i   and 0-i <= y and y <= i   and safe>=-1 and safe<=1}           safe := -1
 else
{0<=N and N<=50 and 1<=i and i<=N   and 0-i <= x and x <= i   and 0-i <= y and y <= i   and safe>=-1 and safe<=1}           skip
 fi 
od;

{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*
int random2d() {
  int N;
  int x;
  int y;
  int i;
  int r;


  x=0;
  y=0;
  i=0;
  while (i<N) {
    i=i+1;
    r=random(); 
    if (r>=0 && r<=3) {
    	if (r==0) x=x+1; else
    	if (r==1) x=x-1; else
    	if (r==2) y=y+1; else
    	if (r==3) y=y-1;
    }
  }
  return 0;
}
*/