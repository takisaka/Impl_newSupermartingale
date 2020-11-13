{true} i := ndet(Real[0,150]);
{0<=i and i<=150} j := ndet(Real[0,150]);
{0<=i and i<=150 and 0<=j and j<=150} k := ndet(Real[0,150]);

{0<=i and i<=150 and 0<=j and j<=150 and 0<=k and k<=150} safe := 1;

{0<=i and i<=150 and 0<=j and j<=150 and -1<=k and k<=150 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}  while i <= 100 and j <= k do
{0<=i and i<=100 and 0<=j and j<=101 and 0 <=k and k<=150 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}    ell := i;
{0<=i and i<=100 and 0<=j and j<=101 and 0 <=k and k<=150 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}    i := j;
{0<=i and i<=101 and 0<=j and j<=101 and 0 <=k and k<=150 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}    j := ell + 1;
{0<=i and i<=101 and 0<=j and j<=101 and 0 <=k and k<=150 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}    k := k - 1;

/*SlightFailure branch*/
{0<=i and i<=101 and 0<=j and j<=101 and -1<=k and k<=149 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0<=i and i<=101 and 0<=j and j<=101 and -1<=k and k<=149 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}           safe := -1
 else
{0<=i and i<=101 and 0<=j and j<=101 and -1<=k and k<=149 and 0<=ell and ell<=100 and safe>=-1 and safe<=1}           skip
 fi

  od;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
int terminate(){
  int i, j, k, ell;
  while(i <= 100 && j <= k){
    ell = i;
    i = j;
    j = ell+1;
    k--;
  }
}
*/