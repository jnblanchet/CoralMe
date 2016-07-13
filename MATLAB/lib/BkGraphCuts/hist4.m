function nn = hist4(Im,Nbins)
nn = zeros(Nbins,Nbins,Nbins);
for k=1:size(Im,1)
    nn(Im(k,1),Im(k,2),Im(k,3)) = nn(Im(k,1),Im(k,2),Im(k,3)) + 1;
end