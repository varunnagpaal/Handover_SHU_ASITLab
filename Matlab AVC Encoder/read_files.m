%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function read_files read image files of continous frams saved as png%
%in the ant_maze folder. It also does the RGB to YUV conversion. the      %
%Output of the fuction is the background image and images of all frames   %
%No of Frames to be scanned is given by 'nframes'.                        %
%                                                                         %
%Example                                                                  %
%[im_grey_bk,im_grey]=read_files(20);                                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [im_grey]=read_files(varargin)

nargs = length(varargin);
if nargs==1
    nframes=varargin{1};
    vid_name='ant_maze';
elseif nargs==2
    nframes=varargin{1};
    vid_name=varargin{2};
end



%Read Images
for i=1:nframes
    %Deduce the File Name
    j=i-1; 
    suffix='.png';
    file=[vid_name,'/',num2str(j),suffix];
    
    a(:,:,:,i)=imread(file);        %Read Image
    YUV=rgb2yuv(a(:,:,:,i),0);      %Convert into YUV
    im_grey(:,:,i)=YUV(:,:,1);      
end

end


