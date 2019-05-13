%%
%part 1
% load data
load 'Bank.data';
NF = [5,10,15,20];
NR = [4,8,12,16,20];
%Radii instead of NR
Radii = [0.8, 0.7, 0.6, 0.55, 0.5;
    0.85, 0.8, 0.75, 0.7, 0.65;
    0.9, 0.85, 0.8, 0.75, 0.7;
    0.98, 0.96, 0.94, 0.92, 0.9;
    ];

%expand grid
[F,R] = ndgrid(NF, NR);
%E will have the average error of every NF-NR combination
E = zeros(numel(NF),numel(NR));


%%  
%part 2
%calculate most important features
X = Bank(:, 1:32);
y = Bank(:, 33);
[ranks, weights] = relieff(X, y, 10);

for f = 1:numel(NF)
    for r = 1:numel(NR)
        %cv partition
        c = cvpartition(y, 'KFold', 5);
        %cv 5-fold
        for i = 1:c.NumTestSets
            %get iteration's indeces
            trn_id = c.training(i);
            tst_id = c.test(i);
            
            %choose the F(i,j) most important features as set
            d_trn = Bank(trn_id, ranks(1:NF(f)));
            d_val = Bank(tst_id, ranks(1:NF(f)));
          
            initFis = genfis2(d_trn(:, 1:NF(f)), y, Radii(f, r));
            
            %training 
            nEpochs = 200;
            trnOpt = [nEpochs, NaN, NaN, NaN, NaN];
            disOpt = [0, 0, 0, 0];
            [trnFis, trnError, stepsize, chkFis, chkError] = anfis(d_trn, initFis,  trnOpt, disOpt, d_val, 1);
            
            %E(i,j)error average
            E(f,r) = E(f,r) + min(chkError)/c.NumTestSets;
        end
        
    end
end
%calculate min(E)
f = NF(1);
r = Radii(1,1);
E_min = E(1,1);
for i= 1:numel(NF)
    for j = 1:numel(NR)
        if E(i,j) < E_min
            f = i;
            r = Radii(i,j);
            E_min = E(i,j);
        end
    end
end
E
%r and f have the optimized values
fprintf('Optimal feature number %d and rule number %d, with %d error.\n',NF(f),r, E_min)

%plot error=f(NR) and error=f(NF)
figure(1)
subplot(2,2,1);
plot(Radii(1,:), E(1,:))
title('NF = 5')
subplot(2,2,2);
plot(Radii(2,:), E(2,:))
title('NF = 10')
subplot(2,2,3);
plot(Radii(3,:), E(3,:))
title('NF = 15')
subplot(2,2,4);
plot(Radii(4,:), E(4,:))
title('NF = 20')
suptitle('Error - NR relation');
saveas(gcf, 'ErrorNR.png');

figure(2)
subplot(2,3,1);
plot(NF, E(:, 1))
title('NR = 4')
subplot(2,3,2);
plot(NF, E(:, 2))
title('NR = 8')
subplot(2,3,3);
plot(NF, E(:, 3))
title('NR = 12')
subplot(2,3,4);
plot(NF, E(:, 4))
title('NR = 16')
subplot(2,3,5);
plot(NF, E(:, 5))
title('NR = 20')
suptitle('Error - NF relation');
saveas(gcf, 'ErrorNF.png');

%%
%%part 3
%choose the f most important features as set
d_trn = Bank(1:4916 , ranks(1:NF(f)));
d_val = Bank(4917:6554, ranks(1:NF(f)));
d_chk = Bank(6555:8192, ranks(1:NF(f)));

%initialize
initFis = genfis2(d_trn(:, 1:NF(f)), y, r);

% plot some (4) membership functions
figure (3)
subplot(2,2,1)
plotmf(initFis, 'input', 1)
subplot(2,2,2)
plotmf(initFis, 'input', 2)
subplot(2,2,3)
plotmf(initFis, 'input', 3)
subplot(2,2,4)
plotmf(initFis, 'input', 4)
suptitle('4 Membership Functions Before Training');
saveas(gcf, 'SomeMembershipFunctionsBeforeTraining.png');

%training 
nEpochs = 500;
trnOpt = [nEpochs, NaN, NaN, NaN, NaN];
disOpt = [0, 0, 0, 0];
[trnFis, trnError, stepsize, chkFis, chkError] = anfis(d_trn, initFis,  trnOpt, disOpt, d_val, 1);
           
%plot some (4) membership functions after the training
figure (4)
subplot(2,2,1)
plotmf(chkFis, 'input', 1)
subplot(2,2,2)
plotmf(chkFis, 'input', 2)
subplot(2,2,3)
plotmf(chkFis, 'input', 3)
subplot(2,2,4)
plotmf(chkFis, 'input', 4)
suptitle('4 Membership Functions After Training');
saveas(gcf, 'SomeMembershipFunctionsAfterTraining.png');


% compute sx^2 and se^2
y = Bank(:, ranks(NF(f)));
average = mean(y(4917:6554));
sum = 0;
for i = 4917:6554
    sum = sum + (y(i)-average)^2;
end
sx2 = sum/(6554-4917);
se = min(chkError);

%calculate nmse and ndei error
RMSE = se
NMSE = se^2/sx2
NDEI = sqrt(NMSE)
R2 = 1 - NMSE %R^2 = 1 - NMSE*(6554-4917)/(6554-4917)


%plot errors
figure(5)
plot([trnError chkError])
hold on
plot([trnError chkError], 'o')
legend('trnError', 'chkError')
xlabel('Epochs')
ylabel('RMSE (Root Mean Squared Error)' )
title('Error Curves')
saveas(gcf, 'ErrorCurvesPart2.png');



%plot result and prediction errors
figure(6) 
anfis_output = evalfis([d_trn(:,1:NF(f)); d_val(:, 1:NF(f)) ; d_chk(:, 1:NF(f))], chkFis); 
index = 1 : 8192;
plot([y(index) anfis_output])
legend('Real Values', 'Anfis Output');
legend('Location', 'southeast', 'Orientation', 'horizontal');
legend('boxoff');
yL = get(gca, 'YLim');
txt1 = 'Training Set';
txt2 = 'Valid Set';
txt3 = 'Checking Set';
line([4916 4916], yL, 'Color', 'r');
line([6554 6554], yL, 'Color', 'r');
text(700, 1.4, txt1);
text(1080, 1.4, txt2);
text(1400, 1.4, txt3);
xlabel('Samples')
title('Real Samples and ANFIS Prediction')
saveas(gcf, 'ComparisonBetweenRealPredictedValuesPart2.png');


