% HEVC 标准方法编码一个 4*4 块，返回 rdcost
function [img_rebuild, split_frame, mode_frame, rdc] = get_rdc4(x, y, img_src, img_rebuild, split_frame, mode_frame)
    PU = 4; %4 8 16 32 64

    [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild, x, y, PU);
    img_rebuild(x:x + PU - 1, y:y + PU - 1) = prederr_blk + pred_blk;
    mode_frame = fill_blk(mode_frame, x, y, PU, mode_blk);

    mode_bits = get_mode_bits_blk(0, mode_frame, x, y);

    rdc = cal_rdc_blk(prederr_blk, mode_blk, mode_bits);

    split_frame(x:x + PU - 1, y:y + PU - 1) = 4;
end
