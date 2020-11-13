{true} i := ndet(Real[0,50]);
{0<=i and i<=50} j := ndet(Real[0,50]);
{0<=i and i<=50 and 0<=j and j<=50} N := ndet(Real[0,50]);

{0<=i and i<=50 and 0<=j and j<=50 and 0<=N and N<=50} safe := 1;

{0<=i and i<=50 and 0<=j and j<=50 and 0<=N and N<=50 and safe>=-1 and safe<=1} while i >= 1 do
{1<=i and i<=50 and 0<=j and j<=50 and 0<=N and N<=50 and safe>=-1 and safe<=1}   if j >= 1 then 
{1<=i and i<=50 and 1<=j and j<=50 and 0<=N and N<=50 and safe>=-1 and safe<=1}    j := j - 1
  else
{1<=i and i<=50 and 0<=j and j<=1  and 0<=N and N<=50 and safe>=-1 and safe<=1}	  j := N;
{1<=i and i<=50 and 0<=j and j<=50 and 0<=N and N<=50 and safe>=-1 and safe<=1}    i := i - 1
  fi;

/*SlightFailure branch*/
{0<=i and i<=50 and 0<=j and j<=50 and 0<=N and N<=50 and safe>=-1 and safe<=1}   if prob(0.0001) then 
{0<=i and i<=50 and 0<=j and j<=50 and 0<=N and N<=50 and safe>=-1 and safe<=1}     safe := -1
  else
{0<=i and i<=50 and 0<=j and j<=50 and 0<=N and N<=50 and safe>=-1 and safe<=1}     skip
  fi  
od;


{safe>=-1 and safe<=1} refute (0 <= safe)

/* original code below */
/*
int cousot9(){

  int i,j,N;

  i=N;
  while(i>0) {

    if(j>0) {j--;}
    else
      {
	j=N;i--;
      }

  }

  return 0;
}
*/