/**/

{ true }                                        
x := 2;
{ x = 2 }                                       
y := 2;
{ x = 2 and y = 2 }                             
t := 0;
{ 0 <= x and 0 <= y and 0 <= t and t <= 101 }   
while t <= 100 do
{ 0 <= x and 0 <= y and 0 <= t and t <= 100 }   
if * then
{ 0 <= x and 0 <= y and 0 <= t and t <= 100 }   
z := Unif (-1,2);
{ 0 <= x and 0 <= y and -1 <= z and 
z <= 2 and 0 <= t and t <= 100 }          
x := x + z
else
{ 0 <= x and 0 <= y and 0 <= t and t <= 100 }       
z := Unif (-1,2);
{ 0 <= x and 0 <= y and -1 <= z and 
z <= 2 and 0 <= t and t <= 100 }              
y := y + z
fi;
{ -1 <= x and -1 <= y and 0 <= t and t <= 100 }   
t := t + 1;
{ -1 <= x and -1 <= y and 1 <= t and t <= 101 } 
[x <= 0]
skip;
{ 0 <= x and -1 <= y and 1 <= t and t <= 101 } 
[y <= 0]
skip
od