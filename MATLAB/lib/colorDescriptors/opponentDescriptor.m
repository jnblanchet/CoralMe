function [out2]=opponentDescriptor(patches_R,patches_G,patches_B,number_of_bins,smooth_flag,lambda)
% Computes the opponent descriptor for a set of N image patches. 
% The patches are hard coded to be 20x20 represented by vectors of (400,1). 
% Note that the descriptor is not normalized to one, instead the descriptor is normalized by color+grey derivative energy.
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

sigma_g=1.5;

[yy,xx]=ndgrid(-9.5:9.5,-9.5:9.5);
spatial_weights=exp((-xx.^2-yy.^2)./50);        % a sigma of 5 pixels 
    
number_of_patches=size(patches_R,2);

patch_in=zeros(20,20,3);
out2=zeros(number_of_bins,number_of_patches);

for kk=1:number_of_patches

    patch_in(:,:,1)=reshape(patches_R(:,kk),20,20);
    patch_in(:,:,2)=reshape(patches_G(:,kk),20,20);
    patch_in(:,:,3)=reshape(patches_B(:,kk),20,20);
      
	
	[f_O1_x,f_O1_y,f_O2_x,f_O2_y,f_O3_x,f_O3_y] = eeOpponentDer(fillBorder(patch_in,floor(3*sigma_g+.5)),sigma_g);
    
	start_wh=floor(3*sigma_g+.5)+1;
	end_h=floor(3*sigma_g+.5)+size(patch_in,1);
	end_w=floor(3*sigma_g+.5)+size(patch_in,2);
	
	f_O1_x=f_O1_x(start_wh:end_h,start_wh:end_w);
	f_O1_y=f_O1_y(start_wh:end_h,start_wh:end_w);
	f_O2_x=f_O2_x(start_wh:end_h,start_wh:end_w);
	f_O2_y=f_O2_y(start_wh:end_h,start_wh:end_w);
	f_O3_x=f_O3_x(start_wh:end_h,start_wh:end_w);
	f_O3_y=f_O3_y(start_wh:end_h,start_wh:end_w);

    f_ang_x = spatial_weights.* ( f_O1_x.^2+f_O2_x.^2 );
    f_ang_y = spatial_weights.* ( f_O1_y.^2+f_O2_y.^2 );
    GreyEn=sum(spatial_weights(:).*(f_O3_x(:).^2+f_O3_y(:).^2));
    
    %x-derivatives
    corner=atan2(f_O1_x,f_O2_x);
    corner=corner+pi.*(corner<0);
    out_x=make_hist_corner(corner,f_ang_x,number_of_bins);
    %y-derivatives
    corner=atan2(f_O1_y,f_O2_y);
    corner=corner+pi.*(corner<0);
    out_y=make_hist_corner(corner,f_ang_y,number_of_bins);
    out=out_x+out_y;
    out=out';
    if(smooth_flag>0)
            for ss=1:smooth_flag
                out=(2*out+[out(2:length(out));out(1)]+[out(length(out));out(1:(length(out)-1))])/4;
            end
    end
    out2(:,kk)=lambda*sqrt(out)/sqrt(sum(out)+GreyEn);
end

function out=make_hist_corner(angle_in,weights,number_of_bins)

out2=zeros(1,number_of_bins+1);
bin_number= (angle_in/pi*number_of_bins);

width=size(angle_in,2);
height=size(angle_in,1);

for jj=1:height
    for ii=1:width
         bn=bin_number(jj,ii);
         if (bn>=number_of_bins), bn=number_of_bins-.1; end
         cc1=floor(bn);
         w_loc=weights(jj,ii);
         for dd1=cc1:cc1+1
                 weight2=(1-abs(bn-dd1) );
                 out2(dd1+1)=out2(dd1+1)+weight2.*w_loc;
         end
    end
end

out=out2(1:number_of_bins);
out(1)=out(1)+out2(1+number_of_bins);

