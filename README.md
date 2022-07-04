# cut-cat

cut-cat is a minimal video editing bash script that relies on ffmpeg.
It was developed to edit videos quickly without transcoding them, but ffmpeg options can be easily changed. 
The primary goals are speed, ease of use, and stability. 
Input files are not modified. 
Things may not work properly with different video formats from different sources without transcoding. 
It works great with the H.264/AAC/.mp4 video from my HTC One and my GoPro.



# usage information

Here is an example project.sh script that uses cut-cat (you can also simple call one the script and do interactively in bash). 
Just run the project.sh script to assemble the output video.
Generally I set cut-cat.sh in my PATH variable

```
#!/bin/bash
. cut-cat.sh                    # source this cut-cat script
newcat                          # reset cut number to start new output file
cut video1.mp4                  # use entire video
cut video2.mp4 13 22            # second syntax
cut video2.mp4 1:33 01:59       # minute syntax
cut video3.mp4 0:0:58 00:01:56  # hour syntax
cut video3.mp4 0:0:58.0 00:01:56.0  # hour syntax
cut video3.mp4 2:38             # use last part of video
cat project.mp4                 # concatenate all of the cuts
```


**newcat**: reset cut number to start new output file

**clean**: remove support files

**cut input_video [optional start time] [optional end time]**: create a cut file (if only one parameter is specified, is used as start time)

**cat output_video**: generate the final output video



