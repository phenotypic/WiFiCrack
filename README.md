# WiFiCrack
#### Wi-Fi cracker for macOS

## What is it?

WiFiCrack is script which allows for the easy and efficient cracking of WPA(2)-secured networks. It captures the necessary Wi-Fi packets associated with with WPA(2) handshakes and then makes use of [hashcat](https://github.com/hashcat/hashcat) for the efficient cracking of those packets in order to extract the password. The script is for educational purposes and should not be misused.

## Usage

Download and run the script with:
```
git clone https://github.com/Tommrodrigues/WiFiCrack
bash ~/WiFiCrack/WiFiCrack.sh
```

The script is fairly easy to use, simply run it using the command above and enter your `sudo` password when prompted. After running the script, you will be asked to choose a network to crack:

![Example](https://i.ibb.co/bWHfBPp/Screenshot-2018-12-13-at-20-26-34.png)

Following the selection of a network, you may have to wait for a while until a WPA(2) handshake is performed on the target network but this can be hastened by performing a [deauthentication attack](https://en.wikipedia.org/wiki/Wi-Fi_deauthentication_attack).

Once a handshake is captured, WiFiCrack will initialise to extract the Wi-Fi password. This step may take a while depending on a number of factors. If successful, you will be presented with the password; otherwise, WiFiCrack will retain the handshake in its directory in case you would like to perform another type of attack against the capture.

## Requirements

When running WiFiCrack, you will be asked to install any outstanding requirements:

| Command | Installation |
| --- | --- |
| `mergecap` | This comes as part of the [Wireshark](https://www.wireshark.org) package and must be installed manually from the website. |
| `./hashcat-utils/src/cap2hccapx.bin` | The WiFiCrack script will automatically install `cap2hccapx` from its [GitHub page](https://github.com/hashcat/hashcat-utils.git) if not already installed. |
| `./hashcat/hashcat` | The WiFiCrack script will automatically install `hashcat` from its [GitHub page](https://github.com/hashcat/hashcat) if not already installed. |

**Note:** You will also need to supply a word list for hashcat

## Removal

```
sudo rm -r ~/WiFiCrack
```
