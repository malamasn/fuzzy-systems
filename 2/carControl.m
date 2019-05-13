clear all
%first we create the fuzzy system
fis = newfis( 'fismat', 'mamdani', 'min', 'max', 'prod', 'max', 'centroid');
%then add all variables
fis = addvar(fis, 'input', 'dV', [0 1]);
fis = addvar(fis, 'input', 'dH', [0 1]);
fis = addvar(fis, 'input', 'theta', [-180 180]);
fis = addvar(fis, 'output', 'dtheta', [-130 130]);

%then we add the membership functions
%dV
fis = addmf(fis, 'input', 1, 'S', 'trimf', [0 0 0.5]);
fis = addmf(fis, 'input', 1, 'M', 'trimf', [0 0.5 1]);
fis = addmf(fis, 'input', 1, 'L', 'trimf', [0.5 1 1]);
%dH
fis = addmf(fis, 'input', 2, 'S', 'trimf', [0 0 0.5]);
fis = addmf(fis, 'input', 2, 'M', 'trimf', [0 0.5 1]);
fis = addmf(fis, 'input', 2, 'L', 'trimf', [0.5 1 1]);
%theta
fis = addmf(fis, 'input', 3, 'N', 'trimf', [-180 -180 0]);
fis = addmf(fis, 'input', 3, 'ZE', 'trimf', [-180 0 180]);
fis = addmf(fis, 'input', 3, 'P', 'trimf', [0 180 180]);
%dtheta
fis = addmf(fis, 'output', 1, 'N', 'trimf', [-130 -130 0]);
fis = addmf(fis, 'output', 1, 'ZE', 'trimf', [-130 0 130]);
fis = addmf(fis, 'output', 1, 'P', 'trimf', [0 130 130]);


%finally we add the rule base
fis = addrule(fis, [1 1 1 3 1 1]);
fis = addrule(fis, [1 1 2 3 1 1]);
fis = addrule(fis, [1 1 3 1 1 1]);
fis = addrule(fis, [2 1 1 3 1 1]);
fis = addrule(fis, [2 1 2 3 1 1]);
fis = addrule(fis, [2 1 3 1 1 1]);
fis = addrule(fis, [3 1 1 3 1 1]);
fis = addrule(fis, [3 1 2 3 1 1]);
fis = addrule(fis, [3 1 3 1 1 1]);

fis = addrule(fis, [1 2 1 3 1 1]);
fis = addrule(fis, [1 2 2 3 1 1]);
fis = addrule(fis, [1 2 3 1 1 1]);
fis = addrule(fis, [2 2 1 3 1 1]);
fis = addrule(fis, [2 2 2 2 1 1]);
fis = addrule(fis, [2 2 3 1 1 1]);
fis = addrule(fis, [3 2 1 3 1 1]);
fis = addrule(fis, [3 2 2 2 1 1]);
fis = addrule(fis, [3 2 3 1 1 1]);

fis = addrule(fis, [1 3 1 3 1 1]);
fis = addrule(fis, [1 3 2 3 1 1]);
fis = addrule(fis, [1 3 3 1 1 1]);
fis = addrule(fis, [2 3 1 3 1 1]);
fis = addrule(fis, [2 3 2 2 1 1]);
fis = addrule(fis, [2 3 3 1 1 1]);
fis = addrule(fis, [3 3 1 3 1 1]);
fis = addrule(fis, [3 3 2 2 1 1]);
fis = addrule(fis, [3 3 3 1 1 1]);

writefis(fis,'car.fis');
%now our model is ready so we have to test the results
%starting values
i = 1;
x(1) = 9;
y(1) = 4.4;
u = 0.05;
th(1) = 0;

dh(1) =1;
dv(1) =1;
fis = readfis('car.fis');
%this loop simulates the movement of the car
while (x(i) <= 15)
    dth(i) = evalfis([dh(i) dv(i) th(i)], fis);
    th(i+1) = th(i) + dth(i);
    a = th(i)*pi/180;
    x(i+1) = x(i) + cos(a)*u*0.1;
    y(i+1) = y(i) + sin(a)*u*0.1;
    % check for obstacles
    if x(i+1) <= 10
        if y(i+1)<= 5
            dh(i+1) = 10 - x(i+1);
        else
            dh(i+1) = 1;
        end
    elseif x(i+1) <= 11
        if y(i+1)<= 6
            dh(i+1) = 11 - x(i+1);
        else
            dh(i+1) = 1;
        end
    elseif x(i+1) <= 12 
        if y(i+1)<= 7
            dh(i+1) = 12 - x(i+1);
        else
            dh(i+1) = 1;
        end
    elseif x(i+1) <= 15
        dh(i+1) = 1;
    else
        dh(i+1) = 0;
    end
    
    if y(i+1) <= 5
        dv(i+1) = 1;
    elseif y(i+1) <= 6
        if x(i+1) >= 10
            dv(i+1) = y(i+1) - 5;
        else
            dv(i+1) = 1;
        end
    elseif y(i+1) <= 7
        if x(i+1) >= 11
            dv(i+1) = y(i+1) - 6;
        else
            dv(i+1) = 1;
        end 
    elseif y(i+1) <= 7.2
        dv(i+1) = y(i+1) - 7;
    else
        dv(i+1) = 1;
    end
    
    i = i+1;

end

plot(x,y)
hold on
X = [0 10 10 11 11 12 12 15];
Y = [0 0 5 5 6 6 7 7];
a = area(X,Y,'DisplayName','Obstacles');
set(a, 'FaceColor', [0 0.75 0.75]);
hold on





