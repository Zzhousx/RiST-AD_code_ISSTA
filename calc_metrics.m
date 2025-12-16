function [apfd, apfdc, x, y] = calc_metrics(ord, lbl, cst)
    n=length(lbl); m=sum(lbl);
    if m==0, apfd=0; apfdc=0; x=0; y=0; return; end
    sl = lbl(ord); sc = cst(ord);
    apfd = 1 - sum(find(sl==1))/(n*m) + 1/(2*n);
    x = [0; cumsum(sc)]/sum(cst)*100;
    y = [0; cumsum(sl)]/m*100;
    apfdc = trapz(x/100, y/100);
end