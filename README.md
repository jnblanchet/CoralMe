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
- **Annotation**: machine learning tools that extract features and predict classes.
- **Communication**: unrelated to coral annotation. It contains everything related to the CoralMe server, RPC protocol, and JSON encoding.


Some important classes and scripts for developers:
- **startServer.m**: script that launches the CoralMe RPC server.
- Communication.**RemoteCallServer** is the server class. It handles data encoding. It handles basic types (double, int, string) as well as images in the form base64 JPEG (for MxNx3 matrices) or PNG (if a 4th transparency channel exists). The class may require improvements in the future to support new data types.
- Communication.**Context** is the session context. The context includes the image that is currently being processed and its segmentation. It also routes external calls to the proper class using the context parameters. See the **coralMeFactory.m** script for a list of the supported classes (that can be queried remotely), and how instantiation is performed.
- **coralMeFactory.m** creates session-specific objects. For simplicity and security, only object listed in the factory can be remotely queried. From the outside, classes are seen as static (e.g. a call to any session-instance would be "ClassName.method(args)"), but within MATLAB, there is 1 instance per class per session. Only public methods can be called.

# Quick start (running the Web demo)
1. Follow the instructions below to launch the CoralMe MATLAB server.
2. Open **index.html** using Firefox or edge. (Note: Chrome will not work for medium to large sized images. There is a problem with the json-rpc java library we use. This will be fixed soon.)

# Setup the CoralMe MATLAB server
1. Open MATLAB
2. Navigate to the CoralMe/MATLAB directory.
3. Add the TCP WebSocket lib jar to the static java path. "javaaddpath" [may not work](http://www.mathworks.com/help/matlab/matlab_external/bringing-java-classes-and-methods-into-matlab-workspace.html). Type **edit('classpath.txt')** in the MATLAB console. Add as a first line the path to "matlabwebsocket.jar". Type "**[pwd filesep 'lib' filesep 'TCP' filesep 'matlabwebsocket.jar']**" in the console to obtain the correct path.
4. If you’re not using 64-bits Windows or Linux, the LIBSVM compiled files (mex) are not included. Move to /lib/libSvm/matlab and run make.m. Refer to the [LIBSVM MATLAB interface repository]( https://github.com/cjlin1/libsvm/tree/master/matlab) for more info.
5. If you’d like to use convolutional neural networks (not required for the demo) compile the matconvnet library by running /lib/matconvnet/ vl_compilenn.m. Refer to the [official website]( http://www.vlfeat.org/matconvnet/install/#compiling) for more info on compiling. You’ll also need to download one of the pretrained networks (transfer learning is currently the only supported CNN feature).
5. Make sure you have an up to date [Java Runtime Environment]( http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) installed.
6. run **startServer.m**

# Remote procedure call
Once the CoralMe MATLAB server is running, it can be queried remotely using the JSON-RPC2 protocol, with the format for the method "**ClassName.method**", and the arguments in an array  **[arg1, arg2, ...]** as required by the MATLAB class signature. Only public methods of the classes listed in **coralMeFactory.m** can be query. See the API section for a full list of the supported calls.

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

# Application programming interface (API)

## Communication.Context

- **isReady()**: Forces initialization of the session and its context.
	- returns: True (once the server is ready).

- **getImage()**: Used to obtain the image that is actively being processed in the current session.
	- returns: the current image in base64 JPEG encoding.

- **getMap()**: Used to obtain a transparent overlay of the region contours for the current segmentation.
	- returns: a base64 PNG image with transparency showing the region contours with unique colors.

- **setImage(image)**: This is one of the first few methods that should always be called. It sets the working image.
	- image: a base64 encoded JPEG image.
	
## Segmentation.SmartRegionSelector
- **isReady()**: Forces initialization (instantiation, image resize, texture caching, etc).
	- returns: true
- **setResizeFactor(resizeFactor)**: Changes the size of the image. This is a trade off between computation speed and texture details.
	- resizeFactor: a factor between 0 and 1 (double or float). The class will estimate its own resize factor if this method is not used.
- **getResizeFactor()**: see setResizeFactor.
	- returns: the image resize factor.
- **getLabelMap()**: used to access the current segmentation map, which is a map of integer index showing the different regions.
	- returns: a 2d segmentation map (integer index array).
- **createBlob(x,y,r)**: Creates a new blob part of a new group.
	- x: the relative [0.0-1.0] or absolute (in px) x position (row id).
	- y: same as x, but for y (col id).
	- r: the radius to consider when creating the blob. if relative (between 0 and 1) it is a ratio of the image width. Otherwise it's a pixel measurement.
	- returns: the id of the new blob.
- **copyBlobToLocation(blobId, x, y, r)**: Creates a new blob, part of the same group as blobId. The union of the two blobs will define the resulting region.
	- x: the relative [0.0-1.0] or absolute (in px) x position (row id).
	- y: same as x, but for y (col id).
	- r: the radius to consider when creating the blob. if relative (between 0 and 1) it is a ratio of the image width. Otherwise it's a pixel measurement.
	- returns: the id of the new blob.
- **moveBlob(blobId, x, y)**: Change the position of an existing blob.
	- blobId: the id of the blob to move.
	- x: the new x (row) position (relative or absolute)
	- y: the new y (col) position (relative or absolute)
- **deleteBlob(blobId)**: removes an existing blob.
	- blobId: the Id of the blob to delete.
- **resizeBlobRegion(blobId, newSize)**: change the radius to consider around a blob.
	- blobId: the id of the target blob.
	- newSize: the new radius relative (0 to 1, as a ratio of the image width), or absolute (in px).
- **isValidBlobId(this, blobId)**: useful to check if an id exists.
	- returns: true if the blob id exists, false otherwise.
- **getKernelSize(this)**: gets the size (in pixels) of the kernel for the texture kernel density estimation.
	- returns: the kernel size.
- **setKernelSize(newSize)**: sets the kernel size. the kernel size should be roughly the same size as the texel of interest.
	- newSize: the new kernel size in pixel.

	
## Segmentation.SuperPixelExtractor
- **isReady()**: Forces initialization (instantiation, image resize, texture caching, etc).
	- returns: true
- **setResizeFactor(resizeFactor)**: Changes the size of the image. This is a tradeoff between computation speed and texture details.
	- resizeFactor: a factor between 0 and 1 (double or float). The class will estimate its own resize factor if this method is not used.
- **getResizeFactor()**: see setResizeFactor.
	- returns: the image resize factor.
- **getLabelMap()**: used to access the current segmentation map, which is a map of integer index showing the different regions.
	- returns: a 2d segmentation map (integer index array).
- **setRegionSize(newRegionSize)**: sets the region size parameter for superpixel extraction (in pixels).
	- newRegionSize: the new size in pixel.
- **getRegionSize()**: gets the region size.
	- returns: the region size in pixel.
- **setRegularizer(newRegularizer)**: sets the weight assigned to spatial distance between pixels above similarity.
	- newRegularizer: the new regularizer factor (positive integer).
- **getRegularizer()**: gets the current regularization factor.
	- returns: the regularization factor.
- **setGraphCutRatio(newGraphCutRatio)**: the percentage of superpixels that will be merged together using iterative cuts based on texture similarity.
	- newGraphCutRatio: the new graphcut cut ratio value.
- **getGraphCutRatio()**: gets the current value of the auto graph cut parameter.
	- returns:  the auto graph cut parameter.
- **getMap()**: launch the super pixel extraction.
	- returns: a base64 PNG image with transparency showing the region contours with unique colors.

## RegionRefinement.GraphCutMergeTool
- **isReady()**: Forces initialization.
	- returns: true
- **getMap()**: Used to obtain a transparent overlay of the region contours for the current segmentation.
	- returns: a base64 PNG image with transparency showing the region contours with unique colors.
- **merge(startX, startY, endX, endY)**: merges all regions between two specified points.
	- startX: the relative (0-1) or absolute (in px) row position of the starting point.
	- startY: same as startX, but for starting col value.
	- endX: same as startX, but for ending row value.
	- endY: same as startX, but for ending col value.
- **cut(startX, startY, endX, endY)**: cuts the largest region below the line into two distinct regions.
	- startX: the relative (0-1) or absolute (in px) row position of the starting point.
	- startY: same as startX, but for starting col value.
	- endX: same as startX, but for ending row value.
	- endY: same as startX, but for ending col value.
	
## RegionRefinement.UnassignedPixelRefinement
- **isReady()**: Forces initilization.
	- returns: true
- **getMap()**: Used to obtain a transparent overlay of the region contours for the current segmentation.
	- returns: a base64 PNG image with transparency showing the region contours with unique colors.
- **assignFreePixels(regularizationWeight)**: Assign all unassigned pixels to their nearest and most similar region.
	- regularizationWeight: an extra weight assigned to the distance (as opposed to the texture distance). It should be float precision value above 0. 1 is the same weight for texture and spatial distance.
	- returns: same as getMap()'s return.
	
## Annotation.RegionInfoProvider
- **getGoodRegionCenters()**: returns relative positions (x,y) where information on each region can be displayed.
	- returns: a 2d array 2xN (x,y) where N is the number of regions. A region's index represents its reference Id.
- **getRegionColors()**: get the colors of each region on the contour map.
	- returns: a 2d array 3xN (R,G,B) where N is the number of regions. RGB values are between 0 and 255. A region's index represents its reference Id.
	
## Annotation.AnnotationManager
- **listDatasets()**: obtain a list of all existing dataset (and models) saved on the server.
	- returns: a list of strings representing the names of the datasets. Names are used to load previous datasets.
- **setReprensentationsToUse(args)**: Sets the texture features to use. If there are multiple features sets, they will be aggregated later using score-level fusion. There are currently three extraction methods supported. They are listed in "extractorFactory.m".
	- args: a variable number of parameters. All params must be strings known by "extractorFactory.m". e.g. setReprensentationsToUse('TextonExtractor','ClbpExtractor');
- **loadDataset(name)**: Load an existing dataset (and its model, if it has been previously trained). The dataset can then be referenced by its name as a parameter (see other methods).
	- name: The dataset name. The listDatasets method can be used to see which datasets exist.
- **buildTmpDataset()**: Creates a nameless and temporary dataset instance. When processing a single image, a temporary dataset is practical. A call to this method will use the context image and segmentation map to extract features. The temporary dataset can later be merged with an existing dataset to expand its sample size.
- **trainModel(name)**: Launches SVM training for all feature representations used. If no name is specified, the operation is performed on the temporary dataset. Model training in necessary prior to calling the predictClasses() method.
- **predictClasses(trainDsName, testDsName)**: perform automatic annotation (SVM prediction). This will update the labels automatically to their most likely class.
	- trainDsName: the name of the training dataset. It must be loaded, and have a model.
	- testDsName: the testing dataset. If no name is specified, the temporary dataset is used instead.
	- returns: class-wise likelihood scores for each region on the image. Scores are normalized on a percentage scale to facilitate their interpretation.
- **appendData(trainDsName, otherDsName)**: Merges the features and labels from one dataset to another.
	- trainDsName: the name of the dataset features will be appended to.
	- otherDsNameL the name of the dataset features will be taken from. (if no name is specified, the temporary dataset is used).
- **addClass(name,classLabel)**: adds a new label (e.g. sand, hard coral, etc...).
	- name: the name of the target dataset. (empty name will target the temporary dataset)
	- classLabel: the new label (string) to add.
	- returns: the new label's Id.
- **getLabelDescriptions(name)**: get a the list of all supported labels.
	- returns: an array of strings representing the labels to use. The position in the array represents each label's id.
- **setLabel(name, idRegion, idLabel)**: Manually sets a label in the specified dataset.
	- name: the target dataset (empty name will reference the temporary dataset).
	- idRegion: the id of the target region.
	- idLabel: the new label's id.
	
# Known limitations
1. The MATLAB server does not support RPC calls from Chrome.
2. It is currently difficult to set parameters. We plan to implement a configuration file.

# Acknowledgement

CoralMe was made possible by the Open-source community:
- [Java-WebSocket](https://github.com/TooTallNate/Java-WebSocket) and its [MATLAB wrapper](https://github.com/jebej/MatlabWebSocket) (CoralMe server)
- [JSONLab](https://github.com/fangq/jsonlab) (JSON parsing and encoding tools)
- [MatConvNet](http://www.vlfeat.org/matconvnet/) (for convolutionnal neural nets).
- [Texton code, and dictionary](http://vision.ucsd.edu/content/moorea-labeled-corals), by Beijbom et.al. in CVPR 2012, "Automated - Annotation of Coral Reef Survey Images"
- [Local Binary Patterns](http://www.cse.oulu.fi/CMV/Downloads/LBPMatlab) by Marko Heikkilä and Timo Ahonen
- Completed Local Binary Patterns by Zhenhua Guo, Lei Zhang, and David Zhang
- [Color Descriptors] (http://lear.inrialpes.fr/people/vandeweijer/color_descriptors.html) by Joost van de Weijer
- Smart Segmentation Tool by JN. Blanchet
- [Multi-classifier Fusion](https://peerj.com/preprints/2026/) by JN. Blanchet, S. Déry, JA. Landry
- [VLFeat](http://www.vlfeat.org/)
- [LIBSVM](https://www.csie.ntu.edu.tw/~cjlin/libsvm/)
- [JavaScript JSON RPC 2.0 jQuery Plugin](https://github.com/datagraph/jquery-jsonrpc) (For remote calls from the web app demo)


# LicenseThe CoralMe source code (src dir) is licensed under the GNU GENERAL PUBLIC license. Each library (lib dir) have their own license (see license files).
