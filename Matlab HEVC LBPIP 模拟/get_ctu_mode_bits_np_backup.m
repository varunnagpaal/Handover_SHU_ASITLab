function sum = get_ctu_mode_bits_np_backup(mode_all, size_all, blflag_all, maxsize, ctux, ctuy, minblk)
    %blflag_all即为区别环状预测和块状预测的信息
    %     CTU =load('size_mode_np.mat');
    %
    %     maxsize=64;
    %     minblk=3;
    %     ctux=1;
    %     ctuy=1;
    %     mode_all=CTU.mode_all;
    %     size_all=CTU.size_all;
    mode_all = mode_all - 1; %模式号整体减1
    %  initGlobals(100);
    mode_blk = mode_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    size_blk = size_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    blflag_blk = blflag_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    idx = 0;
    c = 1;
    d = 1;
    sum = 0;
    temp = 0;

    %初步将矩阵中的数据转换为[行坐标，列坐标，块大小，0（存放标记非正方形块是哪个方向的信息）]的样子
    for i = 1:4:maxsize%这里的ij坐标须为当前点在当前CTU中的相对坐标
        for j = 1:4:maxsize
            if mod(size_blk(i, j), 2) == 0
                a = (floor(i / size_blk(i, j))) * size_blk(i, j) + 1;
                b = (floor(j / size_blk(i, j))) * size_blk(i, j) + 1;
            else
                sqwidth = (size_blk(i, j) - 1) * 2;
                a = floor(i / sqwidth) * sqwidth + 1; %(sizeall(i,j)-1)*2为非正方形补为正方形之后的宽度
                b = floor(j / sqwidth) * sqwidth + 1;
            end
            if (a ~= c || b ~= d) || (a == c && b == d && size_blk(i, j) ~= temp)
                idx = idx + 1;
            end

            L{idx} = [a, b, size_blk(i, j), 0];
            c = L{idx}(1);
            d = L{idx}(2);
            temp = L{idx}(3);
        end
    end
    %去除元胞数组中重复的元素项（这个是因为提取出来的信息因为一点小bug会有一部分重复）
    L = cellfun(@num2str, L, 'un', 0);
    K = unique(L);
    P = cellfun(@str2num, K, 'un', 0);
    %得到每个块的坐标，size信息
    %其中注意，所有非正方形块的定位坐标统一放在将其补齐为正方形后，左上角第一个点
    %包括左上角是块状预测的情况，这种情况下定位点不属于该非正方形块
    s = size(P);

    for k = 1:s(2)%先处理正方形块
        ai = P{k}(1) + ctux - 1; %在整帧中实际坐标(当前块左上角第一个点坐标)
        aj = P{k}(2) + ctuy - 1;
        if mod(P{k}(3), 2) == 0

            if ~blflag_blk(P{k}(1), P{k}(2))%标记为0表示块状预测
                [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                if flag == 0%确认：flag=0表示在候选列表中，使用3bit
                    sum = sum + 3;
                else
                    sum = sum + 6; %不在则用6bit
                end
            else %方形块的环状预测
                modetemp = zeros(1, P{k}(3));
                for l = 1:P{k}(3)
                    modetemp(l) = mode_blk(P{k}(1) + P{k}(3) - 1, P{k}(2) + l - 1); %看最后一行即能得到所有模式号
                end
                %计算首个模式残差存入modediff
                if ai == 1
                    modediff = modetemp(1) - 0;
                else
                    modediff = modetemp(1) - mode_all(ai - 1, aj);
                end
                sum = sum + huffman_testsize([modediff, diff(modetemp(1:P{k}(3) - minblk + 1))]);
            end
        end
    end
    %处理L型块
    for k = 1:s(2)
        ai = P{k}(1) + ctux - 1; %在整帧中实际坐标
        aj = P{k}(2) + ctuy - 1;
        if mod(P{k}(3), 2) ~= 0
            for y = 1:s(2)%通过能否找到对应位置的块坐标信息来判断属于哪种情况
                if y == k
                    continue;
                end
                if P{k}(1) == P{y}(1) && P{k}(2) == P{y}(2)%保留左上的情况
                    location = 1;

                elseif P{y}(1) == P{k}(1) && ...%保留右上的情况
                    P{y}(2) == P{k}(2) + size_blk(P{k}(1), P{k}(2)) - 1
                    location = 2;

                elseif P{y}(1) == P{k}(1) + size_blk(P{k}(1), P{k}(2)) - 1 && ...%保留左下的情况
                    P{y}(2) == P{k}(2)
                    location = 3;

                elseif P{y}(1) == P{k}(1) + size_blk(P{k}(1), P{k}(2)) - 1 && ...%保留右下的情况
                    P{y}(2) == P{k}(2) + size_blk(P{k}(1), P{k}(2)) - 1
                    location = 4;

                end
            end
            switch location
                case {1, 2}
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + i - 1);
                    end

                    if blflag_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + (P{k}(3) - 1) * 2 - 1)%=1为环状预测

                        if ai == 1
                            modediff = modetemp(1) - 0;
                        else
                            modediff = modetemp(1) - mode_all(ai - 1, aj);
                        end

                        sum = sum + huffman_testsize([modediff, diff(modetemp(1:(P{k}(3) - 1) * 2 - minblk + 1))]);

                    else %说明是块状预测
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);

                        if flag == 0%确认：flag0表示在候选列表中
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end

                case 3
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_blk(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end

                    if blflag_blk(P{k}(1), P{k}(2))
                        if ai == 1
                            modediff = modetemp(1) - 0;
                        else
                            modediff = modetemp(1) - mode_all(ai - 1, aj);
                        end

                        sum = sum + huffman_testsize([modediff, diff(modetemp(1:(P{k}(3) - 1) * 2 - minblk + 1))]);
                    else
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);

                        if flag == 0%确认：flag0表示在候选列表中
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end
                case 4
                    modetemp = zeros(P{k}(3) - 1, 1);
                    modediff = zeros(P{k}(3) - 1, 1);
                    for i = 1:P{k}(3) - 1
                        modetemp(i) = mode_blk(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end
                    if blflag_blk(P{k}(1), P{k}(2))
                        if ai == 1
                            modediff(1) = modetemp(1) - 0;
                        else
                            modediff(1) = modetemp(1) - mode_all(ai - 1, aj);
                        end
                        for x = 2:P{k}(3) - 1
                            modediff(x) = modetemp(x) - modetemp(x - 1);
                        end
                        sum = sum + huffman_testsize(modediff);
                    else
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                        if flag == 0%确认：flag0表示在候选列表中
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end
            end
        end
    end
end
