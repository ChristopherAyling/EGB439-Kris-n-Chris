function showImages(images)
    figure(3)
    hold on
    n_images = length(images)
    for i = 1:n_images
        subplot(1, n_images, i);
        imshow(images{i})
    end
end