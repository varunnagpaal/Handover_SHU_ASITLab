% �·ֿ鷽���£�ʹ�û�װ����Ԥ��һ����
% ����ģʽ���п��ܳ���ǰһ�뻷�ο����ز���ȫ���õ�״��������ǰ������Ҫ�ֿ�����
function [prederr_blk_loop, pred_blk_loop, mode_blk_loop, reuse_out] = mode_select_loop_np(Seq, Seq_r, i, j, PU, mask, reuse_in, rb_loop_reuse)
    % ǰһ�뻷 1111 1110 ģʽ�Ľ����һ���ģ����Ա��� 1111 �ļ��������ã�1111ģʽ�����㣩����ʡ����ʱ��
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
        % ǰһ�뻷 1111 1110 ģʽ�Ľ����һ���ģ����Ա��� 1111 �ļ��������ã���ʡ����ʱ��
        if (mask == 1111)
            reuse_out.prederr_blk_loop = prederr_blk_loop;
            reuse_out.pred_blk_loop = pred_blk_loop;
            reuse_out.mode_blk_loop = mode_blk_loop;
        else
            reuse_out = reuse_in;
        end
    end

    % ��һ�뻷ֱ��ʹ�õײ����½ǿ�ļ�����
    prederr_blk_loop(PU / 2 + 1:PU, PU / 2 + 1:PU) = rb_loop_reuse.prederr_blk_loop;
    pred_blk_loop(PU / 2 + 1:PU, PU / 2 + 1:PU) = rb_loop_reuse.pred_blk_loop;
    mode_blk_loop(PU / 2 + 1:PU, PU / 2 + 1:PU) = rb_loop_reuse.mode_blk_loop;
    % ��һ�뻷û����Ҫ���⴦��ĵط�
    % 1110 ģʽ�²���Ҫ�����һ�뻷
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
