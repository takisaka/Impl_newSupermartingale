{ true }                             
x := 3;
{ x = 3 }                            
y := 2;
{ x = 3 and y = 2 }                  
t := 0;
{ x >= y and 0 <= t and t <= 101 }   
while t <= 100 do
{ x >= y and 0 <= t and t <= 100 }       
if * then
{ x >= y and 0 <= t and t <= 100 }         
if prob(0.7) then
{ x >= y and 0 <= t and t <= 100 }           
z := Unif (-1,2);
{ x >= y and 0 <= t and t <= 100 and 
-1 <= z and z <= 2 }            
x := x + z
else
{ x >= y and 0 <= t and t <= 100 }           
z := Unif (-1,2);
{ x >= y and 0 <= t and t <= 100 and 
-1 <= z and z <= 2 }            
y := y + z
fi
else
{ x >= y and 0 <= t and t <= 100 }         
if prob(0.7) then
{ x >= y and 0 <= t and t <= 100 }           
z := Unif (-2,1);
{ x >= y and 0 <= t and t <= 100 and 
-2 <= z and z <= 1 }          
y := y + z
else
{ x >= y and 0 <= t and t <= 100 }           
z := Unif (-2,1);
{ x >= y and 0 <= t and t <= 100 and 
-2 <= z and z <= 1 }
x := x + z
fi
fi;
{ x >= y - 2 and 0 <= t and t <= 100 }   
t := t + 1;
{ x >= y - 2 and 1 <= t and t <= 101 } 
[x <= y]
skip
od