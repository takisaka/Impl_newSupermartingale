/* successful code */

{true} N := ndet(Real[1,100]);
{1 <= N and N <= 100} i := N;
{1 <= N and N <= 100 and 1 <= i and i <= 100} j := N;

{1 <= N and N <= 100 and 1 <= i and i <= 100 and 1 <= j and j <= 100} safe := 1;

{1 <= N and N <= 100 and 0 <= i and i <= 100 and 0 <= j and j <= 100 and safe>=-1 and safe<=1} while (i >= 1) do
{1 <= N and N <= 100 and 1 <= i and i <= 100 and 0 <= j and j <= 100 and safe>=-1 and safe<=1}  j := N;
{1 <= N and N <= 100 and 1 <= i and i <= 100 and 0 <= j and j <= 100 and safe>=-1 and safe<=1}  while (j >= 1) do
{1 <= N and N <= 100 and 1 <= i and i <= 100 and 1 <= j and j <= 100 and safe>=-1 and safe<=1}    j := j-1

/*SlightFailure branch 1*/
/*
{1 <= N and N <= 100 and 1 <= i and i <= 100 and 0 <= j and j <= 99 and safe>=-1 and safe<=1 }     if prob(0.0001) then 
{1 <= N and N <= 100 and 1 <= i and i <= 100 and 0 <= j and j <= 99 and safe>=-1 and safe<=1 }       safe := -1
                                                           else
{1 <= N and N <= 100 and 1 <= i and i <= 100 and 0 <= j and j <= 99 and safe>=-1 and safe<=1 }       skip 
                                                           fi
*/
  od;
{1 <= N and N <= 100 and 1 <= i and i <= 100 and 0 <= j and j <= 1 and safe>=-1 and safe<=1}  i := i-1;

/*SlightFailure branch 2*/
{1 <= N and N <= 100 and 0 <= i and i <= 99  and 0 <= j and j <= 1 and safe>=-1 and safe<=1}     if prob(0.0001) then 
{1 <= N and N <= 100 and 0 <= i and i <= 99  and 0 <= j and j <= 1 and safe>=-1 and safe<=1}       safe := -1
                                                           else
{1 <= N and N <= 100 and 0 <= i and i <= 99  and 0 <= j and j <= 1 and safe>=-1 and safe<=1}       skip 
                                                           fi

od;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
int while2(){

  int i,j,N;
  i=N;
  while(i>0) {
    j=N;
    while(j>0)j--;
    i--;
  }
  return 0;
}
*/