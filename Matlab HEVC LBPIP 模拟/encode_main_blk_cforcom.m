% HEVC 标准方法 编码单帧
% 编码结果体积 size_all
% 各大小块统计 blk_size_sum
% 分块情况 split_frame
% 模式情况 mode_frame
% 每个 CTU 的体积 CTU_bits
function [size_all, blk_size_sum, split_frame, mode_frame, CTU_bits] = encode_main_blk(srcy)
    initGlobals(100);

    [CTU, img_src] = split_CTU(srcy);
    [h, w] = size(srcy);
    % +64, 方便最右/下侧 CTU 确定参考像素
    img_rebuild = nan(h + 64, w + 64);
    split_frame = nan(h, w);
    mode_frame = nan(h, w);

    % for i = 1:numel(CTU)
    for i = 1:3
        i
        [CTU_bits(i), img_rebuild, split_frame, mode_frame] = encode_CTU(CTU(i), img_src, img_rebuild, split_frame, mode_frame);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame);
end
