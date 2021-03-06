clear;
clc;
[weights,dataSet,labelMat]=logisticRegression('testSet.txt');

[m,n]=size(dataSet);

for i=1:m
    if labelMat(i, 1)==0
    	plot(dataSet(i,2),dataSet(i,3),'b.','MarkerSize',10);
        hold on;
    else
    	plot(dataSet(i,2),dataSet(i,3),'r.','MarkerSize',10);
        hold on;
    end
end

x=linspace(-3,3,50);
y = (-weights(1,1)-weights(1,2)*x)/weights(1,3);

plot(x(1,:),y(1,:),'k-','MarkerSize',15);
hold off;