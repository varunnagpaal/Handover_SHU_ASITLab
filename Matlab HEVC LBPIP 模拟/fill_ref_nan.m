% ���һ�� ����һ�� �ο����ش��ڻ�δ�ؽ������ص�ʱ�����������׼8.4.4.2.2�ڣ�
function [PX, PY] = fill_ref_nan(left, top, lt, PU)
    if (all(isnan([left(:); top(:); lt(:)])))
        PX = zeros(2 * PU + 1, 1) + 128;
        PY = PX';
        return
    end

    reverse = [top(end:-1:1), lt, left(1:end)'];
    if isnan(reverse(1))
        first_available = reverse(find(~isnan(reverse), 1));
        reverse(1) = first_available;
    end
    for i = 2:4 * PU + 1
        if isnan(reverse(i))
            reverse(i) = reverse(i - 1);
        end
    end
    PY = reverse(2 * PU + 1:-1:1);
    PX = reverse(2 * PU + 1:4 * PU + 1);
end
