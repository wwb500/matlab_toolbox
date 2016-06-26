function [prediction, params] = symnmf(A,params)

params.alg='anls';
params.maxiter=5000;
params.tol=1e-3;
params.nbRep=10;
Hinit=[];

obj_best = Inf;
for i = 1 : params.nbRep
    if isempty(Hinit)
        switch params.alg
            case 'newton'
                [H, iter, obj] = symnmf_newton(A, params.nbc, params);
            case 'anls'
                [H, iter, obj] = symnmf_anls(A, params.nbc, params);
        end
    else
        params.Hinit = Hinit(:, :, i);
        switch params.alg
            case 'newton'
                [H, iter, obj] = symnmf_newton(A, params.nbc,params);
            case 'anls'
                [H, iter, obj] = symnmf_anls(A, params.nbc, params);
        end
    end
    [~, idx] = max(H, [], 2);
    if obj < obj_best
        prediction = idx;
        params.iter = iter;
        params.obj = obj;
        params.H = H;
    end
    
end

