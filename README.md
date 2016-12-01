# l2gDownloader
Shell-Script für den Download von lecture2go-Videos  
  
# cli-Hilfe

Usage: ./l2gDownloader.sh [-(va) URL [-p PASSPHRASE] [-r] [-c]]  
  
Options:  
&nbsp;&nbsp;-v URL        Download a video.  
&nbsp;&nbsp;-a URL        Download all videos of a lecture series of which the given url belongs to.  
&nbsp;&nbsp;-p PASSPHRASE Add passphrase for protected lecture series.  
&nbsp;&nbsp;-i TOKEN      Add authentification token for protected lecture series.  
&nbsp;&nbsp;-s RANGE      Specify a range of videos to download. Useless if combined with -v.  
&nbsp;&nbsp;-c            Compute MD5 checksum of the video file, add it to the file name  
&nbsp;&nbsp;-r            Download videos in reverse order: n --> 1 instead of 1 --> n (default behaviour). Useless if combined with -v.  
&nbsp;&nbsp;-m            Additionally convert video to audio track after downloading (requires ffmpeg).  
  
Examples:  
&nbsp;&nbsp;./l2gDownloader.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download a single video.  
  
&nbsp;&nbsp;./l2gDownloader.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download all videos of this lecture series.  
  
&nbsp;&nbsp;./l2gDownloader.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s 2-3,7-9,1  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download videos from 2 to 3, from 7 to 9, and video 1 of this lecture series.  
  
&nbsp;&nbsp;./l2gDownloader.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s 1,2,8-  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download videos 1, 2, and from 8 to end of this lecture series.  
  
&nbsp;&nbsp;./l2gDownloader.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s -5,10-15  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download videos from beginning to 5, and from 10 to 15 of this lecture series.  
  
&nbsp;&nbsp;./l2gDownloader.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/v/YYsL1MJFLmnX8bTchn0m7wxx -p GDBWS1617  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download a single video with given passphrase.  
  
&nbsp;&nbsp;./l2gDownloader.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/v/YYsL1MJFLmnX8bTchn0m7wxx -p GDBWS1617  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download all videos of this lecture series with given passphrase.
  
&nbsp;&nbsp;./l2gDownloader.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -rc  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;or  
&nbsp;&nbsp;./l2gDownloader.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -c -r  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download all videos of this lecture series in reverse order, compute add checksums to file name.
  
Limitations:  
&nbsp;&nbsp;It's not possible to download several single videos or several lecture series in a single execution of the script.  
&nbsp;&nbsp;It's not possible to download just the newly added videos from a lecture series.  
&nbsp;&nbsp;It's not possible to view the download progress.  
&nbsp;&nbsp;It's not possible to continue canceled downloads.  
&nbsp;&nbsp;It's not possible to save the downloaded videos into another directory.  
&nbsp;&nbsp;It's not possible to save already used passphrases to a file and try to use them next time automatically.  
  
&nbsp;&nbsp;I will adress some of these limitations in the future.
  
Dependencies:  
&nbsp;&nbsp;curl, getopts, md5sum, stat, grep, sed, head, cat, tac, ...  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;All used commands and programs should already be available in every linux environment. It's also possible to run  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;this script under Windows inside the Cygwin terminal.  
  
Optinal Dependencies:  
&nbsp;&nbsp;ffmpeg  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ffmpeg is needed to extract the audio track from the video file. You don't need to install ffmpeg unless you want to  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;use this feature.  
  
About:  
&nbsp;&nbsp;l2gDownloader has been developed in October/November 2016. It's working for almost any video at the moment,  
&nbsp;&nbsp;however this might change over time. If you're experiencing problems, please contact me (include url), maybe I will  
&nbsp;&nbsp;fix it.  
