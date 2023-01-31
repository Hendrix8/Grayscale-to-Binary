clear;
clc;

close all; 
format compact;

dbstop if error; 
dbstop if warning; 

tic

% ============== Choose Image ============== 
image_file = 'images/cameraman.tif';
image_name = 'cameraman.tif';
name_only = 'cameraman';
% ==========================================

image = imread(image_file); % reading the image
[rows, columns] = size(image); % getting the rows and columns of the image

prob_list = zeros(1, 256); % initializing the list with probabilities p_i
i_pi_list = zeros(1, 256); % list for calculating m_0 and m_1

sigma2_b_list = zeros(1, 256); % initializing the list with values of var in between

for i = 0:255 
    pi = p(rows, columns, image, i);
    i_pi = i .* pi;

    prob_list(i + 1) = pi; % adding the values of pi in the prob_list
    i_pi_list(i + 1) = i_pi; % adding the values of i_pi in the i_pi_list
end




for t = 0:255
    
    w0 = sum(prob_list(1 : t+1));
    m0 = 1/w0 .* sum(i_pi_list(1 : t+1));

    if t == 255 
        w1 = 0;
        m1 = 0;
    else
        w1 = sum(prob_list(t + 2 : 256)); 
        m1 = 1/w1 .* sum(i_pi_list(t + 2 : 256)); 
    end
    
   

    s2_b = w0 .* w1 .* (m0 - m1)^2; % calculating variance in between
    sigma2_b_list(t + 1) = s2_b; % adding the value to the list of variances
    
end

% finding the threshold value and the s2_b of that value
s2_b_max = max(sigma2_b_list);
T = find(sigma2_b_list == s2_b_max);

binary_image = binarize(image, T); % making the image binary

imwrite(binary_image, strcat('binary_images/binary_', image_name)); % saving the binary image


figure('Name', 'Binary_Image')
imshow(binary_image) % showing binary image

figure('Name', 'Histogram');
image_hist(image, image_name, T); % showing the histogram with the threshold marked

saveas(gcf,strcat('histograms/',name_only, '_histogram.png'));

figure('Name', 'Image')
imshow(image) % showing original image

toc

%---------------------------------------------------------------------------------
% -------------------------------- FUNCTIONS -------------------------------------
%---------------------------------------------------------------------------------

% given the greylevel in the range [0,1,...,255] returns the number of pixels with
% that grey level
function num_pix = h(rows, columns, image, i)

    num_pix = 0;
    
    for k = 1:rows
        for l = 1:columns
            if i == image(k, l)
                num_pix = num_pix + 1;
            end
        end
    end
            
end


% creating the probability pi (returns the probability a pixel has the ith
% greylevel
function prob = p(rows, columns, image, i)
    N = rows .* columns;
    prob = h(rows, columns, image, i)/N;
end


% returning histogram of image 
function hist = image_hist(image, image_name, T)

    hist = []; 
    
    [rows, columns] = size(image); % getting the rows and columns of the image
    
    for gl = 0:255
        for k = 1:h(rows, columns, image, gl) % add the number i  h(i) times in the hist array
            hist(end + 1) = gl;
        end
    end
    
    histogram(hist); % creating the histogram
    title(strcat(image_name, ' histogram')) % putting the title
    xlabel('Graylevel') 
    ylabel('Frequency') 
    
    % adding text
    txt = strcat('T = ', string(T));
    y = [];
    for i = 0:255
        y(end + 1) = h(rows, columns, image, i);
    end
    
    text(T, max(y) , txt, 'FontSize', 14)
    
    % adding the threshold vertical line 
    line([T, T], ylim, 'LineWidth', 2, 'Color', 'r');
    
end

% binary image creation 
function bi = binarize(image, T)
    
    binary_image = image;
    [rows, columns] = size(image);
    % creating the new image
    for x = 1:rows
        for y = 1:columns
            if image(x, y) <= T
                binary_image(x,y) = 0;
            else 
                binary_image(x,y) = 255;
            end
        end
    end

    bi = binary_image;

end
