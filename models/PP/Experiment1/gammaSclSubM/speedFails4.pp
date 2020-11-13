
{true} b := ndet(Real[-50,50]);
{-50<=b and b<=50} x := ndet(Real[-50,50]);
{-50<=b and b<=50 and -50<=x and x<=50} n := ndet(Real[-50,50]);

{-50<=b and b<=50 and -50<=x and x<=50 and -50<=n and n<=50} safe := 1;

{-50<=b and b<=50 and -50<=x and x<=50 and -50<=n and n<=50 and safe>=-1 and safe<=1} if b >= 1 then
{1  <=b and b<=50 and -50<=x and x<=50 and -50<=n and n<=50 and safe>=-1 and safe<=1}   t := 1
else
{-50<=b and b<=1  and -50<=x and x<=50 and -50<=n and n<=50 and safe>=-1 and safe<=1}   t := -1
fi;

{1  <=b and b<=50 and -50<=x and x<=51 and -50<=n and n<=50 and t=1  and safe>=-1 and safe<=1 or 
 -50<=b and b<=1  and -50<=x and x<=51 and -50<=n and n<=50 and t=-1 and safe>=-1 and safe<=1} while x <= n do  
{1  <=b and b<=50 and -50<=x and x<=n  and -50<=n and n<=50 and t=1  and safe>=-1 and safe<=1 or 
 -50<=b and b<=1  and -50<=x and x<=n  and -50<=n and n<=50 and t=-1 and safe>=-1 and safe<=1}  if b >= 1 then
{1  <=b and b<=50 and -50<=x and x<=n  and -50<=n and n<=50 and t=1  and safe>=-1 and safe<=1}	  x := x + t
  else 
{-50<=b and b<=1  and -50<=x and x<=n  and -50<=n and n<=50 and t=-1 and safe>=-1 and safe<=1}	  x := x - t
  fi;

/*SlightFailure branch*/
{1  <=b and b<=50 and -49<=x and x<=n+1  and -50<=n and n<=50 and t=1  and safe>=-1 and safe<=1 or 
 -50<=b and b<=1  and -49<=x and x<=n+1  and -50<=n and n<=50 and t=-1 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{1  <=b and b<=50 and -49<=x and x<=n+1  and -50<=n and n<=50 and t=1  and safe>=-1 and safe<=1 or 
 -50<=b and b<=1  and -49<=x and x<=n+1  and -50<=n and n<=50 and t=-1 and safe>=-1 and safe<=1}           safe := -1
 else
{1  <=b and b<=50 and -49<=x and x<=n+1  and -50<=n and n<=50 and t=1  and safe>=-1 and safe<=1 or 
 -50<=b and b<=1  and -49<=x and x<=n+1  and -50<=n and n<=50 and t=-1 and safe>=-1 and safe<=1}           skip
 fi


od;


{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
int speedFails4(){
  int i,x,n,t;
  int b;
  if(b>=1) t=1; else  t=-1;

  while(x<=n)
    {
      if(b>=1)
	{
	  x=x+t;
	}
      else 
	{
	  x=x-t;
	}
    }
  
  return 0;
}
*/
