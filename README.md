# WiFiCrack
#### Automated Wi-Fi cracker for macOS

## What is it?

WiFiCrack allows for the simple and efficient cracking of WPA(2)-secured networks. It captures the necessary Wi-Fi packets associated with with WPA(2) handshakes and then makes use of [hashcat](https://github.com/hashcat/hashcat) for the efficient cracking of those packets in order to extract the password. The script is for educational purposes and should not be misused.

## Usage

Download and run the script with:
```
git clone https://github.com/Tommrodrigues/WiFiCrack
bash ~/WiFiCrack/WiFiCrack.sh
```

The script is fairly easy to use, simply run it using the command above and enter your `sudo` password when prompted. Here are some flags you can add for various purposes:

| Flag | Description |
| --- | --- |
| `-h` | Help: Display all availabe flags |
| `-k` | Keep: Keep all captured packet files (deleted by default at end of session) |
| `-a` | Alert: Turn off successfull crack alert |
| `-w <wordlist>` | Wordlist: Manually define a wordlist (the script will prompt you otherwise) |
| `-i <interface>` | Interface: Manually set Wi-Fi interface (script should normally auto-detect the correct interface) |
| `-d <defice>` | Device: Manually define devices for hashcat |

After running the script, you will be asked to choose a network to crack:

![Example](https://i.ibb.co/bWHfBPp/Screenshot-2018-12-13-at-20-26-34.png)

Following the selection of a network, you may have to wait for a while until a WPA(2) handshake occurs on the target network, but this can be hastened by performing a [deauthentication attack](https://en.wikipedia.org/wiki/Wi-Fi_deauthentication_attack).

Once a handshake is captured, WiFiCrack will initialise `hashcat` to extract the Wi-Fi password. This step may take a while, depending on a number of factors. If successful, you will be presented with the password; otherwise, WiFiCrack will retain the handshake in its directory in case you would like to perform another type of attack against the capture.

## Requirements

When running WiFiCrack, you will need to install any outstanding requirements:

| Command | Installation |
| --- | --- |
| `mergecap` | This comes as part of the [Wireshark](https://www.wireshark.org) application and must be installed manually from the website. |
| `./hashcat-utils/src/cap2hccapx.bin` | The WiFiCrack script can automatically install `cap2hccapx` from its [GitHub page](https://github.com/hashcat/hashcat-utils.git) if not already installed. |
| `./hashcat/hashcat` | The WiFiCrack script can automatically install `hashcat` from its [GitHub page](https://github.com/hashcat/hashcat) if not already installed. |

**Note:** You will also need to supply a word list for hashcat

## To-do list

- [ ] Integrade deauthentication attack into main script
- [ ] Provide more `hashcat` attack options (i.e. brute force options etc.)

## Removal

```
sudo rm -r ~/WiFiCrack
```
