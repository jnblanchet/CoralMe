% Parses JSON-RPC 2.0 request, notification, and response messages. 
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

classdef JSONRPC2Parser < handle

  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = JSONRPC2Parser()
            % Constructor for JSONRPC2Request class.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        new instance of this class

        end            
    
    end % constructor methods %



% =============================================================================
%                      Public Single Message Parsing Methods
% =============================================================================
    methods (Access=public)

        %% --------------------------------------------------------------------
        %   parseJSONRPC2Message
        %% --------------------------------------------------------------------
        function jsonRPC2Message = parseJSONRPC2Message(this,jsonString)
            % Provides common parsing of one JSON-RPC 2.0 requests, notifications, and responses.  
            % NOTE: Expects a single message in the JSON.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Message  (JSONRPC2Message) - Returns: a single instances of 
            %              JSONRPC2Message class with values from the parsed jsonString message
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonStruct      = this.parse(jsonString);
            jsonRPC2Message = this.parseMessageStruct( jsonStruct );               

        end % method parseJSONRPC2Message %

    
        %% --------------------------------------------------------------------
        %   parseJSONRPC2Request
        %% --------------------------------------------------------------------
        function jsonRPC2Request = parseJSONRPC2Request(this,jsonString)
            % Parses one JSON-RPC 2.0 request string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Request  (JSONRPC2Request) - Returns: a single instances of 
            %              JSONRPC2Request class with values from the parsed jsonString 
            %              message.  Will return JSONRPC2Notification if no id is specified 
            %              in the message.
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonStruct      = this.parse(jsonString);
            jsonRPC2Request = this.parseRequestStruct( jsonStruct );               

        end % method parseJSONRPC2Request %
    
    
        %% --------------------------------------------------------------------
        %   parseJSONRPC2Notification
        %% --------------------------------------------------------------------
        function jsonRPC2Notification = parseJSONRPC2Notification(this,jsonString)
            % Parses one JSON-RPC 2.0 notification string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Notification  (JSONRPC2Notification) - Returns: a single instances 
            %              of JSONRPC2Notification class with values from the parsed jsonString 
            %              message
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonStruct           = this.parse(jsonString);
            jsonRPC2Notification = this.parseNotificationStruct( jsonStruct );               
            
        end % method parseJSONRPC2Notification %
    
    
        %% --------------------------------------------------------------------
        %   parseJSONRPC2Response
        %% --------------------------------------------------------------------
        function jsonRPC2Response = parseJSONRPC2Response(this,jsonString)
            % Parses one JSON-RPC 2.0 response string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Response  (JSONRPC2Response) - Returns: a single instances of 
            %              JSONRPC2Response class with values from the parsed jsonString message
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonStruct       = this.parse(jsonString);
            jsonRPC2Response = this.parseResponseStruct( jsonStruct );               
            
        end % method parseJSONRPC2Response %
    
    
% =============================================================================
%                  Public Multiple Messages Parsing Methods
% =============================================================================

        %% --------------------------------------------------------------------
        %   parseJSONRPC2Messages
        %% --------------------------------------------------------------------
        function jsonRPC2Messages = parseJSONRPC2Messages(this,jsonString)
            % Provides common parsing of batch JSON-RPC 2.0 requests, notifications, and responses.  
            % NOTE: Will parse one or more batch messages from the JSON string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Messages  (cellarray) - Returns: cellarray of instances of JSONRPC2Message 
            %             class with values from the parsed jsonString for each message on the jsonString;
            %             any messages with parsing errors will be a double with value
            %               jsonprc2.JSONRPC2Error.JSON_PARSE_ERROR (-32700)
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonBatchCell   = this.parseMultiple(jsonString);
            
            numBatchMessages = length(jsonBatchCell);
            jsonRPC2Messages = cell(1,numBatchMessages);

            for index = 1:numBatchMessages
                try
                    jsonRPC2Messages{1,index} = this.parseMessageStruct( jsonBatchCell{index} );
                catch Exception
                    if( strcmp(Exception.identifier,'JsonRpc:InvalidMessage') )
                        jsonRPC2Messages{1,index} = [jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR];
                    end                         
                end
            end
                
            
                        
            % TODO:  XXX  Do we need to verify that all messages are of the same type???
            
        end % method parseJSONRPC2Messages %
    
        %% --------------------------------------------------------------------
        %   parseJSONRPC2Requests
        %% --------------------------------------------------------------------
        function jsonRPC2Requests = parseJSONRPC2Requests(this,jsonString)
            % Parse batch JSON-RPC 2.0 requests string.
            % NOTE: Will parse one or more batch requests from the JSON string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Requests  (cellarray) - Returns: cellarray of instances 
            %             of JSONRPC2Request or JSONRPC2Notification classes with values 
            %             from the parsed jsonString for each message on the jsonString
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonBatchCell   = this.parseMultiple(jsonString);
            
            numBatchRequests = length(jsonBatchCell);
            jsonRPC2Requests = cell(1,numBatchRequests);

            for index = 1:numBatchRequests
                try
                
                    newRequest = this.parseRequestStruct( jsonBatchCell{index} );
                    jsonRPC2Requests{index} = newRequest;
                
                catch exception  % exception is of type MException
                
                    % TODO: XXX  Should the exception create an instance of JSONRPC2Error and set error code and message
                    % exception.identifier
                    % exception.message

                    % newError = jsonrpc2.JSONRPC2Error(id, ...      % XXX  how to get id if message is good enough to have an id???
                    %                                   jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR, ...
                    %                                   [exception.identifier,' - ',exception.message); 
                    % jsonRPC2Requests{index} = newError;
                    
                    jsonRPC2Requests{index} = [];  % temporarily put in empty
                    
                end
            end                         
        end % method parseJSONRPC2Requests %
    
        %% --------------------------------------------------------------------
        %   parseJSONRPC2Notifications
        %% --------------------------------------------------------------------
        function jsonRPC2Notifications = parseJSONRPC2Notifications(this,jsonString)
            % Parse batch JSON-RPC 2.0 notifications string.
            % NOTE: Will parse one or more batch notifications from the JSON string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Notifications  (cellarray) - Returns: cellarray of instances 
            %             of JSONRPC2Notification class with values from the parsed 
            %             jsonString for each message on the jsonString
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonBatchCell   = this.parseMultiple(jsonString);
            
            numBatchNotifications = length(jsonBatchCell);
            jsonRPC2Notifications = cell(1,numBatchNotifications);

            for index = 1:numBatchNotifications
                try
                
                    newNotification = this.parseNotificationStruct( jsonBatchCell{index} );
                    jsonRPC2Notifications{index} = newNotification;
                
                catch exception  % exception is of type MException
                
                    % TODO: XXX  Should the exception create an instance of JSONRPC2Error and set error code and message
                    % exception.identifier
                    % exception.message

                    % newError = jsonrpc2.JSONRPC2Error(id, ...      % XXX  how to get id if message is good enough to have an id???
                    %                                   jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR, ...
                    %                                   [exception.identifier,' - ',exception.message); 
                    % jsonRPC2Notifications{index} = newError;
                    
                    jsonRPC2Notifications{index} = [];  % temporarily put in empty
                    
                end
            end                         
        end % method parseJSONRPC2Notifications %
    
        %% --------------------------------------------------------------------
        %   parseJSONRPC2Responses
        %% --------------------------------------------------------------------
        function jsonRPC2Responses = parseJSONRPC2Responses(this,jsonString)
            % Parse batch JSON-RPC 2.0 responses string.
            % NOTE: Will parse one or more batch responses from the JSON string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Responses  (cellarray) - Returns: cellarray of instances 
            %             of JSONRPC2Response class with values from the parsed 
            %             jsonString for each message on the jsonString
    
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            jsonBatchCell   = this.parseMultiple(jsonString);
            
            numBatchResponses = length(jsonBatchCell);
            jsonRPC2Responses = cell(1,numBatchResponses);

            for index = 1:numBatchResponses
                try
                
                    newResponse = this.parseResponseStruct( jsonBatchCell{index} );
                    jsonRPC2Responses{index} = newResponse;
                
                catch exception  % exception is of type MException
                
                    % TODO: XXX  Should the exception create an instance of JSONRPC2Error and set error code and message
                    % exception.identifier
                    % exception.message

                    % newError = jsonrpc2.JSONRPC2Error(id, ...      % XXX  how to get id if message is good enough to have an id???
                    %                                   jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR, ...
                    %                                   [exception.identifier,' - ',exception.message); 
                    % jsonRPC2Responses{index} = newError;
                    
                    jsonRPC2Responses{index} = [];  % temporarily put in empty
                    
                end
            end                         
        end % method parseJSONRPC2Responses %

    end % public methods %


% =============================================================================
%                           Private Parsing Methods
% =============================================================================
    methods (Access=private)
    
        %% --------------------------------------------------------------------
        %   parse
        %% --------------------------------------------------------------------
        function jsonStruct = parse(this,jsonString)
            % Provides common parsing of JSON-RPC 2.0 requests and responses.  Expects a 
            % single message in the JSON.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonStruct:    (struct) - Returns: a single JSON message in the parsed 
            %                                  JSON structure.
    
            % -------------------------
            %  Existence check on incoming json string
            % -------------------------            
            if( ~exist('jsonString','var') || ~ischar(jsonString) )
                exception = MException('JsonRpc:Invalid',[ 'Cannot parse non-character JSON message. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            if( isempty(jsonString) )
                exception = MException('JsonRpc:Invalid',[ 'Cannot parse empty JSON message. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end

    
            % -------------------------
            %  Load json as a struct
            % -------------------------            
            jsonObject = loadjson(jsonString);
            
            % -------------------------
            %  Make sure there is only one message
            % -------------------------
            numMessages = -1;
            if( isstruct(jsonObject) ),      numMessages = length(jsonObject);
            elseif( iscell(jsonObject ) ),   numMessages = length(jsonObject);
            elseif( isnumeric(jsonObject) ), numMessages = 0; end

            if( numMessages < 0 )
                exception = MException('JsonRpc:Invalid',[ 'Cannot parse invalid JSON message. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end

            if( numMessages > 1 )
                exception = MException('JsonRpc:TooManyMessages',[ 'The parse method parses a single message, but multiple messages were found.  Try using parseMultiple method. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end

            if( numMessages == 0 )
                exception = MException('JsonRpc:ZeroMessages',[ 'No messages were found in the passed in JSON string. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end            

            % -------------------------
            %  Make sure parsed JSON ended up as a struct.
            %  -- It should when there is only one message.
            % -------------------------
            if( ~isstruct(jsonObject) )
                exception = MException('JSONRPC2Parser:BadParameterType',[ 'JSON string could not be converted to JSON struct.  (Actual Type: ',class(jsonObject),')' ]);
                throw(exception);
            end
                                        
            jsonStruct = jsonObject;
            
        end % method parse %
    
    
        %% --------------------------------------------------------------------
        %   parseMultiple
        %% --------------------------------------------------------------------
        function jsonBatchCell = parseMultiple(this,jsonString)
            % Provides common parsing of JSON-RPC 2.0 requests and responses.  Will parse 
            % one or more messages from the JSON.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonBatchCell  (cellarray) - Returns: a at least one JSON message in 
            %              the parsed JSON cellaray of structs.

            % -------------------------
            %  Existence check on incoming json string
            % -------------------------            
            if( ~exist('jsonString','var') || ~ischar(jsonString) )
                exception = MException('JsonRpc:Invalid',[ 'Cannot parse non-character JSON message. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            if( isempty(jsonString) )
                exception = MException('JsonRpc:Invalid',[ 'Cannot parse empty JSON message. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end

    
            % -------------------------
            %  Load json as a struct
            % -------------------------            
            jsonBatchObject = loadjson(jsonString);
            
            % -------------------------
            %  Count the number of messages
            % -------------------------
            numMessages = -1;
            if( isstruct(jsonBatchObject) ),      numMessages = length(jsonBatchObject);
            elseif( iscell(jsonBatchObject ) ),   numMessages = length(jsonBatchObject);
            elseif( isnumeric(jsonBatchObject) ), numMessages = 0; end

            % -------------------------
            %  Make sure there is at least one message
            % -------------------------
            if( numMessages < 0 )
                exception = MException('JsonRpc:Invalid',[ 'Cannot parse invalid JSON message. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end

            if( numMessages == 0 )
                exception = MException('JsonRpc:ZeroMessages',[ 'No messages were found in the passed in JSON string. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end            
                
            % -------------------------
            %  Make sure output is cellarray of structs
            % -------------------------
            if( isstruct(jsonBatchObject) )
                jsonBatchCell = cell(1,numMessages);
                for index = 1:numMessages
                    jsonBatchCell{index} = jsonBatchObject(index);                    
                end                         
            elseif( iscell(jsonBatchObject) )
                jsonBatchCell = jsonBatchObject;
            else
                exception = MException('JsonRpc:Invalid',[ 'Cannot parse invalid JSON message. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end                                 
            
        end % method parseMultiple %
    

        %% --------------------------------------------------------------------
        %   commonMessageValidation
        %% --------------------------------------------------------------------
        function commonMessageValidation(this,jsonMessageStruct)
            % Validate that the input variable type is correct and that version is supported.
            %
            %    Input:  
            %        jsonMessageStruct:   (struct) struct holding a single json-rpc message
            %
            %    Output:
            %        throws exception if not valid; otherwise, no output
    
            %------------------
            % Validate parameter type
            %------------------
            if( ~isstruct(jsonMessageStruct) )
                exception = MException('JSONRPC2Message:BadParameterType',[ 'Method JSONRPC2Message:BadParameterType.commonMessageValidation requires parameter jsonMessageStruct to be a struct.  (Actual Type: ',class(jsonMessageStruct),')' ]);
                throw(exception);
            end
                        
            %------------------
            % Validate version
            %------------------
            if( isfield(jsonMessageStruct,'jsonrpc') )
                version = jsonMessageStruct.jsonrpc;
            else
                exception = MException('JsonRpc:Invalid',[ 'JSON Invalid: Missing jsonrpc version. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end            

            if( ~strcmp(jsonMessageStruct.jsonrpc,jsonrpc2.JSONRPC2Message.JSON_VERSION ) )
                exception = MException('JsonRpc:Invalid',[ 'JSON Invalid: Unsupported JSON version.  Received ',version,'. Expecting ',jsonrpc2.JSONRPC2Message.JSON_VERSION,'. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
        end % method commonMessageValidation %            


        %% --------------------------------------------------------------------
        %   parseMessageStruct
        %% --------------------------------------------------------------------
        function jsonRPC2Message = parseMessageStruct(this,jsonMessageStruct)
            % Provides common parsing of JSON-RPC 2.0 requests and responses.
            % It is more efficient to use specific message type parsing methods if the type 
            % is known in advance.
            %
            %    Input:  
            %        jsonMessageStruct:   (struct) struct holding a single json-rpc message
            %
            %    Output:
            %        jsonRPC2Message  (jsonRPC2Message) - Returns: instance of this class 
            %               with values from the parsed jsonMessageStruct
    
            %------------------------------
            % Try to parse a Request/Notification
            %------------------------------
            try
                jsonRPC2Message = this.parseRequestStruct( jsonMessageStruct );
                return;            
            catch exception  % exception is of type MException
                % ignore errors and try another type
            end

            %------------------------------
            % Try to parse a Response
            %------------------------------
            try
                jsonRPC2Message = this.parseResponseStruct( jsonMessageStruct );            
                return;            
            catch exception  % exception is of type MException
                % ignore errors and try another type
            end

            %------------------------------
            % Unable to parse one of the valid message types.
            %------------------------------
            exception = MException('JsonRpc:InvalidMessage', ['JSON Invalid: Unknown message type. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
            throw(exception);
                            
        end % method parseMessageStruct %

   
        %% --------------------------------------------------------------------
        %   parseRequestStruct
        %% --------------------------------------------------------------------
        function jsonRPC2Request = parseRequestStruct(this,jsonStruct)
            % Validate JSON struct for requests.  If valid, construct request instance from 
            % the values in JSON struct.
            %
            %    Input:  
            %        jsonStruct:   (struct) struct holding a single json-rpc message
            %
            %    Output:
            %        jsonRPC2Request  (jsonRPC2Request) - Returns: instance of JSONRPC2Request 
            %               class with values from the parsed jsonStruct
    
            this.commonMessageValidation(jsonStruct);  % throws exception if not valid
                        
            %------------------------------
            % Validate this is a request
            % -- method & id are required
            %------------------------------
            if( ~isfield(jsonStruct,'method') )
                exception = MException('JsonRpc:InvalidRequest',[ 'JSON Invalid: Method is missing from request. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            if( ~isfield(jsonStruct,'id') )
                jsonRPC2Request = this.parseNotificationStruct(jsonStruct);
                return;
            end
            
            %------------------------------
            % Get parts of request
            %------------------------------
            method = jsonStruct.method;
            id     = jsonStruct.id;

            if( isfield(jsonStruct,'params') )
                jsonRPC2Request = jsonrpc2.JSONRPC2Request(id,method,jsonStruct.params);
            else
                jsonRPC2Request = jsonrpc2.JSONRPC2Request(id,method);
            end

        end % method parseRequestStruct %
        

        %% --------------------------------------------------------------------
        %   parseNotificationStruct
        %% --------------------------------------------------------------------
        function jsonRPC2Notification = parseNotificationStruct(this,jsonStruct)
            % Validate JSON struct for notifications.  If valid, construct notification 
            % instance from the values in JSON struct.
            %
            %    Input:  
            %        jsonStruct:   (struct) struct holding a single json-rpc message
            %
            %    Output:
            %        jsonRPC2Notification  (jsonRPC2Notification) - Returns: instance of 
            %               JSONRPC2Notification class with values from the parsed jsonStruct
    
            this.commonMessageValidation(jsonStruct);  % throws exception if not valid
            
            
            %------------------------------
            % Validate this is a notification
            % -- method is required
            % -- id should not exist
            %------------------------------
            if( ~isfield(jsonStruct,'method') )
                exception = MException('JsonRpc:InvalidNotification',[ 'JSON Invalid: Method is missing from notification. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            if( isfield(jsonStruct,'id') )
                exception = MException('JsonRpc:InvalidNotification',[ 'JSON Invalid: ID is unknown field for notifications. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            %------------------------------
            % Get parts of notification
            %------------------------------
            method = jsonStruct.method;
            params = [];
            if( isfield(jsonStruct,'params') )
                jsonRPC2Notification = jsonrpc2.JSONRPC2Notification(method,jsonStruct.params);
            else
                jsonRPC2Notification = jsonrpc2.JSONRPC2Notification(method);
            end
            
        end % method parseNotificationStruct %
        

        %% --------------------------------------------------------------------
        %   parseResponseStruct
        %% --------------------------------------------------------------------
        function jsonRPC2Response = parseResponseStruct(this,jsonStruct)
            % Validate JSON struct for responses.  If valid, construct response instance 
            % from the values in JSON struct.
            %
            %    Input:  
            %        jsonStruct:   (struct) struct holding a single json-rpc message
            %
            %    Output:
            %        jsonRPC2Response  (jsonRPC2Response) - Returns: instance of JSONRPC2Response 
            %               class with values from the parsed jsonStruct
    
            this.commonMessageValidation(jsonStruct);  % throws exception if not valid
            
            
            %------------------------------
            % Check if this is an error response
            %------------------------------
            if( isfield(jsonStruct,'error') )
                jsonRPC2Response = this.parseErrorStruct(jsonStruct);
                return;
            end
            
            %------------------------------
            % Validate success response
            % -- result is required
            % -- id is required
            %------------------------------
            if( ~isfield(jsonStruct,'result') )
                exception = MException('JsonRpc:InvalidResponse',[ 'JSON Invalid: Result is missing from response. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            if( ~isfield(jsonStruct,'id') )
                exception = MException('JsonRpc:InvalidResponse',[ 'JSON Invalid: ID is missing from response. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            %------------------------------
            % Get parts of response
            %------------------------------
            id     = jsonStruct.id;
            result = jsonStruct.result;
            
            jsonRPC2Response = jsonrpc2.JSONRPC2Response(id,result);

        end % method parseResponseStruct %
        

        %% --------------------------------------------------------------------
        %   parseErrorStruct
        %% --------------------------------------------------------------------
        function jsonRPC2Error = parseErrorStruct(this,jsonStruct)
            % Validate JSON struct for error responses.  If valid, construct error response 
            % instance from the values in JSON struct.
            %
            %    Input:  
            %        jsonStruct:   (struct) struct holding a single json-rpc message
            %
            %    Output:
            %        jsonRPC2Error  (jsonRPC2Error) - Returns: instance of JSONRPC2Error 
            %               class with values from the parsed jsonStruct
    
            this.commonMessageValidation(jsonStruct);  % throws exception if not valid
            
            %------------------------------
            % Validate error response
            % -- error is required
            % -- id is required
            %------------------------------
            if( ~isfield(jsonStruct,'error') )
                exception = MException('JsonRpc:InvalidError',[ 'JSON Invalid: Error is missing from error response. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            if( ~isfield(jsonStruct,'id') )
                exception = MException('JsonRpc:InvalidError',[ 'JSON Invalid: ID is missing from error response. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            %------------------------------
            % Get parts of error
            %------------------------------
            id     = jsonStruct.id;
            error  = jsonStruct.error;

            %------------------------------
            % Validate error field
            % -- code required
            % -- message required
            %------------------------------
            if( ~isfield(error,'code') )
                exception = MException('JsonRpc:InvalidError',[ 'JSON Invalid: Error code is missing from error response. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
            
            if( ~isfield(error,'message') )
                exception = MException('JsonRpc:InvalidError',[ 'JSON Invalid: Error message is missing from error response. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end

            %------------------------------
            % Get subparts of error
            %------------------------------
            code     = error.code;
            message  = error.message;

            jsonRPC2Error = jsonrpc2.JSONRPC2Error(id,code,message);

        end % method parseErrorStruct %

    end % private parsing methods %

end % classdef %

        
