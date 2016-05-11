function [f_O1_x,f_O1_y,f_O2_x,f_O2_y,f_O3_x,f_O3_y] = eeOpponentDer(in, sigma)

R=double(in(:,:,1));
G=double(in(:,:,2));
B=double(in(:,:,3));

Rx=gDer(R,sigma,1,0);
Ry=gDer(R,sigma,0,1);

Gx=gDer(G,sigma,1,0);
Gy=gDer(G,sigma,0,1);

Bx=gDer(B,sigma,1,0);
By=gDer(B,sigma,0,1);

f_O1_x=(Rx-Gx)/sqrt(2);
f_O1_y=(Ry-Gy)/sqrt(2);
f_O2_x=(Rx+Gx-2*Bx)/sqrt(6);
f_O2_y=(Ry+Gy-2*By)/sqrt(6);
f_O3_x=(Rx+Gx+Bx)/sqrt(3);
f_O3_y=(Ry+Gy+By)/sqrt(3);