function varargout = pca(X, N, method)
%PCA PRINCIPLE COMPONENTS ANALYSIS
%
%  Performing principal components analysis on the N1-by-N2 real-valued
%  data matrix X, where N1 and N2 are the number of features (N1 variables)
%  and observations (N2 samples), respectively.
%
%  P = pca(X,N,method) returns the N-by-N1 matrix P of basis vectors, one
%  basis vector per row, in order of decreasing corresponding eigenvalues,
%  i.e. P*X retains the first N principle components. If N is not
%  specified, all components (N=N1) are kept.
%
%  Two methods are available: 'eig' (default) and 'svd' which solve the
%  problem by eigenvalue decomposition and singular value decomposition,
%  respectively. 'svd' is running in 'economy' mode. If there are more 
%  variables than samples (N1>N2), 'svd' is recommended for this code.
%
%  [P, D] = pca(X,N,method) also returns all eigenvalues (normalized) in D,
%  in descending order.
%
%  [P, D, Y] = pca(X,N,method) further returns the N-by-N2 matrix Y = P*X,
%  each column of whom is the projection of the corresponding observation
%  from X onto the basis vectors contained in P.
%
% Siqing Wu, <6sw21@queensu.ca>
% Version: 1.1, Date: 2008-07-30

error(nargchk(1,3,nargin)) % check the number of arguments
error(nargoutchk(0,3,nargout))

[nr, nc] = size(X);

if nargin<3
    method = 'eig'; % default method
end
if nargin<2
    N = nr; % keep all components
elseif N < 1 || N > nr || round(N)~=N
    fprintf('Input N=%g is not valid; all components will be retained.\n', N)
    N = nr;
end

X = X-repmat(mean(X,2),[1 nc]); % center data

switch method
    case 'eig'
        C = X*X.';
        % should be C/(nc-1) for unbiased estimate of the covariance matix,
        % but won't affect P.
        [E,D] = eig(C); % D lists eigenvalues from small to large
        % rearrange D and E
        D = diag(D);
        D = D(end:-1:1)/max(D);
        E = E(:,end:-1:1)';
        P = E(1:N,:);
        
    case 'svd'
        % Instead of solving X*X' = E*D*E', solve X = U*Sigma*V'
        % X*X' = U*Sigma*V'*V*Sigma*U' = U*Sigma^2*U' -> P = U';
        [U,sigma] = svd(X,'econ'); % "economy size" decomposition
        if N > nc
            fprintf('SVD -> N=%d is used.\n', nc)
            N = nc;
        end
        D = diag(sigma).^2;
        D = D/max(D);
        P = U(:,1:N)';
        
    otherwise
        error('Undefined method!')
end
fprintf('Top %d components are retained; cumulative eigenvalue contribution is %1.2f\n', N, sum(D(1:N))/sum(D))

switch nargout
    case {0,1}
        varargout = {P};
    case {2}
        varargout = {P, D};
    case {3}
        Y = P*X;
        varargout = {P, D, Y};
end