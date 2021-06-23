% HEVC ��׼���� ���뵥֡
% ��������� size_all
% ����С��ͳ�� blk_size_sum
% �ֿ���� split_frame
% ģʽ��� mode_frame
% ÿ�� CTU ����� CTU_bits
function [size_all, blk_size_sum, split_frame, mode_frame, CTU_bits] = encode_main_blk(srcy)
    initGlobals(100);

    [CTU, img_src] = split_CTU(srcy);
    [h, w] = size(srcy);
    % +64, ��������/�²� CTU ȷ���ο�����
    img_rebuild = nan(h + 64, w + 64);
    split_frame = nan(h, w);
    mode_frame = nan(h, w);

    % for i = 1:numel(CTU)
    for i = 1:3
        i
        [CTU_bits(i), img_rebuild, split_frame, mode_frame] = encode_CTU(CTU(i), img_src, img_rebuild, split_frame, mode_frame);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame);
end
