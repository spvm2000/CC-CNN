figure
y1=info.TrainingAccuracy;
y2=info.ValidationAccuracy;
% plot(y1,'Color',[0,0.7,0.9])
plot(y1,'LineWidth',1.5,...
    'Color',[0 0.4470 0.7410])
hold on
plot(y2,'LineWidth',1.5,...
    'Color',[0.8500 0.3250 0.0980])
legend('training acc','validation acc')

title('Model Accuracy')
xlabel('Iteration')
ylabel('Accuracy')
hold off


% hold on
% plot(y1,'Color',[0,0.7,0.9])

% clc
% clear
% figure;
% x=0:pi/50:2*pi;
% y=sin(x);
% subplot(121);
% plot(x,y);
% subplot(122);
% plot(x,y);
% set(gca,'xticklabel',[0 0.1 0.2 0.3 0.4]);
