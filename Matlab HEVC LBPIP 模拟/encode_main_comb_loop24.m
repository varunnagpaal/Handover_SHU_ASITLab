% 编码时分别计算一个块 块状方式 和 环状方式 的 rdcost，择优
% 环状方式一直做到 4x4
% 4x4 块固定用块状方式
function [size_all, blk_size_sum, split_frame, mode_frame, CTU_bits] = encode_main_comb_loop24(srcy)
    initGlobals(100);

    [CTU, img_src] = split_CTU(srcy);
    [h, w] = size(srcy);
    img_rebuild = nan(h + 64, w + 64);
    split_frame = nan(h, w);
    mode_frame = nan(h, w);

    for i = 1:numel(CTU)
        % for i = 1:2
        i
        [CTU_bits(i), img_rebuild, split_frame, mode_frame] = encode_CTU_comb(CTU(i), img_src, img_rebuild, split_frame, mode_frame);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame);
    % 该方法下需要 1bit/块 记录当前块用的是块状还是环状 （4x4 块除外）
    size_all = size_all + sum(blk_size_sum(2:end));
end
