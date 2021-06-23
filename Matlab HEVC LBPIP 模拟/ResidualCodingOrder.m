% 根据块的预测模式，确定该块残差的扫描顺序 （查标准）
function Y = ResidualCodingOrder(A, cIdx, IntraPredModeY, IntraPredModeC)
    TrafoSize = size(A, 1);
    if ((TrafoSize == 4) || (TrafoSize == 8))
        if (cIdx == 0)
            predModeIntra = IntraPredModeY;
        else
            predModeIntra = IntraPredModeC;
        end
        if ((6 <= predModeIntra) && (predModeIntra <= 14))
            scanIdx = 2;
        elseif ((22 <= predModeIntra) && (predModeIntra <= 30))
            scanIdx = 1;
        else
            scanIdx = 0;
        end
    else
        scanIdx = 0;
    end
    r = TrafoSize;
    Y = zeros(1, r * r);
    k = 0;
    if (scanIdx == 0)
        for i = 1:r
            for j = 1:i
                k = k + 1;
                Y(k) = A(i - j + 1, j);
            end
        end
        for i = (r + 1):(2 * r - 1)
            for j = 1:(2 * r - i)
                k = k + 1;
                Y(k) = A(r - j + 1, i + j - r);
            end
        end
    elseif (scanIdx == 1)
        for i = 1:r
            for j = 1:r
                k = k + 1;
                Y(k) = A(i, j);
            end
        end
    elseif (scanIdx == 2)
        for i = 1:r
            for j = 1:r
                k = k + 1;
                Y(k) = A(j, i);
            end
        end
    else
    end
end
