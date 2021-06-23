%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This Function DECODE gets Encoded information from encoder, Side_Info, and%
%using the old image, decodes the image by H.264 Std. For the Current Block%
%specified by (i,j), based on the prediction mentioned in Side_info, the   %
%corresponding reconstruction is Done.                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function blk_im=decode(Side_Info,im_old,recons_im,i,j,rblk, cblk,N)


%initialisation for Temporal Prediction
W=2*N; % width of search window
%Replicate the image along borders to be used for inter Prediction
im_old1 = double(padarray(im_old,[W/2 W/2],'replicate'));
%im_new1 = double(padarray(im_new,[W/2 W/2],'replicate'));

    switch Side_Info(rblk,cblk).prediction 
        case 'Inter'
            motion=Side_Info(rblk,cblk).motion;
            pred_err=Side_Info(rblk,cblk).pred_err;
            
            [rim_inter]=inter_recons(im_old1,motion,pred_err,i,j,N);
            blk_im=rim_inter;        
        case 'Intra'
        
            intra_mode=Side_Info(rblk,cblk).Mode;
                % intra Reconstruction
            rim_intra=intra_recons(recons_im,intra_mode,i,j,N); %change pred_im_tp to reconstructed Image
            blk_im=rim_intra;  
        
        case 'IPCM'
            
            rim_ipcm=Side_Info(rblk,cblk).Data;
            blk_im=Side_Info(rblk,cblk).Data;
        otherwise
            error('Unknown Prediction Type');

    end
    
end

    
