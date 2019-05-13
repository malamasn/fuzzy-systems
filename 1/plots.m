HVc = tf(18.69*1.33*[1 8], [1 12.064+18.69*1.3 18.69*1.3*8])
HTc = tf(-2.92*[1 440 0], [1 12.064+18.69*1.3 18.69*1.3*8])
step(150*HVc)
t = 0 : 0.01 :30;

figure(2);
bode(HVc);
figure(3);
bode(HTc);

uV = 150*stepfun(t,0);
%uT1 = 150*stepfun(t,0);
%uT2 = -50 * stepfun(t,10);
%uT3 = 50*stepfun(t,20);
%uT = uT1 + uT2 + uT3;
uT = 0*stepfun(t,0);
yV = lsim(HVc, uV, t);
yT = lsim(HTc, uT, t);
y = yV +yT;
figure(4);
plot(t, y, t, 20*uT);