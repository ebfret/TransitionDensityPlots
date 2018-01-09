
function H = getTransitions2(F, bins,suppressDiag)
    
        %store in two variables shifted with one datapoint
    ms=size(F);
    F1 = F(1:ms(1)-1, :);
    F2 = F(2:ms(1), :);
    ms=size(F1);

    if suppressDiag
            %build transition histogram
        X = linspace(-0.2, 1.2, bins)';
        H = zeros(bins,bins) ;
        for j = 1:ms(2)
            for i = 1:ms(1)
                if isfinite(F1(i,j)) && isfinite(F2(i,j))
                    x = dsearchn(X,F1(i,j)) ;
                    y = dsearchn(X,F2(i,j)) ;
                    if x~=y
                        H(y,x) = H(y,x) + 1 ;
                    end
                end
            end
        end
    else
            %build transition histogram
        X = linspace(-0.2, 1.2, bins)';
        H = zeros(bins,bins) ;
        for j = 1:ms(2)
            for i = 1:ms(1)
                if isfinite(F1(i,j)) && isfinite(F2(i,j))
                    x = dsearchn(X,F1(i,j)) ;
                    y = dsearchn(X,F2(i,j)) ;
                    H(y,x) = H(y,x) + 1 ;
                end
            end
        end
    end
    
    output = array2table(H);
    writetable(output,['TransitionHistogram.csv'])