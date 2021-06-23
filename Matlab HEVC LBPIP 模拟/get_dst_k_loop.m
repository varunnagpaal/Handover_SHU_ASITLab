% ��ȡ�� PU*PU ��С���еĵ� k ������
% ��˳ʱ�뷽ʽ����Ϊһά
function [dst_1d] = get_dst_k_loop(dst, k, PU)
    cnt = PU - k + 1;
    if (k ~= 1)
        TOP = dst(cnt, cnt + 1:PU);
        LEFT = dst(cnt + 1:PU, cnt);
        TOPLEFT = dst(cnt, cnt);
        dst_1d = [LEFT(end:-1:1)', TOPLEFT, TOP];
    else
        dst_1d = dst(PU, PU);
    end
end
