function OBB = calOBB2(delta, phi, Pp, Pmud, v, S_g, amatte, Gtc, Gec)

Gpol = phi;
Gazi = pi/2 - delta;
Gszi = S_g(3,3);
Gsxi = S_g(2,2);
Gsyi = S_g(1,1);
Gtyzi = S_g(2,3);
Gtxzi = S_g(1,3);
Gtxyi = S_g(1,2);

S_gg = [Gsxi; Gsyi; Gszi; Gtyzi; Gtxzi; Gtxyi];

L1=cos(Gpol)*cos(Gazi);  
L2=-sin(Gazi);
L3=sin(Gpol)*cos(Gazi);
M1=cos(Gpol)*sin(Gazi);
M2=cos(Gazi);
M3=sin(Gazi)*sin(Gpol);
N1=-sin(Gpol);
N2=0;
N3=cos(Gpol);

Tsig=[L1^2 M1^2 N1^2 2*M1*N1 2*N1*L1 2*L1*M1; 
    L2^2 M2^2 N2^2 2*M2*N2 2*N2*L2 2*L2*M2; 
    L3^2 M3^2 N3^2 2*M3*N3 2*N3*L3 2*L3*M3; 
    L2*L3 M2*M3 N2*N3 M2*N3+M3*N2 N2*L3+N3*L2 L2*M3+L3*M2; 
    L3*L1 M3*M1 N3*N1 M1*N3+M3*N1 N1*L3+N3*L1 L1*M3+L3*M1; 
    L1*L2 M1*M2 N1*N2 M1*N2+M2*N1 N1*L2+N2*L1 L1*M2+L2*M1];

Tsig_for_stress=[L1^2 M1^2 N1^2 2*M1*N1 2*N1*L1 2*L1*M1; %주응력 방향이 x,y축 방향이 아닐 때도 고려하기 위해 새로 정의
    L2^2 M2^2 N2^2 2*M2*N2 2*N2*L2 2*L2*M2; 
    L3^2 M3^2 N3^2 2*M3*N3 2*N3*L3 2*L3*M3; 
    L2*L3 M2*M3 N2*N3 M2*N3+M3*N2 N2*L3+N3*L2 L2*M3+L3*M2; 
    -(L3*L1) -(M3*M1) -(N3*N1) -(M1*N3+M3*N1) -(N1*L3+N3*L1) -(L1*M3+L3*M1); 
    -(L1*L2) -(M1*M2) -(N1*N2) -(M1*N2+M2*N1) -(N1*L2+N2*L1) -(L1*M2+L2*M1)];


stressdevmat=[(sin(-Gpol))^2 (cos(-Gpol)*cos(-Gazi))^2 (cos(-Gpol)*sin(-Gazi))^2; % 원래 toolbox
        0 (sin(-Gazi))^2 (cos(-Gazi))^2;
        (cos(-Gpol))^2 (sin(-Gpol)*cos(-Gazi))^2 (sin(-Gpol)*sin(-Gazi))^2;
        0 -(sin(-Gazi))*(cos(-Gazi))*(sin(-Gpol)) (sin(-Gazi))*(cos(-Gazi))*(sin(-Gpol));
        -(sin(-Gpol))*(cos(-Gpol)) (sin(-Gpol))*(cos(-Gpol))*(cos(-Gazi))^2 (sin(-Gpol))*(cos(-Gpol))*(sin(-Gazi))^2;
        0 -(sin(-Gazi))*(cos(-Gazi))*(cos(-Gpol)) (sin(-Gazi))*(cos(-Gazi))*(cos(-Gpol))];
    
%%

devst_sig = Tsig_for_stress*S_gg; 
Gsx=devst_sig(1);
Gsy=devst_sig(2);
Gsz=devst_sig(3);
Gtyz=devst_sig(4);
Gtxz=devst_sig(5);
Gtxy=devst_sig(6);

S_bbb = [Gsx, Gtxy, Gtxz; Gtxy, Gsy, Gtyz; Gtxz, Gtyz, Gsz];
sig = S_bbb; 

amat=transpose(Tsig)*amatte*Tsig;

%%
%% thermal expansion
ep=zeros(1,6);
eptemp=zeros(6,6);
r = 1;
theta = 0 : 0.01*pi : 2*pi;

for countr=1:length(r)
for countth=1:length(theta)
    L11=cos(theta(countth));  
    L22=-sin(theta(countth));
    L33=0;
    M11=sin(theta(countth));
    M22=cos(theta(countth));
    M33=0;
    N11=0;
    N22=0;
    N33=1;

    eptrans=[L11^2 M11^2 N11^2 2*M11*N11 2*N11*L11 2*L11*M11; 
        L22^2 M22^2 N22^2 2*M22*N22 2*N22*L22 2*L22*M22; 
        L33^2 M33^2 N33^2 2*M33*N33 2*N33*L33 2*L33*M33; 
        L22*L33 M22*M33 N22*N33 M22*N33+M33*N22 N22*L33+N33*L22 L22*M33+L33*M22; 
        L33*L11 M33*M11 N33*N11 M11*N33+M33*N11 N11*L33+N33*L11 L11*M33+L33*M11; 
        L11*L22 M11*M22 N11*N22 M11*N22+M22*N11 N11*L22+N22*L11 L11*M22+L22*M11];

    epthertemp=transpose(eptrans)*amat*eptrans;
    epther=epthertemp(2:3,2:3);
    stthertemp=mldivide(epther,[Gtc*Gec;Gtc*Gec]);
    thermalst(countr,countth)=stthertemp(1);
    stther=mldivide(eptrans,[0;stthertemp(1);stthertemp(2);0;0;0]);
    stther=stther*10^-6;
    
    temp=[cos(theta(countth)) sin(theta(countth)) 0; 
    -sin(theta(countth)) cos(theta(countth)) 0; 
    0 0 1]*[stther(1) stther(6) stther(5);
    stther(6) stther(2) stther(4);
    stther(5) stther(4) stther(3)]*[cos(theta(countth)) -sin(theta(countth)) 0; 
    sin(theta(countth)) cos(theta(countth)) 0; 
    0 0 1];

    
    %calculate normal snd shear stresses
    sig_zz(countth) = sig(3,3)-2*v*(sig(1,1)-sig(2,2))*cos(2.*theta(countth))-4*v*sig(1,2)*sin(2.*theta(countth));
    sig_zz(countth) = sig_zz(countth)+temp(3,3);
    
    sig_ththe(countth) = sig(1,1)+sig(2,2)-2*(sig(1,1)-sig(2,2))*cos(2.*theta(countth)) -4*sig(1,2)*sin(2.*theta(countth))-(Pmud-Pp);
    sig_ththe(countth) = sig_ththe(countth)+temp(2,2);
    
    tao_thez(countth) = 2*(sig(2,3).*cos(theta(countth))-sig(1,3).*sin(theta(countth)));
    tao_thez(countth) = tao_thez(countth)+temp(2,3);
    
    sig_rr(countth) = Pmud-Pp;
    sig_rr(countth) = sig_rr(countth)+temp(1,1);
    
end
 

%% principal stresses
sig_tmax = 0.5.*(sig_zz+sig_ththe+((sig_zz-sig_ththe).^2+4*tao_thez.^2).^0.5);
sig_tmin = 0.5.*(sig_zz+sig_ththe-((sig_zz-sig_ththe).^2+4*tao_thez.^2).^0.5);
    
OBB = find(round(sig_tmax,5)==round(max(sig_tmax),5),1)*0.01*pi;
end





