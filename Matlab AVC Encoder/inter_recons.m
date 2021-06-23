%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This Function INTER_RECONS preforms the Inter Prediction/ReConstruction, %
% also known as Temporal Predictiion, in image "im_new"'s current block,  %
%(i,j)of size N. It adds the motion vector the the image and reconstructs %
%the new image.                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rim_inter]=inter_recons(im_old,motion,pred_err,i,j,N)

    rows=i;cols=j;
    N2=2*N;
    
    %take motion vector information
    x1 = motion(1); y1 = motion(2); % take correspionding motion vector
    
    %Reconstructed Image (old image moved by motion vector+ prediction error given)
    recons(1:N,1:N) = im_old(rows+N+y1:rows+y1+N2-1,cols+N+x1:cols+x1+N2-1)+ pred_err(1:N,1:N);
    
    rim_inter=uint8(recons);
end
