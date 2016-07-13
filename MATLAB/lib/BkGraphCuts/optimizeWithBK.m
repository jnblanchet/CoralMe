function [currLabeling E] = optimizeWithBK(BKhandle, numRows, numCols, dataCosts)
BK_SetUnary(BKhandle,dataCosts);
E = BK_Minimize(BKhandle);
currLabeling = BK_GetLabeling(BKhandle);
currLabeling = reshape(currLabeling, numRows, numCols);
end