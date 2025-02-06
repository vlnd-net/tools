#!/bin/bash

REPO_URL="https://raw.githubusercontent.com/vlnd-net/tools/main/update_cleanup_menu.sh"
WEBMIN_SCRIPT="https://raw.githubusercontent.com/vlnd-net/Lemp/main/webmin.sh"
LOCAL_SCRIPT="$0"


##
WHITETXT () {
    echo -e "${WHITE}${1}${RESET}"
}

BLUETXT () {
    echo -e "${BLUE}${1}${RESET}"
}

REDTXT () {
    echo -e "${RED}${1}${RESET}"
}

GREENTXT () {
    echo -e "${GREEN}${1}${RESET}"
}

YELLOWTXT () {
    echo -e "${YELLOW}${1}${RESET}"
}
###


check_update() {
    echo "Sprawdzanie aktualizacji..."
    TEMP_FILE=$(mktemp)
    curl -s "$REPO_URL" -o "$TEMP_FILE"

    if ! diff -q "$TEMP_FILE" "$LOCAL_SCRIPT" &>/dev/null; then
        echo "💡 Nowa wersja skryptu jest dostępna!"
        read -p "Czy chcesz zaktualizować? (t/n): " update_choice
        if [[ "$update_choice" == "t" ]]; then
            mv "$TEMP_FILE" "$LOCAL_SCRIPT"
            chmod +x "$LOCAL_SCRIPT"
            echo "✅ Skrypt został zaktualizowany! Uruchom ponownie."
            exit 0
        fi
    else
        echo "✅ Skrypt jest aktualny."
    fi
    rm -f "$TEMP_FILE"
}

install_packages() {
    read -p "Podaj nazwę pakietu/pakietów do instalacji (oddzielone spacją): " packages
    if [[ -z "$packages" ]]; then
        echo "❌ Nie podano pakietów."
        return
    fi

    echo "🔍 Sprawdzanie menedżera pakietów..."
    if command -v apt &> /dev/null; then
        sudo apt install -y $packages
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y $packages
    elif command -v yum &> /dev/null; then
        sudo yum install -y $packages
    else
        echo "❌ Nieznany menedżer pakietów!"
        return
    fi
    echo "✅ Pakiety zostały zainstalowane."
}

install_webmin() {
    echo "🔍 Pobieranie i instalacja Webmina..."
    
    if command -v curl &> /dev/null; then
        curl -s "$WEBMIN_SCRIPT" | bash
    elif command -v wget &> /dev/null; then
        wget -qO- "$WEBMIN_SCRIPT" | bash
    else
        echo "❌ Brak curl ani wget. Zainstaluj jeden z tych pakietów i spróbuj ponownie."
        return
    fi

    echo "✅ Webmin został zainstalowany!"
}

while true; do

    echo -e "${BOLD}${BLUE}=== MENU GŁÓWNE ===${RESET}"
    echo "1) ${GREEN}Sprawdzenie aktualizacji skryptu${RESET}"
    echo "2) ${YELLOW}Aktualizacja pakietów${RESET}"
    echo "3) ${RED}Usunięcie zbędnych plików log${RESET}"
    echo "4) ${BLUE}Instalacja pakietów${RESET}"
    echo "5) ${WHITE}Instalacja Webmina${RESET}"
    echo "6) ${RED}Wyjście${RESET}"
    read -p "Wybór: " choice

    case $choice in
        1) check_update ;;
        2)
            echo "Aktualizowanie pakietów..."
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt upgrade -y
            elif command -v dnf &> /dev/null; then
                sudo dnf update -y
            elif command -v yum &> /dev/null; then
                sudo yum update -y
            else
                echo "❌ Nieznany menedżer pakietów."
            fi
            ;;
        3)
            echo "Usuwanie starych plików logów..."
            sudo find /var/log -type f -name "*.log" -mtime +7 -exec rm -f {} \;
            echo "✅ Usunięto logi starsze niż 7 dni."
            ;;
        4) install_packages ;;
        5) install_webmin ;;
        6)
            echo "Wyjście..."
            exit 0
            ;;
        *)
            echo "❌ Nieprawidłowy wybór, spróbuj ponownie."
            ;;
    esac
    read -p "Naciśnij Enter, aby kontynuować..."
done
