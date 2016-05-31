# What is CoralMe (http://CoralMe.xyz)
CoralMe is a bundle of state-of-the-art coral reef image annotation algorithms for the purpose of long term coral reef health monitoring. Image annotation today is still mostly done by hand, which is an extremely time consuming task. CoralMe offers tools to speed up manual annotation, or perform automatic annotation. Researchers can easily contribute to CoralMe within their usual MATLAB environment, while allowing external sofware to directly use these tools.

# Why CoralMe?
Currently, transitionning cutting-edge technology from research to operationnal is difficult. It requires computer vision experts, skilled software engineers, expensive software lisences and a considerable amout of time. Furthermore, because technology evolves so quickly, today's methods may become obsolete within just a few months. CoralMe adresses both of these problems. Firstly, because computer vision researchers contribute directly to CoralMe through MATLAB, state of the art methods are readily available. Secondly, CoralMe's intergration in any existing software is done through simple remote procedure calls, and requires nothing more than a novice programmer. See examples below for more information.

## For computer vision researchers
CoralMe is a collaborative MATLAB library where researchers can study, improve, and share algorithms. We adopt an object oriented model to separate contributions, while keeping identical interfaces between classes sharing a similar purpose.

## For marine ecology groups
CoralMe provides functionalities that enhance your home-made or opensource annotation tools. This is made possible by our CoralMe server which runs within the MATLAB environement. Among other features, the CoralMe server supports concurent sessions, and can take advantage of graphical processing units (GPU) to accelarate computation.

# The MATLAB library
The MATLAB library consists of 3 packages :
> Segmentation: tools for region extraction.
> Region refinement: tools that improve an existing rough or incomplete segmentation.
> Annotation: machine learning tools that extract features, and predict classes.

The important classes for developers:
XXX is the server class.
XXX is the session context. The context includes things like the image that is currently being processed and its segmentation. It routes classes to the proper class with the context parameter.
XXX instanciates session-specific objects. For simplicity and security, only object listed in the factory creating code can be remotely queried. From the outside, classes are seen as static (e.g. a call to any session-instance would be "ClassName.method(args)"), but within MATLAB, there is 1 instance per session. Only public methods call be called.

# Setup MATLAB server
compile LIBSVM
run startServer
If you want to use CNN models: compile matconvnet (link), download a cnn network.


# Remote procedure call
Make sure the CoralMe MATLAB server is running  the server is running

# Application programming interfaces

# Known limitations
The MATLAB server does not support RPC calls from Chrome.

# Acknowledgement

JAva server
matlab json converter
matconvnet (CNN)
beijbom dict + texton
LBP
CLBP
hue hist opponent angle
smart seg tool
VLFeat
LIBSVM
fusion (cite us)
javacript JSONRPC library

