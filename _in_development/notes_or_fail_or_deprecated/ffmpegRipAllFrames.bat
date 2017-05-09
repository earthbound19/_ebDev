ECHO OFF
REM Command updated thanks to a post here (it wouldn't accept the -image2 parameter anymore. ?) : http://gutsup.tumblr.com/post/7337621736/converting-video-to-image-sequences-with-ffmpeg
mkdir %1_frames
The double % is necessary to "escape" that character from DOS so that ffmpeg will actually recieve one percent symbol %:
ffmpeg -i %1 %1_frames\%1_fr%%7d.png