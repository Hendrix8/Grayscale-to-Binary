clear;
clc;

close all; 
format compact;

dbstop if error; 
dbstop if warning; 

tic

% ideal parameters through experiments
% cameraman R = 80, C = 20
% coins R = 40, C = -10
% image R = 25, C = 20
% lena_gray R = 50, C = 0
% sonet R = 25, C = 12
% sudoku R = 50, C = 7
% tool R = 70, C = 2.8

% ============== Choose Image ============== 
image_file = 'images/tool.png'; 
image_name = 'tool.png';
% ==========================================

image = imread(image_file); % reading the image
[rows, columns] = size(image); % getting the rows and columns of the image

R = 70;
C = 2.08;

N = rows .* columns; 
t_list = []; % initializing the list that will contain all the thresholds

R = round(R); % keeping R an integer 

image_padded = padarray(image,[R,R], "replicate");

% looping through every point in the image and checking its neighbors with
% respect to window R 
for x = 1:rows
    for y = 1:columns
        win = [];
        im_size = size(image);

        % the center is x + R, y + R and so we want the window x:x+2R, y:y+2R
        for i = x : x + 2 * R
            for j = y : y + 2 * R
                win(end + 1) = image_padded(i, j); % getting the window of the image with respect to R
       
            end
        end
       
           
        win_size = size(win);
        win = reshape(win, [win_size(1) .* win_size(2), 1]); % flattening the window
        
        t_list(end + 1) = (min(win) + max(win))/2 - C; % calculating the threshold for each pixel

    end
end

binary_image = binarize(image, t_list);
imshowpair(image,binary_image, 'montage')

imwrite(binary_image, strcat('binary_images/binary_', image_name)); % saving the binary image

toc

%---------------------------------------------------------------------------------
% -------------------------------- FUNCTIONS -------------------------------------
%---------------------------------------------------------------------------------

function b = binarize(image, T_list)
    
    b = image;
    counter_T_list = 1;
    [rows, columns] = size(image);
    for i = 1:rows
        for j = 1:columns
            if image(i, j) <=  T_list(counter_T_list)
                b(i, j) = 0;
               counter_T_list = counter_T_list + 1;
            else
                b(i, j) = 255;
                counter_T_list = counter_T_list + 1;

            end
        end
    end        
end