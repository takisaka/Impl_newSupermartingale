/*successfull code (lesson: set an invariant at the final state!!)*/

{true} x := ndet(Real[1,10]);
{1<=x and x<=10} y := ndet(Real[1,10]);
{1<=x and x<=10 and 1<=y and y<=10} n := ndet(Real[1,10]);
{1<=x and x<=10 and 1<=y and y<=10 and 1<=n and n<=10} b := ndet(Real[0,1]);

{1<=x and x<=10 and 1<=y and y<=10 and 1<=n and n<=10 and 0<=b and b<=1} safe := 1;
                             
{x >= -1 and x <= 10 and -1<=y and y<=11 and 1<=n and n<=10 and 0<=b and b<=1 and safe>=-1 and safe<=1  } while (x>=0 and 0<=y and y<=n) do
{x >= 0  and x <= 10 and  0<=y and y<=10 and 1<=n and n<=10 and 0<=b and b<=1 and safe>=-1 and safe<=1  }   if (b <= 0.5) then
{x >= 0  and x <= 10 and  0<=y and y<=10 and 1<=n and n<=10 and 0<=b and b<=0.5 and safe>=-1 and safe<=1}     y := y+1;
{x >= 0  and x <= 10 and  1<=y and y<=11 and 1<=n and n<=10 and 0<=b and b<=0.5 and safe>=-1 and safe<=1}     if prob (0.5) then
{x >= 0  and x <= 10 and  1<=y and y<=11 and 1<=n and n<=10 and 0<=b and b<=0.5 and safe>=-1 and safe<=1}       b := 1
                                                                                                              else
{x >= 0  and x <= 10 and  1<=y and y<=11 and 1<=n and n<=10 and 0<=b and b<=0.5 and safe>=-1 and safe<=1}       skip
                                                                                                              fi
                                                                                                            else
{x >= 0  and x <= 10 and  0<=y and y<=10 and 1<=n and n<=10 and 0.5<=b and b<=1 and safe>=-1 and safe<=1}     y := y-1;
{x >= 0  and x <= 10 and -1<=y and y<=9  and 1<=n and n<=10 and 0.5<=b and b<=1 and safe>=-1 and safe<=1}     if prob (0.5) then
{x >= 0  and x <= 10 and -1<=y and y<=9  and 1<=n and n<=10 and 0.5<=b and b<=1 and safe>=-1 and safe<=1}       b := 0;
{x >= 0  and x <= 10 and -1<=y and y<=9  and 1<=n and n<=10 and b=0             and safe>=-1 and safe<=1}       x := x-1
                                                                                                              else
{x >= 0  and x <= 10 and -1<=y and y<=9  and 1<=n and n<=10 and 0.5<=b and b<=1 and safe>=-1 and safe<=1}       skip
                                                                                                              fi
                                                                                                            fi;

/*SlightFailure branch*/
{x >= -1 and x <= 10 and -1<=y and y<=11 and 1<=n and n<=10 and 0<=b and b<=1 and safe>=-1 and safe<=1  }   if prob(0.0001) then 
{x >= -1 and x <= 10 and -1<=y and y<=11 and 1<=n and n<=10 and 0<=b and b<=1 and safe>=-1 and safe<=1  }     safe := -1
                                                                                                    else
{x >= -1 and x <= 10 and -1<=y and y<=11 and 1<=n and n<=10 and 0<=b and b<=1 and safe>=-1 and safe<=1  }     skip
                                                                                                    fi

                                                                                                  od;

{safe>=-1 and safe<=1} refute (0 <= safe)


/* original code below */
/*
int counterex1c()
{
  int n;
  int b;
  int x,y;
  while (x>=0 && 0<=y && y<=n) {
    if (b==0) {
      y++;                      // transition t1 
      if (random()) b=1;        // transition t3 
    }
    else if (b==1) {
      y--;                      // transition t2 
      if (random()) {x--; b=0;} // transition t4 
    }
    else break;
  }
  return 0;
}
*/
