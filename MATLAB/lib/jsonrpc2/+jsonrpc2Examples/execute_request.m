function result = execute_request( request )
    % Common code for executing a request.
    %
    %    Input:  
    %        request   (JSONRPC2Request) - object holding the request information
    %
    %    Output:
    %        result  (Object) - Returns: the results returned from the executed method
    
    method = request.method;         

    fh = str2func(method);
    if( request.hasParameters() )
        params = request.getParams();
        result = fh(params);         
    else
        result = fh();
    end
end

