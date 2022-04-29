%% HOW TO USE THIS CODE:
% This code compares the data measured with the Aurora sensor at the
% beginning of the experiment with the data measured also with the Aurora
% sensor after running the simulation using the KUKA robot.

clear; clc; close all

%% Importing the data

measured_table = readtable("filtered_walking_3.csv");
kuka_table = readtable("walking_kuka.csv");

measured_x = measured_table{:,2};
measured_y = measured_table{:,3};
measured_z = measured_table{:,4};

kuka_y = kuka_table{:,2};
kuka_x = kuka_table{:,3};
kuka_z = kuka_table{:,4};


measured_x_sub = measured_x(2030:end-1007);
measured_y_sub = measured_y(2030:end-1007);
measured_z_sub = measured_z(2030:end-1007);

kuka_x = kuka_x(17:end-17) + 0.38;
kuka_y = kuka_y(17:end-17) + 0.093;
kuka_z = kuka_z(17:end-17);

kuka = [kuka_x,kuka_y];
theta = -pi/14;
x_center = kuka_x(1);
y_center = kuka_y(1);
center = repmat([x_center; y_center], 1, length(kuka_x));
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
s = kuka' - center;     % shift points in the plane so that the center of rotation is at the origin
so = R*s;           % apply the rotation about the origin
vo = so + center; 
kuka_x_rotated = vo(1,:);
kuka_y_rotated = vo(2,:);


%% Data Manipulation

% Flip the data of the vertical axis as the sensor was upside down
for i=1:length(kuka_z)
    kuka_z(i) = kuka_z(i)*-1;
end

new_kuka_x = resample(kuka_x_rotated, 808, 1003)';
new_kuka_y = resample(kuka_y_rotated, 808, 1003)';
new_kuka_z = resample(kuka_z, 808, 1003);

for i=1:length(new_kuka_x)
    new_kuka_x(i) = new_kuka_x(i);
    new_kuka_y(i) = new_kuka_y(i);
    new_kuka_z(i) = new_kuka_z(i);
    measured_x_sub(i) = measured_x_sub(i);
    measured_y_sub(i) = measured_y_sub(i);
    measured_z_sub(i) = measured_z_sub(i);
end

new_kuka_x = new_kuka_x(10:end-10)-new_kuka_x(10);
new_kuka_y = new_kuka_y(10:end-10)-new_kuka_y(10);
new_kuka_z = new_kuka_z(10:end-10)-new_kuka_z(10);
measured_x_sub = measured_x_sub(10:end-10)-measured_x_sub(10);
measured_y_sub = measured_y_sub(10:end-10)-measured_y_sub(10);
measured_z_sub = measured_z_sub(10:end-10)-measured_z_sub(10);

[corr_x, pval_x] = corr(measured_x_sub,new_kuka_x);
[corr_y, pval_y] = corr(measured_y_sub,new_kuka_y);
[corr_z, pval_z] = corr(measured_z_sub,new_kuka_z);

%% Plot data

rounding_val = 3;

figure('Name','Walking','NumberTitle','off');
subplot(2,2,1);
plot(new_kuka_x);
hold on;
plot(measured_x_sub);
hold off;
grid on;
ylabel('metres', 'FontSize',16);
xlim([0 length(new_kuka_x)]);
set(gca,'XTick',[]);
title(['Motion in x' newline 'Linear Correlation Coefficient: ' num2str(round(corr_x, rounding_val)) newline 'p-value: ' num2str(round(pval_x, rounding_val))], 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16, 'Location', 'northwest');

subplot(2,2,2);
plot(new_kuka_y);
hold on;
plot(measured_y_sub);
hold off;
grid on;
ylabel('metres', 'FontSize',16);
xlim([0 length(new_kuka_x)]);
set(gca,'XTick',[]);
title(['Motion in y' newline 'Linear Correlation Coefficient: ' num2str(round(corr_y, rounding_val)) newline 'p-value: ' num2str(round(pval_y, rounding_val))], 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16, 'Location', 'northeast');

subplot(2,2,3);
plot(new_kuka_z);
hold on;
plot(measured_z_sub);
hold off;
grid on;
ylabel('metres', 'FontSize',16);
xlim([0 length(new_kuka_x)]);
set(gca,'XTick',[]);
title(['Motion in z' newline 'Linear Correlation Coefficient: ' num2str(round(corr_z, rounding_val)) newline 'p-value: ' num2str(round(pval_z, rounding_val))], 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16, 'Location', 'northwest');

subplot(2,2,4);
plot3(new_kuka_x, new_kuka_y, new_kuka_z);
hold on;
plot3(measured_x_sub, measured_y_sub, measured_z_sub);
hold off;
grid on;
xlabel('metres', 'FontSize',16);
ylabel('metres', 'FontSize',16);
zlabel('metres', 'FontSize',16);
axis equal;
title('Whole Motion', 'FontSize',24);
legend('KUKA Motion', 'Human Motion Data', 'FontSize',16);

figure('Name','Section Considered','NumberTitle','off');
plot3(measured_x,measured_y,measured_z);
hold on;
plot3(measured_x(2030:end-1007),measured_y(2030:end-1007),measured_z(2030:end-1007),'LineWidth',5);
hold off;
grid on;
xlabel('x coordinate', 'FontSize',16);
ylabel('y coordinate', 'FontSize',16);
zlabel('z coordinate', 'FontSize',16);
title('Whole Motion', 'FontSize',24);
legend('Whole Motion', 'Section Considered', 'FontSize',16);
axis equal;