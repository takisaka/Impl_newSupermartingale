{true} n := ndet(Real[0,50]);
{0<=n and n<=50} m := ndet(Real[0,50]);

{0<=n and n<=50 and 0<=m and m<=50} safe := 1;


{0<=n and n<=50 and 0<=m and m<=50 and safe>=-1 and safe<=1}  if m <= 0 then
{safe>=-1 and safe<=1}    skip
  else
 
{0<=n and n<=50 and 0<=m and m<=50 and safe>=-1 and safe<=1}  if n <= m then
{safe>=-1 and safe<=1}    skip
  else


{0<=n and n<=50 and 0<=m and m<=50 and m<=n and safe>=-1 and safe<=1}  i := 0;
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and i=0 and safe>=-1 and safe<=1}  j := 0;

{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n   and 0<=j and j<=m   and safe>=-1 and safe<=1}  while i + 1 <= n do 
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n-1 and 0<=j and j<=m   and safe>=-1 and safe<=1}    if j + 1 <= m then 
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n-1 and 0<=j and j<=m-1 and safe>=-1 and safe<=1}      j := j + 1
    else
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n-1 and 0<=j and j<=m   and safe>=-1 and safe<=1}      j := 0;
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n-1 and 0<=j and j<=m   and safe>=-1 and safe<=1}      i := i + 1
    fi;

/*SlightFailure branch*/
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n   and 0<=j and j<=m   and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n   and 0<=j and j<=m   and safe>=-1 and safe<=1}           safe := -1
 else
{0<=n and n<=50 and 0<=m and m<=50 and m<=n and 0<=i and i<=n   and 0<=j and j<=m   and safe>=-1 and safe<=1}           skip
 fi

  od
fi
fi;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
void speedpldi3(int m, int n){
  int i, j;
  if(m <= 0) return;
  if(n <= m) return;
  i=0;
  j=0;
  while(i<n)
    if(j<m) ++j;
    else {
      j = 0;
      ++i;
    }
}
*/