/* successfull code */

{true} i := ndet(Real[1,100]);
{1<=i and i<=100 } j := ndet(Real[1,100]);
{1<=i and i<=100 and 1<=j and j<=100 } k := ndet(Real[1,100]);
{1<=i and i<=100 and 1<=j and j<=100  and 1<=k and k<=100 } tmp := ndet(Real[1,100]);

{1<=i and i<=100 and 1<=j and j<=100  and 1<=k and k<=100  and 1<=tmp and tmp<=100 } safe := 1;

{1<=i and 1<=j and 0<=k and 1<=tmp and safe>=-1 and safe<=1}while i<=100 and j<=k do
{1<=i and 1<=j and 1<=k and 1<=tmp and safe>=-1 and safe<=1}  tmp := i;
{1<=i and 1<=j and 1<=k and 1<=tmp and safe>=-1 and safe<=1}  i := j;
{1<=i and 1<=j and 1<=k and 1<=tmp and safe>=-1 and safe<=1}  j := tmp + 1;
{1<=i and 1<=j and 1<=k and 1<=tmp and safe>=-1 and safe<=1}  k := k - 1;

/*SlightFailure branch*/
{1<=i and 1<=j and 0<=k and 1<=tmp and safe>=-1 and safe<=1}   if prob(0.0001) then 
{1<=i and 1<=j and 0<=k and 1<=tmp and safe>=-1 and safe<=1}     safe := -1
                                                                else
{1<=i and 1<=j and 0<=k and 1<=tmp and safe>=-1 and safe<=1}     skip 
                                                                fi
                                   od;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*exmini*/

/*
int exmini()
{
  int i,j,k,tmp;

  while(i<=100 && j<=k){
    tmp = i;
    i=j;
    j=tmp+1;
    k=k-1;
  }


  return 0;

*/
