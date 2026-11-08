default:
    @just --list

# check the lua for syntax errors
check:
    luac -p workshop/Contents/mods/modfixes/42/media/lua/*/*.lua

# link the mod into the game's workshop folder, to test and upload it in game
link:
    ln -sfn "{{justfile_directory()}}/workshop" ~/Zomboid/Workshop/modfixes

# remove the mod's symlink from the game's workshop folder
unlink:
    @if [ -L ~/Zomboid/Workshop/modfixes ]; then rm ~/Zomboid/Workshop/modfixes; else echo "no symlink to remove"; fi
