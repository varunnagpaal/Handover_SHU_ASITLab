%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%THIS IS THE MAIN EXECUTABLE FILE%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This m file does both Encoding and decoding by H.264/AVC standard. First%
% a video is read. Played to the user and then saved as images. then one  %
% of the image is read. Then for variable Block sizing, it is divided into%
% 16x16 blcks.The standard deviation within each blck is calculated.If it %
% is more than limit,it means more deviation within block hence reduce the%
% block size to 8x8. If deviation is more here also, then block size is   %
% reduced to 4x4. In any of the block Size, a dunction Prediction is called
% which does the Intra/Inter/IPCM prediction based on the error values. The
% parameter Side_Info has all the necessary information. It is passed to  %
% Decoder Side. Based on the block Size, the corresponding reconstruction %
% function is called.                                                     %
% The program also calculates the robustnes of the data hiding and also   %
% the capacity of data can be hidden in the image                         %
% Graph plots the Original image with block seperation and the decoded    %
% image also.                                                             %
%                                                                         %
% This file is an attempt to the implementation of the paper:             %
%Real time data hiding by exploiting the IPCM macroblocks in H.264/AVC    %
%streams by Spyridon K. Kapotas∆ Athanassios N. Skodras, J Real-Time Image%
%Proc., DOI 10.1007/s11554-008-0100-2                                     %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

sd_plot = 0; % parameter to plot Deviation & block Size plot or not Value of 1 will plot

read_video(); %Reads the video and stores it as a image files in a folder
[im_grey] = read_files(2); % Read Files

N = 16; %block size NxN
min_N = 4; %minimum Block Size
[rows, cols] = size(im_grey(:, :, 1));

if mod(rows, N) ~= 0
    Height = floor(rows / N) * N; % cut off the extra rows if not divisible by N
else
    Height = rows; % else keep as it is
end
if mod(cols, N) ~= 0
    Width = floor(cols / N) * N; % cut off the extra cols if not divisible by N
else
    Width = cols; % else Keep as it is
end

im_new = im_grey(:, :, 2); im_old = im_grey(:, :, 1);
recons_im = uint8(zeros(Height, Width)); %initialize Reconstructed image

%figure();imshow(im_new);hold on;
if sd_plot == 1
    figure();
    imshow(uint8(im_new)); hold on; title('Block Size and Deviation');
end

%Initialisation
for i = 1:min_N:Height
    for j = 1:min_N:Width
        sd(i, j) = 0;
        Side_Info(i, j).info = 'H.264';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ENCODER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:N:Height
    for j = 1:N:Width

        rblk = ceil(i / min_N); cblk = ceil(j / min_N); % Block no calc
        sd(rblk, cblk) = std2(im_new(i:i + N - 1, j:j + N - 1)); % Std Dev calc

        if sd(rblk, cblk) < 10% Compare Std Dev
            %%%%%%%%%%%%%%%%%%%%%%%%% 16x16 block%%%%%%%%%%%%%%%%%%%%%%%%%%
            [Side_Info, blk_im] = Encode(Side_Info, im_old, im_new, recons_im, i, j, rblk, cblk, N); % Encode for 16x16 block size
            recons_im(i:i + N - 1, j:j + N - 1) = blk_im; %Store Image

            if sd_plot == 1%for standard deviation plot
                rectangle('position', [j i N N]); %Plot Rectangle of 16x16
                text((j + N / 2), (i + N / 2), num2str(uint8(sd(rblk, cblk))), 'fontsize', 6); % Write Std Dev value in the rectangle
                hold on;
            end

        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 8x8 Block%%%%%%%%%%%%%%%%%%%%%%%
            N = N / 2;

            for k = 0:N:2 * N - 1% for 4 different blocks  of Blk Size 8
                for l = 0:N:2 * N - 1
                    ii = i + k; jj = j + l;
                    rblk = ceil(ii / min_N); cblk = ceil(jj / min_N); % New Block Number
                    sd(rblk, cblk) = std2(im_new(ii:ii + N - 1, jj:jj + N - 1)); %Std Dev Calc

                    if sd(rblk, cblk) < 10%Compare Std Dev
                        [Side_Info, blk_im] = Encode(Side_Info, im_old, im_new, recons_im, ii, jj, rblk, cblk, N); % Encode for 8x8
                        recons_im(ii:ii + N - 1, jj:jj + N - 1) = blk_im; %Store Image
                        if sd_plot == 1%for standard deviation plot
                            rectangle('position', [jj ii N N]); %Plot Rectangle of Size 8x8
                            text((jj + N / 2), (ii + N / 2), num2str(uint8(sd(rblk, cblk))), 'fontsize', 4); % Write Std Dev value in the rectangle
                            hold on;
                        end
                    else
                        %%%%%%%%%%%%%%%%%%%%%4x4 block %%%%%%%%%%%%%%%%%%%%

                        N = N / 2;
                        for m = 0:N:2 * N - 1% for 4 different blocks of blk size 4
                            for n = 0:N:2 * N - 1
                                iii = ii + m; jjj = jj + n;
                                rblk = ceil(iii / min_N); cblk = ceil(jjj / min_N); % New Block Numbers
                                sd(rblk, cblk) = std2(im_new(iii:iii + N - 1, jjj:jjj + N - 1)); % Std Dev calc

                                [Side_Info, blk_im] = Encode(Side_Info, im_old, im_new, recons_im, iii, jjj, rblk, cblk, N); % Encode for 4x4 block
                                recons_im(iii:iii + N - 1, jjj:jjj + N - 1) = blk_im; % Store Image

                                if sd_plot == 1%for standard deviation plot
                                    rectangle('position', [jjj iii N N]); % Draw Recatngle of 4x4 size
                                    text((jjj + N / 2), (iii + N / 2), num2str(uint8(sd(rblk, cblk))), 'fontsize', 3); % Write std dev in the rectangle
                                    hold on;
                                end
                            end
                        end
                        % Old N & Old Block Nos.
                        N = 2 * N;
                        rblk = ceil(ii / N); cblk = ceil(jj / N);

                    end

                end
            end
            % Old N & Old Block Nos.
            N = 2 * N;
            rblk = ceil(i / N); cblk = ceil(j / N);

        end
    end
end

if sd_plot == 1
    hold off;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% CAPACITY ESTIMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for Y Frame
bin_bits = Height * Width;
Ascii_bits_Y = bin_bits / 8;

%for U Frame
bin_bits = Height * Width / 2;
Ascii_bits_U = bin_bits / 8;

%for V Frame
bin_bits = Height * Width / 2;
Ascii_bits_V = bin_bits / 8;

Ascii_bits = Ascii_bits_Y + Ascii_bits_U + Ascii_bits_V;
Capacity_I = Ascii_bits * 1; % for I frame
Capacity_P = Ascii_bits * 0.50; % for P frame
Capacity_B = Ascii_bits * 0.25; % for B frame

disp(['No of Charecters(8 bit length) that can be hidden in one I frame : ' int2str(Capacity_I)]);
disp(['No of Charecters(8 bit length) that can be hidden in one P frame : ' int2str(Capacity_P)]);
disp(['No of Charecters(8 bit length) that can be hidden in one B frame : ' int2str(Capacity_B)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODE DESICION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('MODE DESICION STARTS');
Embed_txt = 'Successfully completed the Data Hiding '; % Data to be hidden
leng = numel(Embed_txt); % Length of Data
hide_no = floor((Height * Width / 16^2) / (leng * 8/256)); % Calc no of pixels req for the data to be hidden
ipcm_cnt = 0; ipcm_noncnt = 0; ipcm_add = 0; %Initialisation

for i = 1:N:Height
    for j = 1:N:Width
        rblk = ceil(i / min_N); cblk = ceil(j / min_N); % Bock no calc
        N = Side_Info(rblk, cblk).Block_Size; % Blk size calc
        if strcmp(Side_Info(rblk, cblk).prediction, 'IPCM') == 1
            ipcm_cnt = ipcm_cnt + 1; % Count Total No of IPCM Blocks already Present
        end
    end
end

if ipcm_cnt < hide_no% if more IPCM blocks to be created
    for i = 1:N:Height
        for j = 1:N:Width
            rblk = ceil(i / min_N); cblk = ceil(j / min_N); % Block no calc
            N = Side_Info(rblk, cblk).Block_Size; % Blk size calc

            if strcmp(Side_Info(rblk, cblk).prediction, 'IPCM') ~= 1% Take up non-IPCM Blocks
                if ipcm_noncnt >= hide_no
                    ipcm_noncnt = 0;
                end
                if ipcm_noncnt == 0% Convert one block into IPCM for every 'hide_no' of blocks
                    Side_Info(rblk, cblk).info = 'H.264';
                    Side_Info(rblk, cblk).prediction = 'IPCM'; % Change Side Info_Prediction
                    blk_size = Side_Info(rblk, cblk).Block_Size;
                    Side_Info(rblk, cblk).Data = im_new(i:i + blk_size - 1, j:j + blk_size - 1); % Change Data
                    ipcm_add = ipcm_add + 1; % Recount No of IPCM Blocks
                end
                ipcm_noncnt = ipcm_noncnt + 1; %Count no of non-ipcm blocks

            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%IPCM DATA EMBEDDING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('DATA HIDING IN IPCM BLOCK ALONE');
remain_len = numel(Embed_txt); % Rength of text
txt_cnt = 0; ipcm_cnt = 0;
for i = 1:min_N:Height
    for j = 1:min_N:Width
        rblk = ceil(i / min_N); cblk = ceil(j / min_N); % Block No Calc
        if (strcmp(Side_Info(rblk, cblk).prediction, 'IPCM') == 1) && (Side_Info(rblk, cblk).Block_Size == 16)% Take up only IPCM blocks
            ipcm_cnt = ipcm_cnt + 1;
            len = Side_Info(rblk, cblk).Block_Size * Side_Info(rblk, cblk).Block_Size / 8; % Calc Length of data that can be hidden
            if (remain_len >= len)
                em_data = embed(Side_Info(rblk, cblk).Data, Embed_txt(txt_cnt + 1:txt_cnt + len)); % Call Embed func to hide data
                txt_cnt = txt_cnt + len;
                %Change parameters in Side_Info
                Side_Info(rblk, cblk).Data_Embd = 'YES';
                Side_Info(rblk, cblk).EM_Data = em_data;
                Side_Info(rblk, cblk).Hid_Size = len;
                remain_len = remain_len - len;
            else
                % If length of data hidden is to be less than length of image
                em_data = embed(Side_Info(rblk, cblk).Data, Embed_txt(txt_cnt + 1:txt_cnt + remain_len)); % Call Embed func with diff size
                txt_cnt = txt_cnt + remain_len;
                % Cange parameters in Side_Info
                Side_Info(rblk, cblk).Data_Embd = 'YES';
                Side_Info(rblk, cblk).EM_Data = em_data;
                Side_Info(rblk, cblk).Hid_Size = remain_len;
                remain_len = 0;
            end
        else
            Side_Info(rblk, cblk).Data_Embd = 'NO';

        end
    end
end

disp('DATA HIDING DONE');
%%% ENCODER OVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% TRANSMISSION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DECODER STARTS %%%%%%
disp('TRANSMISSION with Data Corruption');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%ROBUSTNESS CALCULATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add Gaussian noise as a part of communication Transmission
mean = 0;
var = .99E-6;
% If the variance is above 10^-6, then it is seen that the embedded data is
% getting corrupted.
k = 1;
for i = 1:min_N:Height
    for j = 1:min_N:Width
        rblk = ceil(i / min_N); cblk = ceil(j / min_N);
        if (strcmp(Side_Info(rblk, cblk).prediction, 'IPCM') == 1) && (strcmp(Side_Info(rblk, cblk).Data_Embd, 'YES') == 1)
            % add noise using imnoise function to EM_Data
            Side_Info(rblk, cblk).EM_Data_n = imnoise(Side_Info(rblk, cblk).EM_Data, 'gaussian', mean, var);
            psnr_im(k) = psnr(Side_Info(rblk, cblk).EM_Data, Side_Info(rblk, cblk).EM_Data_n);
            k = k + 1;
        end
    end
end

disp(['Max Noise that can be added w/o corrupting hidden data in terms of PSNR (db): ' num2str(max(psnr_im))]);
disp('RECEIVED');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%IPCM DATA RETRIEVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('HIDDEN DATA REMOVAL');
Recovered_Txt = '';
for i = 1:min_N:Height
    for j = 1:min_N:Width
        rblk = ceil(i / min_N); cblk = ceil(j / min_N);
        if (strcmp(Side_Info(rblk, cblk).prediction, 'IPCM') == 1) && (strcmp(Side_Info(rblk, cblk).Data_Embd, 'YES') == 1)
            em_data = Side_Info(rblk, cblk).EM_Data;
            siz = Side_Info(rblk, cblk).Hid_Size;
            [im_Data, txt] = recover(em_data, siz);
            Recovered_Txt = [Recovered_Txt txt];
        end
    end
end
disp('EMBEDDED DATA RETREIVED');
disp(['DATA RETRIEVED IS: ' Recovered_Txt]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DECODER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 16x16 Block %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 16;
for i = 1:N:Height
    for j = 1:N:Width
        rblk = ceil(i / min_N); cblk = ceil(j / min_N); % Block Numbers
        if Side_Info(rblk, cblk).Block_Size == N
            [blk_im] = decode(Side_Info, im_old, recons_im, i, j, rblk, cblk, N); % Do Decoding
            decoded_im(i:i + N - 1, j:j + N - 1) = blk_im; % Store Image
            clear blk_im;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 8x8 Block %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 8;
for i = 1:N:Height
    for j = 1:N:Width
        rblk = ceil(i / min_N); cblk = ceil(j / min_N); % Block Numbers
        if Side_Info(rblk, cblk).Block_Size == N
            [blk_im] = decode(Side_Info, im_old, recons_im, i, j, rblk, cblk, N); % Do Decoding
            decoded_im(i:i + N - 1, j:j + N - 1) = blk_im; % Store Image
            clear blk_im;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4x4 Block %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 4;
for i = 1:N:Height
    for j = 1:N:Width
        rblk = ceil(i / min_N); cblk = ceil(j / min_N); % Block Numbers
        if Side_Info(rblk, cblk).Block_Size == N
            [blk_im] = decode(Side_Info, im_old, recons_im, i, j, rblk, cblk, N); % Do Decoding
            decoded_im(i:i + N - 1, j:j + N - 1) = blk_im; % Store Image
            clear blk_im;
        end
    end
end

figure();
imshow(uint8(decoded_im)); title('Output of Decoder');
