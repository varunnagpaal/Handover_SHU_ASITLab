function [im_Data,txt]=recover(em_data,siz)

b = 1;
bsize = 8*siz;
n = numel(em_data);
dim = size(em_data);
%addl = n-bsize;

em_data1 = reshape(em_data,1,n);
em_data2 = round(abs(em_data1(1:n)));
p = 2;h = 1;
txt_bin = zeros(1,n);

ac_data=zeros(n,1);

for k = 1:n
    r = rem(em_data2(k),p);
    if r >= h 
        txt_bin(k) = 1;
    end
    acdata(k)=em_data2(k)-txt_bin(k);
end
txt_lin = (dec2bin(txt_bin(1:bsize),1))';
rbin = reshape(txt_lin,siz,8);
txt = char((bin2dec(rbin))');

im_Data=reshape(acdata,dim);

end