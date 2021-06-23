% 新分块方法下，使用换装方法预测一个块
% 根据模式，有可能出现前一半环参考像素并非全可用的状况，所以前半后半需要分开考虑
function [prederr_blk_loop, pred_blk_loop, mode_blk_loop, reuse_out] = mode_select_loop_np(Seq, Seq_r, i, j, PU, mask, reuse_in, rb_loop_reuse)
    % 前一半环 1111 1110 模式的结果是一样的，可以保留 1111 的计算结果复用（1111模式最先算），节省运算时间
    if (mask == 1110)
        prederr_blk_loop = reuse_in.prederr_blk_loop;
        pred_blk_loop = reuse_in.pred_blk_loop;
        mode_blk_loop = reuse_in.mode_blk_loop;
        reuse_out = reuse_in;
    else
        Seq_r_for_pre_half = Seq_r;
        for k = PU:-1:(PU / 2 + 1)
            [prederr_loop, pred_loop, ~, mode_loop] = select_single_loop_np(Seq, Seq_r_for_pre_half, i, j, k, PU, mask);

            [Seq_r_for_pre_half] = get_rebuild_loop_np(prederr_loop, pred_loop, i, j, k, PU, Seq_r_for_pre_half, mask);

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
        % 前一半环 1111 1110 模式的结果是一样的，可以保留 1111 的计算结果复用，节省运算时间
        if (mask == 1111)
            reuse_out.prederr_blk_loop = prederr_blk_loop;
            reuse_out.pred_blk_loop = pred_blk_loop;
            reuse_out.mode_blk_loop = mode_blk_loop;
        else
            reuse_out = reuse_in;
        end
    end

    % 后一半环直接使用底层右下角块的计算结果
    prederr_blk_loop(PU / 2 + 1:PU, PU / 2 + 1:PU) = rb_loop_reuse.prederr_blk_loop;
    pred_blk_loop(PU / 2 + 1:PU, PU / 2 + 1:PU) = rb_loop_reuse.pred_blk_loop;
    mode_blk_loop(PU / 2 + 1:PU, PU / 2 + 1:PU) = rb_loop_reuse.mode_blk_loop;
    % 后一半环没有需要特殊处理的地方
    % 1110 模式下不需要计算后一半环
    % if (mask ~= 1110)
    %     for k = (PU / 2):-1:4
    %         [prederr_loop, pred_loop, ~, mode_loop] = select_single_loop(Seq, Seq_r, i, j, k, PU);

    %         [Seq_r] = get_rebuild_loop(prederr_loop, pred_loop, i, j, k, PU, Seq_r);

    %         cnt = PU - k;
    %         prederr_blk_loop(1 + cnt, 1 + cnt) = prederr_loop(k);
    %         prederr_blk_loop(1 + cnt, 2 + cnt:PU) = prederr_loop(k + 1:end);
    %         prederr_blk_loop(2 + cnt:PU, 1 + cnt) = prederr_loop(k - 1:-1:1);
    %         pred_blk_loop(1 + cnt, 1 + cnt) = pred_loop(k);
    %         pred_blk_loop(1 + cnt, 2 + cnt:PU) = pred_loop(k + 1:end);
    %         pred_blk_loop(2 + cnt:PU, 1 + cnt) = pred_loop(k - 1:-1:1);
    %         mode_blk_loop(1 + cnt, 1 + cnt) = mode_loop;
    %         mode_blk_loop(1 + cnt, 2 + cnt:PU) = mode_loop;
    %         mode_blk_loop(2 + cnt:PU, 1 + cnt) = mode_loop;
    %     end

    %     [prederr_3, pred_3, ~, mode_3] = mode_select_blk(Seq, Seq_r, i + PU - 3, j + PU - 3, 3);
    %     prederr_blk_loop(PU - 2:PU, PU - 2:PU) = prederr_3;
    %     pred_blk_loop(PU - 2:PU, PU - 2:PU) = pred_3;
    %     mode_blk_loop(PU - 2:PU, PU - 2:PU) = mode_3;
    % end
end
