% javaaddpath([pwd filesep 'lib' filesep 'TCP' filesep 'matlabwebsocket.jar']); 

port = 8888; 
server = RemoteCallServer(port);