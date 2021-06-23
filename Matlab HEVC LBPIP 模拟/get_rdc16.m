% HEVC 标准方法编码一个块，比较当前层更好还是底层更好，返回较小的 rdcost
% 根据比较结果更新（或保持）分块/模式记录
function [img_rebuild, split_frame, mode_frame, rdc] = get_rdc16(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_deep_layer, rdc_ind)
    PU = 16; %4 8 16 32 64

    [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = prederr_blk + pred_blk;
    mode_frame_temp = fill_blk(mode_frame, x, y, PU, mode_blk);

    mode_bits = get_mode_bits_blk(0, mode_frame_temp, x, y);

    rdc_curr = cal_rdc_blk(prederr_blk, mode_blk, mode_bits);
    rdc_deep = sum(rdc_deep_layer(rdc_ind * 4 - 3:rdc_ind * 4));

    if (rdc_curr < rdc_deep)
        rdc = rdc_curr;
        mode_frame = mode_frame_temp;
        split_frame = fill_blk(split_frame, x, y, PU, PU);
    else
        rdc = rdc_deep;
        % mode_frame 保持不变
        % split_frame 保持不变
    end
end
