% This make.m is for MATLAB and OCTAVE under Windows, Mac, and Unix

try
	Type = ver;
	% This part is for OCTAVE
	if(strcmp(Type(1).Name, 'Octave') == 1)
		mex libsvmread.c
		mex libsvmwrite.c
		mex svmtrain.c ../svm.cpp svm_model_matlab.c
		mex svmpredict.c ../svm.cpp svm_model_matlab.c
	% This part is for MATLAB
	% Add -largeArrayDims on 64-bit machines of MATLAB
	else
		mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims libsvmread.c
		mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims libsvmwrite.c
        
        %openMP compiler flags for Visual Studio 2010 compile on Windows
		%mex -v CFLAGS="\$CFLAGS -std=c99" COMPFLAGS="$COMPFLAGS /openmp" -largeArrayDims svmtrain.c ../svm.cpp svm_model_matlab.c
		%mex -v CFLAGS="\$CFLAGS -std=c99" COMPFLAGS="$COMPFLAGS /openmp" -largeArrayDims svmpredict.c ../svm.cpp svm_model_matlab.c
        
        % for linux add -fopenmp and -lgomp
        mex -v CFLAGS="\$CFLAGS -std=c99 -fopenmp"  -lgomp -largeArrayDims svmtrain.c ../svm.cpp svm_model_matlab.c
        mex -v CFLAGS="\$CFLAGS -std=c99 -fopenmp"  -lgomp -largeArrayDims svmpredict.c ../svm.cpp svm_model_matlab.c
	end
catch
	fprintf('If make.m failes, please check README about detailed instructions.\n');
end
