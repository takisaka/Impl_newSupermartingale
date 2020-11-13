
{true} tx := ndet(Real[-100,100]);
{-100 <= tx and tx <= 100} x := ndet(Real[-100,100]);
{-100 <= tx and tx <= 100 and -100 <= x and x <= 100} y := ndet(Real[-100,100]);

{-100 <= tx and tx <= 100 and -100 <= x and x <= 100 and -100 <= y and y <= 100} safe := 1;

{-100 <= tx and tx <= 100 and -100 <= x and x <= 100 and -100 <= y and y <= 100 and safe>=-1 and safe<=1 } if (tx >= 0) then
{   0 <= tx and tx <= 100 and -201 <= x and x <= 100 and -100 <= y and y <= 201 and safe>=-1 and safe<=1 }   while (x>=y) do
{   0 <= tx and tx <= 100 and -100 <= x and x <= 100 and -100 <= y and y <= 100 and safe>=-1 and safe<=1 }     if * then
{   0 <= tx and tx <= 100 and -100 <= x and x <= 100 and -100 <= y and y <= 100 and safe>=-1 and safe<=1 }       x := x - 1 - tx
    else
{   0 <= tx and tx <= 100 and -100 <= x and x <= 100 and -100 <= y and y <= 100 and safe>=-1 and safe<=1 }       y := y + 1 + tx
    fi;

/*SlightFailure branch 1*/
{   0 <= tx and tx <= 100 and -201 <= x and x <= 100 and -100 <= y and y <= 201 and safe>=-1 and safe<=1 }     if prob(0.0001) then 
{   0 <= tx and tx <= 100 and -201 <= x and x <= 100 and -100 <= y and y <= 201 and safe>=-1 and safe<=1 }       safe := -1
                                                           else
{   0 <= tx and tx <= 100 and -201 <= x and x <= 100 and -100 <= y and y <= 201 and safe>=-1 and safe<=1 }       skip 
                                                           fi
  od
else
{safe>=-1 and safe<=1}  skip
fi;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
int aaron2() {
  int tx, x, y;
  if (tx>=0) {
    while (x>=y) {
      if (tx<0) return 0;
      if (nondet()) 
	{
	  x=x-1-tx;
	}
      else
	{
	  y=y+1+tx;
	}
    }
  }
  return 0;
}
*/