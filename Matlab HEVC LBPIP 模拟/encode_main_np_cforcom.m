% 应用新分块方法 + 环状预测（环状做到 3x3）的测试入口
% 新分块方法：顶层搜索时允许保留 1/4 底层结果的分块方法
% 1111: 不保留底层结果
% 0111: 保留左上角底层结果
% 1011: 保留右上角
% 1101: 保留左下角
% 1110: 右下角
function [size_all, blk_size_sum, split_frame, mode_frame, loop_flag_frame_np, CTU_bits, CTU_split_tree_bits, type_cnt] = encode_main_np(srcy)
    initGlobals(100);

    [CTU, img_src] = split_CTU(srcy);
    [h, w] = size(srcy);
    img_rebuild = nan(h + 64, w + 64);
    split_frame = nan(h, w);
    mode_frame = nan(h, w);
    loop_flag_frame_np = nan(h, w);

    % for i = 1:numel(CTU)
    for i = 1:3
        i
        [CTU_bits(i), CTU_split_tree_bits(i), type_cnt{i}, img_rebuild, split_frame, mode_frame, loop_flag_frame_np] = encode_CTU_np(CTU(i), img_src, img_rebuild, split_frame, mode_frame, loop_flag_frame_np);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame);
end
