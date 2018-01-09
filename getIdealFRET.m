function IF = getIdealFRET(pathData, frame)

    mx=max(pathData(:,1));
    i=1;
    while i<= mx
        Length = find(pathData(:, 1)'==i);
        k = 1;
        for j = Length
           IF(k, i) = pathData(j, 2);
           k = k + 1;
       end
       size_j = size(Length);
       jms=size_j(2);
       IF(jms+1:frame, i)=NaN;    
       i=i+1;
   end
        
