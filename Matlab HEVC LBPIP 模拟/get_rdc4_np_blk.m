% 应用新分块方法编码一个 4x4 块
% 仅做块状
% 新分块方法在 4x4 层没有体现
function [img_rebuild, split_frame, mode_frame, rdc, rdc_res_part] = get_rdc4_np_blk(x, y, img_src, img_rebuild, split_frame, mode_frame)
    PU = 4; %4 8 16 32 64

    % blk 部分
    [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = prederr_blk + pred_blk;
    img_rebuild_temp_blk = prederr_blk + pred_blk;
    mode_frame_temp_blk = fill_blk(mode_frame, x, y, PU, mode_blk);
    mode_bits = get_mode_bits_blk_np(0, mode_frame_temp_blk, x, y, 1111, PU);
    [rdc_curr_temp_blk, res_part_blk] = cal_rdc_np(prederr_blk, mode_bits, 1:PU^2, 0, 0, 1111);
    % blk 部分

    rdc = rdc_curr_temp_blk;
    mode_frame = mode_frame_temp_blk;
    rdc_res_part = res_part_blk;

    split_frame(x:x + PU - 1, y:y + PU - 1) = PU;
    %assert(all(img_rebuild_temp_blk == img_rebuild_temp_loop, [1, 2]))
    img_rebuild(x:x + PU - 1, y:y + PU - 1) = img_rebuild_temp_blk;

end
