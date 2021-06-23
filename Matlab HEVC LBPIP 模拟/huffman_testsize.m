% 计算 huffman 编码 array 需要的 bits
% 使用的码表和 initGlobal 有关，测试中用 Q=100 对应的表
function size = huffman_testsize(array)
    bufferPutBuffer_test = 0;
    bufferPutBits_test = 0;

    ACcode = 1;
    size = 0;

    global AC_matrix;

    r = 0;

    arrcnt = numel(array);
    for k = 1:arrcnt
        temp = array(k);
        if temp == 0
            r = r + 1;
        else
            while r > 15
                size = size + bufferIt(AC_matrix(ACcode, hex2dec('F0') + 1, 1), AC_matrix(ACcode, hex2dec('F0') + 1, 2));
                r = r - 16;
            end
            temp2 = temp;
            if temp < 0
                temp = -temp;
                temp2 = temp2 - 1;
            end
            nbits = 1;
            temp = bitshift(temp, -1);
            while temp ~= 0
                nbits = nbits + 1;
                temp = bitshift(temp, -1);
            end
            i = bitshift(r, 4) + nbits;
            size = size + bufferIt(AC_matrix(ACcode, i + 1, 1), AC_matrix(ACcode, i + 1, 2));
            size = size + bufferIt(temp2, nbits);

            r = 0;
        end
    end

    if r > 0
        size = size + bufferIt(AC_matrix(ACcode, 1, 1), AC_matrix(ACcode, 1, 2));
    end

    size = size * 8 + bufferPutBits_test;

    function l = bufferIt(code, sym_size)
        l = 0;

        if code < 0
            code = (2^32) + code;
        end
        PutBuffer = code;
        PutBits = bufferPutBits_test;

        t = bitshift(1, sym_size) - 1;

        PutBuffer = bitand(PutBuffer, t);
        PutBits = PutBits + sym_size;
        PutBuffer = bitshift(PutBuffer, 24 - PutBits);
        PutBuffer = bitor(PutBuffer, bufferPutBuffer_test);

        while PutBits >= 8
            c = bitand(bitshift(PutBuffer, -16), hex2dec('FF'));
            l = l + 1;

            if c == hex2dec('FF')
                l = l + 1;
            end
            %         PutBuffer = bitshift(PutBuffer, 8);
            PutBuffer = bitand(bitshift(1, 24) - 1, bitshift(PutBuffer, 8));

            PutBits = PutBits - 8;
        end
        bufferPutBuffer_test = PutBuffer;
        bufferPutBits_test = PutBits;
    end
end
