% loop 模式下 33 个角度方式的预测
function [pred_1d] = Intra_Angular_Model_loop(top, left, nS)

    % 环状模式下并不需要计算整个块的预测值，仅需计算下列 index 的预测值
    single_loop_index = [[5 * nS + 1:-1:4 * nS + 2], [5 * nS + 2:nS:(nS + 3) * nS + 2]];

    % 补全长度方便代码运行，实际上补充的内容不可能被用于环状的预测值计算
    top(end + 1:2 * nS + 1) = 0;
    left(end + 1:2 * nS + 1) = 0;
    ref(1:2 * nS + 1) = left';
    ref(2 * nS + 2:4 * nS + 1) = top(2:end);
    ref = ref';

    intraPredAngleSet = [NaN, NaN, ...% Planar, DC
                    32, 26, 21, 17, 13, 9, 5, 2, 0, -2, -5, -9, -13, -17, -21, -26, ...%INTRA_ANGULAR2 ~ INTRA_ANGULAR17
                    -32, -26, -21, -17, -13, -9, -5, -2, 0, 2, 5, 9, 13, 17, 21, 26, 32]; %INTRA_ANGULAR18 ~ INTRA_ANGULAR34

    % invAngleSet = round( 2^13./intraPredAngleSet );
    invAngleSet = [NaN NaN 256 315 390 482 630 910 1638 4096 Inf -4096 -1638 -910 -630 -482 -390 -315 -256 -315 -390 -482 -630 -910 -1638 -4096 Inf 4096 1638 910 630 482 390 315 256];

    %% Step 1
    % Generate a big vector including block pixels, p(x,-1) and p(-1,x), x=0..nS-1.
    % record corresponding pixel's loaction [x,y]

    p_vec = [];
    vec_num = 0;

    % Left
    for y = -1:(-1 + 2 * nS)
        vec_num = vec_num + 1;
        p_vec = [p_vec; [-1 y]];
    end

    % Top
    for x = 0:(-1 + 2 * nS)
        vec_num = vec_num + 1;
        p_vec = [p_vec; [x -1]];
    end

    % Main body
    for x = 0:(-1 + nS)
        for y = 0:(-1 + nS)
            vec_num = vec_num + 1;
            p_vec = [p_vec; [x y]];
        end
    end

    %% ====== generate mapping from block to vector ======
    map_size = 2 * nS + 1;
    order_map = zeros(map_size, map_size);
    count = 0;
    for y = 1:map_size
        count = count + 1;
        order_map(y, 1) = count;
    end
    for x = 2:map_size
        count = count + 1;
        order_map(1, x) = count;
    end
    for x = 2:nS + 1
        for y = 2:nS + 1
            count = count + 1;
            order_map(y, x) = count;
        end
    end

    %% Step 3
    % Generate the intraPrediction maxtrix pred_mtx that
    % pred_mtx*pVec = pVec - pred_pVec
    pred_1d = cell(33, 1);
    for predModeIntra = 2:34
        pred_mtx = zeros(vec_num, vec_num);

        pred_mtx(1:1 + 4 * nS, 1:1 + 4 * nS) = eye(1 + 4 * nS);

        % VER Mode
        if (predModeIntra == 26)
            for i = single_loop_index
                ix = p_vec(i, 1);
                pred_pos_in_p_vec = order_map(1, ix + 2);
                pred_mtx(i, pred_pos_in_p_vec) = 1;
            end
        end

        % HOR Mode
        if (predModeIntra == 10)
            for i = single_loop_index
                iy = p_vec(i, 2);
                pred_pos_in_p_vec = order_map(iy + 2, 1);
                pred_mtx(i, pred_pos_in_p_vec) = 1;
            end
        end

        % DC Mode
        % Note that a filter after DC prediction is not applied!
        % if (predModeIntra == 1)
        %     k = log2(nS);
        %     for i = (4 * nS + 2):vec_num
        %         for pred_pos_in_p_vec = 2:nS + 1% top
        %             pred_mtx(i, pred_pos_in_p_vec) = 1 / (2^(k + 1));
        %         end
        %         for pred_pos_in_p_vec = 2 * nS + 2:3 * nS + 1% left
        %             pred_mtx(i, pred_pos_in_p_vec) = 1 / (2^(k + 1));
        %         end
        %     end
        %     return;
        % end

        %% Step 4 (Angular Mode)
        % if mode_index >= 3

        %Step 4.1
        % Derive refMain[x] (x = -nS...2*nS)specifing the reference samples' location
        % We need a Offset=nS+1 here so that the x+Offset are always > 0

        Offset = nS + 1;
        refMain = zeros(2 * nS + Offset, 2); %refMain(:,1)--(x,:), refMain(:,2)--(:,y)

        intraPredAngle = intraPredAngleSet(predModeIntra + 1);
        invAngle = invAngleSet(predModeIntra + 1);

        if predModeIntra >= 18
            for refIndex = 0:nS
                refMain(refIndex + Offset, :) = [-1 + refIndex, -1];
            end
            if intraPredAngle < 0
                for refIndex = floor((nS * intraPredAngle) / 32):-1
                    refMain(refIndex + Offset, :) = [-1, -1 + floor((refIndex * invAngle + 128) / 256)];
                end
            else
                for refIndex = nS + 1:2 * nS
                    refMain(refIndex + Offset, :) = [-1 + refIndex, -1];
                end
            end
        else
            for refIndex = 0:nS
                refMain(refIndex + Offset, :) = [-1, -1 + refIndex];
            end
            if intraPredAngle < 0
                for refIndex = floor((nS * intraPredAngle) / 32):-1
                    refMain(refIndex + Offset, :) = [-1 + floor((refIndex * invAngle + 128) / 256), -1];
                end
            else
                for refIndex = nS + 1:2 * nS
                    refMain(refIndex + Offset, :) = [-1, -1 + refIndex];
                end
            end
        end

        % Step 4.2
        %****************************************************************
        % iIdx = ((y+1)*intraPredAngle) >> 5
        % iFact = ((y+1)*intraPredAngle) & 31
        % if iFact <> 0
        %   predSample[x,y] = ((32-iFact)*refMain[x+iIdx+1] + iFact*refMain[x+iIdx+2] + 16) >> 5
        % else
        %   predSample[x,y] = refMain[x+iIdx+1]
        % end
        %****************************************************************

        for i = single_loop_index
            if predModeIntra >= 18
                x = p_vec(i, 1);
                y = p_vec(i, 2);
            else
                x = p_vec(i, 2);
                y = p_vec(i, 1);
            end
            iIdx = floor((y + 1) * intraPredAngle / 32);
            if (y + 1) * intraPredAngle >= 0
                iFact = bitand((y + 1) * intraPredAngle, 31);
            else
                % 2^20-1
                iFact = bitand(bitxor(-(y + 1) * intraPredAngle, hex2dec('FFFFF')) + 1, 31);
            end
            %iFact
            if iFact ~= 0
                if refMain(x + iIdx + 1 + Offset, 1) == -1
                    pred_pos_in_p_vec_1 = refMain(x + iIdx + 1 + Offset, 2) + 2;
                else
                    pred_pos_in_p_vec_1 = 2 * nS + 2 + refMain(x + iIdx + 1 + Offset, 1);
                end

                if refMain(x + iIdx + 2 + Offset, 1) == -1
                    pred_pos_in_p_vec_2 = refMain(x + iIdx + 2 + Offset, 2) + 2;
                else
                    pred_pos_in_p_vec_2 = 2 * nS + 2 + refMain(x + iIdx + 2 + Offset, 1);
                end
                pred_mtx(i, pred_pos_in_p_vec_1) = (32 - iFact) / 32;
                pred_mtx(i, pred_pos_in_p_vec_2) = iFact / 32;
            else
                if refMain(x + iIdx + 1 + Offset, 1) == -1
                    pred_pos_in_p_vec = refMain(x + iIdx + 1 + Offset, 2) + 2;
                else
                    pred_pos_in_p_vec = 2 * nS + 2 + refMain(x + iIdx + 1 + Offset, 1);
                end
                pred_mtx(i, pred_pos_in_p_vec) = 1;
            end
        end

        pred_pix = round(pred_mtx(single_loop_index, 1:4 * nS + 1) * ref);
        pred_1d{predModeIntra - 1} = pred_pix';

    end
end
