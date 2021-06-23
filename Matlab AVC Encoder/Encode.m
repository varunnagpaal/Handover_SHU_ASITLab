%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function does the H.264/AVC encoding function. 
function [Side_Info, blk_im]=Encode(Side_Info,im_old, im_new,recons_im,i,j,rblk, cblk,N)

[H,W]=size(recons_im);
err_lt=12;
%initialisation for Temporal Prediction
W=2*N; % width of search window
%Replicate the image along borders to be used for inter Prediction
im_old1 = double(padarray(im_old,[W/2 W/2],'replicate'));
im_new1 = double(padarray(im_new,[W/2 W/2],'replicate'));


    [motion,pred_err]=inter_cons(im_old1,im_new1,i,j,N);  % Call Inter Prediction function for the block
            
    [rim_inter]=inter_recons(im_old1,motion,pred_err,i,j,N); %inter prediction Reconstruction
            
    err_tp=mean2(rim_inter-im_new(i:i+N-1,j:j+N-1)) ;%Inter Error Calculation
    if err_tp<=err_lt
        %do Inter prediction itself
        Side_Info(rblk,cblk).prediction='Inter';
        Side_Info(rblk,cblk).Block_Size=N;
        Side_Info(rblk,cblk).motion=motion;
        Side_Info(rblk,cblk).pred_err=pred_err;
        blk_im=rim_inter;
                
    elseif (i>=N && j>=N && i<(H-2*N) && j<(W-2*N))
        %Try Intra Prediction itself
        %Intra Prediction
        %[sp_image,sp_mode]=sp_cons(im_new1,i,j,N);
        [intra_image,intra_mode,blk_size]=intra_cons(im_new1,i,j,N);
        % Intra Reconstruction
        rim_intra=intra_recons(recons_im,intra_mode,i,j,blk_size); %change pred_im_tp to reconstructed Image
        %Intra Error Calculation
        err_sp=mean2(im_new(i:i+N-1,j:j+N-1)-rim_intra);
            
        % Chk Error Limit
        if err_sp<=err_lt
            % Do intra Prediction Itself
            Side_Info(rblk,cblk).prediction='Intra';
            Side_Info(rblk,cblk).Block_Size=N;
            Side_Info(rblk,cblk).Mode=intra_mode;
            blk_im=intra_image;
        else
            % Send Data Directly - IPCM
            Side_Info(rblk,cblk).prediction='IPCM';
            Side_Info(rblk,cblk).Block_Size=N;
            Side_Info(rblk,cblk).Data=im_new(i:i+N-1,j:j+N-1);
            blk_im=im_new(i:i+N-1,j:j+N-1);
        end
    else
        % Send Data Directly - IPCM
        Side_Info(rblk,cblk).prediction='IPCM';
        Side_Info(rblk,cblk).Block_Size=N;
        Side_Info(rblk,cblk).Data=im_new(i:i+N-1,j:j+N-1);
        blk_im=im_new(i:i+N-1,j:j+N-1);
    end
    
end

    
