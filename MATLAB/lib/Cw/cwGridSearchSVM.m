function [optC, optG] = cwGridSearchSVM(features,labels, weights)
    
    if nargin < 3
        weightstr = [];
    else
        weightstr = makeLibsvmWeightString( weights );
    end
    % Coarse grid optimization
    %disp(sprintf('    Coarse grid search'));

    log2C = -0:2:6;
    log2G = -8:2:0;
    p.C = 2.^log2C;
    p.G = 2.^log2G;
    [p.optC, p.optG, p.optC2, p.optG2, p.optPerf, p.optRes, p.optTime] = gridSearchSVM(features, labels, p.C, p.G);

    % Detect if there is two or more optimal values or 100% perf.
    if p.optPerf == 100
        %
%         disp(sprintf('    Coarse search resulted in 100%% performance.'));

        p.optCf = p.optC;
        p.optGf = p.optG;
        p.optPerfF = p.optPerf;

%         if sum(p.optPerf == p.optRes(:)) > 1
%             disp(sprintf('    (Warning) There are many optimal parametrisation.'));
%         end
    else
        % Fine grid optimization around coarse optimum
%         disp(sprintf('    Coarse search optimum: C=%-9.9f G=%-9.9f)', p.optC, p.optG));
%         disp(sprintf('    With a 2nd best of : C=%-9.9f G=%-9.9f)', p.optC2, p.optG2));
%         disp(sprintf('    Fine grid search'));

        c1 = log2C(p.C == p.optC2);
        g1= log2G(p.G == p.optG2);
        c2 = log2C(p.C == p.optC);
        g2 = log2G(p.G == p.optG);
        beginLog2Cf = min(c1,c2); endLog2Cf = max(c1,c2);
        beginLog2Gf = min(g1,g2); endLog2Gf = max(g1,g2);
        if(beginLog2Cf == endLog2Cf)
            log2Cf = beginLog2Cf;
        else
            log2Cf = beginLog2Cf:(endLog2Cf-beginLog2Cf)/5:endLog2Cf;
        end
        if(beginLog2Gf == endLog2Gf)
            log2Gf = beginLog2Gf;
        else
            log2Gf = beginLog2Gf:(endLog2Gf-beginLog2Gf)/5:endLog2Gf;
        end
        p.Cf = 2.^log2Cf;
        p.Gf = 2.^log2Gf;


        [p.optCf, p.optGf, ~,~, p.optPerfF, p.optResF, p.optTimeF] = gridSearchSVM(features, labels, p.Cf, p.Gf);

        % Detect if optimum is at boundary
%         if any(p.Cf([1 end]) == p.optCf) || any(p.Gf([1 end]) == p.optGf)
%             disp(sprintf('    (Warning) Optimum is at search space boundary.'));
%         end
%         disp(sprintf('    Fine search optimum: C=%-9.9f G=%-9.9f', p.optCf, p.optGf));
    end

    optC = p.optCf;
    optG = p.optGf;

    % GridSearchSVM Optimization for C-SVC using RBF kernel
        function [optC, optG, optC2, optG2, maxPerf, optRes, optTime] = gridSearchSVM(features,labels,C,G)

            optSize = [numel(C) numel(G)];
            optRes  = zeros(prod(optSize),1);
            optTime = zeros(prod(optSize),1);

            for i=1:prod(optSize)
                [ci,gi] = ind2sub(optSize,i);

                % Call libsvm
                % -s 0 : C-SVC, -t 2 : RBF, -c COST, -g GAMMA,
                % -v N : N-FOLD X-VAL, -q : QUIET -h=1 : SHRINK
                param = sprintf('-s 0 -t 2 -c %-9.9f -g %-9.9f -z 2 -v 2 -q -h 1 %s', C(ci), G(gi), weightstr);

                tic
                optRes(i) = svmtrain(labels, features, param);
                optTime(i) = toc;

                % fprintf('CW>    %d,%d,%d',C(ci),G(ci),optRes(i));
            end

            optRes = reshape(optRes,optSize);
            optTime = reshape(optTime,optSize);

            % Get maximum performance
            [maxPerf, maxPerfInd] = max(optRes(:));
            % Get optimal C and G index
            [optCind, optGind] = ind2sub(size(optRes), maxPerfInd);
                      
            % Get optimal C and G values
            optC = C(optCind);
            optG = G(optGind);
            
            % get 2nd best
            copyOptRes = optRes;
            copyOptRes(optCind,optGind) = 0;
            [~, maxPerfInd2] = max(copyOptRes(:));
            [optCind2, optGind2] = ind2sub(size(copyOptRes), maxPerfInd2);
            optC2 = C(optCind2);
            optG2 = G(optGind2);
        end

end