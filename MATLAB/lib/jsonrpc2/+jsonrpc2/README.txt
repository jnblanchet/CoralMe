===================================
 README.txt for +jsonrpc2
===================================
22-Jan-2014

ABOUT
-----
+jsonrpc2 holds classes to represent, parse and serialise JSON-RPC 2.0 requests, notifications and responses.

It is open source according to the license required by MATLAB File Exchange.]
See license file for more information.


AKNOWLEDGEMENTS
---------------

The API was modeled as close as possible to that used by Vladimir Dzhuvinov in his Java implementation of 
JSON-RPC 2.0 Base.  For more information on the Java implementation, see his website at...
http://software.dzhuvinov.com/json-rpc-2.0-base.html


DEPENDENCIES
------------
Dependencies for +jsonrpc2 classes
1.  jsonlab - (REQUIRED) [New 19 Oct 2011; Updated 26 Aug 2013] 
    http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encodedecode-json-files-in-matlaboctave


GETTING STARTED
---------------
1) Assumed you already downloaded jsonrpc2 package since you are reading this file. 
2) Download jsonlab from http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encodedecode-json-files-in-matlaboctave.
3) Make sure the +jsonrpc2 package and jsonlab are on the MATLAB file path.


RECOMMENDED
-----------
Run tests prior to use.  All tests should pass.  See +jsonrpc2Tests/README.txt for information on running tests.


EXAMPLES
--------
% Request Example:

id = 1;
method = 'concat';
params = struct;
params.s1 = 'Hello ';
params.s2 = 'World';
request1 = jsonrpc2.JSONRPC2Request(id, method, params );
requestJson = request1.toJSONString();

request2 = jsonrpc2.JSONRPC2Request.parse(requestJson);


% Response Example:

id = 1;
result = 'Hello World';
response1 = jsonrpc2.JSONRPC2Response(id, results );
responseJson = response1.toJSONString();

response2 = jsonrpc2.JSONRPC2Response.parse(responseJson);


GETTING HELP
------------
All classes are documented.  Type the following command at the MATLAB command prompt.

doc jsonrpc2
