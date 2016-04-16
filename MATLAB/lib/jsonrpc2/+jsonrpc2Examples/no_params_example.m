function json_response = no_params_example()
    % Example code for no parameter request
    % To Run:  json_response = jsonrpc2Examples.no_params_example()
    
    %    json_request =
    %      { 
    %        "jsonrpc": "2.0",
    %        "id": 121,
    %        "method": "jsonrpc2Examples.echo"    % have to include the package in the method name
    %      }
  
    json_request = '{ "jsonrpc": "2.0", "id": 121, "method": "jsonrpc2Examples.echo" }';
    request = jsonrpc2.JSONRPC2Request.parse(json_request);

    result = jsonrpc2Examples.execute_request( request );

    response = jsonrpc2.JSONRPC2Response( request.id, result );
    json_response = response.toJSONString();

    %    json_response = 
    %      {
    %        "jsonrpc": "2.0",
    %        "id": 121,
    %        "result": "echo"
    %      }    
end

