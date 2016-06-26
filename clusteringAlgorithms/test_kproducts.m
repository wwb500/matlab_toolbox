c = 3*randn(2,3);
T = 20;
z = [randn(2,T)+repmat(c(:,1),1,T) randn(2,T)+repmat(c(:,2),1,T) randn(2,T)+repmat(c(:,3),1,T)];
w = kproducts(z,3);
plot(z(1,:),z(2,:),'.k')
axis square;
hold on
plot(c(1,:),c(2,:),'o','markerfacecolor','w','markeredgecolor','k')
plot(w(1,:),w(2,:),'+','markeredgecolor','r')
hold off
legend('observations','centroides "vrais"','centroides estimes')
