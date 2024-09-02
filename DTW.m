function d = DTW(s, t, windowsize)
    ns = size(s,1);
    nt = size(t,1);
    windowsize = max(windowsize, abs(ns-nt)); 

    
    D = zeros(ns+1,nt+1) + Inf; 
    D(1,1) = 0;

    for i = 1:ns
        for j = max(i-windowsize, 1):min(i+windowsize, nt)
            cost = norm(s(i,:) - t(j,:));
            D(i+1,j+1) = cost + min([D(i, j+1), D(i+1, j), D(i, j)]);
        end
    end
    d = D(ns+1, nt+1);
end