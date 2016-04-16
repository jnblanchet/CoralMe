function result = concat(varargin)
	% Concat a result that is the same as the incoming parameters.
	% Handles by name and by order parameters from a message queue.
    %
    %   INPUT:
    %      s1  (string) base string to extend
    %      s2  (string) extension onto the end of the base string
    %      sep (string) separator between base and extension

    numvarargs = length(varargin);
    switch( numvarargs )
        case 1
            params = varargin{1};
            if( isstruct(params) )
                s1  = params.s1;
                s2  = params.s2;
                sep = params.sep;
            elseif( iscell(params) )
                s1  = params{1,1};
                s2  = params{1,2};
                sep = params{1,3};
            else
                exception = MException('Parameter:InvalidType',['Single incoming argument must be of type struct or cell. ', ...
                                       '(type = ',class(params),')']);
                throw( exception );
            end
        case 3
            s1  = varargin{1};
            s2  = varargin{2};
            sep = varargin{3};           
        otherwise
            exception = MException('Parameter:InvalidCount',['This function supports one or three incoming arguments. ', ...
                                   '(num arguments = ',num2str(numvarargs),')']);
            throw( exception );
    end
    
	result = [s1,sep,s2];   % concatenate
   
end % method concat %
