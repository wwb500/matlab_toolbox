function [w,h,z,u,g,xa] = plca_5d_fast_hmm( x, K, R, F, Q, iter, sh, sz, su, w, h, z, u, g, pl)
%
% An efficient temporally-constrained probabilistic model for sound event
% detection/automatic music transcription
%
% Inputs:
%  x     input distribution
%  K     number of components (pitches/sound event classes)
%  R     number of instrumnent sources/exemplars per event class
%  F     number of bins/semitone
%  Q     number of sound states
%  iter  number of EM iterations [default = 30]
%  sh    sparsity of h
%  sz    sparsity of z
%  su    sparsity of u
%  w     initial value of w (basis 5-D tensor)
%  h     initial value of h (pitch shifting tensor)
%  z     initial value of z (pitch activation matrix)
%  u     initial value of u (source contribution tensor)
%  g     initial value of g (sound state activation tensor)
%  pl    plot flag
%
% Outputs:
%  w   spectral bases
%  h   pitch shifting
%  z   pitch activation
%  u   source contribution
%  g   sound state activation
%  xa  approximation of input
%
% Emmanouil Benetos 2015


% Get sizes
[M,N] = size(x);
sumx = sum(x);

% Default training iterations
if ~exist( 'iter')
    iter = 30;
end

% Initialize
if ~exist( 'w') || isempty( w)
    w = rand(M,R,K,F,Q);
end
for r=1:R
    for k=1:K
        for f=1:F
            for q=1:Q
                w(:,r,k,f,q) = w(:,r,k,f,q) ./ (sum(w(:,r,k,f,q))+eps);
            end;
        end;
    end;
end;
if ~exist( 'z') || isempty( z)
    z = rand( K, N);
end
n=1:N;
z(:,n) = repmat(sumx(n),K,1) .* (z(:,n) ./ (repmat( sum( z(:,n), 1), K, 1)+eps));
if ~exist( 'u') || isempty( u)
    u = zeros( R, K, N);
end
for k=1:K
    for r=1:R
        u(r,k,:) = ones( size(x,2),1);
    end;
end;
for k=1:K
    for n=1:N
        u(:,k,n) = u(:,k,n) ./ (sum(u(:,k,n))+eps);
    end;
end;
if ~exist( 'h') || isempty( h)
    h = rand( F, K, N);
end
for k=1:K
    for n=1:N
        h(:,k,n) = h(:,k,n) ./ (sum(h(:,k,n)+eps));
    end;
end;
if ~exist( 'g') || isempty( g)
    g = 1/Q*ones(Q,K,N);
end


% Initialize HMM parameters
priors = 1/Q*ones(K,Q);
transitions = 1/Q*ones(K,Q,Q);
observations = ones(Q,K,N);


% Initialize update parameters
w_reshaped = reshape(w,[M R*K*F*Q]);
sumx = diag(sumx);


% Iterate
for it = 1:iter
    
    % E-step
    uz = u .* permute(repmat(z,[1 1 R]),[3 1 2]);    
    uz_big = permute(repmat(uz,[1 1 1 F Q]),[3 1 2 4 5]);
    h_big = permute(repmat(h,[1 1 1 R Q]),[3 4 2 1 5]);
    g_big = permute(repmat(g,[1 1 1 R F]),[3 4 2 5 1]);
    uzhg = uz_big .* h_big .* g_big;
    uzhg_reshaped = reshape(uzhg,[N R*K*F*Q]);
    xa = w_reshaped * uzhg_reshaped';
    D = x ./ (xa+eps);
    
    % Compute observation probability
    if (it > iter - 3)
        for k=1:K
            for q=1:Q
                uzhg_aux = reshape(squeeze(uzhg(:,:,k,:,q)),[N R*F]);
                w_aux = reshape(squeeze(w(:,:,k,:,q)),[M R*F]);
                xa_aux = w_aux * uzhg_aux';
                temp_obs = x .* log(xa_aux+eps);
                observations(q,k,:) = sum(temp_obs);
            end
            for n=1:N
                observations(:,k,n) =  (observations(:,k,n)-min(observations(:,k,n)))/(max(observations(:,k,n)-min(observations(:,k,n)))+eps);
                observations(:,k,n) =  observations(:,k,n) ./ (sum(observations(:,k,n))+eps);
            end;
        end
    end
    
    % M-step (update h,z,u,g)
    WD = D' * w_reshaped;
    WDUZHG = reshape(uzhg_reshaped .* WD,[N R K F Q]);

    z = (squeeze(sum(sum(sum(WDUZHG,2),4),5))').^sz;
    h = (permute(squeeze(sum(sum(WDUZHG,2),5)),[3 2 1])).^sh;
    u = (permute(sum(sum(WDUZHG,4),5),[2 3 1])).^su;
    
    if (it > iter - 3)
        for k=1:K
            [priors(k,:),transitions(k,:,:),temp_g] = forwardbackward(squeeze(priors(k,:)),squeeze(transitions(k,:,:)),squeeze(observations(:,k,:))');
            g(:,k,:) = temp_g;
        end
    end

    % Normalize h,z,u
    z = (z ./ (repmat(sum(z,1),[K 1])+eps)) * sumx;
    
    u_resh = reshape(u,[R K*N]);
    u_resh = (u_resh ./ (repmat(sum(u_resh,1),[R 1])+eps));
    u = reshape(u_resh,[R K N]);
    
    h_resh = reshape(h,[F K*N]);
    h_resh = (h_resh ./ (repmat(sum(h_resh,1),[F 1])+eps));
    h = reshape(h_resh,[F K N]);  
    
    % Display
    if pl
        subplot(3, 1, 1), imagesc(x), axis xy, title(['Iteration: ' num2str(it)])
        subplot(3, 1, 2), imagesc(xa), axis xy
        subplot(3, 1, 3), imagesc(z), axis xy
        drawnow
    end    
    
end
