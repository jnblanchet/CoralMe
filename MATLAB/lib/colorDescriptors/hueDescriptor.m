function [out]=hueDescriptor(patches_R,patches_G,patches_B,number_of_bins,smooth_flag,lambda)
% Computes the hue descriptor for a set of N image patches. 
% The patches are hard coded to be 20x20 represented by vectors of (400,1). 
% Note that the descriptor is not normalized to one, instead the color descriptor is normalized by color+grey.
% Performance can differ significantly for different choices of lambda.
%
% patches_R, _G, _B ( each 400 * N ): red, green and blue channel of N input patches (400 *N )
% number of bins                    : number of bins of the descriptor
% smooth_flag                       : amount of smoothing of final histogram
% lambda                            : multiplication factor before combining with SIFT 
%
% out (number_of_bins * N)          : returns N descriptors
%
% LITERATURE :
%
% Joost van de Weijer, Cordelia Schmid
% "Coloring Local Feature Extraction"
% Proc. ECCV2006, Graz, Austria, 2006.
%

if(nargin<6), lambda=1; end
if(nargin<5), smooth_flag=2; end
if(nargin<4), number_of_bins=36; end


[yy,xx]=ndgrid(-9.5:9.5,-9.5:9.5);
spatial_weights=exp((-xx.^2-yy.^2)./50);        % a sigma of 5 pixels 

out=zeros(number_of_bins,size(patches_R,2));

H=atan2((patches_R+patches_G-2*patches_B),sqrt(3)*(patches_R-patches_G))+pi;
H(isnan(H))=0;
saturation=sqrt(2/3*(patches_R.^2+patches_G.^2+patches_B.^2-patches_R.*(patches_G+patches_B)-patches_G.*patches_B)+0.01);
grey_energy=(sum((patches_R+patches_G+patches_B).*(spatial_weights(:)*ones(1,size(patches_R,2)))));

H=floor(H/(2*pi)*(number_of_bins));
for jj=0:number_of_bins-1
        out(jj+1,:)=sum(saturation.*(spatial_weights(:)*ones(1,size(patches_R,2))).*(H==jj));
end

if(smooth_flag>0)
     for ss=1:smooth_flag
          out=(2*out+[out(2:size(out,1),:);out(1,:)]+[out(size(out,1),:);out(1:(size(out)-1),:)])/4;
     end
end

out=lambda*out./(ones(size(out,1),1)*(sum(out)+grey_energy) );
