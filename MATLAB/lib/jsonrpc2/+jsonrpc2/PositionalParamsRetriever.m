% Utility class for retrieving JSON-RPC 2.0 positional parameters (packed into a JSON Array). 
%
% Copyright (c) 2014, Cornell University, Lab of Ornithology
% All rights reserved.
%
% Distributed under BSD license.  See LICENSE_BSD.txt for full license.
%
% DEPENDS ON:
% 1.  jsonlab
%
% author: E. L. Rayle (elr37 at cornell)
% date: 01/22/2014
%
% NOTE: Interface design based on Java implementation by The Transaction Company.
%       http://software.dzhuvinov.com/json-rpc-2.0-base.html
%       http://software.dzhuvinov.com/files/jsonrpc2base/javadoc/index.html

classdef PositionalParamsRetriever < jsonrpc2.ParamsRetriever

  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = PositionalParamsRetriever(params)
            % Constructor for PositionalParamsRetriever class.
            %
            %    Input:  
            %        params:        (struct) named parameters
            %
            %    Output:
            %        new instance of this class
    
            if( ~exist('params','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''params''.');
                throw(exception);                
            end
            if( ~iscell(params) )
                exception = MException('Parameter:InvalidType','Parameter ''params'' must be a cell array.');
                throw(exception);
            end
            
            this.params = params;
        end            
    
    end % constructor methods %


% =============================================================================
%                         Getter/Setter Methods
% =============================================================================
        
% =============================================================================
%                             Instance Methods
% =============================================================================
    methods (Access=public)

        %% --------------------------------------------------------------------
        %   hasParam
        %% --------------------------------------------------------------------
        function has_param = hasParam(this,position)
            % Returns true if a parameter by the specified name exists, else false. 
            %
            %    Input:  
            %        position   (int) - The parameter position. 
            %
            %    Output:
            %        has_param  (boolean) - Returns: true if the parameter exists; otherwise, false.
            
            if( ~exist('position','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''position''.');
                throw(exception);                
            end
            if( ~isnumeric(position) )
                exception = MException('Parameter:InvalidType','Parameter ''position'' must be numeric.');
                throw(exception);
            end
            if( position < 1 )
                exception = MException('Parameter:OutOfRange',['Position index (',num2str(position),') must be an integer greater than 0.'] );
                throw(exception);
            end

            has_param = false;
            if( length(this.params) >= position ), has_param = true; end
            
        end % hasParam %
        
    
        %% --------------------------------------------------------------------
        %   get
        %% --------------------------------------------------------------------
        function value = get(this,position)
            % Retrieves the specified parameter which can be of any type.
            %
            %    Input:  
            %        position   (int) - The parameter position. 
            %
            %    Output:
            %        has_param  (boolean) - Returns: true if the parameter exists; otherwise, false.
            
            if( ~exist('position','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''position''.');
                throw(exception);                
            end
            if( ~isnumeric(position) )
                exception = MException('Parameter:InvalidType','Parameter ''position'' must be numeric.');
                throw(exception);
            end
            if( position < 1 )
                exception = MException('Parameter:OutOfRange',['Position index (',num2str(position),') must be an integer greater than 0.'] );
                throw(exception);
            end

            if( ~this.hasParam(position) )
                exception = MException('PositionalParams:InvalidParams',['Missing parameter at position ',position,'.  (',int2str(jsonrpc2.JSONRPC2Error.JSON_INVALID_PARAMS),')'] );
                throw(exception);
            end
            value = this.params{position};
            
        end % get %
        
    
        %% --------------------------------------------------------------------
        %   toJSONString
        %% --------------------------------------------------------------------
        function jsonString = toJSONString(this)
            % Returns a JSON string representation of this set of params for use in a JSON-RPC 2.0 request or notification. 
            % NOTE: Generally not used.  The conversion to JSON string is usually done as part of the request or notification's toJSONString method.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        jsonString  (string) - Returns: The JSON object string representing the parameters portion of a JSON-RPC 2.0 request or notification.

            jsonString = savejson('',this.params);

        end % toJSONString %       
    
    end % methods %

% =============================================================================
%                             Helper Methods
% =============================================================================
    methods (Access=public)
    
       function has_named = hasNamedParameters(this)
            % Does this request have named parameters?
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        has_named  (boolean) - Returns: true if request has named 
            %             parameters; otherwise, false
           has_named = false;
       end
       
       function has_positional = hasPositionalParameters(this)
            % Does this request have positional parameters?
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        has_named  (boolean) - Returns: true if request has positional 
            %             parameters; otherwise, false
           has_positional = true;
       end
       
       function has_parameters = hasParameters(this)
            % Does this request have parameters?
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        has_named  (boolean) - Returns: true if request has 
            %             parameters; otherwise, false
           has_parameters = true;
       end
    
    end % methods %

% =============================================================================
%                             Protected Methods
% =============================================================================
    methods (Access=protected)
        %% --------------------------------------------------------------------
        %   calculateSize
        %% --------------------------------------------------------------------
        function calc_size = calculateSize(this)
            % Calculates the parameter count.  Used by size getter method.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        size  (int) - Returns: count of parameters
            
            calc_size = length(this.params); 
        end
        
    end % methods %

end % classdef %

        
