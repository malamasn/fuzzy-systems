% load data and plot them
load CCPP.dat;
T = CCPP(:, 1);
AP = CCPP(:, 2);
RH = CCPP(:, 3);
V = CCPP(:, 4);
E = CCPP(:, 5);
figure(1)
subplot(2,2,1);
plot(T)
title('Temperature')
subplot(2,2,2);
plot(AP)
title('Pressure')
subplot(2,2,3);
plot(RH)
title('Humidity')
subplot(2,2,4);
plot(V)
title('Exhaust vacuum')

% initialize training sets, we need the 5th row free for the output values
d_trn = zeros(5740, 5);
d_val = zeros(1914, 5);
d_chk = zeros(1914, 5);

% training sets
d_trn(:, 1) = T(1 : 5740);
d_trn(:, 2) = AP(1 : 5740);
d_trn(:, 3) = RH(1 : 5740);
d_trn(:, 4) = V(1 : 5740);
d_trn(:, 5) = E(1 : 5740);

% value sets
d_val(:, 1) = T(5741 : 7654);
d_val(:, 2) = AP(5741 : 7654);
d_val(:, 3) = RH(5741 : 7654);
d_val(:, 4) = V(5741 : 7654);
d_val(:, 5) = E(5741 : 7654);

% checking sets
d_chk(:, 1) = T(7655 : 9568);
d_chk(:, 2) = AP(7655 : 9568);
d_chk(:, 3) = RH(7655 : 9568);
d_chk(:, 4) = V(7655 : 9568);
d_chk(:, 5) = E(7655 : 9568);


% Training Hybrid Algorithm. 2 MF. Singleton output.
% initialize 
initFis = genfis1(d_trn, 2, 'gbellmf', 'constant');
% plot membership functions
figure (2)
subplot(2,2,1)
plotmf(initFis, 'input', 1)
subplot(2,2,2)
plotmf(initFis, 'input', 2)
subplot(2,2,3)
plotmf(initFis, 'input', 3)
subplot(2,2,4)
plotmf(initFis, 'input', 4)
suptitle('Membership Functions Before Training');
saveas(gcf, 'MembershipFunctionsBeforeTraining1.png');

%training for backpropagation (1 in anfis means hybrid)
nEpochs = 1000;
trnOpt = [nEpochs, NaN, NaN, NaN, NaN];
disOpt = [0, 0, 0, 0];
[trnFis, trnError1, stepsize, chkFis, chkError1] = anfis(d_trn, initFis,  trnOpt, disOpt, d_val, 1);

%show rules
showrule(chkFis)

%plot membership functions after the training
figure (3)
subplot(2,2,1)
plotmf(chkFis, 'input', 1)
subplot(2,2,2)
plotmf(chkFis, 'input', 2)
subplot(2,2,3)
plotmf(chkFis, 'input', 3)
subplot(2,2,4)
plotmf(chkFis, 'input', 4)
suptitle('Membership Functions After Training');
saveas(gcf, 'MembershipFunctionsAfterTraining1.png');

% compute sx^2 and se^2
average = mean(E(5741:7654));
sum = 0;
for i = 5741:7654
    sum = sum + (E(i)-average)^2;
end
sx2 = sum/(7654-5740);
se = min(chkError1);

%calculate nmse and ndei error
RMSE = se
NMSE = se^2/sx2
NDEI = sqrt(NMSE)
R2 = 1 - NMSE %R^2 = 1 - NMSE*(7654-5740)/(7654-5740)


%plot errors
figure(4)
plot([trnError1 chkError1])
hold on
plot([trnError1 chkError1], 'o')
legend('trnError', 'chkError')
xlabel('Epochs')
ylabel('RMSE (Root Mean Squared Error)' )
title('Error Curves')
saveas(gcf, 'ErrorCurves1.png');

%plot result and prediction errors
figure(5) 
anfis_output = evalfis([d_trn(:,1:4); d_val(:, 1:4) ; d_chk(:, 1:4)], chkFis);
index = 1 : 9568;
subplot(2,1,1)
plot([E(index) anfis_output])
legend('Real Values', 'Anfis Output');
legend('Location', 'southeast', 'Orientation', 'horizontal');
legend('boxoff');
yL = get(gca, 'YLim');
txt1 = 'Training Set';
txt2 = 'Valid Set';
txt3 = 'Checking Set';
line([5740 5740], yL, 'Color', 'r');
line([7654 7654], yL, 'Color', 'r');
text(700, 1.4, txt1);
text(1080, 1.4, txt2);
text(1400, 1.4, txt3);
xlabel('Samples')
title('Real Samples and ANFIS Prediction')
subplot(2, 1, 2)
plot(E(index) - anfis_output)
yL = get(gca, 'YLim');
line([5740 5740], yL, 'Color', 'r');
line([7654 7654], yL, 'Color', 'r');
text(700, -0.1, txt1);
text(1080, -.1, txt2);
text(1400, -.1, txt3);
xlabel('Samples')
title('Prediction Errors')
saveas(gcf, 'ComparisonBetweenRealPredictedValues1.png');