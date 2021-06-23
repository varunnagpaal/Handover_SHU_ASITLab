% 统计一帧图像的体积、分块
function [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame)

    size_all = sum(CTU_bits);

    cnt4 = sum(sum(split_frame == 4)) / (4 * 4);
    cnt8 = sum(sum(split_frame == 8)) / (8 * 8);
    cnt16 = sum(sum(split_frame == 16)) / (16 * 16);
    cnt32 = sum(sum(split_frame == 32)) / (32 * 32);
    cnt64 = sum(sum(split_frame == 64)) / (64 * 64);

    blk_size_sum = [cnt4, cnt8, cnt16, cnt32, cnt64];
end
