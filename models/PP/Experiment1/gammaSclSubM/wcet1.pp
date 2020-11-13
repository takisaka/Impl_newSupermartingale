/* successful code */

{true} n := ndet(Real[1,100]);
{1<=n and n<=100} j := 0;
{1<=n and n<=100 and j = 0} i := n;

{1<=n and n<=100 and 1<=i and i<=100 and j = 0} safe := 1;

{1<=n and n<=100 and 1<=i and i<=100 and j = 0 and safe>=-1 and safe<=1} if (n >= 1) then
{1<=n and n<=100 and -1<=i and i<=100 and 0<=j  and j<=100 and safe>=-1 and safe<=1}  while (i >= 0) do  /* mimicking do while i>0*/
{1<=n and n<=100 and  0<=i and i<=100 and 0<=j  and j<=100 and safe>=-1 and safe<=1}    if prob (0.5) then
{1<=n and n<=100 and  0<=i and i<=100 and 0<=j  and j<=100 and safe>=-1 and safe<=1}      j := j+1;
{1<=n and n<=100 and  0<=i and i<=100 and 1<=j  and j<=101 and safe>=-1 and safe<=1}      if (j >= n) then
{1<=n and n<=100 and  0<=i and i<=100 and 1<=j  and j<=101 and safe>=-1 and safe<=1}        j := 0
                                                                                          else
{1<=n and n<=100 and  0<=i and i<=100 and 1<=j  and j<=100 and safe>=-1 and safe<=1}        skip
                                                                                          fi
                                                                                        else
{1<=n and n<=100 and  0<=i and i<=100 and 0<=j  and j<=100 and safe>=-1 and safe<=1}      j := j-1;
{1<=n and n<=100 and  0<=i and i<=100 and -1<=j and j<=99  and safe>=-1 and safe<=1}      if (j <= 0) then
{1<=n and n<=100 and  0<=i and i<=100 and -1<=j and j<=0   and safe>=-1 and safe<=1}        j := 0
                                                                                          else
{1<=n and n<=100 and  0<=i and i<=100 and 0<=j  and j<=99  and safe>=-1 and safe<=1}        skip
                                                                                          fi
                                                                                        fi;
{1<=n and n<=100 and  0<=i and i<=100 and 0<=j  and j<=100 and safe>=-1 and safe<=1}    i := i-1;


/*SlightFailure branch*/
{1<=n and n<=100 and -1<=i and i<=99 and 0<=j and j<=100 and safe>=-1 and safe<=1}     if prob(0.0001) then 
{1<=n and n<=100 and -1<=i and i<=99 and 0<=j and j<=100 and safe>=-1 and safe<=1}       safe := -1
                                                                                      else
{1<=n and n<=100 and -1<=i and i<=99 and 0<=j and j<=100 and safe>=-1 and safe<=1}       skip 
                                                                                      fi
                                                                                    od
else
{safe>=-1 and safe<=1}  skip
fi;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
int wcet1 () {
  int i,j,n;

  j=0;
  i=n;
  if (n>=1) 
    do {
      if (random()){
	  j++;
	  if(j>=n) j=0;
	}
      else {
	j--;
	if(j<=0) j=0;
      }
      
      i--;
    }
    while(i>0);

  return 0;
}
*/