function PcOnly(S123, Svmag, phi, rho_r, rho_f, alpha, PcCheck, norm2Sv)
% compute and plot stereonet group (advanced analysis #2, 4)

try
    
%% variable definition
S1 = S123(1, 1); % S1 magnitude
S2 = S123(2, 1); % S2 magnitude
S3 = S123(3, 1); % S3 magnitude
S1_d = S123(1, 2:4); % direction of S1
S2_d = S123(2, 2:4); % direction of S2
S3_d = S123(3, 2:4); % direction of S3

Pcm = Pcm_cal(S1, S3, phi); % minimum critical pressure for shearing
Pco = Pco_cal(Pcm, alpha, S3); % cut-off pressure for shearing

nor_sig3 = S3/Svmag;
nor_sig1 = S1/Svmag;
nor_Pco = Pco/Svmag;
nor_Pcm = Pcm/Svmag;

gr_sv=rho_r/100*0.980665;% vertical stress gradient
gr_f=rho_f/100*0.980665;% hydrostatic pressure gradient
%gr_f=roundn(gr_f,-2);

sigma = zeros(361,91); 
tau = zeros(361,91); 
kc = zeros(361,91);% normalized pc
pp_gr=zeros(361,91);% pressure gradient
x=zeros(361,91);% lower hemisphere projection
y=zeros(361,91);% lower hemisphere projection

no=91;
p = zeros(no); % pressure interval used to compute No. of poles assume 90 intervals
num_fra = zeros(no);%number of fracures within pressure interval
prob = zeros(no);%cumulative probability of shearing with respect to the increasing pressure

%% main computation
if PcCheck == 1
    dp = (nor_sig1 - nor_Pcm)/(no-1);
    for i=1:no
        p(i) = nor_Pcm + (i-1)*dp;
    end
end

counter1 = 0;
counter2 = 0;

for i=1:361
    did = (i-1)/180*pi; % dip direction
    tre = did + pi;% trend of joint normal pole
    for j=1:91
        di = (j-1)/180*pi; % dip
        plu = 0.5*pi-di; % plunge
        jNormal = [sin(di)*sin(did) sin(di)*cos(did) cos(di)];
        l = dot(jNormal, S1_d)/norm(jNormal); % direction cosine to S1
        m = dot(jNormal, S2_d)/norm(jNormal); % direction cosine to S2
        n = dot(jNormal, S3_d)/norm(jNormal); % direction cosine to S3
        sigma(i, j) = l^2*S1 + m^2*S2 + n^2*S3; % resolved normal stress
        tau(i, j) = sqrt(((S1-S2)*l*m)^2 + ((S2-S3)*m*n)^2 + ((S3-S1)*n*l)^2); % resolved shear stress
        kc(i, j) = (sigma(i,j) - tau(i, j)/tan(phi))/Svmag; % normalized critical pressure for shearing
        pp_gr(i, j) = kc(i, j)*gr_sv; % normalized gradient of critical pressure
        x(i, j) = sqrt(2)*cos(tre)*cos(0.5*(0.5*pi+plu)); % calculated as equal-area stereonet
        y(i, j) = sqrt(2)*sin(tre)*cos(0.5*(0.5*pi+plu));

        ST(i,j) = tau(i,j)/(sigma(i,j)-41.95*1000000); % slip tendency
        
        if j==1
            counter1 = counter1+1; % counter for dip = 0 deg.
        end
        if j==91
            counter2 = counter2+1; % counter for dip = 90 deg.
        end
        
        if PcCheck==1
            if (j==1&&counter1<2) || (j==91&&counter2<181) || (j>1&&j<91)
                k = 1;
                while 1
                    if k == no
                        break
                    end
                    if (kc(i, j)>=p(k) && kc(i, j)<p(k + 1)) || (k==no-1 && kc(i,j)==p(k+1))
                        num_fra(k) = num_fra(k) + 1; % number of joints sheared by p(k)
                    elseif kc(i, j) < p(k)
                        break
                    end
                    k = k + 1;
                end
            end
        end
        
     end
end

kc(361,:) = kc(1,:);
pp_gr(361,:) = pp_gr(1,:);
x(361,:) = x(1,:);
y(361,:) = y(1,:);

if PcCheck == 1
    prob(2) = num_fra(1);
    for i = 3:no
        prob(i) = prob(i-1) + num_fra(i-1);
    end
    prob = prob/(360*89+180+1);
end

%% plot
if PcCheck == 1
    if norm2Sv == 1
 
    else
        figure()
        set(gcf,'color','w')
        contourf(y, x, kc*Svmag/1000000, 80, 'LineStyle','none')
        hold on
        colormap(jet(256))
    
%         di = [61; 65; 67; 31.6]*pi/180; % dips of fault scenarios
%         did = [311; 306; 25; 70]*pi/180; % dip directions of ~~
        
        di = [61; 67]*pi/180; % dips of fault scenarios
        did = [311; 25]*pi/180; % dip directions of ~~
        
        tre = did + pi*[1; 1];
        plu = 0.5*pi*[1; 1]-di;
        X = sqrt(2)*cos(tre).*cos(0.5*(0.5*pi+plu));
        Y = sqrt(2)*sin(tre).*cos(0.5*(0.5*pi+plu));
        scatter(Y, X, 60, 'markeredgecolor', 'k', 'markerfacecolor', 'w', 'markerfacealpha', 0, 'linewidth', 1.5)
        
        colorbar
        h4=colorbar;
        set(h4, 'fontsize', 11)
        set(get(h4,'label'),'string','{Critical pressure for shearing (MPa)}', 'fontsize', 14)
        axis off;
        daspect([1 1 1])
        
        title('Critical pressure for shearing', 'FontWeight', 'Bold', 'fontsize', 14);
        
        
        figure()
        set(gcf,'color','w')
        contourf(y, x, sigma/1000000, 80, 'LineStyle','none')
        hold on
        colormap(jet(256))
        scatter(Y, X, 60, 'markeredgecolor', 'k', 'markerfacecolor', 'w', 'markerfacealpha', 0, 'linewidth', 1.5)     
        colorbar
        h5=colorbar;
        set(h5, 'fontsize', 11)
        set(get(h5,'label'),'string','{Resolved normal stress (MPa)}', 'fontsize', 14)
        axis off;
        daspect([1 1 1])
        
        title('Fracture normal stress', 'FontWeight', 'Bold', 'fontsize', 14);
        
        
        di = 61*pi/180; % dips of fault scenarios
        did = 311*pi/180; % dip directions of ~~
        
        tre = did + pi;
        plu = 0.5*pi-di;
        X = sqrt(2)*cos(tre)*cos(0.5*(0.5*pi+plu));
        Y = sqrt(2)*sin(tre)*cos(0.5*(0.5*pi+plu));
        
        figure()
        set(gcf,'color','w')
        contourf(y, x, ST, 80, 'LineStyle','none')
        hold on
        colormap(jet(256))
        scatter(Y, X, 60, 'markeredgecolor', 'k', 'markerfacecolor', 'w', 'markerfacealpha', 0, 'linewidth', 1.5)     
        colorbar
        h5=colorbar;
        set(h5, 'fontsize', 11)
        set(get(h5,'label'),'string','{(resolved shear/resolved eff.normal)}', 'fontsize', 16)
        axis off;
        daspect([1 1 1])
        title('slip tendency', 'FontWeight', 'Bold', 'fontsize', 20);
        
        max(max(ST))
        
        di = 61*pi/180;
        did = 311*pi/180;
        jNormal = [sin(di)*sin(did) sin(di)*cos(did) cos(di)];
        l = dot(jNormal, S1_d)/norm(jNormal); % direction cosine to S1
        m = dot(jNormal, S2_d)/norm(jNormal); % direction cosine to S2
        n = dot(jNormal, S3_d)/norm(jNormal); % direction cosine to S3
        sigma = l^2*S1 + m^2*S2 + n^2*S3; % resolved normal stress
        tau = sqrt(((S1-S2)*l*m)^2 + ((S2-S3)*m*n)^2 + ((S3-S1)*n*l)^2); % resolved shear stress
     
        ST = tau/(sigma-41.95*1000000) % slip tendency
        
        
    end

  
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'PcOnly.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end