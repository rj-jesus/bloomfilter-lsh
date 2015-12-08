% teste independ?ncia
n=100000;
Nc= 20;         % N?mero de carat?res das strings
%%
setstr= double(['0':'9' 'A':'Z' 'a':'z']);
Ls= length(setstr);
idx= randi([1 Ls],n,Nc);
Test= cellstr(char(setstr(idx)));
 
%%
N= 1000000;
v= InitHashFunction(N);
k=4;
for i=1:n
    str=Test{i};
    for k=1:k
        str=[str num2str(k)];
        hcodes(i,k)= HashCode(v,N,str);
    end
end
%% aprox joint pmf
clear pmf
% consider 10 x 10
divisoes=10;
x=linspace(0,N,divisoes);
y=x;
col1=3;   % to control wwhich hash functions to compare
col2=4; 
values1=hcodes(:,col1);
values2=hcodes(:,col2);
for i=1:length(x)-1
    for j=1:length(x)-1
 
        aux=find( (values1 >= x(i)) & (values1 <x(i+1) )  &  (values2 >= y(i)) & (values2 <y(i+1) ));
        pmf(i,j)=length(aux);
    end
end
pmf=pmf/n;
figure(1)
subplot(231); bar3(pmf)
pmf1=sum(pmf,2)
pmf2=sum(pmf,1)
subplot(234); stem(pmf1)
subplot(235); stem(pmf2)
pmfindep=pmf1 * pmf2
subplot(232); bar3(pmfindep)
subplot(233); surf(pmfindep-pmf)