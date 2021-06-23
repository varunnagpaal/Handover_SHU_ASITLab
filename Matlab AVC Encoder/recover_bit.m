function [IM_Data,hid_data]=recover_bit(I,siz,bit)

bsiz = 8*siz/bit;
n = numel(I);
if bsiz > n
    error('Size of text given exceeds the maximum that can be embedded in the image');
end
dim = size(I);
I1 = reshape(I,1,n);
I2 = round(abs(I1(1:bsiz)));
dim1=size(I2);

for bitplane=1:bit
p = 2^bitplane;
h = 2^(bitplane-1);
rb = zeros(1,bsiz);

for k = 1:bsiz
    I2(k) = round(I2(k));
    r = rem(I2(k),p);
    if r >= h 
        rb(k) = 1;
    end
    
end
d = h*48;
bi = (h*rb);% - d; 
acdata=double(I2)-bi;

rbi = (dec2bin(rb,1))';
rbin = reshape(rbi,siz/bit,8);

txt = char((bin2dec(rbin))');
im_Data=reshape(acdata,dim1);

TexT(:,bitplane)=txt;
I2=im_Data;
end


IM_Data=reshape([I2 I1(bsiz+1:end)],dim);
hid_data=reshape(TexT,1,siz);

return