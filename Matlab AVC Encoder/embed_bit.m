function em_data=embed_bit(Data,txt,bit)

N = 8*numel(txt);
S = numel(Data);
addl = S-N;
dim = size(Data);
if N > S*bit
    error('Text Longer than Data Size');
end

data_lin = reshape(Data,1,S);
Data_lin=data_lin(1:N/bit);

for bitplane=1:bit
p = 2^bitplane;h = 2^(bitplane-1);
%Data_lin = reshape(Data,1,S);
%si = sign(Data_lin(1:N));

for k = 1:N/bit
   % if si(k) == 0
   %     si(k) = 1;
   % end
    if mod((Data_lin(k)),p) >= h
        Data_lin(k) = Data_lin(k) - h;
    end
end

% convert TXT to Bin array
l=N/(8*bit);
t=txt(((bitplane-1)*l)+1:bitplane*l);
bt = dec2bin(t,8); % Txt to Bin
bint = reshape(bt,1,N/bit); % To Array
d = h*48;
bi = (h*bint) - d; % For each element

% Data Hide By Adding Image with TXT binary
binadd = [bi zeros(1,addl)]; 
%Data_adj = double(si).*double(Data_lin);
Emb_I(bitplane,:) = uint8(double(Data_lin) + binadd);
Data_lin=Emb_I(bitplane,:);
end


em_data = reshape(Emb_I(bit,:),dim);

end

