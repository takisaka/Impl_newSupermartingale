/* successfull code */

{true} x := ndet(Real[0,50]);
{0<=x and x<=50} y := ndet(Real[0,50]);

{0<=x and x<=50 and 0<=y and y<=50} safe := 1;

{0<=x and x<=50 and 0<=y and y<=50 and safe>=-1 and safe<=1} while x <= 9 and x - y <= 2 and x - y >= 1 do
{9<=x and x<=50 and 0<=y and y<=50 and safe>=-1 and safe<=1} x := Unif(0,50);
{0<=x and x<=50 and 0<=y and y<=50 and safe>=-1 and safe<=1}   y := x;

/*SlightFailure branch*/
{0<=x and x<=50 and 9<=y and y<=50 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0<=x and x<=50 and 9<=y and y<=50 and safe>=-1 and safe<=1}           safe := -1
 else
{0<=x and x<=50 and 9<=y and y<=50 and safe>=-1 and safe<=1}           skip
 fi
od;

{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*

int random();

int relation1(){
  int x,y;

  x=0;

  do {
    x=random();
    y=x;

    if ((x-y>2) || (x-y<1)) break;
  }
  while(x<10);

  return 0;
}
*/