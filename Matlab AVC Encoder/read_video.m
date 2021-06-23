

videoObj = VideoReader('ant_maze.avi');

plot_flag=0;
nFrames = videoObj.NumberOfFrames;
vidHeight = videoObj.Height;
vidWidth = videoObj.Width;
T_frames=nFrames-1;

% Preallocate movie structure.
mov(1:nFrames) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),'colormap', []);

% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(videoObj, k);
    
    %plot the frame
    if(plot_flag==1)
        imshow(mov(k).cdata);
    end
    
    %create the file name
    j=k-1; 
    prefix='ant_maze\';suffix='.png';
    file=[prefix,num2str(j),suffix];
    
    % Create Folder if already not present
    f1=fullfile('ant_maze'); % Name of Folder
    if (exist(f1) == 0) % Chk already Present
        mkdir (f1);        % Create if already not present 
    end
    
    %Save the image file for each frame
    imwrite(mov(k).cdata,file,'PNG'); 
end

% Size a figure based on the video's width and height.
hf = figure;
set(hf, 'position', [150 150 vidWidth vidHeight])

% Play back the movie once at the video's frame rate.
movie(hf, mov, 1, videoObj.FrameRate);


