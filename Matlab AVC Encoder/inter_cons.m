%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This Function INTER_CONS preforms the Inter Prediction/Construction, also%
%known as Temporal Predictiion, in image "im_new"'s current block,(i,j) of%
%size N. The function calculated the motion vector for the specified block%
%The search window is 2*N. It motion vector points the block displayed    %
% which has the less SAD. Prediction error is calclated by the difference %
% of the original image and the image poited by the motion vector         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [motion,pred_err]=inter_cons(im_old,im_new,i,j,N)


rows=i+N-1;cols=j+N-1; % incrementing N coz of image increase due to replication


    SAD = 1.0e+10;% initial Cumulative Absolute Difference(CAD)
    for u = -N:N
        for v = -N:N
            sad = im_new(rows+1:rows+N,cols+1:cols+N)-im_old(rows+u+1:rows+u+N,cols+v+1:cols+v+N); %difference
            sad = sum(abs(sad(:)));% SAD between pixels
            if sad < SAD            %min SAD
                SAD=sad;
                %Motion Vectors are positions in block, in which SAD is minimum
                x= v; y = u; %Motion Vectors
            end
        end
    end

    motion=[x y];

    %Predicted frame from Motion Vector
    pred_im(1:N,1:N)=im_old(rows+y+1:rows+y+N,cols+x+1:cols+x+N);
    
    % Predicted Error Frame (Predicted Image- actual image)
    pred_err(1:N,1:N) = im_new(rows:rows+N-1,cols:cols+N-1)-pred_im(1:N,1:N);
    
end