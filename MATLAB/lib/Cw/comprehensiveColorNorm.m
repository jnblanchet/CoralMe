function normalizedImg  = comprehensiveColorNorm(img_)

img = double(img_);
if(max(img(:) > 1.0))
    img = img ./ 255.0;
end

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

Ri = R;
Gi = G;
Bi = B;

pixNum = size(R,1) * size(R,2); % quantity of pixels
chanNum = 3; % quantity of channels
norm = pixNum/chanNum; % normalization factor

% criterion = 1e-10;
criterion = max(img(:)) ./ 10;
diff = 1;
maxIter = 100;
i=0;
while diff > criterion
    % First normalization
    total = R+G+B+eps;
    R = R./total;
    G = G./total;
    B = B./total;
      
    % Second normalization
    Rtot = sum (R(:));
    Gtot = sum (G(:));
    Btot = sum (B(:));
    
    R = norm.*R./Rtot;
    G = norm.*G./Gtot;
    B = norm.*B./Btot;
    
    % Criterion  
    diff = max(max([abs(Ri - R),...
        abs(Gi - G),...
        abs(Bi - B)]));
    Ri = R;
    Gi = G;
    Bi = B;
    if(i >= maxIter)
        break;
    end
    i = i + 1;
end

normalizedImg = img;
normalizedImg (:,:,1) = R;
normalizedImg (:,:,2) = G;
normalizedImg (:,:,3) = B;
end