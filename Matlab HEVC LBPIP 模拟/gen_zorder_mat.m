function zorder = gen_zorder_mat()

    %产生关于z型扫描的顺序矩阵
    x = 1;
    y = 1;
    A = zeros(16, 16);
    for i = 0:3
        switch i
            case {1, 3}
                x = x + 1;
                y = y - 7;
            case 2
                x = x - 15;
                y = y + 1;
        end
        for j = 0:3
            switch j

                case {1, 3}
                    x = x + 1;
                    y = y - 3;
                case 2
                    x = x - 7;
                    y = y + 1;
            end
            for k = 0:3
                switch k
                    case {1, 3}
                        x = x + 1;
                        y = y - 1;
                    case 2
                        x = x - 3;
                        y = y + 1;
                end
                A(x, y) = k * 4 + j * 16 + i * 64;
                x = x + 1;
                A(x, y) = 1 + k * 4 + j * 16 + i * 64;
                x = x - 1; y = y + 1;
                A(x, y) = 2 + k * 4 + j * 16 + i * 64;
                x = x + 1;
                A(x, y) = 3 + k * 4 + j * 16 + i * 64;
            end
        end
    end
    zorder = A';
end
