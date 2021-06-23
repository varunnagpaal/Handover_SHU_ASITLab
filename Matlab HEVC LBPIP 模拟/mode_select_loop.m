% 环状编码一个块，做到 4x4 为止
% 最后 4x4 用 HEVC 方法完成
function [prederr_blk_loop, pred_blk_loop, mode_blk_loop] = mode_select_loop(Seq, Seq_r, i, j, PU)
    for k = PU:-1:5
        [prederr_loop, pred_loop, ~, mode_loop] = select_single_loop(Seq, Seq_r, i, j, k, PU);

        [Seq_r] = get_rebuild_loop(prederr_loop, pred_loop, i, j, k, PU, Seq_r);

        cnt = PU - k;
        prederr_blk_loop(1 + cnt, 1 + cnt) = prederr_loop(k);
        prederr_blk_loop(1 + cnt, 2 + cnt:PU) = prederr_loop(k + 1:end);
        prederr_blk_loop(2 + cnt:PU, 1 + cnt) = prederr_loop(k - 1:-1:1);
        pred_blk_loop(1 + cnt, 1 + cnt) = pred_loop(k);
        pred_blk_loop(1 + cnt, 2 + cnt:PU) = pred_loop(k + 1:end);
        pred_blk_loop(2 + cnt:PU, 1 + cnt) = pred_loop(k - 1:-1:1);
        mode_blk_loop(1 + cnt, 1 + cnt) = mode_loop;
        mode_blk_loop(1 + cnt, 2 + cnt:PU) = mode_loop;
        mode_blk_loop(2 + cnt:PU, 1 + cnt) = mode_loop;
    end
    [prederr_4, pred_4, ~, mode_4] = mode_select_blk(Seq, Seq_r, i + PU - 4, j + PU - 4, 4);
    prederr_blk_loop(PU - 3:PU, PU - 3:PU) = prederr_4;
    pred_blk_loop(PU - 3:PU, PU - 3:PU) = pred_4;
    mode_blk_loop(PU - 3:PU, PU - 3:PU) = mode_4;
end
