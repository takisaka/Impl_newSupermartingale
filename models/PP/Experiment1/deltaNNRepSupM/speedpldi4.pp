/* successful code */

{true} n := ndet(Real[1,100]);
{1<=n and n<=100}    m := ndet(Real[1,100]);

{1<=n and n<=100 and 1<=m and m<=100} safe := 1;


{1<=n and n<=100 and 1<=m and m<=100 and safe>=-1 and safe<=1} if(m <= 0) then
{1<=n and n<=100 and 1<=m and m<=100 and safe>=-1 and safe<=1}   skip
                                                               else
{1<=n and n<=100 and 1<=m and m<=100 and safe>=-1 and safe<=1}   if (n <= m) then
{1<=n and n<=100 and 1<=m and m<=100 and safe>=-1 and safe<=1}     skip
                                                                 else

/* main loop */
{1<=n and n<=100 and 1<=m and m<=100 and safe>=-1 and safe<=1}     i := n;
{1<=n and n<=100 and 1<=m and m<=100 and -1<=i and i<=100 and safe>=-1 and safe<=1}     while (i >= 1) do
{1<=n and n<=100 and 1<=m and m<=100 and 1<=i  and i<=100 and safe>=-1 and safe<=1}       if (i <= m-1) then
{1<=n and n<=100 and 1<=m and m<=100 and 1<=i  and i<=99  and safe>=-1 and safe<=1}         i := i-1
                                                                                         else
{1<=n and n<=100 and 1<=m and m<=100 and 1<=i  and i<=100 and safe>=-1 and safe<=1}         i := i-m
                                                                                         fi;

/*SlightFailure branch*/
{1<=n and n<=100 and 1<=m and m<=100 and -1<=i and i<=99  and safe>=-1 and safe<=1}       if prob(0.0001) then 
{1<=n and n<=100 and 1<=m and m<=100 and -1<=i and i<=99  and safe>=-1 and safe<=1}         safe := -1
                                                                                         else
{1<=n and n<=100 and 1<=m and m<=100 and -1<=i and i<=99  and safe>=-1 and safe<=1}         skip 
                                                                                         fi
                                                                                       od

                                        fi
                                      fi;

{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*
void speedpldi4(int m, int n){
  int i;

  if(m <= 0) return;
  if(n <= m) return;
  i=n;
  while(i>0)
    if(i<m)
      --i;
    else
      i -= m;
}
*/