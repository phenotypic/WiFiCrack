# WiFiCrack

WiFiCrack demonstrates of some of the security flaws associated with WPA(2) networks by demonstrating simple and efficient cracking. It captures the necessary Wi-Fi packets associated with with WPA(2) handshakes and then utilises [hashcat](https://github.com/hashcat/hashcat) to attempt to extract the hashed passkey. The script is for educational purposes and should not be misused.

See [WiFiCrackPy](https://github.com/phenotypic/WiFiCrackPy) for a new streamlined version of this script

## Prerequisites

You must have [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?l=en&mt=12) installed. You will need to install any other outstanding requirements:

| Command | Installation |
| --- | --- |
| `hashcat` | Manual installation: install via [brew](https://brew.sh) by running `brew install hashcat`|
| `mergecap` | Manual installation: comes with the [Wireshark](https://www.wireshark.org) application (v2.6.12) |
| `./hashcat-utils/src/cap2hccapx.bin` | Automatic installation option when script is run |

**Note:** You will also need to supply a word list for hashcat

**Note:** The script has been successfully tested with macOS Catlaina when using the `bash` shell. `zsh` may cause some problems

## Usage

Download with:
```
git clone https://github.com/phenotypic/WiFiCrack.git
```

Run from same directory with:
```
bash WiFiCrack.sh
```

The script is fairly easy to use, simply run it using the command above and enter your `sudo` password when prompted. Here are some flags you can add:

| Flag | Description |
| --- | --- |
| `-h` | Help: Display all available flags |
| `-k` | Keep: Keep all captured packet files (deleted at end of session by default) |
| `-a` | Alert: Turn off successful crack alert |
| `-w <wordlist>` | Wordlist: Manually define a wordlist path (the script will prompt you otherwise) |
| `-i <interface>` | Interface: Manually set Wi-Fi interface (script should normally auto-detect the correct interface) |
| `-d <device>` | Device: Manually define 'devices' for hashcat |

After running the script, you will be asked to choose a network to crack.

Following the selection of a network, you may have to wait for a while until a handshake occurs on the target network (i.e. for a device to (re)connect to the network), but this can be hastened by performing a [deauthentication attack](https://en.wikipedia.org/wiki/Wi-Fi_deauthentication_attack).

Once a handshake is captured, WiFiCrack will initialise `hashcat` to extract the Wi-Fi password. This step may take a while depending on a number of factors including your processing power. If successful you will be presented with the password, otherwise, WiFiCrack will retain the handshake in its directory if you would like to perform another type of attack against the capture.

## To-do list

- [ ] Integrate deauthentication attack into main script
- [ ] Provide more `hashcat` attack options (e.g. brute force)
