function stereonetGroup(S123, Svmag, phi, rho_r, rho_f, alpha, PcCheck, dPcdzCheck, norm2Sv)

try
    
% compute and plot stereonet group (advanced analysis #2, 4)

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

for i=1:360
    did = (i-1)/180*pi; % dip direction
    tre = did + pi;% trend of joint normal pole
    for j=1:91
        di = (j-1)/180*pi; % dip
        plu = 0.5*pi-di; % plunge
        jNormal = [sin(di)*sin(did) sin(di)*cos(did) cos(di)];
        l = dot(jNormal, S1_d)/norm(jNormal); % direction cosine to S1
        m = dot(jNormal, S2_d)/norm(jNormal); % direction cosine to S2
        n = dot(jNormal, S3_d)/norm(jNormal); % direction cosine to S3
        sigma = l^2*S1 + m^2*S2 + n^2*S3; % resolved normal stress
        tau = sqrt(((S1-S2)*l*m)^2 + ((S2-S3)*m*n)^2 + ((S3-S1)*n*l)^2); % resolved shear stress
        kc(i, j) = (sigma - tau/tan(phi))/Svmag; % normalized critical pressure for shearing
        pp_gr(i, j) = kc(i, j)*gr_sv; % normalized gradient of critical pressure
        x(i, j) = sqrt(2)*cos(tre)*cos(0.5*(0.5*pi+plu)); % calculated as equal-area stereonet
        y(i, j) = sqrt(2)*sin(tre)*cos(0.5*(0.5*pi+plu));
        
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
        fig = figure('Name','critical pressure for shearing & shearing probability with growing pressure');
        set(fig, 'position', [100 60 800 400])
        ax1 = subplot(1, 2, 1);
        set(ax1,'position',[0.03 0.05 0.45 0.9])
        set(gcf,'color','w');
        contourf(y, x, kc, 80,'LineStyle','none');
        colormap(jet(256));
        colorbar;
        h4=colorbar;
        set(get(h4,'title'),'string','{\itk\rm_c}', 'fontsize', 12);
        axis off;
        daspect([1 1 1])
        hold on;
        [c,h1]=contour(y, x, kc, [nor_Pco nor_sig3],'k','linewidth',2);
        clabel(c,h1,'fontsize',14,'color','yellow');
        title('Normalized critical pressure for shearing', 'FontWeight', 'Bold', 'fontsize', 12);
    else
        fig = figure('Name','normalized critical pressure for shearing & shearing probability with growing pressure');
        set(fig, 'position', [100 60 800 400])
        ax1 = subplot(1, 2, 1);
        set(ax1,'position',[0.03 0.05 0.45 0.9])
        set(gcf,'color','w');
        contourf(y, x, kc*Svmag/1000000, 80, 'LineStyle','none');
        colormap(jet(256));
        colorbar;
        h4=colorbar;
        set(get(h4,'title'),'string','{\itP\rm_c (MPa)}', 'fontsize', 12);
        axis off;
        daspect([1 1 1])
        hold on;
        [c,h1]=contour(y, x, kc*Svmag/1000000, [nor_Pco nor_sig3]*Svmag/1000000, 'k', 'linewidth', 2);
        clabel(c,h1,'fontsize',14,'color','yellow');
        title('Critical pressure for shearing', 'FontWeight', 'Bold', 'fontsize', 12);
    end

    ax2 = subplot(1, 2, 2);
    set(ax2,'position',[0.58 0.2 0.38 0.7])
    if norm2Sv == 1
        plot(p, prob*100, 'black', 'linewidth', 1.5);
        grid on;
        set(gca,'fontsize',12);
        xlabel('Normalized injection pressure, \itk\rm_{PP}','fontsize',12);
        ylabel('Probability of shearing (%)','fontsize',12);
        axis([max(min(p)) max(max(p)) 0 100]);
        hold on;
        x1=nor_sig3;
        x2=nor_Pco;
        nx1=(nor_sig3-nor_Pcm)/dp; %find the x position
        nx2=(nor_Pco-nor_Pcm)/dp;
        nx1=round(nx1);
        nx2=round(nx2);
        y1=100*prob(nx1+1);
        y2=100*prob(nx2+1);
        scatter(x1,y1,'black','square','fill'); %plot where pressure=sigma3
        scatter(x2,y2,'black','square','fill'); %plot where pressure=pco
        text(nor_sig3+0.02,y1-2,' \itk\rm_{w}=  \itk\rm_{3}','fontsize',12);
        text(nor_Pco+0.02,y2-2,' \itk\rm_{w} =  \itk\rm_{co}','fontsize',12);
        % set(gca,'xtick',floor(nor_Pcm*10)/10-0.1:0.1:nor_sig1);
    else
        max(max(prob))
        plot(p*Svmag/1000000,prob*100,'black','linewidth',1.5);
        grid on;
        set(gca,'fontsize',12);
        xlabel('Injection pressure, \itP\rm_{w} (MPa)','fontsize',12);
        ylabel('Probability of shearing (%)','fontsize',12);
        axis([max(min(p))*Svmag/1000000 max(max(p))*Svmag/1000000 0 100]);
        hold on;
        x1=nor_sig3;
        x2=nor_Pco;
        nx1=(nor_sig3-nor_Pcm)/dp; %find the x position
        nx2=(nor_Pco-nor_Pcm)/dp;
        nx1=round(nx1);
        nx2=round(nx2);
        y1=100*prob(nx1+1);
        y2=100*prob(nx2+1);
        scatter(x1*Svmag/1000000,y1,'black','square','fill'); %plot where pressure=sigma3
        scatter(x2*Svmag/1000000,y2,'black','square','fill'); %plot where pressure=pco
        text(nor_sig3*Svmag/1000000+0.02,y1-2,' \itP\rm_{w}=  \itS\rm_{3}','fontsize',12);
        text(nor_Pco*Svmag/1000000+0.02,y2-2,' \itP\rm_{w} =  \itP\rm_{co}','fontsize',12);
        %set(gca,'xtick',(floor(nor_Pcm*10)/10-0.1)*Svmag/1000000:0.1*Svmag/1000000:nor_sig1*Svmag/1000000);
    end
end

if dPcdzCheck == 1
    figure('Name','gradient of critical pressure');
    set(gcf,'color','w');
    contourf(y,x,pp_gr,80,'LineStyle','none');
    colormap(jet(256));
    colorbar;
    h2=colorbar;
    set(get(h2,'title'),'string','{\itP_c^`\rm(MPa/km)}', 'fontsize', 12);
    axis off;
    axis equal;
    hold on; 
    [c,h3]=contour(y,x,pp_gr,[gr_f gr_f],'k','linewidth',2);%%contour line of zero
    clabel(c,h3,'fontsize',14,'color','yellow');
    title('gradient of critical pressure', 'FontWeight', 'Bold', 'fontsize', 14);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereonetGroup.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end