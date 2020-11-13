

{true} n := ndet(Real[0,30]);
{0<=n and n<=30} m := ndet(Real[0,30]);
{0<=n and n<=30 and 0<=m and m<=30} N := ndet(Real[0,30]);

{0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30} safe := 1;

{0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1} if 0<=n and 0<=m and 0<=N then
{0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}  i := 0;
{0<=i and i<=n+N+1 and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}  while i + 1 <= n do
{0<=i and i<=n-1   and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}    j := 0;
{0<=i and i<=n+N   and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}    while j + 1 <= m do
{0<=i and i<=n+N   and 0<=j and j<=m-1 and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}      j := j + 1;
{0<=i and i<=n+N   and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}      k := i;
{0<=i and i<=n+N   and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}      while k + 1 <= N do
{0<=i and i<=n+N   and 0<=j and j<=m   and 0<=k and k<=N-1 and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}        k := k+1
      od;
{0<=i and i<=n+N   and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}      i := k
    od;
{0<=i and i<=n+N   and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}    i := i + 1;

/*SlightFailure branch*/
{1<=i and i<=n+N+1 and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{1<=i and i<=n+N+1 and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}           safe := -1
  else
{1<=i and i<=n+N+1 and 0<=j and j<=m   and 0<=k and k<=n+N and 0<=n and n<=30 and 0<=m and m<=30 and 0<=N and N<=30 and safe>=-1 and safe<=1}           skip
  fi

  od

else
{safe>=-1 and safe<=1}  skip
fi;

{safe>=-1 and safe<=1} refute (safe <= 0)



/* original code below */
/*
void nestedLoop(int n, int m, int N){
  int i, j, k;
  if(0<=n && 0<=m && 0<=N){
    i = 0;
    while(i<n){
      j = 0;
      while(j<m){
        j += 1;
        k = i;
        while(k<N)
          k += 1;
        i = k;
      }
      ++i;
    }
  }
}
*/