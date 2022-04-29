%% HOW TO USE THIS CODE:
% This code compares the data measured with the Aurora sensor at the
% beginning of the experiment with the data measured also with the Aurora
% sensor after running the simulation using the KUKA robot.

clear; clc; close all

%% Importing the data

measured_table = readtable("underground_motion_v2.csv");
kuka_table = readtable("underground_kuka.csv");

measured_x = measured_table{:,2};
measured_y = measured_table{:,3};
measured_z = measured_table{:,4};

kuka_y = kuka_table{:,2};
kuka_x = kuka_table{:,3};
kuka_z = kuka_table{:,4};

%% Data Manipulation

% Flip the data of the vertical axis as the sensor was upside down
for i=1:length(kuka_z)
    kuka_z(i) = kuka_z(i)*-1;
end

% Eliminate unuseful data due to filtering
start_of_data = 34; % Eliminate the first part of the data
end_of_data = 47; % Eliminate ht elast part of the data
count = 1;
for i=start_of_data:(length(kuka_x)-end_of_data)
    kuka_data(i-start_of_data+1,1) = kuka_x(i);
    kuka_data(i-start_of_data+1,2) = kuka_y(i);
    kuka_data(i-start_of_data+1,3) = kuka_z(i); 
    count = count +1;
end



%%
% Resample the data so it matches with the one measured at the beginning of
% the experiment
new_kuka_x = resample(kuka_data(:,1), 320, 1003);
new_kuka_y = resample(kuka_data(:,2), 320, 1003);
new_kuka_z = resample(kuka_data(:,3), 320, 1003);


% Eliminate data that should not be taken into consideration wfor
% comparison
start_of_data = 100; % Eliminate the first part of the data
end_of_data = 10; % Eliminate ht elast part of the data
for i=start_of_data:(length(new_kuka_x)-end_of_data)
    kuka_data_2(i-start_of_data+1,1) = new_kuka_x(i) - new_kuka_x(start_of_data);
    kuka_data_2(i-start_of_data+1,2) = new_kuka_y(i) - new_kuka_y(start_of_data);
    kuka_data_2(i-start_of_data+1,3) = new_kuka_z(i) - new_kuka_z(start_of_data);
    kuka_data_2(i-start_of_data+1,4) = measured_x(i) - measured_x(start_of_data);
    kuka_data_2(i-start_of_data+1,5) = measured_y(i) - measured_y(start_of_data);
    kuka_data_2(i-start_of_data+1,6) = measured_z(i) - measured_z(start_of_data);
end

%% Calculate linear correlation coefficient
[corr_x, pval_x] = corr(kuka_data_2(:,1), kuka_data_2(:,4));
[corr_y, pval_y] = corr(kuka_data_2(:,2), kuka_data_2(:,5));
[corr_z, pval_z] = corr(kuka_data_2(:,3), kuka_data_2(:,6));

%% Plot data

rounding_val = 3;

figure('Name','Standing and Sitting','NumberTitle','off');
subplot(2,2,1);
plot(kuka_data_2(:,1));
hold on;
plot(kuka_data_2(:,4));
hold off;
grid on;
ylabel('metres', 'FontSize',16);
xlim([0 length(kuka_data_2(:,3))])
set(gca,'XTick',[]);
title(['Motion in x' newline 'Linear Correlation Coefficient: ' num2str(round(corr_x, rounding_val)) newline 'p-value: ' num2str(round(pval_x, rounding_val))], 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16, 'Location', 'northwest');

subplot(2,2,2);
plot(kuka_data_2(:,2));
hold on;
plot(kuka_data_2(:,5));
hold off;
grid on;
ylabel('metres', 'FontSize',16);
xlim([0 length(kuka_data_2(:,3))])
set(gca,'XTick',[]);
title(['Motion in y' newline 'Linear Correlation Coefficient: ' num2str(round(corr_y, rounding_val)) newline 'p-value: ' num2str(round(pval_y, rounding_val))], 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16, 'Location', 'northwest');

subplot(2,2,3);
plot(kuka_data_2(:,3));
hold on;
plot(kuka_data_2(:,6));
hold off;
grid on;
ylabel('metres', 'FontSize',16);
xlim([0 length(kuka_data_2(:,3))])
set(gca,'XTick',[]);
title(['Motion in z' newline 'Linear Correlation Coefficient: ' num2str(round(corr_z, rounding_val)) newline 'p-value: ' num2str(round(pval_z, rounding_val))], 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16, 'Location', 'northwest');

subplot(2,2,4);
plot3(kuka_data_2(:,1),kuka_data_2(:,2),kuka_data_2(:,3));
hold on;
plot3(kuka_data_2(:,4),kuka_data_2(:,5),kuka_data_2(:,6));
hold off;
grid on;
xlabel('metres', 'FontSize',16);
ylabel('metres', 'FontSize',16);
zlabel('metres', 'FontSize',16);
axis equal;
title('Whole Motion', 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16);
