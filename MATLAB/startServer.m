% the TCP WebSocket lib jar must be added to the static java path. See
% matlab documentation here:
% http://www.mathworks.com/help/matlab/matlab_external/bringing-java-classes-and-methods-into-matlab-workspace.html.
% "javaaddpath" may not work. Use "edit('classpath.txt')", and insert a
% new line containing the result of this call:
% "[pwd filesep 'lib' filesep 'TCP' filesep 'matlabwebsocket.jar']"
% (a matlab restart will be needed

addpath(genpath(pwd));

port = 8888; 
server = RemoteCallServer(port);

% Initialize GPU now.
try
    d = gpuDevice;
catch
end

% init vl_feat
vl_setup