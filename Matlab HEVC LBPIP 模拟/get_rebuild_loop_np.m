% 新分块方法下，部分模式的前一半环预测完成不能全部重建
function [Seq_r] = get_rebuild_loop_np(prederr, pred, i, j, k, PU, Seq_r, mask)
    rebuild_loop = pred + prederr;
    switch mask
        case {1111, 0111, 1110}
            ;
        case 1011
            rebuild_loop([end - (PU / 2 - 1):end]) = nan;
        case 1101
            rebuild_loop([1:PU / 2]) = nan;
    end

    if (k ~= 1)
        LEFT = rebuild_loop(k - 1:-1:1);
        TOPLEFT = rebuild_loop(k);
        TOP = rebuild_loop(k + 1:end);
    else
        TOPLEFT = rebuild_loop;
    end
    cnt = PU - k;
    Seq_r(i + cnt, j + cnt) = TOPLEFT;
    if (k ~= 1)
        Seq_r(i + cnt, j + cnt + 1:j + PU - 1) = TOP;
        Seq_r(i + cnt + 1:i + PU - 1, j + cnt) = LEFT;
    end
end
