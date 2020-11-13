{true} x := ndet(Real[0,50]);
{0<=x and x<=50} y := ndet(Real[0,50]);
{0<=x and x<=50 and 0<=y and y<=50} z := ndet(Real[0,50]);

{0<=x and x<=50 and 0<=y and y<=50 and 0<=z and z<=50 and safe>=-1 and safe<=1} safe := 1;

{0<=x and x<=50 and 0<=y and y<=50 and 0<=z and z<=50 and safe>=-1 and safe<=1} x := 12;
{x=12           and 0<=y and y<=50 and 0<=z and z<=50 and safe>=-1 and safe<=1} y := 0;

{12<=x and y<=0 and 0<=z and z<=50 and safe>=-1 and safe<=1 } while z >= 1 do
{12<=x and y<=0 and 1<=z and z<=50 and safe>=-1 and safe<=1 }    x := x + 1;
{13<=x and y<=0 and 1<=z and z<=50 and safe>=-1 and safe<=1 }    y := y - 1;
{13<=x and y<=-1 and 1<=z and z<=50 and safe>=-1 and safe<=1}    z := z - 1;

/*SlightFailure branch*/
{13<=x and y<=-1 and 0<=z and z<=50 and safe>=-1 and safe<=1}   if prob(0.0001) then 
{13<=x and y<=-1 and 0<=z and z<=50 and safe>=-1 and safe<=1}     safe := -1
  else
{13<=x and y<=-1 and 0<=z and z<=50 and safe>=-1 and safe<=1}     skip
  fi 
od;

{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*

int easy2() {
  int x=12;
  int y=0;
  int z;
  while (z>0) {
    x=x+1;
    y=y-1;
    z=z-1;
}
return 0;
}
*/