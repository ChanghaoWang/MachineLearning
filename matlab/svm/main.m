clear;%清屏
clc;
dataOri =load('data.txt');
n = length(dataOri);%总样本数量
dataSet = dataOri(:,1:3);
% dataSet=dataSet/(max(max(abs(dataSet)))-min(min(abs(dataSet))));
labels = dataOri(:,4);%类别标志
labels(labels==0) = -1;

% load('Flame.mat');
% dataSet = Flame;
% n = length(dataSet);%总样本数量
% labels = dataOri(:,4);%类别标志
% labels(labels==0) = -1;

sigma=1;        %高斯核函数
TOL = 0.0001;   %精度要求
C = 1;          %参数，对损失函数的权重
b = 0;          %初始设置截距b
bold=0;
bnew=0;
Wold = 0;       %未更新a时的W(a)
Wnew = 0;       %更新a后的W(a)

a = ones(n,1)*0.2;  %参数a，随机初始化a,a属于[0,C]

%高斯核函数处理数据
% K=dataSet;
K=pdist(dataSet);
K=squareform(K);
K = -K.^2/(2*sigma*sigma);
K = full(spfun(@exp, K));
for i=1:n
    K(i,i)=1;
end

sum=(a.*labels)'*K;

while 1
    %启发式选点，n1,n2代表选择的2个点
    n1 = 1;
    n2 = 2;
    %n1，第一个违反KKT条件的点选择
    while n1 <= n
        if labels(n1) * (sum(n1) + b) == 1 && a(n1) >= C && a(n1) <=  0
            break;
        end
        if labels(n1) * (sum(n1) + b) > 1 && a(n1) ~=  0
            break;
        end
        if labels(n1) * (sum(n1) + b) < 1 && a(n1) ~=C
            break;
        end
        n1 = n1 + 1;
    end
    
    %n2按照最大化|E1-E2|的原则选取
    E2 = 0;
    maxDiff = 0;%假设的最大误差
    E1 = sum(n1) + b - labels(n1);%n1的误差
    for i = 1 : n
        tempW = sum(i) + b - labels(i);
        if abs(E1 - tempW)> maxDiff
            maxDiff = abs(E1 - tempW);
            n2 = i;
            E2 = tempW;
        end
    end
    
    %以下进行更新
    a1old = a(n1);
    a2old = a(n2);
    KK = K(n1,n1) + K(n2,n2) - 2*K(n1,n2);
    a2new = a2old + labels(n2) *(E1 - E2) / KK;
    
    yy=labels(n1) * labels(n2);
    if yy==-1
        L=max(0,a2old - a1old);
        H=min(C,C + a2old - a1old );
    else
        L=max(0,a1old + a2old - C);
        H=min(C,a1old + a2old);
    end
    
    a2new=min(a2new,H);
    a2new=max(a2new,L);
    a1new = a1old + yy * (a2old - a2new);
    
    %更新a
    a(n1) = a1new;
    a(n2) = a2new;
    
    %更新Ei和b
    sum=(a.*labels)'*K;
    
    Wold = Wnew;
    Wnew = 0;%更新a后的W(a)
    tempW=0;
    for i = 1 : n
        for j = 1 : n
            tempW= tempW + labels(i )*labels(j)*a(i)*a(j)*K(i,j);
        end
        Wnew= Wnew+ a(i);
    end
    Wnew= Wnew - tempW/2;
    
    %以下更新b：通过找到某一个支持向量来计算
    bold=b;
    if a1new>=0 && a1new<=C
        b=(a1old-a1new)*labels(n1)*K(n1,n1)+(a2old-a2new)*labels(n2)*K(n2,n1)-E1+bold;
    elseif a2new>=0 && a2new<=C
        b=(a1old-a1new)*labels(n1)*K(n1,n2)+(a2old-a2new)*labels(n2)*K(n2,n2)-E2+bold;
    else      % (a1new<0||a1new>C)&&(a2new<0||a2new>C)
        b1=(a1old-a1new)*labels(n1)*K(n1,n1)+(a2old-a2new)*labels(n2)*K(n2,n1)-E1+bold;
        b2=(a1old-a1new)*labels(n1)*K(n1,n2)+(a2old-a2new)*labels(n2)*K(n2,n2)-E2+bold;
        b=(b1+b2)/2;
    end
    
    %判断停止条件
    if abs(Wnew/ Wold - 1 ) <= TOL
        break;
    end
end

for i = 1 : n
    if sum(i) + b  < 0
        fprintf('-1\n');
    else 
        fprintf('1\n');
    end
end
%输出结果：包括原分类，辨别函数计算结果，svm分类结果
% for i = 1 : n
%     fprintf('第%d点:原标号 ',i);
%     if i <= 50
%         fprintf('-1');
%     else
%         fprintf(' 1');
%     end
%     fprintf('    判别函数值%f      分类结果',sum(i) + b);
%     if sum(i) + b  < 0
%         fprintf('-1\n');
%     else 
%         fprintf('1\n');
%     end
% end

% result=zeros(n,1);
% %输出结果：包括原分类，辨别函数计算结果，svm分类结果
% for i = 1 : n
%     if abs(sum(i) + b - 1) < 0.5
%         result(i)=2;
%     else
%         result(i)=1;
%     end
% end

% labels(labels==-1)=2;
% result(result==-1)=2;

% score=nmi(labels,result);