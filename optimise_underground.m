%% HOW TO USE THIS CODE:
% This code optimise the underground motion data so the robot can read it
% Use this code after running kinza_code with underground data
% (testu.csv)

clear; clc;

%% Importing the data

% NOTE: the column order needs to be: Time, Horizontal Movement, Forward and
% Backward, Vertical Movement
% underground_motion.csv
read_data = readtable("underground_motion.csv");

%% Optimise the data

% Create an array for time and motion in each of the axis
time = read_data{:,1}; % time
x_coor = read_data{:,2};
y_coor = read_data{:,3};
z_coor = read_data{:,4}; % vertical motion


for i=1:length(x_coor)
    
    if x_coor(1) > 0
        x_coor(i) = x_coor(i) - abs(x_coor(1));
    elseif x_coor(1) < 0
        x_coor(i) = x_coor(i) + abs(x_coor(1));
    else
        x_coor(i) = x_coor(i);
    end
       
end



num = 100;
distance_moved = 0.1;
line_x = linspace(0,-distance_moved,num);
line_y = linspace(0, 0,num);
line_z = linspace(0, 0,num);


% Create final arrays by combining both parts above

for i=2:length(x_coor)
    line_x(end+1) = x_coor(i) - distance_moved;
    line_y(end+1) = y_coor(i);
    line_z(end+1) = z_coor(i);
end

x_coor = line_x;
y_coor = line_y;
z_coor = line_z;




% Create time array for the data
time_interval = time(2) - time(1);
init = 0;
for i=1:length(x_coor)
    time_final(i) = init;
    init = init + time_interval;
end

% Combine the whole data into 1 array
for i=1:length(x_coor)
    ubuntu_data(i,1) = time_final(i);
    if x_coor(1) > 0
        ubuntu_data(i,2) = x_coor(i) - abs(x_coor(1));
    elseif x_coor(1) < 0
        ubuntu_data(i,2) = x_coor(i) + abs(x_coor(1));
    else
        ubuntu_data(i,2) = x_coor(i);
    end
    

    if y_coor(1) > 0
        ubuntu_data(i,3) = y_coor(i) - abs(y_coor(1));
    elseif y_coor(1) < 0
        ubuntu_data(i,3) = y_coor(i) + abs(y_coor(1));
    else
        ubuntu_data(i,3) = y_coor(i);
    end
     
    % Vertical Movement
    if z_coor(1) > 0
        ubuntu_data(i,4) = z_coor(i) - abs(z_coor(1));
    elseif z_coor(1) < 0
        ubuntu_data(i,4) = z_coor(i) + abs(z_coor(1));
    else
        ubuntu_data(i,4) = z_coor(i);
    end
     
end

figure('Name','Underground Motion','NumberTitle','off');
plot3(ubuntu_data(:,2), ubuntu_data(:,3), ubuntu_data(:,4));
xlabel('X Coordinate');
ylabel('Y Coordinate');
zlabel('Z Coordinate');
title('Whole Motion in 3D');
axis equal;
grid on;

% Add header
header = {'Time', 'Tx', 'Ty', 'Tz'};
ubuntu_data = [header; num2cell(ubuntu_data)];

%% Save data into a CSV file
%writecell(ubuntu_data, 'underground_motion_v2.csv');