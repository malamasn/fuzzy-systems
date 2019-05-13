%%
%part 1
% load data
load 'waveform.data';
NF = [4,8,12,16];
NR = [3,9,15,21];
N = 5000;

Radii = [0.4, 0.3, 0.25, 0.22;
    0.53, 0.35, 0.33, 0.30;
    0.9, 0.5, 0.45, 0.4;
    0.95, 0.65, 0.55, 0.5;
    ];

%expand grid
[F,R] = ndgrid(NF, NR);
%E will have the average error of every NF-NR combination
E = zeros(numel(NF),numel(NR));

%find classes frequencies
y = waveform(:, 41);
freq = zeros(3,1);
for i = 1:5000
    t = y(i);
    t = t +1;
    freq(t) = freq(t) +1;
end
%split data to 3 subsets with equal class frequencies in each one
%d_trn,d_val,d_chk
d_trn = zeros(3000, 41);
d_chk = zeros(1000, 41);
d_val = zeros(1000, 41);

zero = zeros(3,1);
one = zeros(3,1);
two = zeros(3,1);
index = zeros(3,1);
for i = 1:N
   if waveform(i,41) == 0
       if zero(1) < ceil(0.6*freq(1))
           zero(1) = zero(1) + 1;
           index(1) = index(1) + 1;
           d_trn(index(1), :) = waveform(i, :);
       elseif one(1) < floor(0.2*freq(1))
           one(1) = one(1) +1;
           index(2) = index(2) + 1;
           d_val(index(2), :) = waveform(i, :);
       else
           two(1) = two(1) + 1;
           index(3) = index(3) + 1;
           d_chk(index(3), :) = waveform(i, :);
       end
   end
   if waveform(i,41) == 1
       if zero(2) < floor(0.6*freq(2))
           zero(2) = zero(2) + 1;
           index(1) = index(1) + 1;
           d_trn(index(1), :) = waveform(i, :);
       elseif one(2) < ceil(0.2*freq(2))
           one(2) = one(2) +1;
           index(2) = index(2) + 1;
           d_val(index(2), :) = waveform(i, :);
       else
           two(2) = two(2) + 1;
           index(3) = index(3) + 1;
           d_chk(index(3), :) = waveform(i, :);
       end
   end
   if waveform(i,41) == 2
       if zero(3) < ceil(0.6*freq(3))
           zero(3) = zero(3) + 1;
           index(1) = index(1) + 1;
           d_trn(index(1), :) = waveform(i, :);
       elseif one(3) < floor(0.2*freq(3))
           one(3) = one(3) +1;
           index(2) = index(2) + 1;
           d_val(index(2), :) = waveform(i, :);
       else
           two(3) = two(3) + 1;
           index(3) = index(3) + 1;
           d_chk(index(3), :) = waveform(i, :);
       end
   end
end


%calculate most important features
X = d_trn(:, 1:40);
y = d_trn(:, 41);
[ranks, weights] = relieff(X, y, 10);
%%  
%part 2
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
            d_trn_temp = waveform(trn_id, ranks(1:NF(f)));
            d_val_temp = waveform(tst_id, ranks(1:NF(f)));
            
            initFis = genfis2(d_trn(:, 1:NF(f)), y, Radii(f, r));
            
            %training 
            nEpochs = 200;
            trnOpt = [nEpochs, NaN, NaN, NaN, NaN];
            disOpt = [0, 0, 0, 0];
            [trnFis, trnError, stepsize, chkFis, chkError] = anfis(d_trn_temp, initFis,  trnOpt, disOpt, d_val_temp, 1);
            
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
title('NF = 4')
subplot(2,2,2);
plot(Radii(2,:), E(2,:))
title('NF = 8')
subplot(2,2,3);
plot(Radii(3,:), E(3,:))
title('NF = 12')
subplot(2,2,4);
plot(Radii(4,:), E(4,:))
title('NF = 16')
suptitle('Error - NR relation');
saveas(gcf, 'ErrorNR_class.png');

figure(2)
subplot(2,2,1);
plot(NF, E(:, 1))
title('NR = 3')
subplot(2,2,2);
plot(NF, E(:, 2))
title('NR = 9')
subplot(2,2,3);
plot(NF, E(:, 3))
title('NR = 15')
subplot(2,2,4);
plot(NF, E(:, 4))
title('NR = 21')
suptitle('Error - NF relation');
saveas(gcf, 'ErrorNF_class.png');


%%
%%part 3
%choose the f most important features as set
%r and f have the optimized values
%r=0.9 f=4, NF(f)=16;


y = waveform(:, 41);
%initialize
d_trn = d_trn(:, [ranks(1:NF(f)), 41]);
d_val = d_val(:, [ranks(1:NF(f)), 41]);
d_chk = d_chk(:, [ranks(1:NF(f)), 41]);
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
saveas(gcf, 'SomeMembershipFunctionsBeforeTraining_class.png');

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
saveas(gcf, 'SomeMembershipFunctionsAfterTraining_class.png');

%measurements here. check evalfis inputs, error matrix, rest!!!
%plot result and prediction errors
anfis_output = evalfis([d_trn(:,1:NF(f)); d_val(:, 1:NF(f)) ; d_chk(:, 1:NF(f))], chkFis);
%round the results (classification problem)  
anfis_output = round(anfis_output);
for i = 1:N
    if anfis_output(i) <= 0
        anfis_output(i) = 0;
    elseif anfis_output(i) >= NF(f) + 1
        anfis_output(i) = NF(f);
    end
end


%error matrix
E = zeros(NF(f));
for i = 1:N
    E(anfis_output(i)+1, waveform(i,41)+1) = E(anfis_output(i)+1, waveform(i,41)+1) + 1;
end
E

%Overall accuracy
OA = sum(diag(E))/N

%Producer’s accuracy – User’s accuracy
PA = zeros(NF(f),1);
UA = zeros(NF(f),1);
for i = 1:NF(f)
    PA(i) = E(i,i)/sum(E(:, i));
    UA(i) = E(i,i)/sum(E(i, :));
end
PA
UA

%K
temp = 0;
for i = 1:NF(f)
    temp = temp + sum(E(:, i))*sum(E(i, :)); 
end

K = (N*sum(diag(E))- temp)/(N^2 - temp)


%plot errors
figure(5)
plot([trnError chkError])
hold on
plot([trnError chkError], 'o')
legend('trnError', 'chkError')
xlabel('Epochs')
ylabel('RMSE (Root Mean Squared Error)' )
title('Error Curves')
saveas(gcf, 'ErrorCurvesPart2_class.png');



%plot result and prediction errors
figure(6) 
index = 1 : 5000;
y = waveform(:, 41);
plot([y(index) anfis_output])
legend('Real Values', 'Anfis Output');
legend('Location', 'southeast', 'Orientation', 'horizontal');
legend('boxoff');
yL = get(gca, 'YLim');
txt1 = 'Training Set';
txt2 = 'Valid Set';
txt3 = 'Checking Set';
line([3000 3000], yL, 'Color', 'r');
line([4000 4000], yL, 'Color', 'r');
text(700, 1.4, txt1);
text(1080, 1.4, txt2);
text(1400, 1.4, txt3);
xlabel('Samples')
title('Real Samples and ANFIS Prediction')
saveas(gcf, 'ComparisonBetweenRealPredictedValuesPart2_class.png');

