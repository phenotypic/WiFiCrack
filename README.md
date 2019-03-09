# WiFiCrack
#### Automated Wi-Fi cracker for macOS

## What is it?

WiFiCrack allows for the simple and efficient cracking of WPA(2) networks. It captures the necessary Wi-Fi packets associated with with WPA(2) handshakes and then utilises [hashcat](https://github.com/hashcat/hashcat) to attempt to extract the hashed passkey.

## Prerequisites

Before running WiFiCrack you must have [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?l=en&mt=12) installed. You will need to install any other outstanding requirements:

| Command | Installation |
| --- | --- |
| `mergecap` | This comes as part of the [Wireshark](https://www.wireshark.org) application and must be installed manually from the website. |
| `./hashcat-utils/src/cap2hccapx.bin` | The WiFiCrack script can automatically install `cap2hccapx` from its [GitHub page](https://github.com/hashcat/hashcat-utils.git) if not already installed. |
| `./hashcat/hashcat` | The WiFiCrack script can automatically install `hashcat` from its [GitHub page](https://github.com/hashcat/hashcat) if not already installed. |

**Note:** You will also need to supply a word list for hashcat

## Usage

Download and run the script with:
```
git clone https://github.com/Tommrodrigues/WiFiCrack.git
bash ~/WiFiCrack/WiFiCrack.sh
```

The script is fairly easy to use, simply run it using the command above and enter your `sudo` password when prompted. Here are some flags you can add:

| Flag | Description |
| --- | --- |
| `-h` | Help: Display all availabe flags |
| `-k` | Keep: Keep all captured packet files (deleted at end of session by default) |
| `-a` | Alert: Turn off successfull crack alert |
| `-w <wordlist>` | Wordlist: Manually define a wordlist path (the script will prompt you otherwise) |
| `-i <interface>` | Interface: Manually set Wi-Fi interface (script should normally auto-detect the correct interface) |
| `-d <device>` | Device: Manually define 'devices' for hashcat |

After running the script, you will be asked to choose a network to crack:

![Example](https://i.ibb.co/bWHfBPp/Screenshot-2018-12-13-at-20-26-34.png)

Following the selection of a network, you may have to wait for a while until a handshake occurs on the target network (i.e. for a device to (re)connect to the network), but this can be hastened by performing a [deauthentication attack](https://en.wikipedia.org/wiki/Wi-Fi_deauthentication_attack).

Once a handshake is captured, WiFiCrack will initialise `hashcat` to extract the Wi-Fi password. This step may take a while depending on a number of factors including your processing power. If successful you will be presented with the password, otherwise, WiFiCrack will retain the handshake in its directory if you would like to perform another type of attack against the capture.

## To-do list

- [ ] Integrate deauthentication attack into main script
- [ ] Provide more `hashcat` attack options (e.g. brute force)

## Removal

```
sudo rm -r ~/WiFiCrack
```
