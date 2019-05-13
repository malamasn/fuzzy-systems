% load data and plot them
load wifi-localization.dat;
N = 2000;
% initialize training sets
d_trn = zeros(1200, 8);
d_val = zeros(400, 8);
d_chk = zeros(400, 8);
%have to split data with equal frequencies in all subsets

d_trn(1:300,:) = wifi_localization(1:300,:);
d_trn(301:600,:) = wifi_localization(501:800,:);
d_trn(601:900,:) = wifi_localization(1001:1300,:);
d_trn(901:1200,:) = wifi_localization(1501:1800,:);

d_val(1:100,:) = wifi_localization(301:400,:);
d_val(101:200,:) = wifi_localization(801:900,:);
d_val(201:300,:) = wifi_localization(1301:1400,:);
d_val(301:400,:) = wifi_localization(1801:1900,:);

d_chk(1:100,:) = wifi_localization(401:500,:);
d_chk(101:200,:) = wifi_localization(901:1000,:);
d_chk(201:300,:) = wifi_localization(1401:1500,:);
d_chk(301:400,:) = wifi_localization(1901:2000,:);


% initialize 
n_clusters = 4;
opt = NaN(4,1);
opt(4) = 0;
initFis = genfis3(d_trn(:,1:7), d_trn(:,8), 'sugeno', n_clusters, opt);

% plot membership functions
figure (2)
subplot(3,3,1)
plotmf(initFis, 'input', 1)
subplot(3,3,2)
plotmf(initFis, 'input', 2)
subplot(3,3,3)
plotmf(initFis, 'input', 3)
subplot(3,3,4)
plotmf(initFis, 'input', 4)
subplot(3,3,5)
plotmf(initFis, 'input', 5)
subplot(3,3,6)
plotmf(initFis, 'input', 6)
subplot(3,3,7)
plotmf(initFis, 'input', 7)
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
subplot(3,3,1)
plotmf(chkFis, 'input', 1)
subplot(3,3,2)
plotmf(chkFis, 'input', 2)
subplot(3,3,3)
plotmf(chkFis, 'input', 3)
subplot(3,3,4)
plotmf(chkFis, 'input', 4)
subplot(3,3,5)
plotmf(chkFis, 'input', 5)
subplot(3,3,6)
plotmf(chkFis, 'input', 6)
subplot(3,3,7)
plotmf(initFis, 'input', 7)
suptitle('Membership Functions After Training');
saveas(gcf, 'MembershipFunctionsAfterTraining1.png');


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
anfis_output = evalfis([d_trn(:,1:7); d_val(:, 1:7) ; d_chk(:, 1:7)], chkFis);
%round the results (classification problem)  
anfis_output = round(anfis_output);
for i = 1:N
    if anfis_output(i) <= 0
        anfis_output(i) = 1;
    end
    if anfis_output(i) >= n_clusters + 1
        anfis_output(i) = n_clusters;
    end
end

%error matrix
E = zeros(n_clusters);
for i = 1:N
    E(anfis_output(i), wifi_localization(i,8)) = E(anfis_output(i), wifi_localization(i,8)) + 1;
end
E

%Overall accuracy
OA = sum(diag(E))/N

%Producer’s accuracy – User’s accuracy
PA = zeros(n_clusters,1);
UA = zeros(n_clusters,1);
for i = 1:n_clusters
    PA(i) = E(i,i)/sum(E(:, i));
    UA(i) = E(i,i)/sum(E(i, :));
end
PA
UA

%K
temp = 0;
for i = 1:n_clusters
    temp = temp + sum(E(:, i))*sum(E(i, :)); 
end

K = (N*sum(diag(E))- temp)/(N^2 - temp)


