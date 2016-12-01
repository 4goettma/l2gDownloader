# l2gDownloader
Shell-Script für Download von lecture2go-Videos

Usage: /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh [-(va) URL [-p PASSPHRASE] [-r] [-c]]

Options:
  -v URL        Download a video.
  -a URL        Download all videos of a lecture series of which the given url belongs to.
  -p PASSPHRASE Add passphrase for protected lecture series.
  -i TOKEN      Add authentification token for protected lecture series.
  -s RANGE      Specify a range of videos to download. Useless if combined with -v.
  -c            Compute MD5 checksum of the video file, add it to the file name
  -r            Download videos in reverse order: n --> 1 instead of 1 --> n (default behaviour). Useless if combined with -v.
  -m            Additionally convert video to audio track after downloading (requires ffmpeg).

Examples:
  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774
     Download a single video.

  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774
     Download all videos of this lecture series.

  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s 2-3,7-9,1
     Download videos from 2 to 3, from 7 to 9, and video 1 of this lecture series.

  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s 1,2,8-
     Download videos 1, 2, and from 8 to end of this lecture series.

  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s -5,10-15
     Download videos from beginning to 5, and from 10 to 15 of this lecture series.

  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/v/YYsL1MJFLmnX8bTchn0m7wxx -p GDBWS1617
     Download a single video with given passphrase.

  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -a https://lecture2go.uni-hamburg.de/l2go/-/get/v/YYsL1MJFLmnX8bTchn0m7wxx -p GDBWS1617
     Download all videos of this lecture series with given passphrase.

  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -rc
     or
  /home/julian/Documents/Code/Shell/Lecture2Go-Downloader/l2gDownloader_v0.9.6.4.sh -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -c -r
     Download all videos of this lecture series in reverse order, compute add checksums to file name.

Limitations:
  It's not possible to download several single videos or several lecture series in a single execution of the script.
  It's not possible to download just the newly added videos from a lecture series.
  It's not possible to view the download progress.
  It's not possible to continue canceled downloads.
  It's not possible to save the downloaded videos into another directory.
  It's not possible to save already used passphrases to a file and try to use them next time automatically.

  Maybe I will adress some of these limitations in the future.

Dependencies:
  curl, getopts, md5sum, stat, grep, sed, head, cat, tac, ...
     All used commands and programs should already be available in every linux environment. It's also possible to run
     this script under Windows inside the Cygwin terminal.

Optinal Dependencies:
  ffmpeg
     ffmpeg is needed to extract the audio track from the video file. You don't need to install ffmpeg unless you want to
     use this feature.

About:
  l2gDownloader has been developed in October/November 2016. It's working for almost any video at the moment,
  however this might change over time. If you're experiencing problems, please contact me (include url), maybe I will
  fix it.
