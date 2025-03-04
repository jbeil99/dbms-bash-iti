#!/bin/bash
source ./ddl.sh
source ./dml.sh
source ./dql.sh
source ./validation.sh

DB_DIR="./databases"
CURRENT_DB=""

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
ENDCOLOR='\033[0m' 
BOLD='\033[1m'

header () {
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}            "$*" ${ENDCOLOR}"
    echo -e "${CYAN}${BOLD}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${ENDCOLOR}"
}



main_menu (){
    #clear
    if [ -z $CURRENT_DB ]; 
    then
        header "Welcome to dBashms"
        echo -e "${BLUE}${BOLD}1.${ENDCOLOR} Connect to a database"
        echo -e "${BLUE}${BOLD}2.${ENDCOLOR} List databases"
        echo -e "${BLUE}${BOLD}3.${ENDCOLOR} Create a database"
        echo -e "${BLUE}${BOLD}4.${ENDCOLOR} Drop Database"
    else
        header "Connected to $CURRENT_DB"
        echo -e "${BLUE}${BOLD}1.${ENDCOLOR} Create table"
        echo -e "${BLUE}${BOLD}2.${ENDCOLOR} List Tables"
        echo -e "${BLUE}${BOLD}3.${ENDCOLOR} Get Table Data"
        echo -e "${BLUE}${BOLD}4.${ENDCOLOR} Insert data"
        echo -e "${BLUE}${BOLD}5.${ENDCOLOR} Update Data"
        echo -e "${BLUE}${BOLD}6.${ENDCOLOR} Delete Data"
        echo -e "${BLUE}${BOLD}7.${ENDCOLOR} Drop Table"
    echo -e "${BLUE}${BOLD}10.${ENDCOLOR} Main menu"
    fi
    
    echo -e "${BLUE}${BOLD}0.${ENDCOLOR} Exit"
    read -p "ENTER YOUR CHOICE: " choice
}


connect_db () {
    header Connect Database
    get_dbs
    read -p "Enter Database name to coonect: " db_name
    if [ -d "$DB_DIR/$db_name" ];
    then
        CURRENT_DB=$db_name
        echo -e "${GREEEN}Connected to $db_name${ENDCOLOR}"
    else
        echo -e "${RED}Database not found $db_name${ENDCOLOR}"
    fi
    
}


while true; 
do
    main_menu
    case $choice in 
    0)
        echo -e "${GREEN}Thank you for using dBashms ${ENDCOLOR}"
        exit 0
        ;;
    1)
        if [ -z $CURRENT_DB ];
        then
            connect_db
        else
            create_table
        fi
        ;;
    2)
        if [ -z $CURRENT_DB ];
        then
           list_db 
        else
            list_tables    
        fi
        ;;
    3)
        if [ -z $CURRENT_DB ];
        then
          create_db 
        else
           get_table_data 
        fi
        ;;
    4)
        if [ -z $CURRENT_DB ];
        then
            drop_dp 
        else
          insert_rows 
        fi
        ;;
    5)
        if ! [ -z $CURRENT_DB ];
        then
           update_rows
        fi
        ;;
    6)
        if ! [ -z $CURRENT_DB ];
        then
           delete_rows
        fi
        ;;
    7)
        if ! [ -z $CURRENT_DB ];
        then
            drop_table
        fi
        ;;
    10)
        CURRENT_DB=""
        ;;
    *)
        read -p "unkown Choice Press Enter to continue" 
        ;;
    esac
done