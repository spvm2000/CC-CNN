figure
y3=info.TrainingLoss;
y4=info.ValidationLoss;
plot(y3,'LineWidth',1.5,...
    'Color',[0 0.4470 0.7410])
hold on
plot(y4,'LineWidth',1.5,...
    'Color',[0.8500 0.3250 0.0980])
legend('training loss','validation loss')
title('Model Loss')
xlabel('Iteration')
ylabel('Loss')
hold off