% The base abstract class for the JSON-RPC 2.0 parameter retrievers. 
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

classdef ParamsRetriever < handle

    properties
        params;  % the parameters -- should be empty (for no params), struct (for named), or cell array (for positional)
    end
    
    properties (Dependent)
        size;    % count of parameters
    end

  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = ParamsRetriever()
            % Constructor for ParamsRetriever class.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        new instance of this class
    
            % Created only when there are no params
            
        end            
    
    end % constructor methods %


% =============================================================================
%                             Factory Methods
% =============================================================================
    methods (Static)  

        %% --------------------------------------------------------------------
        %   factory
        %% --------------------------------------------------------------------
        function this = Factory(varargin)
            % Factory constructor for ParamsRetriever, NamedParamsRetriever, and PositionalParamsRetriever classes.
            %
            %    Input:  
            %        params:        (cell OR struct) named or positional parameters
            %
            %    Output:
            %        new instance of this class or a subclass of this
    
            % -------------------------------------
            %  check for invalid number of arguments
            % -------------------------------------
            numvarargs = length(varargin);
            if( numvarargs > 1 )
                exception = MException('ParamsRetriever:TooManyArguements','Too many arguments sent to ParamsRetreiver constructor.  0 or 1 supported.' );
                throw(exception);
            end
            
            % -------------------------------------
            %  check for case of no parameters
            % -------------------------------------
            if( numvarargs < 1 )
                this = jsonrpc2.ParamsRetriever();
                return;
            end

            % -------------------------------------
            %  get params from varargin
            % -------------------------------------
            paramsin = varargin{1};
            
            if( isstruct(paramsin) )          
                this = jsonrpc2.NamedParamsRetriever(paramsin);
            elseif( iscell(paramsin) )  
                this = jsonrpc2.PositionalParamsRetriever(paramsin);
            elseif( ischar(paramsin) )
                cparams = cell(1,1);
                cparams{1} = paramsin;
                this = jsonrpc2.PositionalParamsRetriever(cparams);
            elseif( isnumeric(paramsin) && ~isempty(paramsin) )
                cparams = num2cell(paramsin);
                this = jsonrpc2.PositionalParamsRetriever(cparams);
            else
                exception = MException('JSONRPC2Params:InvalidParams',['Attempt to set parameters with unsupported class type.  Expected: struct or cell  Actual: ',class(params),'  (',int2str(jsonrpc2.JSONRPC2Error.JSON_INVALID_PARAMS),')'] );
                throw(exception);
            end
        end               

    end % factory methods %


    
% =============================================================================
%                         Getter/Setter Methods
% =============================================================================
    methods
        
        %% --------------------------------------------------------------------
        %   getter size
        %% --------------------------------------------------------------------
        function size = get.size(this)
            % Returns the parameter count.  
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        size  (int) - Returns: count of parameters
            
            size = this.calculateSize(); 
        end     
        
    
        %% --------------------------------------------------------------------
        %   getParams
        %% --------------------------------------------------------------------
        function params = getParams(this)
            % Gets the parameters for this retriever.  
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        params  (struct or cell) - Returns: named or positional parameters
            
            if( this.hasParameters() )
                params = this.params;
            else
                exception = MException('JSONRPC2Params:InvalidParams',['Attempt to fetch non-existent parameters.  (',int2str(jsonrpc2.JSONRPC2Error.JSON_INVALID_PARAMS),')'] );
                throw(exception);
            end
            
        end
        
    end % methods %
        
% =============================================================================
%                             Instance Methods
% =============================================================================
    methods (Access=public)
    
        %% --------------------------------------------------------------------
        %   toJSONString
        %% --------------------------------------------------------------------
        function jsonString = toJSONString(this)

            % Handled by subclasses

        end                    
    
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
           if( strcmp(class(this),'NamedParamsRetriever') )
               has_named = true;
           end
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
           has_positional = false; 
           if( strcmp(class(this),'PositionalParamsRetriever') )
               has_positional = true;
           end
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
           has_parameters = false; 
           if( strcmp(class(this),'NamedParamsRetriever') )
               has_parameters = true;
           elseif( strcmp(class(this),'PositionalParamsRetriever') )
               has_parameters = true;
           end
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
            
            calc_size = 0; 
        end        

    end % methods %

end % classdef %

        
