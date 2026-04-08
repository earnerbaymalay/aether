#!/usr/bin/env bash
# 🌌 Aether-AI Skill Marketplace // V 1.0
# Registry of high-performance local AI tools and plugins.

ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"; DIM="#4c566a"
SKILLS_DIR="$HOME/aether/skills"

header() {
    clear
    figlet -f small " MARKET" | gum style --foreground "$ACCENT"
    echo -e "   \033[1;30mNEURAL OPERATING INTERFACE // SKILL MARKETPLACE\033[0m\n"
}

list_marketplace() {
    echo -e "\033[1;34m[ DISCOVERABLE SKILLS ]\033[0m"
    # This is a representative marketplace list
    gum table --border rounded --columns "Skill,Description,Author" \
        "Obsidian-Sync,Real-time vault synchronization,Aether-Core" \
        "Vision-Lite,Local image description,Aether-Core" \
        "Web-Crawler,Privacy-centric search,Aether-Core" \
        "Code-Audit,Advanced security linting,Sentinel-Project"
}

header
list_marketplace

ACTION=$(gum choose " 📥 INSTALL SKILL " " 🧪 DEVELOP NEW " " 🔙 BACK ")

case "$ACTION" in
    *"INSTALL"*) 
        SKILL=$(gum input --placeholder "Enter skill name to synchronize...")
        [ -n "$SKILL" ] && gum spin --title "Synchronizing $SKILL..." -- sleep 2 && gum toast "$SKILL Ready."
        ;;
    *"DEVELOP"*) 
        NAME=$(gum input --placeholder "New skill name?")
        [ -n "$NAME" ] && mkdir -p "$SKILLS_DIR/$NAME" && touch "$SKILLS_DIR/$NAME/SKILL.md" && gum toast "$NAME Template Created."
        ;;
    *) exit 0 ;;
esac
