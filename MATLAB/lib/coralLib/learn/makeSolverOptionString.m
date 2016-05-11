function optStr = makeSolverOptionString(options, weights, labelIndex)
% function optStr = makeSolverOptionString(options, weights, labelIndex)
%
% makeSolverOptionString converts INPUT options struct to a string that
% can be used to call various SVM solvers command line. INPUT weights
% specify class specific weights, if needed. optional INPUT labelIndex is a
% map from index in weight vector to actual class numbers.
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

switch options.type
    
    case 'pegasos'
        optStr = sprintf('-lambda %.20f -k %d', exp(options.lambda), exp(options.k));
    case 'libsvm'
        optStr = makeLibsvmOptionString(options.libsvm, weights);
        
    case 'joah'
        optStr = sprintf('-c %.8f', exp(options.joah.C));
        
    case 'steve'
        options.steve.Regularization_0x20__0x28_C_0x29_ = exp(options.steve.Regularization_0x20__0x28_C_0x29_);
        options.steve.Feature_0x20_Scale = exp(options.steve.Feature_0x20_Scale);
        optStr = savejson(' ', options.steve);
        
    case 'liblin'
        optStr = sprintf('-c %.20f -s %d -e %.20f -a %f -b %f', options.C, options.solver, options.epsilon, options.outputTempModels(1), options.outputTempModels(2));
        
    case 'svmmulti'
        optStr = sprintf('-c %.20f -w %d -e %.10f -l %d -i %f -j %f', options.C, options.solver, options.epsilon, options.loss, options.outputTempModels(1), options.outputTempModels(2));
        
    case 'imp'
        optStr = sprintf('-L %.20f -e %.20f -m %s -w %f %f', options.lambda, options.epsilon, options.stepper, options.outputTempModels(1), options.outputTempModels(2));
        
    case 'pegasos_ova'
        optStr = sprintf('-lambda %.20f -a %f -b %f', options.lambda, options.outputTempModels(1), options.outputTempModels(2));
        if(isfield(options, 'niter'))
            optStr = sprintf('%s -iter %f', optStr, options.niter);
        end
    case 'pegasos_multi'
        optStr = sprintf('-lambda %.20f -a %f -b %f', options.lambda, options.outputTempModels(1), options.outputTempModels(2));
        if(isfield(options, 'niter'))
            optStr = sprintf('%s -iter %f', optStr, options.niter);
        end
        
end

end