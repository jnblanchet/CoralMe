

clc


% set the numver of thread for openMp
setenv OMP_NUM_THREADS 8

dataFolder = 'D:\UWM\doktorat\code\KMLib\KMLibUsageApp\Data\';

%tr_path='heart_scale';
%tst_path='heart_scale';

tr_path=[dataFolder 'a9a'];
tst_path=[dataFolder 'a9a.t'];

[trYY trXX]=libsvmread(tr_path);
[tstYY tstXX]=libsvmread(tst_path);

tic
%string z parametrami svm, C-penlaty param, t-kernel type, g-gamma in rbf
%kernel

% -t 0 linear
model = svmtrain(trYY, trXX,'-c 4 -t 0 -q');
modelTime=toc;
tic
[pred, acc, dec_vals] = svmpredict(tstYY, tstXX, model);
predTime = toc;
ss=sprintf('libsvm linear acc=%0.5g modeltime=%g predtime=%g \n',acc(1),modelTime, predTime);
disp(ss);

%% -t 2 rbf
tic;
model = svmtrain(trYY, trXX,'-c 4 -t 2 -g 0.5 -q');
modelTime=toc;
tic
[pred, acc, dec_vals] = svmpredict(tstYY, tstXX, model);
predTime = toc;
ss=sprintf('libsvm RBF acc=%0.5g modeltime=%g predtime=%g \n\n',acc(1),modelTime, predTime);
disp(ss);


%% precomputed chi^2
dataTr= full(trXX);
%dataTr=sqrt(sum(dataTr.^2,2));
%mn = min(dataTr,[],1); mx = max(dataTr,[],1);
%dataTr = bsxfun(@rdivide, bsxfun(@minus, dataTr, mn), (mx-mn)+eps);
%dataTr=sqrt(sum(dataTr.^2,2)); l2 - norm
dataTr=bsxfun(@rdivide,dataTr,sum(dataTr,2)); %l1 - norm

dataTst= full(tstXX);
%dataTst=sqrt(sum(dataTst.^2,2));
%mn = min(dataTst,[],1); mx = max(dataTst,[],1);
%dataTst = bsxfun(@rdivide, bsxfun(@minus, dataTst, mn), (mx-mn)+eps);
%dataTst=sqrt(sum(dataTst.^2,2));
dataTst=bsxfun(@rdivide,dataTst,sum(dataTst,2)); %l1 - norm


tic;
K = chi_square_kernel(dataTr);
params = '-c 4 -t 4';
model = svmtrain(trYY, K, params);
modelTime=toc;

tic
KK = chi_square_kernel(dataTst);
[pred, acc, dec_vals] = svmpredict(tstYY, KK, model);
predTime = toc;
ss=sprintf('libsvm chi^2 precomputed norm acc=%0.5g modeltime=%g predtime=%g \n\n',acc(1),modelTime, predTime);
disp(ss);


%% norm chi^2 - modified libsvm norm dense
dataTr= full(trXX);
%mn = min(dataTr,[],1); mx = max(dataTr,[],1);
%dataTr = bsxfun(@rdivide, bsxfun(@minus, dataTr, mn), (mx-mn)+eps);
dataTr=bsxfun(@rdivide,dataTr,sum(dataTr,2)); %l1 - norm
tic
model = svmtrain(trYY, dataTr,'-c 4 -t 5');
modelTime=toc;
dataTst= full(tstXX);
%mn = min(dataTst,[],1); mx = max(dataTst,[],1);
%dataTst = bsxfun(@rdivide, bsxfun(@minus, dataTst, mn), (mx-mn)+eps);
dataTst=bsxfun(@rdivide,dataTst,sum(dataTst,2)); %l1 - norm
tic
[pred, acc, dec_vals] = svmpredict(tstYY, dataTst, model);
predTime = toc;
ss=sprintf('libsvm chi^2 modified dense acc=%0.5g modeltime=%g predtime=%g \n\n',acc(1),modelTime, predTime);
disp(ss);

%% chi^2 - sparse lib svm
trXXn=trXX;
%mn = min(trXXn,[],1); mx = max(trXXn,[],1);
%trXXn = bsxfun(@rdivide, bsxfun(@minus, trXXn, mn), (mx-mn)+eps);
trXXn=bsxfun(@rdivide,trXXn,sum(trXXn,2)); %l1 - norm
tic;
model = svmtrain(trYY, trXXn,'-c 4 -t 5');
modelTime=toc;

tstXXn=tstXX;
%mn = min(tstXXn,[],1); mx = max(tstXXn,[],1);
%tstXXn = bsxfun(@rdivide, bsxfun(@minus, tstXXn, mn), (mx-mn)+eps);
tstXXn=bsxfun(@rdivide,tstXXn,sum(tstXXn,2)); %l1 - norm

tic
[pred, acc, dec_vals] = svmpredict(tstYY, tstXXn, model);
predTime = toc;
ss=sprintf('libsvm chi^2 sparse acc=%0.5g modeltime=%g predtime=%g \n',acc(1),modelTime, predTime);
disp(ss);

%% exp chi^2 - sparse from libsvm
trXXn=trXX;

trXXn=bsxfun(@rdivide,trXXn,sum(trXXn,2)); %l1 - norm
tic;
model = svmtrain(trYY, trXXn,'-c 4 -t 7 -g 0.5');
modelTime=toc;

tstXXn=tstXX;
tstXXn=bsxfun(@rdivide,tstXXn,sum(tstXXn,2)); %l1 - norm

tic
[pred, acc, dec_vals] = svmpredict(tstYY, tstXXn, model);
predTime = toc;
ss=sprintf('libsvm exp chi^2 norm sparse acc=%0.5g modeltime=%g predtime=%g \n',acc(1),modelTime, predTime);
disp(ss);

%% precomputed exp(chi^2)
dataTr= trXX;
dataTr=bsxfun(@rdivide,dataTr,sum(dataTr,2)); %l1 - norm

dataTst= tstXX;
dataTst=bsxfun(@rdivide,dataTst,sum(dataTst,2)); %l1 - norm

K = exp_chi_square_kernel(dataTr,0.5);

params = '-c 4 -t 4';
tic;
model = svmtrain(trYY, K, params);
modelTime=toc;

KK = exp_chi_square_kernel(dataTst,0.5);
tic
[pred, acc, dec_vals] = svmpredict(tstYY, KK, model);
predTime = toc;
ss=sprintf('libsvm precomputed exp(chi^2) norm acc=%0.5g modeltime=%g predtime=%g \n',acc(1),modelTime, predTime);
disp(ss);

