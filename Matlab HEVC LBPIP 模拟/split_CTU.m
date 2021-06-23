% 切割 CTU 保存每个 CTU 的坐标
function [CTU, src_double] = split_CTU(srcy)
    [h, w] = size(srcy);

    cnt = 1;
    src_double = double(srcy);
    for i = 1:64:h
        for j = 1:64:w
            CTU(cnt).data = src_double(i:i + 63, j:j + 63);
            CTU(cnt).x = i;
            CTU(cnt).y = j;
            cnt = cnt + 1;
        end
    end
end
