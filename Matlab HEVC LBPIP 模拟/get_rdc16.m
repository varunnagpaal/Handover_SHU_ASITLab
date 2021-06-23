% HEVC ��׼��������һ���飬�Ƚϵ�ǰ����û��ǵײ���ã����ؽ�С�� rdcost
% ���ݱȽϽ�����£��򱣳֣��ֿ�/ģʽ��¼
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
        % mode_frame ���ֲ���
        % split_frame ���ֲ���
    end
end
