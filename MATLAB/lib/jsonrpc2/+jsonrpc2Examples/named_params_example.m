function json_response = named_params_example()
    % Example code for named parameters request
    % To Run:  json_response = jsonrpc2Examples.named_params_example()
    
    %    json_request =
    %      { 
    %        "jsonrpc": "2.0",
    %        "id": 121,
    %        "method": "jsonrpc2Examples.concat",          % have to include the package in the method name
    %        "params": { "s1": "Hello", "s2": "World", "sep": " " }
    %      }
  
    json_request = '{ "jsonrpc": "2.0", "id": 121, "method": "jsonrpc2Examples.concat", "params": { "s1": "Hello", "s2": "World", "sep": " " } }';
    request = jsonrpc2.JSONRPC2Request.parse(json_request);

    result = jsonrpc2Examples.execute_request( request );

    response = jsonrpc2.JSONRPC2Response( request.id, result );
    json_response = response.toJSONString();

    %    json_response = 
    %      {
    %        "jsonrpc": "2.0",
    %        "id": 121,
    %        "result": "Hello World"
    %      }    
end

