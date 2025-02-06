#!/bin/bash

while true; do
    clear
    echo "Wybierz opcję:"
    echo "1) Aktualizacja pakietów"
    echo "2) Usunięcie zbędnych plików log"
    echo "3) Wyjście"
    read -p "Wybór: " choice

    case $choice in
        1)
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
        2)
            echo "Usuwanie starych plików logów..."
            sudo find /var/log -type f -name "*.log" -mtime +7 -exec rm -f {} \;
            echo "Usunięto logi starsze niż 7 dni."
            ;;
        3)
            echo "Wyjście..."
            exit 0
            ;;
        *)
            echo "Nieprawidłowy wybór, spróbuj ponownie."
            ;;
    esac
    read -p "Naciśnij Enter, aby kontynuować..."
done
