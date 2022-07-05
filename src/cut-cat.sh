#!/bin/bash
#
# usage information
# cut input_video [optional start time] [optional end time]
# cat output_video
#
# Here is an example project.sh script that uses cut-cat. 
# Just run the project.sh script to assemble the output video.
#
# #!/bin/bash
# . cut-cat.sh                    # source this cut-cat script
# newcat                          # reset cut number to start new output file
# cut video1.mp4                  # use entire video
# cut video2.mp4 13 22            # second syntax
# cut video2.mp4 1:33 01:59       # minute syntax
# cut video3.mp4 0:0:58 00:01:56  # hour syntax
# cut video3.mp4 0:0:58.0 00:01:56.0  # hour syntax
# cut video3.mp4 2:38             # use last part of video
# cat project.mp4                 # concatenate all of the cuts


cut_number=0


newcat ()
{
    cut_number=0
}



cut ()
{
    input_file=$1
    start_time=$2
    end_time=$3
    cut_number=$((cut_number+1))
    if [ $cut_number == 0 ]; then
        rm -f cut*.ts
    fi
    rm -f cut$cut_number.ts

    echo ""
    echo "process cut $input_file s:$start_time e:$end_time"

    #ROTATION=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream_tags=rotate -of default=nw=1:nk=1 -i $input_file)
    #echo "rotation:${ROTATION}"

    PARAM="-hide_banner -loglevel panic"

    #time
    PARAM="${PARAM} -ss $start_time"
    if [ -n "$end_time" ]; then
        PARAM="${PARAM} -to $end_time"
    fi
    PARAM="${PARAM} -i $input_file"

    #param out
    PARAM="${PARAM} -map_metadata 0 -c:a copy "
    
    echo "param: ${PARAM}"

    echo "cutting to file : cut$cut_number.mp4"

    set -e
    ffmpeg ${PARAM} cut$cut_number.mp4 > /dev/null
    set +e

    echo "file cut$cut_number.mp4" >> cutfiles.txt

    echo "done : cut$cut_number.mp4"
}

cat ()
{
    output_file=$1
    if [ -e $output_file ]; then
        echo
        echo "ERROR: output file already exists: $output_file"
        exit 1
    fi
    concat_string="concat:"
    for ((c=1;$c<=$cut_number;c=$c+1)); do
        if [ $c == 1 ]; then
            concat_string="${concat_string}cut$c.mp4"
        else
            concat_string="$concat_string|cut$c.mp4"
        fi
    done

    echo "concat files:$cut_number"
    echo "concat files:$concat_string"

    ffmpeg -hide_banner -loglevel panic -f concat -i cutfiles.txt -map_metadata 0 -codec copy $output_file
#    ffmpeg -i "$concat_string" -c copy  $output_file

}

clean()
{
  rm cutfiles.txt
  rm -f cut*.mp4
}


rotate ()
{
   input_file=$1
   ffmpeg -i $input_file -vf "hflip,vflip,format=yuv420p" -metadata:s:v rotate=0  "r_$input_file"
}

post(){

    video_file=$1
    fade_in=$2
    fade_out=$3
    audio_file=$4

    dur=$(ffprobe -loglevel error -show_entries format=duration -of default=nk=1:nw=1 "$video_file")
    offset=$(bc -l <<< "$dur"-"$fade_out")
    echo "duration:$dur offset:$offset"

    fade_video="[0:v]fade=type=in:duration=$fade_in,fade=type=out:duration=$fade_out:start_time='$offset'[v];"
    echo "fade_video:$fade_video"

    fade_audio="[0:a]afade=type=in:duration=$fade_in,afade=type=out:duration=$fade_out:start_time='$offset'[a];"
    echo "fade_audio:$fade_audio"

    params="-i $video_file -i $audio_file -filter_complex '$fade_video$fade_audio' -map '[v]' -map '[a]' fade/'$video_file' -c:v copy -shortest"
    echo "params:$params"
    #ffmpeg -i video.mkv -i audio.mp3 -map 0 -map 1:a -c:v copy -shortest output.mkv
}

## fade
# video
#ffmpeg -i video.mp4 -vf "fade=t=in:st=0:d=10,fade=t=out:st=10:d=5" -c:a copy out.mp4
# audio
# ffmpeg -i music.mp3 -af "afade=t=in:st=0:d=5,afade=t=out:st=5:d=5" out.mp3

#  dur=$(ffprobe -loglevel error -show_entries format=duration -of default=nk=1:nw=1 "$f")
#  offset=$(bc -l <<< "$dur"-1)
#  ffmpeg -i "$f" -filter_complex "[0:v]fade=type=in:duration=1,fade=type=out:duration=1:start_time='$offset'[v];[0:a]afade=type=in:duration=1,afade=type=out:duration=1:start_time='$offset'[a]" -map "[v]" -map "[a]" fade/"$f"
