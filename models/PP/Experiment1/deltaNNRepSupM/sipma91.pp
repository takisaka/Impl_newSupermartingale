{true} x := ndet(Real[0,150]);

{0<=x and x<=150} safe := 1;

{0<=x and x<=150 and safe>=-1 and safe<=1}  y1 := x;
{0<=x and x<=150 and y1=x and safe>=-1 and safe<=1}  y2 := 1;

{0<=x and x<=150 and y1=x and y2=1 and safe>=-1 and safe<=1}  if y1 -1 >= 100 then
{safe>=-1 and safe<=1}     z := y1 - 10

  else
{0<=x and x<=150 and 0  <=y1 and y1<=111 and 1<=y2 and safe>=-1 and safe<=1}    while y1 <= 100 do
{0<=x and x<=150 and 0  <=y1 and y1<=100 and 1<=y2 and safe>=-1 and safe<=1}      y1 := y1 + 11;
{0<=x and x<=150 and 11 <=y1 and y1<=111 and 1<=y2 and safe>=-1 and safe<=1}      y2 := y2 + 1
    od;
{0<=x and x<=150 and 100<=y1 and y1<=112 and 1<=y2 and safe>=-1 and safe<=1}    while y2 - 1 >= 1 do
{0<=x and x<=150 and 100<=y1 and y1<=112 and 2<=y2 and safe>=-1 and safe<=1}      y1 := y1 - 10;
{0<=x and x<=150 and 90 <=y1 and y1<=102 and 2<=y2 and safe>=-1 and safe<=1}      y2 := y2 - 1;
{0<=x and x<=150 and 90 <=y1 and y1<=102 and 1<=y2 and safe>=-1 and safe<=1}      if y1 - 1 >= 100 and y2 = 1 then
{0<=x and x<=150 and 101<=y1 and y1<=102 and 1=y2  and safe>=-1 and safe<=1}        z := y1 - 10
      else 
{0<=x and x<=150 and 90 <=y1 and y1<=102 and 1<=y2 and safe>=-1 and safe<=1}	      if y1 - 1 >= 100 then
{0<=x and x<=150 and 101<=y1 and y1<=102 and 1<=y2 and safe>=-1 and safe<=1}          y1 := y1 - 10;
{0<=x and x<=150 and 91 <=y1 and y1<=92  and 1<=y2 and safe>=-1 and safe<=1}          y2 := y2 - 1
        else
{0<=x and x<=150 and 90 <=y1 and y1<=101 and 1<=y2 and safe>=-1 and safe<=1}          skip
        fi;
{0<=x and x<=150 and 90 <=y1 and y1<=101 and 0<=y2 and safe>=-1 and safe<=1}        y1 := y1 + 11;
{0<=x and x<=150 and 101<=y1 and y1<=112 and 0<=y2 and safe>=-1 and safe<=1}        y2 := y2 + 1
      fi;

/*SlightFailure branch*/
{0<=x and x<=150 and 101<=y1 and y1<=112 and 1<=y2 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0<=x and x<=150 and 101<=y1 and y1<=112 and 1<=y2 and safe>=-1 and safe<=1}           safe := -1
 else
{0<=x and x<=150 and 101<=y1 and y1<=112 and 1<=y2 and safe>=-1 and safe<=1}           skip
 fi

    od
  fi;

{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*
void sipma91(int x){
  int y1, y2, z;

  y1 = x;
  y2 = 1;

  if(y1 > 100) z = y1 - 10;
  else {
    while(y1 <= 100){
      y1 = y1 + 11;
      y2 = y2 + 1;
    }

    while(y2 > 1){
      y1 = y1 - 10;
      y2 = y2 - 1;
      if(y1 > 100 && y2 == 1) z = y1 - 10;
      else {
	if(y1 > 100){
          y1 = y1 - 10;
          y2 = y2 - 1;
        }
        y1 = y1 + 11;
        y2 = y2 + 1;
      }
    }
  }
}
*/