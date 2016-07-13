function sEnergy = computeSmoothEnergyForLabeling(nWeights,currLabeling)
    [idx nIdx values] = find(nWeights);
    sEnergy = sum(values (currLabeling(idx)~=currLabeling(nIdx)));
    
end