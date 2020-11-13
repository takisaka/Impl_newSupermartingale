{true} i := ndet(Real[0,10]);
{0<=i and i<=10} j := ndet(Real[0,10]);

{0<=i and i<=10 and 0<=j and j<=10} safe := 1;
  
{0<=i and i<=10 and 0<=j and j<=10 and safe>=-1 and safe<=1}  while i + 1 <= 5 do
{0<=i and i<=4  and 0<=j and j<=10 and safe>=-1 and safe<=1}    j := 0;
{0<=i and i<=4  and 0<=j and j<=10 and safe>=-1 and safe<=1}    while i - 1 >= 2 and j <= 9 do
{3<=i and i<=4  and 0<=j and j<=9  and safe>=-1 and safe<=1}      j := j + 1
    od;
{0<=i and i<=4  and 0<=j and j<=10 and safe>=-1 and safe<=1}    i := i + 1;

/*SlightFailure branch*/
{1<=i and i<=5  and 0<=j and j<=10 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{1<=i and i<=5  and 0<=j and j<=10 and safe>=-1 and safe<=1}           safe := -1
 else
{1<=i and i<=5  and 0<=j and j<=10 and safe>=-1 and safe<=1}           skip
 fi

  od;

{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*
int wcet2 () {
  int i,j;

  while(i<5){

    j=0;
    while(i>2 && j<=9) j++;
    i++;

  }
  return 0;
}
*/