/** 
  * This code is successful! with gamma = 0.999999, glpk computes a lower bound of 
  * reachability probability as 0.991... .
  */

{true} x := ndet(Real[-50,50]);
{-50<=x and x<=50} z := ndet(Real[-1,1]);


{-50<=x and x<=50 and -1 <= z and z <= 1} safe := 1;

{-1 <= safe and safe <= 1 and -50<=x  and x <= 50 and -1 <= z and z <= 1} while x + 1 <= 40 do
{-1 <= safe and safe <= 1 and -50<=x  and x <= 39 and -1 <= z and z <= 1}   if z <= 0 then
{-1 <= safe and safe <= 1 and -50<=x  and x <= 39 and -1 <= z and z <= 1}     x := x + 1
                       else
{-1 <= safe and safe <= 1 and -50<=x  and x <= 39 and -1 <= z and z <= 1}     x := x + 2
                                                      fi;
{-1 <= safe and safe <= 1 and -50<=x  and x <= 41 and -1 <= z and z <= 1}   if prob(0.0001) then 
{-1 <= safe and safe <= 1 and -50<=x  and x <= 41 and -1 <= z and z <= 1}     safe := -1
                                                      else
{-1 <= safe and safe <= 1 and -50<=x  and x <= 41 and -1 <= z and z <= 1}     skip
                                                      fi
                                                    od;

/* Known Issue: the solver returns a trivial bound if we let "refute (safe = 1)" here instead. */
{-1 <= safe and safe <= 1} refute (safe <= 0)



/* original code below */

/*
int easy1() {
  int x, y;
  int z;
  x=0;
  y=100;
  while (x<40) {
    if (z==0) { x=x+1; } else { x=x+2; }
  }
}
*/
