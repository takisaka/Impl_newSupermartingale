{ true }
x0 := 6;
{ x0 = 6 }
x1 := ndet Real[17,22];
{ x0 = 6 and 17 <= x1 and x1 <= 22 }
x2 := ndet Real[16,23];
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 23 }
t := 0;
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 23 and 0 <= t and t <= 101 }
while t <= 100 do
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 23 and 0 <= t and t <= 100 }
controller1 := 19.5 - x1;
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 23 and -2.5 <= controller1 
and controller1 <= 2.5 and 0 <= t and t <= 100 }
controller2 := 19.5 - x2;
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 23 and -2.5 <= controller1 
and controller1 <= 2.5 and -3.5 <= controller2 
and controller2 <= 3.5 and 0 <= t and t <= 100 }
noise1 := Unif(-0.1,0.1);
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 23 and -2.5 <= controller1 
and controller1 <= 2.5 and -3.5 <= controller2 
and controller2 <= 3.5 and -0.1 <= noise1 
and noise1 <= 0.1 and 0 <= t and t <= 100 }
noise2 := Unif(-0.1,0.1);
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 23 and -2.5 <= controller1 and 
controller1 <= 2.5 and -3.5 <= controller2 and 
controller2 <= 3.5 and -0.1 <= noise1 and 
noise1 <= 0.1 and -0.1 <= noise2 and noise2 <= 0.1 
and 0 <= t and t <= 100 }
x1 := x1 + 0.0375 * x0 - 0.0375 * x1 + 0.0625 * x2 
- 0.0625 * x1 + 0.5 * controller1 + noise1;
{ x0 = 6 and 15 <= x1 and x1 <= 24 and 16 <= x2 
and x2 <= 23 and -3.5 <= controller2 and 
controller2 <= 3.5 and -0.1 <= noise2 and 
noise2 <= 0.1 and 0 <= t and t <= 100 }
x2 := x2 + 0.025 * x0 - 0.025 * x2 + 0.0625 * x1 
- 0.0625 * x2 + 0.5 * controller2 + noise2; 
{ x0 = 6 and 14 <= x1 and x1 <= 25 and 13 <= x2 
and x2 <= 26 and 0 <= t and t <= 100 }
t := t + 1;
{ x0 = 6 and 14 <= x1 and x1 <= 25 and 13 <= x2 
and x2 <= 26 and 0 <= t and t <= 101 } [x1 < 17]
skip;
{ x0 = 6 and 17 <= x1 and x1 <= 25 and 13 <= x2 
and x2 <= 26 and 0 <= t and t <= 101 } [x1 > 22]
skip;
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 13 <= x2 
and x2 <= 26 and 0 <= t and t <= 101 } [x2 < 16]
skip;
{ x0 = 6 and 17 <= x1 and x1 <= 22 and 16 <= x2 
and x2 <= 26 and 0 <= t and t <= 101 } [x2 > 23]
skip
od		