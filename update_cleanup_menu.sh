#!/bin/bash

REPO_URL="https://raw.githubusercontent.com/vlnd-net/tools/main/update_cleanup_menu.sh"
LOCAL_SCRIPT="$0"

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

while true; do
    clear
    echo "Wybierz opcję:"
    echo "1) Sprawdzenie aktualizacji"
    echo "2) Aktualizacja pakietów"
    echo "3) Usunięcie zbędnych plików log"
    echo "4) Wyjście"
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
                echo "Nieznany menedżer pakietów."
            fi
            ;;
        3)
            echo "Usuwanie starych plików logów..."
            sudo find /var/log -type f -name "*.log" -mtime +7 -exec rm -f {} \;
            echo "Usunięto logi starsze niż 7 dni."
            ;;
        4)
            echo "Wyjście..."
            exit 0
            ;;
        *)
            echo "Nieprawidłowy wybór, spróbuj ponownie."
            ;;
    esac
    read -p "Naciśnij Enter, aby kontynuować..."
done
