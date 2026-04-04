#!/usr/bin/env bash
pkg update -y && pkg upgrade -y
pkg install git build-essential cmake ninja gum termux-api figlet ncurses-utils wget -y
mkdir -p models knowledge ~/.aether/sessions
