filePath = 'C:\Users\MY\Desktop\';
csvFileName = '20151208_161513';
file = [filePath, csvFileName];
file = [file, '.csv'];


[ndata, text] = xlsread(file);
len = length(ndata);    % length of rows

tagA = rawDataPacket('3139');
tagB = rawDataPacket('3131');
tagC = rawDataPacket('3114');

for i = 1 : 1 : len
    epc = ndata(i, 1);
    %time = ndata(i, 2);
    %antenna = ndata(i, 3);
    %tx_power = ndata(i, 4);
    %frequency = ndata(i, 5);
    %rssi = ndata(i, 6);
    phase_in_radian = ndata(i, 7);
    %phase_in_degree = ndata(i, 8);
    %doppler_shift = ndata(i, 9);
    %velocity = ndata(i, 10);
    
    if epc == tagA.EPC
        append(tagA.PhaseInRadian, phase_in_radian);
        %append(tagA.DopplerShift, doppler_shift);
        %append(tagA.RSSI, rssi);
    elseif epc == tagB.EPC
        append(tagB.PhaseInRadian, phase_in_radian);
        %append(tagB.DopplerShift, doppler_shift);
        %append(tagB.RSSI, rssi);
    elseif epc == tagC.EPC
        append(tagC.PhaseInRadian, phase_in_radian);
        %append(tagC.DopplerShift, doppler_shift);
        %append(tagC.RSSI, rssi);
    end
end 

% let average phase in 5 seconds as the measured phase.
phaseA = mean(tagA.PhaseInRadian);
phaseB = mean(tagB.PhaseInRadian);
phaseC = mean(tagC.PhaseInRadian);

% First distribution solution
distAB = 0.08; % m
distBC = 0.08; % m
distAC = 0.16; % m

% hyperbola parameters. suppose the tag B's location is the original point of local coordinate
% A(distAB, 0);  B(0, 0);   C(-distBC, 0)
% focus point: A, C;
[AC_a1, AC_b1, AC_a2, AC_b2] = HyperbolaParameters(phaseA, phaseC, tagA.Frequency, distAC / 2);
[r_AC_a1, r_AC_b1, r_AC_a2, r_AC_b2] = HyperbolaParameters(phaseC, phaseA, tagA.Frequency, distAC / 2);

% focus point: A, B;
[AB_a1, AB_b1, AB_a2, AB_b2] = HyperbolaParameters(phaseA, phaseB, tagA.Frequency, distAB / 2);
[r_AB_a1, r_AB_b1, r_AB_a2, r_AB_b2] = HyperbolaParameters(phaseB, phaseA, tagA.Frequency, distAB / 2);

% focus point: B, C;
[BC_a1, BC_b1, BC_a2, BC_b2] = HyperbolaParameters(phaseB, phaseC, tagB.Frequency, distBC / 2);
[r_BC_a1, r_BC_b1, r_BC_a2, r_BC_b2] = HyperbolaParameters(phaseC, phaseB, tagB.Frequency, distBC / 2);


syms x, y;
AC_eqn_1 = 'x^2/(AC_a1^2) - y^2/(AC_b1^2) = 1';
AC_eqn_2 = 'x^2/(r_AC_a1^2) - y^2/(r_AC_a1^2) = 1';

AB_eqn_1 = '(x-distAB/2)^2/(AB_a1^2) - y^2/(AB_b1^2) = 1';
AB_eqn_2 = '(x-distAB/2)^2/(r_AB_a1^2) - y^2/(r_AB_b1^2) = 1';
[x, y] = slove(AC_eqn_1, AC_eqn_2, AB_eqn_1, AB_eqn_2);

x
y
 
% get data
figure();
plot(ndata(:, 8)); % phase 