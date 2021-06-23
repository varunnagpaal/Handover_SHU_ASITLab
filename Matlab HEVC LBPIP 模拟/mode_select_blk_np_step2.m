% �·ֿ鷽���£���״Ԥ��һ����
% step2: ���ݲ�ͬ�ı�����ʽ��ȷ������Ԥ��ģʽ�����
function [prederr, pred, sae, mode] = mode_select_blk_np_step2(pred_pixels, dst, pred_range)
    for m = 1:35
        prederr_all{m} = dst - pred_pixels{m};

        prederr_for_cal_sae = prederr_all{m};
        % ���������е�Ԥ��㶼���� SAE ����
        sae_all(m) = sum(abs(prederr_for_cal_sae(pred_range)));
    end
    [sae, mode] = min(sae_all);
    prederr = prederr_all{mode};
    pred = pred_pixels{mode};
end
