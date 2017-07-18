function view_simphosphene_stimuli
%Written by Xing 5/7/17

%grandMask with phosphene locations
figure
h = imshow(grandMask(:,:,1:3));
set(h,'AlphaData',255-grandMask(:,:,4))

lumCond=3;
figure
imshow(grandMasks2letter{lumCond}(:,:,1:3));%plot grandMask2 for letter A, with RGB values
hold on;
h = imshow(grandMask(:,:,1:3));%plot mask with Gaussians
set(h,'AlphaData',grandMask(:,:,4))
