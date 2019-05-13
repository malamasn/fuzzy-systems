clear all

% first i create the fuzzy system
fis = newfis('dc', 'mamdani', 'min', 'max', 'min', 'max', 'centroid');

%i add variables
fis = addvar(fis, 'input', 'e', [-1 1]);
fis = addvar(fis, 'input', 'de', [-1 1]);
fis = addvar(fis, 'output', 'du', [-1 1]);

% add membership functions to fis inputs
% membership functions for e
fis = addmf(fis, 'input', 1, 'NL', 'trimf', [-1 -1 -0.67]);
fis = addmf(fis, 'input', 1, 'NM', 'trimf', [-1 -0.67 -0.33]);
fis = addmf(fis, 'input', 1, 'NS', 'trimf', [-0.67 -0.33 0]);
fis = addmf(fis, 'input', 1, 'ZR', 'trimf', [-0.33 0 0.33]);
fis = addmf(fis, 'input', 1, 'PS', 'trimf', [0 0.33 0.67]);
fis = addmf(fis, 'input', 1, 'PM', 'trimf', [0.33 0.67 1]);
fis = addmf(fis, 'input', 1, 'PL', 'trimf', [0.67 1 1]);

% membership functions for de
fis = addmf(fis, 'input', 2, 'NL', 'trimf', [-1 -1 -0.67]);
fis = addmf(fis, 'input', 2, 'NM', 'trimf', [-1 -0.67 -0.33]);
fis = addmf(fis, 'input', 2, 'NS', 'trimf', [-0.67 -0.33 0]);
fis = addmf(fis, 'input', 2, 'ZR', 'trimf', [-0.33 0 0.33]);
fis = addmf(fis, 'input', 2, 'PS', 'trimf', [0 0.33 0.67]);
fis = addmf(fis, 'input', 2, 'PM', 'trimf', [0.33 0.67 1]);
fis = addmf(fis, 'input', 2, 'PL', 'trimf', [0.67 1 1]);

% membership functions for du
fis = addmf(fis, 'output', 1, 'NV', 'trimf', [-1 -1 -0.75]);
fis = addmf(fis, 'output', 1, 'NL', 'trimf', [-1 -0.75 -0.5]);
fis = addmf(fis, 'output', 1, 'NM', 'trimf', [-0.75 -0.5 -0.25]);
fis = addmf(fis, 'output', 1, 'NS', 'trimf', [-0.5 -0.25 0]);
fis = addmf(fis, 'output', 1, 'ZR', 'trimf', [-0.25 0 0.25]);
fis = addmf(fis, 'output', 1, 'PS', 'trimf', [0 0.25 0.5]);
fis = addmf(fis, 'output', 1, 'PM', 'trimf', [0.25 0.5 0.75]);
fis = addmf(fis, 'output', 1, 'PL', 'trimf', [0.5 0.75 1]);
fis = addmf(fis, 'output', 1, 'PV', 'trimf', [0.75 1 1]);

% add rules
% e = NL
ruleList =[1 7 5 1 1
           1 6 4 1 1
           1 5 3 1 1
           1 4 2 1 1
           1 3 1 1 1 
           1 2 1 1 1 
           1 1 1 1 1];
 fis = addrule(fis, ruleList);
 
 % e = NM
 ruleList = [2 7 6 1 1
             2 6 5 1 1
             2 5 4 1 1 
             2 4 3 1 1
             2 3 2 1 1
             2 2 1 1 1
             2 1 1 1 1];
fis = addrule(fis, ruleList);   

% e = NS
 ruleList = [3 7 7 1 1
             3 6 6 1 1
             3 5 5 1 1 
             3 4 4 1 1
             3 3 3 1 1
             3 2 2 1 1
             3 1 1 1 1];
 fis = addrule(fis, ruleList);

% e = ZR
ruleList = [4 7 8 1 1
            4 6 7 1 1
            4 5 6 1 1
            4 4 5 1 1 
            4 3 4 1 1
            4 2 3 1 1
            4 1 2 1 1];
fis = addrule(fis, ruleList);

% e = PS
ruleList = [5 7 9 1 1
            5 6 8 1 1
            5 5 7 1 1 
            5 4 6 1 1
            5 3 5 1 1
            5 2 4 1 1
            5 1 3 1 1];
fis = addrule(fis, ruleList);

% e = PM
ruleList = [6 7 9 1 1
            6 6 9 1 1
            6 5 8 1 1
            6 4 7 1 1
            6 3 6 1 1
            6 2 5 1 1
            6 1 4 1 1];
fis = addrule(fis, ruleList);

% e = PL
ruleList = [7 7 9 1 1 
            7 6 9 1 1 
            7 5 9 1 1
            7 4 8 1 1
            7 3 7 1 1
            7 2 6 1 1
            7 1 5 1 1];
fis = addrule(fis, ruleList);
 
writefis(fis,'dc.fis')
