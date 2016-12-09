#!/bin/sh

### TODO ###
# - Passwörter aus/in Liste lesen/schreiben
# - Option für kurze Namen
# - automatisch/Flag fürs Erstellen von Ordnern
# - auf Möglichkeit hinweisen, das Skript mithilfe von alias zu verknüpfen
# - cookie-jar.cache löschen
# - Audio-Konvertierung um Größenanzeige erweitern?
# - ffmpeg-missing-Case besser einbinden

# http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
type ffmpeg >/dev/null 2>&1 || echo -e "[WARNING] Couldn't find ffmpeg!"

selected() {
    # $1 = Ausdruck, $2 = Wert
    included="false"
    #Eingabe bereinigen und Kommas verfielfältigen, da Grep gematchte Regex-Teile frisst, aus ",2,3," wird ",2," + "3," => nur 1 Treffer.
    input=$(echo $1 | sed -e "s/[^0-9,-]//g" | sed "s/,/,,/g")
    input=",$input,"
    # Bereich
    for j in $(echo "$input" | grep -oE "[0-9]+-[0-9]+"); do
        a=$(echo "$j" | grep -oE "[0-9]+\-" | grep -oE "[0-9]+");
        b=$(echo "$j" | grep -oE "\-[0-9]+" | grep -oE "[0-9]+");
        # echo "Bereich: $a bis $b";
        if [[ "$2" -ge "$a" ]] && [[ "$2" -le "$b" ]]; then
            included="true";
        fi
    done;
    # nach oben offen
    for j in $(echo "$input" | grep -oE "[0-9]+-," | grep -oE "[0-9]+"); do
        if [ "$2" -ge "$j" ]; then
            included="true";
        fi
    done;
    # nach unten offen
    for j in $(echo "$input" | grep -oE ",\-[0-9]+" | grep -oE "[0-9]+"); do
        if [ "$2" -le "$j" ]; then
            included="true";
        fi
    done;
    # Einzelwerte
    for j in $(echo "$input" | grep -oE ",[0-9]+," | grep -oE "[0-9]+"); do
        if [ "$2" == "$j" ]; then
            included="true";
        fi
    done;
}

download() {
    all=$1
    reverse=$2
    checksum=$3
    mp3=$4
    cookie=$5
    url=$6
    passwort=$7
    selection=$8

    if [ "$all" == "true" ]
    then
        echo -en "\n[INFO]    Anweisung: Vorlesungsreihe um Video \"$url\" herum"
    else
        echo -en "\n[INFO]    Anweisung: Einzelnes Video \"$url\""
    fi

    if [ "$passwort" != "_" ]
    then
        echo -en " mit Passwort \"$passwort\""
    elif [ "$cookie" != "_" ]
    then
        echo -en " mit AuthToken \"$cookie\""
    else
        echo -en ""
    fi

    if [ "$selection" != "_" ]
    then
        echo -en " gemäß Filter \"$selection\""
    else
        echo -en ""
    fi

    if [ "$reverse" != "false" ]
    then
        echo -en " in umgekehrter Reihenfolge"
    else
        echo -en ""
    fi

    if [ "$checksum" != "false" ]
    then
        echo -en " herunterladen und Prüfsumme berechnen"
    else
        echo -en " herunterladen"
    fi

    if [ "$mp3" != "false" ]
    then
        echo -e " und Audiospur speichern!"
    else
        echo -e "!"
    fi

	accessible="true"
    # Seite herunterladen...
    if [ "$(echo $url | grep -oE "https://lecture2go.uni-hamburg.de/l2go/-/get/v/[[:alnum:]]{24}")" != "" ]
    then
        echo "[INFO]    Passwortgeschützte Vorlesung erkannt."
        # Erster Besuch der angegebenen URL, Cookies werden akzeptiert und gespeichert, die Übergabe des Passwortes ist vermutlich überflüssig.
        curl -sc cookie-jar.cache "$url?_lgopenaccessvideos_WAR_lecture2goportlet_password=$passwort" > /dev/null
        # Zweiter Besuch der angegebenen URL, Cookies werden geschickt, Passwort kann in ein theoretisch zwischendurch aufgetauchten Passwort-Feld eingetragen worden sein (das überspringen wir).
        if [ "$passwort" != "_" ]
        then
            curlInput=$(curl -sb cookie-jar.cache "$url?_lgopenaccessvideos_WAR_lecture2goportlet_password=$passwort")
        else
            curlInput=$(curl -sb cookie-jar.cache "$url" --cookie "L2G_LSID=$cookie")
        fi
        if [ "$(echo $curlInput | grep -oE ".m3u8")" != "" ]
        then
            echo "[INFO]    Passwort/AuthToken anscheinend korrekt."
        else
            echo "[ERROR]   Passwort/AuthToken vermutlich fehlerhaft oder keine Internetverbindung verfügbar."
            accessible="false"
        fi
    else
        curlInput=$(curl -s "$url")
    fi

    if [ "$accessible" == "true" ]
    then
        vorlesung=$(echo $curlInput | grep -oE "<SPAN>.*</SPAN>")
        vorlesung=${vorlesung:6}
        vorlesung=${vorlesung::-7}

        if [ "$all" == "true" ]
        then
            # ...und daraus die URLs der einzelnen Vorlesungen (gemeint sind die Seiten, noch nicht die Videos!) extrahieren.
            # (die Links zu den Videos enden auf [vl]/[0-9]+, die der passwortgeschützten Videos allerdings auf [v]/[a-zA-z0-9]{24}, daher war hier im Vergleich zu 0.6 eine Anpassung notwendig)
            videos=$(echo $curlInput | grep -oE "onClick=\"window.location='https://lecture2go.uni-hamburg.de/l2go/-/get/[vl]/[[:alnum:]]{1,24}'" | grep -oE "'.*'" | sed s/\'//g)
            
            if [ "$reverse" == "false" ]
            then
                videos=$(echo "$videos" | tac)
            fi
            
            videosCount=$(echo $videos | grep -oE "lecture2go.uni-hamburg.de" | wc -l)
            echo "[INFO]    Vorlesungsreihe \"$vorlesung\" enthält $videosCount Videos..."
        else
            #...und trotzdem nur die übergebene URL als Quelle nehmen. Der obere Teil ist damit fast komplett überflüssig, aber schadet nicht weiter.
            videos=$url
        fi

        if [ "$reverse" == "false" ]
        then
            c=1
        else
            c=$videosCount
        fi
        # für jede Vorlesung die Video-URL extrahieren und den Download-Prozess durchlaufen
        for i in $videos; do
            selected $selection $c

            if [[ "$included" == "true" ]] || [[ "$selection" == "_" ]] || [[ "$all" == "false" ]] 
            then
                if [ "$(echo $i | grep -o -E "https://lecture2go.uni-hamburg.de/l2go/-/get/v/[[:alnum:]]{24}")" != "" ]
                then
                    # siehe oben, Cookies müssen nur lesbar sein.
                    if [ "$passwort" != "_" ]
                    then
                        curlInput=$(curl -sb cookie-jar.cache "$i?_lgopenaccessvideos_WAR_lecture2goportlet_password=$passwort")
                    else
                        curlInput=$(curl -sb cookie-jar.cache "$i" --cookie "L2G_LSID=$cookie")
                    fi
                else
                    curlInput=$(curl -s "$i")
                fi

                m3u8=$(echo $curlInput | grep -o -E "fms.rrz.uni-hamburg.de/vod/_definst/mp4:[[:alnum:][:punct:]]{2,100}.mp4/playlist.m3u8")
                path=$(echo $curlInput | grep -o -E "fms.rrz.uni-hamburg.de/vod/_definst/mp4:[[:alnum:][:punct:]]{2,100}.mp4/")
                title=$(echo $curlInput | grep -o -E "<title>.*</title>" | sed s/\ -\ Universität\ Hamburg\ -\ Lecture2Go//g | sed s/\&.*\;//g | sed s/\ \ /\ -\ /g | sed s/\:/_/g)
                title=${title:7}
                title=${title::-8}
                datum=$(echo $curlInput | grep -o -E "<div class=\"date\">[0-9]{2}.[0-9]{2}.[0-9]{4}</div>")
                datum=${datum:18}
                datum=${datum::-6}
                echo -e "\n[INFO]    Starte Download von \"$title\", aufgenommen am $datum..."
                title2=${title::100}
                title2=$(echo $title2 | sed s/\ /_/g)

                # Temporäre Stream-ID
                tid=$(curl -s "$m3u8" | grep "chunk" | grep -o -E "[[:digit:]]+" | head -n 1)

                #Sicherstellen, dass Download mit einer leeren Datei beginnt, wahrscheinlich überflüssig
                echo "" > "l2g_"$title2"_("$datum")_"$tid".mp4.part"
                # 1000 Abschnitte dürften ausreichen, falls Video unvollständig, Wert erhöhen auf z.B. 1500, 2000, 2500 oder so
                curl -s "$path"media_w{$tid}_[0-1000].ts >> "l2g_"$title2"_("$datum")_"$tid".mp4.part"

                #.mp4.part in .mp4 umbenennen
                if [[ $(stat -c %s "l2g_"$title2"_("$datum")_"$tid".mp4.part") -gt 1073741824 ]]
                then
                    videoGroesse=$(( $(stat -c %s "l2g_"$title2"_("$datum")_"$tid".mp4.part") / 1073741824))
                    videoGroesseEinheit="GiB"
                elif [[ $(stat -c %s "l2g_"$title2"_("$datum")_"$tid".mp4.part") -gt 1048576 ]]
                then
                    videoGroesse=$(( $(stat -c %s "l2g_"$title2"_("$datum")_"$tid".mp4.part") / 1048576))
                    videoGroesseEinheit="MiB"
                elif [[ $(stat -c %s "l2g_"$title2"_("$datum")_"$tid".mp4.part") -gt 1024 ]]
                then
                    videoGroesse=$(( $(stat -c %s "l2g_"$title2"_("$datum")_"$tid".mp4.part") / 1024))
                    videoGroesseEinheit="KiB"
                else
                    videoGroesse=$(stat -c %s "l2g_"$title2"_("$datum")_"$tid".mp4.part")
                    videoGroesseEinheit="B"
                fi

                fileHash=""
                if [ "$checksum" == "true" ]
                then
                    echo "[INFO]    Download abgeschlossen, berechne MD5-Prüfsumme des Videos..."
                    fileHash=$(md5sum "l2g_"$title2"_("$datum")_"$tid".mp4.part")
                    fileHash="_["${fileHash::32}"]"
                fi

                mv "l2g_"$title2"_("$datum")_"$tid".mp4.part" "l2g_"$title2"_("$datum")_"$tid""$fileHash".mp4"
                echo "[INFO]    Download abgeschlossen, gespeichert in l2g_"$title2"_("$datum")_"$tid""$fileHash".mp4 ($videoGroesse $videoGroesseEinheit)"
                if [ "$mp3" == "true" ]
                then
                    echo "[INFO]    Konvertiere Video zu .mp3..."
                    ffmpeg -hide_banner -i "l2g_"$title2"_("$datum")_"$tid""$fileHash".mp4" "l2g_"$title2"_("$datum")_"$tid""$fileHash".mp3"
                    echo "[INFO]    Konvertierung abgeschlossen, gespeichert in l2g_"$title2"_("$datum")_"$tid""$fileHash".mp3"
                fi
                echo "[INFO]    Datei bei Bedarf bitte manuell umbenennen!"
            else
                echo "[INFO]    Video $c gemäß Filter übersprungen"
            fi

            if [ "$reverse" == "false" ]
            then
                c=$(($c+1))
            else
                c=$(($c-1))
            fi

        done;
    fi
}

all="false"
checksum="false"
reverse="false"
mp3="false"
passwort="_"
cookie="_"
selection="_"
while getopts s:v:a:p:i:crm opt
do
    case $opt in
        s) selection=$OPTARG;;
        p) passwort=$OPTARG;;
        v) video=$OPTARG;;
        a) video=$OPTARG; all="true";;
        i) cookie=$OPTARG;;
        c) checksum="true";;
        r) reverse="true";;
        m) mp3="true";;
    esac
done

if [ "$video" != "" ]
then
    download $all $reverse $checksum $mp3 $cookie $video $passwort $selection
else
    echo -e "Usage: $0 [-(va) URL [-p PASSPHRASE] [-i TOKEN] [-r] [-c] [-m] [-s RANGE]]\n"
#   echo -e "Usage: $0 (-[va] URL (-p PASSPHRASE) (-r) (-c))\n" #better?
    echo "Options:"
    echo "  -v URL        Download a video."
    echo "  -a URL        Download all videos of a lecture series of which the given url belongs to."
    echo "  -p PASSPHRASE Add passphrase for protected lecture series."
    echo "  -i TOKEN      Add authentification token for protected lecture series."
    echo "  -s RANGE      Specify a range of videos to download. Useless if combined with -v."
    echo "  -c            Compute MD5 checksum of the video file, add it to the file name"
    echo "  -r            Download videos in reverse order: n --> 1 instead of 1 --> n (default behaviour). Useless if combined with -v."
    echo "  -m            Additionally convert video to audio track after downloading (requires ffmpeg)."
    echo -e "\nExamples:"
    echo -e "  $0 -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774\n     Download a single video.\n"
    echo -e "  $0 -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774\n     Download all videos of this lecture series.\n"
    echo -e "  $0 -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s 2-3,7-9,1\n     Download videos from 2 to 3, from 7 to 9, and video 1 of this lecture series.\n"
    echo -e "  $0 -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s 1,2,8-\n     Download videos 1, 2, and from 8 to end of this lecture series.\n"
    echo -e "  $0 -a https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -s -5,10-15\n     Download videos from beginning to 5, and from 10 to 15 of this lecture series.\n"
    echo -e "  $0 -v https://lecture2go.uni-hamburg.de/l2go/-/get/v/YYsL1MJFLmnX8bTchn0m7wxx -p GDBWS1617\n     Download a single video with given passphrase.\n"
    echo -e "  $0 -a https://lecture2go.uni-hamburg.de/l2go/-/get/v/YYsL1MJFLmnX8bTchn0m7wxx -p GDBWS1617\n     Download all videos of this lecture series with given passphrase.\n"
    echo -e "  $0 -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -rc\n     or\n  $0 -v https://lecture2go.uni-hamburg.de/l2go/-/get/l/4774 -c -r\n     Download all videos of this lecture series in reverse order, compute add checksums to file name.\n"

    echo -e "Limitations:"
    echo -e "  It's not possible to download several single videos or several lecture series in a single execution of the script."
    echo -e "  It's not possible to download just the newly added videos from a lecture series."
    echo -e "  It's not possible to view the download progress."
    echo -e "  It's not possible to continue canceled downloads."
    echo -e "  It's not possible to save the downloaded videos into another directory."
    echo -e "  It's not possible to save already used passphrases to a file and try to use them next time automatically."
    echo -e "\n  Maybe I will adress some of these limitations in future updates."
    
    echo -e "\nDependencies:"
    echo -e "  curl, getopts, md5sum, stat, grep, sed, head, cat, tac, ..."
    echo -e "     All used commands and programs should already be available in every linux environment. It's also possible to run\n     this script under Windows inside the Cygwin terminal."

    echo -e "\nOptinal Dependencies:"
    echo -e "  ffmpeg"
    echo -e "     ffmpeg is needed to extract the audio track from the video file. You don't need to install ffmpeg unless you want to\n     use this feature."
    
    echo -e "\nAbout:"
    echo -e "  l2gDownloader has been developed in October/November 2016. It's working for almost any video at the moment,\n  however this might change over time. If you're experiencing problems, please contact me (include url), maybe I will\n  fix it."
fi
