/* successfull code */

{true} i := ndet(Real[0,50]);
{0<=i and i<=50} j := ndet(Real[0,50]);
{0<=i and i<=50 and 0<=j and j<=50} n := ndet(Real[0,50]);

{0<=i and i<=50 and 0<=j and j<=50 and 0<=n and n<=50} safe := 1;

{0<=i and i<=50 and 0<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1} i := 0;
{i=0            and 0<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1} j := 0;

{i=j   and 0<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1} while j <= n - 2 do
{i=j   and 0<=j and j<=49 and 0<=n and n<=50  and safe>=-1 and safe<=1}   j := j+1;
{i=j-1 and 1<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1}   i := i+1;

/*SlightFailure branch*/
{i=j and 1<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1  }         if prob(0.0001) then 
{i=j and 1<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1  }           safe := -1
 else
{i=j and 1<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1  }           skip
 fi

 od;

{i=j   and 0<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1} while j >= n - 1 and i <= n - 2 do
{i=j   and 0<=j and j<=50 and 0<=n and n<=50 and safe>=-1 and safe<=1}  skip
 od;

{safe>=-1 and safe<=1} refute (safe <= 0)

/* original code below */
/*
int ax() {
  int i,j,n;

    i=0;
    do {
      j=0;
      while(j<n-1) ++j;
      ++i;
    }
    while(j>=n-1 && i<n-1);

  return 0;
}
*/