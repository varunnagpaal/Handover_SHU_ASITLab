function em_data=embed(Data,txt)

N = 8*numel(txt);
S = numel(Data);
addl = S-N;
dim = size(Data);
if N > S
    error('Text Longer than Data Size');
end
p = 2;h = 1;
Data_lin = reshape(Data,1,S);

for k = 1:N
    if mod((Data_lin(k)),p) >= h
        Data_lin(k) = Data_lin(k) - h;
    end
end

% convert TXT to Bin array
bt = dec2bin(txt,8); % Txt to Bin
bint = reshape(bt,1,N); % To Array
d = h*48;
bi = (h*bint) - d; % For each element

% Data Hide By Adding Image with TXT binary
binadd = [bi zeros(1,addl)]; 
Emb_I = uint8(double(Data_lin) + binadd);

em_data = reshape(Emb_I,dim);

end
