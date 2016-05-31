# What is CoralMe (http://CoralMe.xyz)
CoralMe is a bundle of state-of-the-art coral reef image annotation algorithms for the purpose of long term coral reef health monitoring. Image annotation today is still mostly done by hand, which is an extremely time consuming task. CoralMe offers tools to speed up manual annotation, or perform automatic annotation. Researchers can easily contribute to CoralMe within their usual MATLAB environment, while allowing external software to directly use these tools.

# Why CoralMe?
Currently, transitioning cutting-edge technology from research to operational is difficult. It requires computer vision experts, skilled software engineers, expensive software licenses and a considerable amount of time. Furthermore, because technology evolves so quickly, today's methods may become obsolete within just a few months. CoralMe addresses both of these problems. Firstly, because computer vision researchers contribute directly to CoralMe through MATLAB, state of the art methods are readily available. Secondly, CoralMe's integration in any existing software is done through simple remote procedure calls, and requires nothing more than a novice programmer to implement. See examples below for more information.

## For computer vision researchers
CoralMe is a collaborative MATLAB library where researchers can study, improve, and share algorithms. We adopt an object oriented model to separate contributions, while keeping identical interfaces between classes sharing a similar purpose.

## For marine ecology groups
CoralMe provides functionalities that enhance your home-made or Open-source annotation tools. This is made possible by our CoralMe server which runs within the MATLAB environment. Among other features, the CoralMe server supports concurrent sessions, and can take advantage of graphical processing units (GPU) to accelerate computation. The server can run either on your local or on a powerful remote machine.

# The MATLAB library
The MATLAB library consists of 4 packages:
- **Segmentation**: tools for region extraction.
- **Region refinement**: tools that improve an existing rough or incomplete segmentation.
- **Annotation**: machine learning tools that extract features, and predict classes.
- **Communication**: unrelated to coral annotation. It contains everything related to the CoralMe server, RPC protocol, and JSON encoding.


Some important classes and scripts for developers:
- **startServer.m**: script that launches the CoralMe RPC server.
- Communication.**RemoteCallServer** is the server class. It handles data encoding. It handles basic types (double, int, string) as well as images in the form base64 JPEG (for MxNx3 matrices) or PNG (if a 4th transparency channel exists). The class may require improvements in the future to support new data types.

- Communication.**Context** is the session context. The context includes the image that is currently being processed and its segmentation. It also routes external calls to the proper class using the context parameters. See the **coralMeFactory.m** script for a list of the supported classes (that can be queried remotely), and how instantiation is performed.
- **coralMeFactory.m** creates session-specific objects. For simplicity and security, only object listed in the factory can be remotely queried. From the outside, classes are seen as static (e.g. a call to any session-instance would be "ClassName.method(args)"), but within MATLAB, there is 1 instance per class per session. Only a class’ public methods can be called.

# Quickstart (running the Web demo)
1. Follow the instructions below to launch the CoralMe MATLAB server.
2. Open **index.html** using firefox or edge. (Note: Chrome will not work for medium-sized images. There is a problem with the json-rpc java library we use. This will be fixed soon.)

# Setup the CoralMe MATLAB server
1. Open MATLAB
2. Navigate to the CoralMe/MATLAB directory.
3. If you’re not using 64-bits Windows or Linux, the LIBSVM compiled files (mex) are not included. Move to /lib/libSvm/matlab and run make.m. Refer to the [LIBSVM MATLAB interface repository]( https://github.com/cjlin1/libsvm/tree/master/matlab) for more info.
4. If you’d like to use convolutional neural networks (not required for the demo) compile the matconvnet library by running /lib/matconvnet/ vl_compilenn.m. Refer to the [official website]( http://www.vlfeat.org/matconvnet/install/#compiling) for more info on compiling. You’ll also need to download one of the pretrained networks (transfer learning is currently the only supported CNN feature).
5. Make sure you have an up to date [Java Runtime Environment]( http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) installed.
6. run **startServer.m**

# Remote procedure call
Once the CoralMe MATLAB server is running, it can be queried remotely using the JSON-RPC2 protocol, with the format for the method "**ClassName.method**, and the argments in an array  **[arg1, arg2, ...]** as required by the MATLAB class signature. Only public methods of the classes listed in **coralMeFactory.m** can be query. See the API section for a full list of the supported calls.

Here’s an example of a call from a JavaScript application using the [JSON RPC 2.0 jQuery Plugin](https://github.com/datagraph/jquery-jsonrpc). Note that the socket should remain open until the client application closes, because the context is erased when the session ends.
```
var socket = new $.JsonRpcClient({ socketUrl: 'ws://localhost:8888' });
socket.call('GraphCutMergeTool.merge', [10,10,50,50], //same as the following in MATLAB:
			// myGraphCutMergeToolInstance.merge(10,10,50,50);
			function(result) {
				// callback logic (when MATLAB is finished)
			}
		);
```

# Application programming interfaces (API)

## Communication
**Communication.Context**
**isReady()**: Forces initilization of the session and its context.
	returns: True when the server is ready.

**getImage()**: Used to obtain the image that is actively being processed in the current session.
	returns: the current image in base64 JPEG encoding.

**getMap()**: Used to obtain a transparent overlay of the region contours for the current segmentation.
	returns: a base64 PNG image with transparency showing the region contours with unique colors.

**setImage(image)**: This is one of the first few methods that should always be called. It sets the working image.
	image: a base64 encoded JPEG image.
	
## Segmentation
**Segmentation.SmartRegionSelector**
	
**Segmentation.SuperPixelExtractor**

## RegionRefinement
**Segmentation.GraphCutMergeTool**
	
**Segmentation.UnassignedPixelRefinement**
	
## Annotation
**Annotation.AnnotationManager**


# Known limitations
1. The MATLAB server does not support RPC calls from Chrome.
2. It is currently difficult to set parameters. We plan to implement a configuration file.

# Acknowledgement

[Java-WebSocket](https://github.com/TooTallNate/Java-WebSocket) and its [MATLAB wrapper](https://github.com/jebej/MatlabWebSocket)
[JSONLab](https://github.com/fangq/jsonlab)
[MatConvNet](http://www.vlfeat.org/matconvnet/) (for convolutionnal neural nets).
[Texton code, and dictionary](http://vision.ucsd.edu/content/moorea-labeled-corals), by Beijbom et.al. in CVPR 2012, "Automated Annotation of Coral Reef Survey Images"
[Local Binary Patterns](http://www.cse.oulu.fi/CMV/Downloads/LBPMatlab) by Marko Heikkilä and Timo Ahonen
Completed Local Binary Patterns by Zhenhua Guo, Lei Zhang, and David Zhang
[Color Descritors] (http://lear.inrialpes.fr/people/vandeweijer/color_descriptors.html) by Joost van de Weijer
Smart Segmentation Tool by JN. Blanchet
(Multi-classifier Fusion) [https://peerj.com/preprints/2026/] by JN. Blanchet, S.Déry, JA. Landry
[VLFeat](http://www.vlfeat.org/)
[LIBSVM](https://www.csie.ntu.edu.tw/~cjlin/libsvm/)
[JavaScript JSON RPC 2.0 jQuery Plugin](https://github.com/datagraph/jquery-jsonrpc)


# License
The CoralMe source code (src dir) is licensed under the MIT license. Each library (lib dir) have their own license.