/* successfull code */

{true} n := ndet(Real[1,100]);
{1<=n and n<=100}    m := ndet(Real[1,100]);
{1<=n and n<=100 and 1<=m and m<=100} safe := 1;

{1<=n and n<=100 and 1<=m and m<=100 and safe>=-1 and safe<=1} if (n>=0 and m >= 0) then
{1<=n and n<=100 and 1<=m and m<=100 and safe>=-1 and safe<=1}  v1 := n;
{1<=n and n<=100 and 1<=m and m<=100 and 1<=v1 and v1<=100 and safe>=-1 and safe<=1}  v2 := 0;

{1<=n and n<=100 and 1<=m and m<=100 and 0<=v1 and v1<=100 and 0<=v2 and v2<=100 and safe>=-1 and safe<=1}   while (v1 >= 1) do
{1<=n and n<=100 and 1<=m and m<=100 and 1<=v1 and v1<=100 and 0<=v2 and v2<=100 and safe>=-1 and safe<=1}     if (v2 <= m-1) then
{1<=n and n<=100 and 1<=m and m<=100 and 1<=v1 and v1<=100 and 0<=v2 and v2<=99  and safe>=-1 and safe<=1}       v2 := v2+1;
{1<=n and n<=100 and 1<=m and m<=100 and 1<=v1 and v1<=100 and 1<=v2 and v2<=100 and safe>=-1 and safe<=1}       v1 := v1-1
                                                                                                               else
{1<=n and n<=100 and 1<=m and m<=100 and 1<=v1 and v1<=100 and 1<=v2 and v2<=100 and safe>=-1 and safe<=1}       v2 := 0
                                                                                                               fi;

/*SlightFailure branch*/
{1<=n and n<=100 and 1<=m and m<=100 and 0<=v1 and v1<=100 and 0<=v2 and v2<=100 and safe>=-1 and safe<=1}     if prob(0.0001) then 
{1<=n and n<=100 and 1<=m and m<=100 and 0<=v1 and v1<=100 and 0<=v2 and v2<=100 and safe>=-1 and safe<=1}       safe := -1
                                                                                                               else
{1<=n and n<=100 and 1<=m and m<=100 and 0<=v1 and v1<=100 and 0<=v2 and v2<=100 and safe>=-1 and safe<=1}       skip 
                                                                                                               fi
                                                                                                             od
else
{safe>=-1 and safe<=1}  skip
fi;

{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*
void speedpldi2(int n, int m){
  int v1, v2;
  if(n>=0 && m>0){

  V1N:  v1 = n;
  V2Z:  v2 = 0;
  WH:  while(v1 > 0)
    I:  if(v2<m){
      P:  ++v2;
      M:  --v1;
    } else 
      ZZ: v2 = 0;
  }
}
*/
