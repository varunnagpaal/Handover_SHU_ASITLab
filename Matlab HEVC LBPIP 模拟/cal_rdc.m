% 环状模式下计算当前块 rdcost
% 没有像 HEVC 一样考虑残差扫描顺序，直接使用 ↓↓↓ 的顺序扫描
function rdc = cal_rdc(res, mode_bits)
    res_order = res(:);
    res_bits = huffman_testsize(res_order);

    rdc = res_bits + mode_bits;
end
