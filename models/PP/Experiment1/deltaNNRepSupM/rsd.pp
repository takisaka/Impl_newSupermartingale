{true} r := ndet(Real[0,50]);

{0<=r and r<=50} safe := 1;

{0<=r and r<=50 and safe>=-1 and safe<=1} if r >= 0 then
{0<=r and r<=50 and safe>=-1 and safe<=1}  da := 2 * r;
{0<=r and r<=50 and da=2*r and safe>=-1 and safe<=1}  db := 2 * r;
{0<=r and r<=50 and r-1<=da and da<=2*r   and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}  while da >= r do
{0<=r and r<=50 and r  <=da and da<=2*r   and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}    if prob(0.5) then
{0<=r and r<=50 and r  <=da and da<=2*r   and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}      da := da - 1
    else
{0<=r and r<=50 and r  <=da and da<=2*r   and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}      temp := da;
{0<=r and r<=50 and r  <=da and da<=2*r   and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}      da := db - 1;
{0<=r and r<=50 and r-1<=da and da<=2*r-1 and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}      db := temp
    fi;
{0<=r and r<=50 and r-1<=da and da<=2*r-1 and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}    c1 := c1 + 1;

/*SlightFailure branch*/
{0<=r and r<=50 and r-1<=da and da<=2*r-1 and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}         if prob(0.0001) then 
{0<=r and r<=50 and r-1<=da and da<=2*r-1 and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}           safe := -1
 else
{0<=r and r<=50 and r-1<=da and da<=2*r-1 and r<=db and db <=2*r and r<=temp and temp <=2*r and 0<=c1 and safe>=-1 and safe<=1}           skip
 fi
  od  
else
{safe>=-1 and safe<=1}   skip
fi;

{safe>=-1 and safe<=1} refute (safe <= 0)



/* original code below */
/*
int random();

int rsd ()
{
  int r;
  int da,db,temp;
  int c1;
  c1=0;
  if (r>=0){
    da = 2*r;
    db = 2*r;
    while (da >=r) {
      if (random()){
	da --;
      }
      else{
	temp = da;
	da = db - 1;
	db = temp;
      }
      c1++;
    }
  }

  return 0;

  
}
*/