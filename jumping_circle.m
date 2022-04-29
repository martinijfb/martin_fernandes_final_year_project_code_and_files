%% HOW TO USE THIS CODE:
% This code creates a semicircular path of the robot motion while jumping
% The data that needs to be read is jumping data

clear; clc;

%% Read data
% data.csv contains Julia's jumping data

read_data = readtable("jumping_data.csv");

time = read_data{:,1}; % time
vertical_motion = read_data{:,4}; % vertical motion

%% Data Manipulation and adapting the motion to the robot

% get rid of initial and final data to make movement fluid
% modify this according to data: Use the vertical movement plot as a guide
vertical_motion = vertical_motion(50:393);

% Set how many times you want to repeat the data set
number_of_repeated_motions = 6;

%Find the number of data points needed
number_of_data_points = number_of_repeated_motions * length(vertical_motion);

% Make sure it's divisible by three
if mod(number_of_data_points, 3) == 1
    number_of_data_points = number_of_data_points - 1;
elseif mod(number_of_data_points, 3) == 2
    number_of_data_points = number_of_data_points - 2;    
end

% Some robot parameters
r = 0.65; % radius
x_centre = -r; % centre is shift as the robot motion starts relative to it's starting position
y_centre = 0;
robot_limit = pi/9; % Robot can turn only +/-170

%% Create robot motion data

% 1/3 of the motion (init part), get x and y coordinates.
theta = (linspace(0, pi-(robot_limit), number_of_data_points/3));
for i = 1:1:number_of_data_points/3
    x_init(i) = r * cos(theta(i)) + x_centre;
    y_init(i) = r * sin(theta(i)) + y_centre;
end

% get the rest of the motion, get x and y coordinates.
theta_2 = linspace(pi-(robot_limit), -pi+(robot_limit), 2*number_of_data_points/3);
for i = (number_of_data_points/3)+1:1:number_of_data_points
    x(i-number_of_data_points/3) = r * cos(theta_2(i-number_of_data_points/3)) + x_centre;
    y(i-number_of_data_points/3) = r * sin(theta_2(i-number_of_data_points/3)) + y_centre;
end

% Create final arrays by combining both parts above
x_final = x_init;
y_final = y_init;

for i=1:length(x)
    x_final(end+1) = x(i);
    y_final(end+1) = y(i); 
end

% Create time array for the data
time_interval = time(2) - time(1);
init = 0;
for i=1:length(x_final)
    time_final(i) = init;
    init = init + time_interval;
end


% create a final array for the vertical motion
final_vertical_motion = [];
loop_condition = true;

while loop_condition
    for i = 1:length(vertical_motion)
        final_vertical_motion(end+1) = vertical_motion(i);
        if length(final_vertical_motion) == number_of_data_points
            loop_condition = false;
            break;
        end
    end
end

%% Plots

% Vertical Motion
figure('Name','Vertical Motion','NumberTitle','off')
plot(vertical_motion);
title('Vertical Movement');
set(gca,'XTick',[]);
grid on;

% Robot Motion
figure('Name','Circular Motion Data','NumberTitle','off')
subplot(2,2,1)
plot3(x_init, y_init, final_vertical_motion(1:length(x_init)));
title('Initial Motion (1/3)', 'FontSize',24);
xlabel('x coordinate', 'FontSize',16);
ylabel('y coordinate', 'FontSize',16);
grid on;
axis equal;

subplot(2,2,2)
plot3(x, y, final_vertical_motion(length(x_init)+1:length(x_final)));
title('Final Part of Motion', 'FontSize',24);
xlabel('x coordinate', 'FontSize',16);
ylabel('y coordinate', 'FontSize',16);
grid on;
axis equal;

subplot(2,2,[3 4])
plot3(x_final, y_final, final_vertical_motion);
title('Whole Motion in 3D', 'FontSize',24);
xlabel('x coordinate', 'FontSize',16);
ylabel('y coordinate', 'FontSize',16);
zlabel('z coordinate', 'FontSize',16);
grid on;
axis equal;

%% Create final data

% Combine the whole data into 1 array
for i=1:length(x_final)
    ubuntu_data(i,1) = time_final(i);
    ubuntu_data(i,2) = x_final(i); 
    ubuntu_data(i,3) = y_final(i); 
    ubuntu_data(i,4) = final_vertical_motion(i); % Vertical Movement
end

% Add header
header = {'Time', 'Tx', 'Ty', 'Tz'};
ubuntu_data = [header; num2cell(ubuntu_data)];

%% Save data into a CSV file
%writecell(ubuntu_data, 'circular_jumping.csv')
