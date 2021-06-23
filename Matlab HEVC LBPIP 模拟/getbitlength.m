% 计算记录分块信息四叉树需要的 bits
function split_bit_len = getbitlength(s_mat)
    cnt4 = sum(sum(s_mat == 4)) / (4 * 4);
    cnt8 = sum(sum(s_mat == 8)) / (8 * 8);
    cnt16 = sum(sum(s_mat == 16)) / (16 * 16);
    cnt32 = sum(sum(s_mat == 32)) / (32 * 32);
    cnt64 = sum(sum(s_mat == 64)) / (64 * 64);

    cnt8 = cnt8 + cnt4 / 4;
    cnt16 = cnt16 + cnt8 / 4;
    cnt32 = cnt32 + cnt16 / 4;
    cnt64 = cnt64 + cnt32 / 4;

    %assert(cnt64 == 1)
    split_bit_len = cnt8 + cnt16 + cnt32 + cnt64;
end
