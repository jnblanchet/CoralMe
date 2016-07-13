function E = computeEnergy(neighborhoodWeights,l, M_foreground_pixel_eval, M_background_pixel_eval)

sEnergy = computeSmoothEnergyForLabeling(neighborhoodWeights,l);
RegionalCostPixel=l.*M_foreground_pixel_eval+(1-l).*M_background_pixel_eval;
rEnergy=sum(RegionalCostPixel(:));
E = sEnergy + rEnergy;

end

