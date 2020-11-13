/* successfull code */

{true} n := ndet(Real[0,100]);
{0<=n and n<=100} i := n-1;

{0<=n and n<=100 and -1<=i and i<=99 } safe := 1;

{0<=n and n<=100 and -1<=i and i<=99  and safe>=-1 and safe<=1  } while (i - 1 >= 1) do
{0<=n and n<=100 and  2<=i and i<=99  and safe>=-1 and safe<=1  } i := i-1;

/*SlightFailure branch*/
{0<=n and n<=100 and  1<=i and i<=98  and safe>=-1 and safe<=1  }   if prob(0.0001) then 
{0<=n and n<=100 and  1<=i and i<=98  and safe>=-1 and safe<=1  }    safe := -1
                                                                else
{0<=n and n<=100 and  1<=i and i<=98  and safe>=-1 and safe<=1  }     skip 
                                                                fi
od;
{safe>=-1 and safe<=1} refute (safe <= 0)


/* original code below */
/*
int ndecr ()
{
  int n;

  int i=n-1;

  while(i>1) {i--;}


  return 0;

}
*/