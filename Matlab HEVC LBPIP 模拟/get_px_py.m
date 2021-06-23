% 为了预测 PU*PU 大小块的第 k 环数据，需要提取出上一环的参考像素
% PX 左侧参考像素（包括左上角一点）
% PY 上侧参考像素（包括左上角一点）
% 与块状不同，环状预测用到的参考像素不需要往左下、右上扩展 PU 个，只需要扩展 1 个
% 未知像素的填充方法参考 HEVC 标准，简单来说：逆时针搜索，碰到未知点用右侧（上侧）替代
function [PX, PY] = get_px_py(Seq_r, i, j, k, PU)
    ind = PU - k - 1;
    ii = i + ind;
    jj = j + ind;

    if (ii == 0 || jj == 0)
        lt = nan;
    else
        lt = Seq_r(ii, jj);
    end
    if (jj == 0)
        left = nan(k + 1, 1);
    else
        left = Seq_r(ii + 1:ii + 1 + k, jj);
    end
    if (ii == 0)
        top = nan(1, k + 1);
    else
        top = Seq_r(ii, jj + 1:jj + 1 + k);
    end

    if (all(isnan([left(:); top(:); lt(:)])))
        PX = zeros(k + 2, 1) + 128;
        PY = PX';
        return
    end

    reverse = [top(end:-1:1), lt, left(1:end)'];
    if isnan(reverse(1))
        first_available = reverse(find(~isnan(reverse), 1));
        reverse(1) = first_available;
    end
    for i = 2:2 * k + 3
        if isnan(reverse(i))
            reverse(i) = reverse(i - 1);
        end
    end
    PY = reverse(k + 2:-1:1);
    PX = reverse(k + 2:2 * k + 3);

    % if ((ii >= 1) && (jj >= 1))
    %     PY = Seq_r(ii, jj:j + PU - 1);
    %     PX = Seq_r(ii:i + PU - 1, jj);
    % elseif ((ii >= 1) && (~(jj >= 1)))
    %     PY = [Seq_r(ii, jj + 1), Seq_r(ii, jj + 1:j + PU - 1)];
    %     PX = zeros(k + 1, 1) + PY(1);
    % elseif (~(ii >= 1) && (jj >= 1))
    %     PX = [Seq_r(ii + 1, jj); Seq_r(ii + 1:i + PU - 1, jj)];
    %     PY = zeros(1, k + 1) + PX(1);
    % else
    %     PX = zeros(k + 1, 1) + 128;
    %     PY = zeros(1, k + 1) + 128;
    % end
end
