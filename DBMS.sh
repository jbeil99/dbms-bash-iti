#!/bin/bash

# Configuration
DB_DIR="./databases"
CURRENT_DB=""
CLEAR_CMD="clear"  

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
ENDCOLOR='\033[0m' # No Color
BOLD='\033[1m'

main_menu (){
    clear
    if [ -z $CURRENT_DB ]; 
    then
        echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
        echo -e "${CYAN}${BOLD}           Welcome to dBashms         ${ENDCOLOR}"
        echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
        echo -e "${BLUE}${BOLD}1.${ENDCOLOR} Connect to a database"
        echo -e "${BLUE}${BOLD}2.${ENDCOLOR} List databases"
        echo -e "${BLUE}${BOLD}3.${ENDCOLOR} Create a database"
        echo -e "${BLUE}${BOLD}4.${ENDCOLOR} Drop Database"
    else
        echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
        echo -e "${CYAN}${BOLD}      Connected to ${CURRENT_DB}      ${ENDCOLOR}"
        echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
        echo -e "${BLUE}${BOLD}1.${ENDCOLOR} Create table"
        echo -e "${BLUE}${BOLD}2.${ENDCOLOR} List Tables"
        echo -e "${BLUE}${BOLD}3.${ENDCOLOR} Get Table Data"
        echo -e "${BLUE}${BOLD}4.${ENDCOLOR} Insert data"
        echo -e "${BLUE}${BOLD}5.${ENDCOLOR} Update Data"
        echo -e "${BLUE}${BOLD}6.${ENDCOLOR} Delete Data"
        echo -e "${BLUE}${BOLD}7.${ENDCOLOR} Drop Table"
    fi
    
    echo -e "${BLUE}${BOLD}0.${ENDCOLOR} Exit"
    echo -e "${BLUE}${BOLD}10.${ENDCOLOR} Main menu"
    read -p "ENTER YOUR CHOICE: " choice
}


create_db () {
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}            Create Database           ${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
    read -p "Enter database name: " db_name

    if [ -d $DB_DIR/$db_name ];
    then
        echo -e "${RED}${BOLD} DATABASE NAME ALREADT EXISTS ${ENDCOLOR}"
    else
        mkdir -p "$DB_DIR/$db_name"
        echo -e "${GREEN} Databse '$db_name' was created successfully ${ENDCOLOR}"
        $CURRENT_DB="$db_name"
    fi
    read -p "Press Enter to continue"
}


get_dbs(){
    if [ -z "$(ls $DB_DIR)" ];
    then
        echo -e "${BOLD}${YELLOW} NO DATABASES FOUND ${ENDCOLOR}"
    else

        echo -e "${BOLD}${GREEN} All Databases: ${ENDCOLOR}"
        count=1
        for db in $(ls $DB_DIR);
        do
            echo "$count-$db"
            (( count++ ))
        done
    fi

}


list_db () {
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}            List Databases           ${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"

    get_dbs
    read -p "Press Enter to continue"
}


connect_db () {
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}          Connect Database           ${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
    get_dbs

    read -p "Enter Database name to coonect: " db_name
    if [ -d "$DB_DIR/$db_name" ];
    then
        CURRENT_DB=$db_name
        echo -e "${GREEEN}Connected to $db_name${ENDCOLOR}"
    else
        echo -e "${RED}Database not found $db_name${ENDCOLOR}"
    fi

    read -p "Press Enter to continue"
    
}


while true; 
do
    main_menu
    
    case $choice in 
    0)
        echo -e "${RED}Nah dont leave meeeeeeeeeeeee${ENDCOLOR}"
        exit 0
        ;;
    1)
        connect_db
        ;;
    2)
        list_db
        ;;
    3)
        create_db
        ;;
    esac
done