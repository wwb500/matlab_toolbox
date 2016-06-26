function [w, crit] = kproducts(z, K)

% z: T observations dans R^dim sous la forme d'une matrice de taille dim x T
% K: Nombre de classes
% w: centroides sous forme d'une matrice de taille dim x K
% J: suite des valeurs du critère (par défaut, 1000 itérations)

T = size(z,2);    % Nombre d'observations
dim = size(z,1);  % Observations dans R^dim

nbMinimisation = 1;
iteMax = 1000;
normeKprod = 1;
regularisation = 10e-10; % epsilon de l'article

% K-Produit 
%----------

MIN = min(z')';
MAX = max(z')';
%FIGCRIT = 0;

for test=1:nbMinimisation

%fprintf('test No. %d\t',test)
%color = map(ceil(test/nbMinimisation*size(colormap,1)),:);

% initialisation aléatoire uniforme sur le support des observations
    w = min(z')'*ones(1,K) + (max(z')'-min(z')')*rand(1,K); % initialisation aléatoire (algorithme indépendant de l'init)

%figure(1)
%plot(w(1,:),w(2,:),'+','markeredgecolor',color)

    % minimisation par relaxation sur chaque mode
    ite=1; % indice de l'itération

    % paramètre de mise à jour du Kème mode
    % initialisation des coefficients C(K,n) (produits de K-1 termes)
    % première boucle = calcul C(1,n) à partir de C(K,n)
    C=ones(K,T);
    for n=1:T        
        for k=1:K-1 
            C(K,n)=C(K,n)*norm(z(:,n)-w(:,k))^2; % produit K-1 termes
        end    
        Jn(n)=C(K,n)*norm(z(:,n)-w(:,K))^2; % produit K termes
    end 
    
    % boucle d'estimation 
    while (ite<iteMax) 
wold = w;
        for k=1:K % mise à jour du kème mode
    
            for n=1:T % calcul des N coefficients C(k,n) et des D(k,n)
    
                % calcul C(k,n)
                if (norm(z(:,n)-w(:,k))~=0) % recurrence possible            
                    if (k>1)
                        if(dim==1)
                            C(k,n)=C(k-1,n)*(z(n)-w(k-1))^2/(z(n)-w(k))^2; %1D
                        else % dim>1
                            C(k,n)=C(k-1,n)*norm(z(:,n)-w(:,k-1))^2/norm(z(:,n)-w(:,k))^2; 
                        end
                    else % k=1, calculé par récurrence à partir de C(K,n)
                        if(dim==1)
                            C(k,n)=C(K,n)*(z(n)-w(K))^2/(z(n)-w(k))^2;  %1D
                        else % dim>1
                            C(k,n)=C(K,n)*norm(z(:,n)-w(:,K))^2/norm(z(:,n)-w(:,k))^2;
                        end
                    end                
                else % recurrence pas possible (entrainerait une division par zero)
                    C(k,n)=1;               
                    for kk=1:K
                        if (kk~=k)                        
                            C(k,n)=C(k,n)*norm(z(:,n)-w(:,kk))^2;
                        end
                    end
                end % if (recurence possible) else (recurrence pas possible)
                Jn(n)=C(k,n)*norm(z(:,n)-w(:,k))^2; % produit des K termes           
    
            end % boucle sur le calcul des K coefficients pour chaque observations          
    
            % mise à jour du k-ème mode par moyenne pondérée des observations
            if(normeKprod==2) % norme carré
                w(:,k) = z * C(k,:)'/sum(C(k,:)) ;  
            else % norme 
                D=C(k,:).*((Jn+regularisation).^(-0.5));
                w(:,k) = z * D'/sum(D) ;
            end
    
        end % boucle sur la mise à jour par mode
                                
        % calcul des critères à l'itération "ite"
if (normeKprod==2)
        J(ite)=sum(Jn); % KP norme carré
else
%        Jnorme1(ite)=sum(sqrt(Jn+regularisation)); % KP norme régularisée
        J(ite)=sum(sqrt(Jn+regularisation)); % KP norme régularisée
end
if(ite<200)
%  plot([wold(1,:); w(1,:)],[wold(2,:); w(2,:)],'-','Color',color)
end
        ite=ite+1; % itération courante
%        if (floor(ite/500)==ite/500), 
        if rem(ite,NaN)==0,
            fprintf('%d eme iteration\n',ite)
        end
    end % while(ite<iteMax)
        [poubelle,indS] = sort(w(1,:));
        w = w(:,indS);

%plot(w(1,:),w(2,:),'o','markerfacecolor',color,'markeredgecolor',color)
%fprintf('crit = %e\n',J(end)-Jref)
%fprintf('crit = %e\n',J(end))

end % boucle sur les init différentes


