function cT_CarFollowing(Lead)
% The function deals with a 'lead' and 'following' vehicle only.
    load('cT_Setup.mat');
    load('cT_Feedback.mat');
    load('cT_SDE.mat');
    load('cT_U0.mat');
    Follow = Lead + 1;
% Estimate the following:    
    H_tk   = 0*ones(n,1); % headway
    H_tkn  = 0*ones(n,1); % new headway
    H_safe = 0*ones(n,1); % safe headway, two car lengths minimum
    K_tkn  = 0*ones(n,1); % density
    Q_tkn  = 0*ones(n,1); % traffic flow
    n_Viol = 0*ones(n,1); % rule of the road violation
    
% Ideal Conditions. Drivers are unhindered by car-following rules %%%%%%%%%%%
% X_tk and U_tk matrices are known 

% Estimate safe headway spaces: H_safe
    for i = 1:n
        speed     = U_tk(i,Lead);
        H_safe(i) = cT_SafeHeadway(speed,l);
        H_tk(i)   = X_tk(i,Lead) - X_tk(i,Follow);
    end
 %   [U_tk(:,Lead) H_safe]
 
% Drivers are hindered by car-following rules  
% If a following vehicle violates the safe headway rule (distance), then it 
% must slow down. It is assumed that the vehicle will to the lead vehicle speed. 
% Fix following vehicle speed U_tk(i,Follow) and X_tk(i,Follow)
% if there is a safe headway violation.
     for i = 1:n
         if H_tk(i) < H_safe(i); % following vehicle violates safe driving rule
            U_tk(i,Follow)  = U_tk(i,Lead);
            n_Viol(i)       = 1;
            u_lead          = U_tk(i,Lead);
            h_safe1         = cT_SafeHeadway(u_lead,l);
            x_follow1       = X_tk(i,Lead) - h_safe1; 
            x_follow2       = X_tk(i,Lead) + dt*U_tk(i,Follow);
            X_tk(i,Follow)  = min(x_follow1, x_follow2);
            h_safe2         = dt*U_tk(i,Follow);
            H_tk(i)         = max(h_safe1, h_safe2);
         end
     end 
  [t n_Viol U_tk(:,Lead) U_tk(:,Follow) H_tk X_tk(:,Lead) X_tk(:,Follow)];
% Estimate Trafic Density
    for i  = 1:n
        k1 = 1/H_tk(i); 
        K_tkn(i) = k1; 
    end
% Store traffic densities 
    global K_t
    K_t(:,Lead)   = 5280*K_tkn;
    K_t(201:203,:);
    U_t(:,Lead)   = U_tk(:,Lead);
    X_t(:,Lead)   = X_tk(:,Lead);
    U_t(:,Follow) = U_tk(:,Follow);
    X_t(:,Follow) = X_tk(:,Follow);
    V_t(:,Lead)   = n_Viol;
% Calculate flow  q = k * u
    H_ft        = mean(H_tk(100:n));
    U_fpsLead   = mean(U_tk(100:n,Lead));
    U_fpsFollow = mean(U_tk(100:n,Follow));
    K_vpf       = mean(K_tkn(100:n)); % vehicles per foot
    K_vpm       = K_vpf*5280;
    U_fps       = (U_fpsLead + U_fpsFollow)/2;
    Q_vph       = 3600 * K_vpf * U_fps;
    U_mph       = 3600/5280*U_fps;
    Q_star_vph  = 3600/5280*x0*45;   % vehicles per hour
    n_Viol      = sum(n_Viol);
    T = table(Lead,Q_star_vph,Q_vph,n_Viol,H_ft,K_vpm,U_mph) 
    
% Plots     
    figure('Name','CarFollowing')
    subplot(3,1,1)
    plot(t,U_tk(:,Lead),'k-')
    hold on
    plot(t,U_tk(:,Follow),'r-')
    hold on
    title(['Vehicles ',num2str(Lead),' and ',num2str(Follow),''])
    ylabel(str3,'Interpreter','latex')
    xlabel(str1,'Interpreter','latex') 
    legend('Lead u_L','Following u_F','Location','southeast') 

    subplot(3,1,2)
    plot(t,H_tk,'k-')
    hold on
    title(['Vehicles ',num2str(Lead),' and ',num2str(Follow),''])
    ylabel(str7,'Interpreter','latex')
    xlabel(str1,'Interpreter','latex') 
    legend('h','Location','southeast') 
    hold off
    
    subplot(3,1,3)
    plot(t,X_t(:,Lead),'k-')
    hold on
    plot(t,X_t(:,Follow),'r-')
    hold on
    title(['Vehicles ',num2str(Lead),' and ',num2str(Follow),''])
    ylabel(str2,'Interpreter','latex')
    xlabel(str1,'Interpreter','latex') 
    legend('Lead u_L','Following u_F','Location','southeast') 
    axis([0 60 -500 5000])
    
    if Lead == 1 
        saveas(gcf,'Figure3.pdf')  
    end
    size(K_t);
    save cT_CarFollowing.mat 
end