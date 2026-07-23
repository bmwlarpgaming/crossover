# Fork of totallynotinteresting/crossover (deleted)
## The README.md is mostly identical, same as the script, only changes being that it uses this repository and there are some new QOL changes.
## Have fun!

how to run:

umm grant Terminal Full Disk Access. System Settings > Privacy & Security > Full Disk Access(or search "Full Disk Access") and toggle on Terminal

uh open the terminal (cmd + space, type in terminal, and press the one that literally says "Terminal")

download or copy the complete repository to your Mac. The installer is now
local-only: `patch.sh`, `pco.sh`, and `hook.m` must stay together in the same
directory. It does not clone a repository or download fallback files.

then run:
```sh
cd /path/to/crossover
bash ./patch.sh
```

if CrossOver is outside `/Applications` or `~/Applications`, run:
```sh
CROSSOVER_APP_PATH="/path/to/CrossOver.app" bash ./patch.sh
```

then open /Applications/CrossOver.app, should all be good, i hope :p

check if all good - in menu bar while in crossover, click "CrossOver" > "Unlock Crossover". It should say - "It will stop working in 9999 days" or smth

if u hav question open an issue, if u have improvements, do not suggest some because i am a cocky nerd (you can still open a pr if u want)

uhh i'll make an uninstaller sometime when i can remember to

to codeweavers: dont charge so much for reskinned wine and this wouldnt happen

[license: MIT](https://github.com/everythinginitsrightplace/crossover/blob/main/LICENSE)
