{true} a := ndet(Real[0,50]);
{0<=a and a<=50} b := ndet(Real[0,50]);

{0<=a and a<=50 and 0<=b and b<=50 } safe := 1;

{0 <= a and a <= 50 and -11 <= b and b <= 28 and safe>=-1 and safe<=1}  while a + 1 <= 30 do
{0 <= a and a <= 29 and -11 <= b and b <= 35 and safe>=-1 and safe<=1}      while b + 1 <= a do
{0 <= a and a <= 29 and -11 <= b and b <= 28 and safe>=-1 and safe<=1}	  	  if b + 1 >= 5 then
{0 <= a and a <= 29 and   4 <= b and b <= 28 and safe>=-1 and safe<=1}	        b := b + 7
	      else
{0 <= a and a <= 29 and -11 <= b and b <= 4  and safe>=-1 and safe<=1}	        b := b + 2
		  fi;
{0 <= a and a <= 29 and  -1 <= b and b <= 35 and safe>=-1 and safe<=1}	      if b >= 10 and b <= 12 then 
{0 <= a and a <= 29 and  10 <= b and b <= 12 and safe>=-1 and safe<=1}	        a := a + 10
	      else 
{0 <= a and a <= 29 and  -1 <= b and b <= 35 and safe>=-1 and safe<=1}	        a := a + 1
	      fi
	  od;
{0 <= a and a <= 39 and  -1 <= b and b <= 35 and safe>=-1 and safe<=1}      a := a + 2; 
{0 <= a and a <= 41 and  -1 <= b and b <= 35 and safe>=-1 and safe<=1}      b := b - 10;

/*SlightFailure branch*/
{0 <= a and a <= 41 and -11 <= b and b <= 25 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0 <= a and a <= 41 and -11 <= b and b <= 25 and safe>=-1 and safe<=1}           safe := -1
 else
{0 <= a and a <= 41 and -11 <= b and b <= 25 and safe>=-1 and safe<=1}           skip
 fi

  od;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
int complex(int a, int b)
{
  while(a < 30)
    {
      while(b < a)
	{ 
	  if(b > 5) 
	    b = b + 7; 
	  else
	    b = b + 2;
	  if(b >= 10 && b <= 12) 
	    a = a + 10;
	  else 
	    a = a + 1;
	}
      a = a + 2; 
      b = b - 10; 
    }
  return 1;
}
*/