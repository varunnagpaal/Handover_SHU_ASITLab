% 环状预测一个块，环状做到 3x3
function [prederr_blk_loop, pred_blk_loop, mode_blk_loop] = mode_select_loop_loop23(Seq, Seq_r, i, j, PU)
    for k = PU:-1:4
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
    [prederr_3, pred_3, ~, mode_3] = mode_select_blk(Seq, Seq_r, i + PU - 3, j + PU - 3, 3);
    prederr_blk_loop(PU - 2:PU, PU - 2:PU) = prederr_3;
    pred_blk_loop(PU - 2:PU, PU - 2:PU) = pred_3;
    mode_blk_loop(PU - 2:PU, PU - 2:PU) = mode_3;
end
