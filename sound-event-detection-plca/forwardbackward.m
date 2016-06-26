function [newPriors,newTransition,gamma] = forwardbackward(priors,transition,observation)


% Allocation
[N,Q] = size(observation);
a = zeros(N,Q);
b = zeros(N,Q);
ksi = zeros(N,Q,Q);
c = zeros(N,1);
observation = observation + eps;

% Initialization
a(1,:) = priors.*observation(1,:); a(1,:) = a(1,:) ./ (sum(a(1,:))+eps); 
b(N,:) = 1;
c(1) = 1/(sum(a(1,:))+eps);

% Induction (forward)
for n=2:N
    for q=1:Q
        a(n,q) = sum(a(n-1,:).*transition(:,q)') * observation(n,q) + eps;
    end;
    c(n) = 1 / (sum(a(n,:))+eps);         % scaling factor (from Rabiner89, p.272)
    a(n,:) = a(n,:) ./ (sum(a(n,:))+eps); % normalize a (from Rabiner 89, p.272)
end;


% Induction (backward)
for n=N-1:-1:1
    for q=1:Q
        b(n,q) =  c(n) .* sum(transition(q,:) .* observation(n+1,:) .* b(n+1,:)) + eps;
    end;
end;


% Gamma
gamma = a.*b+eps;
gamma = gamma ./ ((repmat(sum(gamma,2),1,Q))+eps);


% New priors
newPriors = gamma(1,:);

% New transition
for n=1:N-1
    for q1=1:Q
        for q2=1:Q
            ksi(n,q1,q2) = a(n,q1) * transition(q1,q2) * observation(n+1,q2) * b(n+1,q2) + eps;
        end;
    end;
end;
for n=1:N-1 ksi(n,:,:) = squeeze(ksi(n,:,:)) ./ (repmat(sum(sum(ksi(n,:,:))),Q,Q)+eps); end;
newTransition = squeeze(sum(ksi,1));
newTransition = newTransition ./ (repmat(sum(newTransition,2),1,Q)+eps);

gamma=gamma';