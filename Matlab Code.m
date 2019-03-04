% Reading Video file
clc
clear all
V=VideoReader('vidi.mp4');
while hasFrame(V)
    video = readFrame(V);
end
whos video

display(V); %To Show properties of a Video file
implay('vidi')
YIQ=rgb2ntsc(video); %RGB TO YIQ
Y = YIQ(:,:,1); %luminance (intensity) Y
I = YIQ(:,:,2); %first color component I
Q = YIQ(:,:,3); %second color component Q
figure, imshow(Y);
figure, imshow(I);
figure, imshow(Q);
figure, imshow(YIQ);
title('YIQ Image');


% Fast Fourier transform of Y,I&Q
Y_freq = fft2(Y);
Y_freq = fftshift(Y_freq);
Y_freq = abs(Y_freq); 
Y_freq = log(Y_freq+1);
Y_freq = mat2gray(Y_freq);

I_freq = fft2(I);
I_freq = fftshift(I_freq);
I_freq = abs(I_freq);
I_freq = log(I_freq+1);
I_freq = mat2gray(I_freq);

Q_freq = fft2(Q);
Q_freq = fftshift(Q_freq);
Q_freq = abs(Q_freq);
Q_freq = log(Q_freq+1);
Q_freq = mat2gray(Q_freq);

% Y,I,Q in spatial domain
figure;
subplot(1,3,1),imshow(Y);
title('Y Frame')
subplot(1,3,2),imshow(I);
title('I Frame')
subplot(1,3,3),imshow(Q);
title('Q Frame')
% Y,I,Q in in frequency domain
figure;
subplot(1,3,1),imshow(Y_freq,[]);
title('Y Frame');
subplot(1,3,2),imshow(I_freq,[]);
title('I Frame');
subplot(1,3,3),imshow(Q_freq,[]);
title('Q Frame');

%Conversion of frame data to raster
Y_raster=im2col(Y,[480 720],'distinct');
I_raster=im2col(I,[480 720],'distinct');
Q_raster=im2col(Q,[480 720],'distinct');

figure;
Fs=30*720*480; % Fs = sampling rate
subplot(1,3,1),plot([0:1/Fs:720*480/Fs-1/Fs],Y_raster(1:720*480));
ylabel('Gray Level');
xlabel('Time');
title('Y-Waveform') %Plotting Y Waveform
axis ([0,1E-4,0,0.3]);
% Filtering Y raster through Low pass filter
Filtered_Y=filter(Hdy,Y_raster);
fvtool(Filtered_Y);
title('Filtered Y')



%Reciever side

Filtered_Y_reciver=filter(Hdy,Filtered_Y);
fvtool(Filtered_Y_reciver);
title('Filtered Y reciever')
% YIQ recovered
YIQ_recovered=Filtered_Y_reciver+I_raster+Q_raster;
subplot(1,1,1),plot([0:1/Fs:720*1/Fs-1/Fs],YIQ_recovered(1:720*1));
ylabel('Gray Level');
xlabel('Time');
title('YIQ_recovered') %Plotting YIQ_recovered Waveform

% Raster to Image frames
YIQ_Frames=col2im(YIQ_recovered(1:480*720),[1 1],[480 720]);
imshow(YIQ_Frames);
y=YIQ_Frames(:,:,1);
i=YIQ_Frames(:,:,2);
q=YIQ_Frames(:,:,3);

%Converting Recovered YIQ to RGB
r_frame=y+0.956*i+0.620*q;
g_frame=y-0.272*i-0.647*q;
b_frame=y-1.108*i+1.7*q;

rgb(:,:,1)=r_frame;
rgb(:,:,2)=g_frame;
rgb(:,:,3)=b_frame;
%Recovered Final Video
implay(rgb);



