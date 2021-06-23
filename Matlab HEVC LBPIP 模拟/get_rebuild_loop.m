% 环状模式下 重建一个环
function [Seq_r] = get_rebuild_loop(prederr, pred, i, j, k, PU, Seq_r)
    rebuild_loop = pred + prederr;

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
