function polygonGroup(phi, Svmag, rho_r, rho_f, alpha, PcmCheck, PcoCheck, probDownCheck, norm2Sv)
% compute and plot stress polygon group(advanced analysis #1, 3, 5)

try
    
n = 50; % number of nodes on each boundaries of stress polygon
k0=rho_f/rho_r; % normalized hydrostatic pressure gradient

%% variable defining %%
x=zeros(n,n); %shmin coordinate of contour plot
y=zeros(n,n);%shmax coordinate of contour plot
str1=zeros(3);% field principal stress
kcm=zeros(n,n);% pressure for shearing most optimally oriented fracture
kco=zeros(n,n);% normalized cut-off pressure
pro_pco=zeros(n,n); % shearing probability by Pco
pro_down=zeros(n,n);% downward slip probability
pp=zeros(91,91);%pressure for slip

%% mu-, mu+ for stress polygon boundary definition
mu = tan(phi);
mup=sqrt(mu^2+1)+mu; % mu+
mum=sqrt(mu^2+1)-mu; % mu-

%% main computing
for i = 1:n
    for j = 1:n
        sfDown=0; %downward slip fracture number
        if j == n
            x(i, n) = mum/mup;
            y(i, n) = x(i, n) * (1 + (i-1)/(n-1)*(mup/mum-1));
        else
            x(i, j) = (mum/mup*tan(pi/2*(j-1)/(n-1)) + mup/mum) / (1 + (i-1)/(n-1)*(mup/mum-1) +tan(pi/2*(j-1)/(n-1)));
            y(i, j) = x(i, j) * (1 + (i-1)/(n-1)*(mup/mum-1));
        end
        sig = sort([y(i, j) x(i, j) 1], 'descend');
        kcm(i, j) = Pcm_cal(sig(1)*Svmag/1000000,sig(3)*Svmag/1000000, phi) / Svmag*1000000;
        
        str1(3,3)=1.0;% vertical stress
        str1(1,1)=y(i,j);% shmi
        str1(2,2)=x(i,j);% shma
        
        if PcoCheck == 1 || probDownCheck == 1
            
            kco(i,j) = kcm(i,j) + alpha*(sig(3) - kcm(i,j));
            sfPco = 0; %slip fracture number
            
            counter1 = 0;
            counter2 = 0;
            
            for k = 1:90
                did = 4*(k-1)/180*pi;
                for h = 1:91
                    di = (h-1)/180*pi;
                    nv = [-sin(di)*cos(did); -sin(di)*sin(did); cos(di)];
                    tr=str1*nv; % fracture traction vector
                    nor=dot(tr,nv); %fracture normal stress
                    she=sqrt(dot(tr,tr)-nor*nor);%joint shear stress
                    pp(k,h)=nor-she/tan(phi); %required pressure for slip
                    
                    if h==1
                        counter1 = counter1+1; % counter for dip = 0 deg.
                    end
                    if h==91
                        counter2 = counter2+1; % counter for dip = 90 deg.
                    end
                    
                    if (h==1&&counter1<2) || (h==91&&counter2<46) || (h>1&&h<91)
                        if (pp(k,h)-kco(i,j))<0
                            sfPco=sfPco+1;
                        end
                        if (pp(k, h) - k0) < 0
                            sfDown = sfDown + 1;
                        end
                    end
                end
            end
            if (kcm(i,j)-k0)>=0
                sfDown=0;
            end
            pro_down(i,j)=sfDown/(90*89+45+1);
            pro_pco(i,j)=sfPco/(90*89+45+1);
        end
    end
end

%% plot
if PcmCheck == 1
    if norm2Sv == 0
        figure('name','contour of Pcm');
        contourf(x*Svmag/1000000,y*Svmag/1000000,kcm*Svmag/1000000,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]*Svmag/1000000);
        set(gca,'fontsize',12);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        h2=colorbar; %colorbar handle
        set(get(h2,'title'),'string','{\itP\rm_c_m (MPa)}', 'fontsize', 12);
        xlabel('Min. horiztontal stress,{\itS\rm_h_m_i_n (MPa)}','fontweight','bold');
        ylabel('Max. horiztontal stress,{\itS\rm_H_m_a_x (MPa)}','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Minimum critical pressure', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup;1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1*Svmag/1000000,y1*Svmag/1000000,'black','linewidth',1);
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1*Svmag/1000000,y1*Svmag/1000000,'--k');
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'--k');
        plot(x3*Svmag/1000000,y3*Svmag/1000000,'--k');
    else
        figure('name','contour of kcm');
        contourf(x,y,kcm,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]);
        set(gca,'fontsize',12);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        h2=colorbar; %colorbar handle
        set(get(h2,'title'),'string','{\itk\rm_c_m}', 'fontsize', 12);
        xlabel('Normalized min. horiztontal stress,{\itk\rm_h}','fontweight','bold');
        ylabel('Normalized max. horiztontal stress,{\itk\rm_H}','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Minimum critical pressure', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup; 1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1,y1,'black','linewidth',1);
        plot(x2,y2,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1,y1, '--k');
        plot(x2,y2,'--k');
        plot(x3,y3,'--k');
    end
end

if PcoCheck == 1
    if norm2Sv == 1
        fig = figure('name','contour of kco & contour of pro_kco');
        set(fig, 'position', [100 100 900 400])
        ax1 = subplot(1, 2, 1);
        set(ax1,'position',[0.07 0.2 0.45 0.7])
        contourf(x,y,kco,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]);
        set(gca,'fontsize',12);
        %set(gca,'xtick',[0.5 1.0 1.5 2]);
        %set(gca,'ytick',[0.5 1.0 1.5 2]);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        h2=colorbar; %colorbar handle
        set(get(h2,'title'),'string','{\itk\rm_c_o}');
        xlabel('Normalized min. horiztontal stress,{\itk\rm_h}','fontweight','bold');
        ylabel('Normalized max. horiztontal stress,{\itk\rm_H}','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Normalized cut-off pressure, kco', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup; 1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1,y1,'black','linewidth',1);
        plot(x2,y2,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1,y1, '--k');
        plot(x2,y2,'--k');
        plot(x3,y3,'--k');
    else
        fig = figure('name','contour of kco & contour of pro_kco');
        set(fig, 'position', [100 100 900 400])
        ax1 = subplot(1, 2, 1);
        set(ax1,'position',[0.07 0.2 0.45 0.7])
        contourf(x*Svmag/1000000,y*Svmag/1000000,kco*Svmag/1000000,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]*Svmag/1000000);
        set(gca,'fontsize',12);
        %set(gca,'xtick',[0.5 1.0 1.5 2]);
        %set(gca,'ytick',[0.5 1.0 1.5 2]);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        h2=colorbar; %colorbar handle
        set(get(h2,'title'),'string','{\itP\rm_c_o} (MPa)');
        xlabel('Min. horiztontal stress,{\itS\rm_h_m_i_n} (MPa)','fontweight','bold');
        ylabel('Max. horiztontal stress,{\itS\rm_H_m_a_x} (MPa)','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Cut-off pressure, Pco', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup; 1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1*Svmag/1000000,y1*Svmag/1000000,'black','linewidth',1);
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1*Svmag/1000000,y1*Svmag/1000000, '--k');
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'--k');
        plot(x3*Svmag/1000000,y3*Svmag/1000000,'--k');
    end

    ax2 = subplot(1, 2, 2);
    set(ax2,'position',[0.55 0.2 0.45 0.7])
    if norm2Sv == 1
        contourf(x,y,pro_pco,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]);
        set(gca,'fontsize',12);
        %set(gca,'xtick',[0.5 1.0 1.5 2]);
        %set(gca,'ytick',[0.5 1.0 1.5 2]);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        colorbar; %colorbar handle
        %set(get(h2,'title'),'string','{\itProbability\rm_c_o}');
        xlabel('Normalized min. horiztontal stress,{\itk\rm_h}','fontweight','bold');
        ylabel('Normalized max. horiztontal stress,{\itk\rm_H}','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Probability of shearing with high tendency(by kco)', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup; 1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1,y1,'black','linewidth',1);
        plot(x2,y2,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1,y1, '--k');
        plot(x2,y2,'--k');
        plot(x3,y3,'--k');
    else
        contourf(x*Svmag/1000000,y*Svmag/1000000,pro_pco,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]*Svmag/1000000);
        set(gca,'fontsize',12);
        %set(gca,'xtick',[0.5 1.0 1.5 2]*Svmag/1000000);
        %set(gca,'ytick',[0.5 1.0 1.5 2]*Svmag/1000000);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        colorbar; %colorbar handle
        %set(get(h2,'title'),'string','{\itProbability\rm_c_o}');
        xlabel('Min. horiztontal stress,{\itS\rm_h_m_i_n} (MPa)','fontweight','bold');
        ylabel('Max. horiztontal stress,{\itS\rm_H_m_a_x} (MPa)','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Probability of shearing with high tendency(by Pco)', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup; 1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1*Svmag/1000000,y1*Svmag/1000000,'black','linewidth',1);
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1*Svmag/1000000,y1*Svmag/1000000, '--k');
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'--k');
        plot(x3*Svmag/1000000,y3*Svmag/1000000,'--k');
    end
end

if probDownCheck == 1
    if norm2Sv == 1
        figure('name','contour of probability of downward slip');
        contourf(x,y,pro_down,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]);
        set(gca,'fontsize',12);
        %set(gca,'xtick',[0.5 1.0 1.5 2]);
        %set(gca,'ytick',[0.5 1.0 1.5 2]);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        colorbar; %colorbar handle
        xlabel('Normalized min. horiztontal stress,{\itk\rm_h}','fontweight','bold');
        ylabel('Normalized max. horiztontal stress,{\itk\rm_H}','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Probability of downward shearing', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup; 1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1,y1,'black','linewidth',1);
        plot(x2,y2,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1,y1, '--k');
        plot(x2,y2,'--k');
        plot(x3,y3,'--k');
    else
        figure('name','contour of probability of downward slip');
        contourf(x*Svmag/1000000,y*Svmag/1000000,pro_down,80,'linestyle','none');
        box off;
        axis square;
        axis([0 1.1*mup/mum 0 1.1*mup/mum]*Svmag/1000000);
        set(gca,'fontsize',12);
        %set(gca,'xtick',[0.5 1.0 1.5 2]);
        %set(gca,'ytick',[0.5 1.0 1.5 2]);
        set(gca,'xminortick','on');
        set(gca,'yminortick','on');
        colormap(jet(256));
        colorbar;
        colorbar; %colorbar handle
        xlabel('Min. horiztontal stress,{\itS\rm_h_m_i_n} (MPa)','fontweight','bold');
        ylabel('Max. horiztontal stress,{\itS\rm_H_m_a_x} (MPa)','fontweight','bold');
        set(gca,'ticklength',[0.02 0.025]);% set tick length
        title('Probability of downward shearing', 'FontWeight', 'Bold');
        hold on;
        x1=[mum/mup; 1];
        y1=[1;1];
        x2=[1;1];
        y2=[1;mup/mum];
        plot(x1*Svmag/1000000,y1*Svmag/1000000,'black','linewidth',1);
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'black','linewidth',1);
        x1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); rho_f/rho_r + mum/mup*(1-rho_f/rho_r)];
        y1 = [rho_f/rho_r + mum/mup*(1-rho_f/rho_r); 1];
        x2 = y1;
        y2 = [1; rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        x3 = y2;
        y3 = [rho_f/rho_r + mup/mum*(1-rho_f/rho_r); rho_f/rho_r + mup/mum*(1-rho_f/rho_r)];
        plot(x1*Svmag/1000000,y1*Svmag/1000000, '--k');
        plot(x2*Svmag/1000000,y2*Svmag/1000000,'--k');
        plot(x3*Svmag/1000000,y3*Svmag/1000000,'--k');
    end
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'polygonGroup.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end