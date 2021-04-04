#!/bin/bash -e

# ==============================================================
# Plugin Language File Creator
# Author: Theunis Coetzee (ipokkel)
#
# This file must be placed inside the /plugin-folder/language/ folder
#
# Excecute from plugin root folder with ". languages/make-pot.sh"
# Check if executed from root, if not moves up one folder and
# check if current folder has name matching php file to make sure
# we're in the plugin's root folder.
# If NOT it'll close the terminal.
#
# If no existing language template file (*.pot) exists, create it and
# default .po and .mo, otherwise,
# Give user the option to merge old template with new (updatesd default po & mo also).
#
# Check if there's existing language packe, e.g. text-domain-fr_FR, and
# give user the option to update and merge.
# ==============================================================

echo "========================================"
echo "===== Plugin Language File Creator ====="
echo "========================================"

current_dir=${PWD##*/}
languages_dir="languages"

# Lets move up until we find the languages directory.
while [ ${current_dir} = ${languages_dir} ]; do
    echo "You are in the languages directory, were moving up one directory"
    cd ..
    current_dir=${PWD##*/}
done

current_dir=${PWD##*/}

# Let's avoid a loop
count=$(ls -1 ${current_dir}.php 2>/dev/null | wc -l)
if [ $count = 0 ]; then
    echo "Seems like you're not in the right place or the file names are not configured correctly."
    echo "We're going to exit to be on the safe side."
    sleep 1.5s
    exit 0
fi

# check if we have a pot and an a po
pot_exists=$(ls -1 languages/${current_dir}.pot 2>/dev/null | wc -l)
po_exists=$(ls -1 languages/${current_dir}.po 2>/dev/null | wc -l)
# mo_exists=$(ls -1 languages/${current_dir}.mo 2>/dev/null | wc -l)

merge_pot="n"

# Make/Update .pot file.
if [ $pot_exists != 0 ]; then
    echo "You already have a language file template, if your plugin's language files are hosted by Glotpress you should merge the new template with the existing template."
    echo "Do you want to merge with it? [Y/n]"
    read -e merge_pot
fi

if [ "$merge_pot" != n ]; then
    wp i18n make-pot . "${PWD}/languages/${current_dir}.pot" --merge --headers='{"Report-Msgid-Bugs-To":"info@paidmembershipspro.com","Last-Translator":"Paid Memberships Pro <info@paidmembershipspro.com>","Language-Team":"Paid Memberships Pro <info@paidmembershipspro.com>"}'
    wp i18n make-pot . "${PWD}/languages/${current_dir}.po" --merge --headers='{"Report-Msgid-Bugs-To":"info@paidmembershipspro.com","Last-Translator":"Paid Memberships Pro <info@paidmembershipspro.com>","Language-Team":"Paid Memberships Pro <info@paidmembershipspro.com>"}'
    msgfmt "${PWD}/languages/${current_dir}.po" -o "${PWD}/languages/${current_dir}.mo"
    # --- UPDATE LANGUAGE PACKS --- #
    # use nullglob in case there are no matching files
    shopt -s nullglob
    # create an array with all the filer/dir inside ~/myDir
    pofiles=(languages/${current_dir}-*.po)
    pofilescount=${#pofiles[@]}
    # echo "${pofilescount}"

    updatepacks="n"

    if [ ${pofilescount} != 0 ]; then
        echo "${pofilescount} Language pack(s) detected"
        echo "Would you like to update your language pack(s)? [Y/n]"
        read -e updatepacks
        if [ "$updatepacks" != n ]; then
            for x in "${pofiles[@]}"; do
                wp i18n make-pot . "${PWD}/${x}" --merge="${PWD}/${x}" --headers='{"Report-Msgid-Bugs-To":"info@paidmembershipspro.com","Last-Translator":"Paid Memberships Pro <info@paidmembershipspro.com>","Language-Team":"Paid Memberships Pro <info@paidmembershipspro.com>"}'
                po_name=${x%.po}
                msgfmt "${PWD}/${x}" -o "${PWD}/${po_name}.mo"
            done
        fi
    fi
else
    wp i18n make-pot . "${PWD}/languages/${current_dir}.pot" --headers='{"Report-Msgid-Bugs-To":"info@paidmembershipspro.com","Last-Translator":"Paid Memberships Pro <info@paidmembershipspro.com>","Language-Team":"Paid Memberships Pro <info@paidmembershipspro.com>"}'
    wp i18n make-pot . "${PWD}/languages/${current_dir}.po" --headers='{"Report-Msgid-Bugs-To":"info@paidmembershipspro.com","Last-Translator":"Paid Memberships Pro <info@paidmembershipspro.com>","Language-Team":"Paid Memberships Pro <info@paidmembershipspro.com>"}'
    msgfmt "${PWD}/languages/${current_dir}.po" -o "${PWD}/languages/${current_dir}.mo"
    # --- UPDATE LANGUAGE PACKS --- #
    # use nullglob in case there are no matching files
    shopt -s nullglob
    # create an array with all the filer/dir inside ~/myDir
    pofiles=(languages/${current_dir}-*.po)
    pofilescount=${#pofiles[@]}
    # echo "${pofilescount}"

    updatepacks="n"

    if [ ${pofilescount} != 0 ]; then
        echo "${pofilescount} Language pack(s) detected"
        echo "Would you like to update your language pack(s)? [Y/n]"
        read -e updatepacks
        if [ "$updatepacks" != n ]; then
            for x in "${pofiles[@]}"; do
                wp i18n make-pot . "${PWD}/${x}" --headers='{"Report-Msgid-Bugs-To":"info@paidmembershipspro.com","Last-Translator":"Paid Memberships Pro <info@paidmembershipspro.com>","Language-Team":"Paid Memberships Pro <info@paidmembershipspro.com>"}'
                po_name=${x%.po}
                msgfmt "${PWD}/${x}" -o "${PWD}/${po_name}.mo"
            done
        fi
    fi
fi

#  -- END -- #