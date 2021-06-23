% 新分块方法下，除了 1110 模式，其他模式的环状预测模式信息数量要多一些
% function loop_mode_bits = cal_loop_mode_bits(mode_blk_loop)
function mode_bits_loop = cal_loop_mode_bits_np(mode_blk_loop, mode_frame_temp, i, j, mask)
    [PU, ~] = size(mode_blk_loop);
    switch mask
        case 1110
            mode_1d = mode_blk_loop(1:PU / 2, PU) - 1;
        otherwise
            mode_1d = mode_blk_loop(1:PU - 2, PU) - 1;
    end

    % if (i > 1 && j > 1)
    %     pre_loop_mode = mode_frame_temp(i - 1, j - 1);
    % if (j > 1)
    %     pre_loop_mode = mode_frame_temp(i, j - 1);
    if (i > 1)
        pre_loop_mode = mode_frame_temp(i - 1, j) - 1;
    else
        pre_loop_mode = 0;
    end

    mode_1d_diff = diff([pre_loop_mode, mode_1d']);
    mode_bits_loop = huffman_testsize(mode_1d_diff);
end
