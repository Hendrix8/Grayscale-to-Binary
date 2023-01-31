clear;
clc;

close all; 
format compact;

dbstop if error; 
dbstop if warning; 

tic

% ideal parameters through experiments
% cameraman R = 80, C = 11
% coins R = 45, C = -6
% image R = 60, C = 4
% lena_gray R = 40, C = 5
% sonet R = 18, C = 7
% sudoku R = 18, C = 7
% tool R = 70, C = 0

% ============== Choose Image ============== 
image_file = 'images/lena_gray.png'; 
image_name = 'lena_gray.png';
% ==========================================

image = imread(image_file); % reading the image
[rows, columns] = size(image); % getting the rows and columns of the image

R = 55;
C = 9;

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

        % the center is x + R, y + R and so we want the mask [x:x+2R, y:y+2R]
        for i = x : x + 2 * R
            for j = y : y + 2 * R
                win(end + 1) = image_padded(i, j); % getting the window of the image with respect to R
       
            end
        end
       
           
        win_size = size(win);
        win = reshape(win, [win_size(1) .* win_size(2), 1]); % flattening the mask
        
        t_list(end + 1) = median(win) - C; % calculating the threshold for each pixel

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