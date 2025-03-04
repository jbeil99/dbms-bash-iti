#!/bin/bash
source ./validation.sh

create_table () {
    header "Create Table"
    
    read -p "Enter Table name: " table_name
    if [[ $table_name == 0 ]];
    then
       return 
    elif ! [[ $table_name =~ ^[a-zA-Z0-9_]+$ ]]; 
    then
        echo -e "\n${RED}Error: Table name can only contain letters, numbers, and underscores!${ENDCOLOR}"
        read -p "Press Enter to continue..."
        return
    fi
    
    if [ -f "$DB_DIR/$CURRENT_DB/$table_name" ]; 
    then
        echo -e "\n${RED}Error: Table '$table_name' already exists!${ENDCOLOR}"
        read -p "Press Enter to continue..."
        return
    fi

    columns=()
    types=()
    echo -e "${YELLOW}Define table columns ${ENDCOLOR}"
    echo -e "${YELLOW}Example: id or enter 0 to exist ${ENDCOLOR}"

    while true;
    do
        read -p "Enter column: " column

        if [[ $column == 0 ]];
        then
            break
        elif [ -z $column ]; 
        then
            echo -e "${RED} Column Cant be empty ${ENDCOLOR}"
            continue
        fi

        validate_string $column Column
        if ! [[ "$?" == 0 ]];
        then
            continue
        fi

        read -p "Enter type: " type 
        if [[ $type == 0 ]];
        then
            break
        elif [ -z $type ]; 
        then
            echo -e "${RED} Type Cant be empty ${ENDCOLOR}"
            continue
        fi

        validate_type $type  Type
        if ! [[ $? == 0 ]];
        then
            continue
        fi

        columns+=( $column )
        types+=( $type )
    done
    
    row=$(IFS=,; echo "${columns[*]}")
    row_type=$(IFS=","; echo "${types[*]}")

    echo "$row" > "$DB_DIR/$CURRENT_DB/$table_name"
    echo "$row_type" > "$DB_DIR/$CURRENT_DB/type_$table_name"
    echo -e "\n${GREEN}Table '$table_name' created successfully!${ENDCOLOR}"
    
    read -p "Press Enter to Continue"
}

get_tables () {
    if [ -z "$(ls $DB_DIR/$CURRENT_DB)" ];
    then
        echo -e "${BOLD}${YELLOW} NO TABLES FOUND ${ENDCOLOR}"
    else
        echo -e "${BOLD}${GREEN} All Databases: ${ENDCOLOR}"
        count=1
        for table in $(ls $DB_DIR/$CURRENT_DB | grep -v "^type_");
        do
            echo "$count-$table"
            (( count++ ))
        done
    fi
}

list_tables () {
    header "List Table"
    get_tables
    read -p "Press Enter to continue"
}


drop_table () {
    header "Drop Table"
    get_tables
    read -p "Enter table Name: " table
    if [ -z $table ];
    then
        echo -e "${RED} Table Cant be empty ${ENDCOLOR}"
    elif [ -f "$DB_DIR/$CURRENT_DB/$table" ];
    then
        rm -f $DB_DIR/$CURRENT_DB/$table
        rm -f "$DB_DIR/$CURRENT_DB/type_$table"
        echo -e "${GREEN}${BOLD} $table Was Deleted Successfully${ENDCOLOR}"
    else
        echo -e "${YELLOW} Table $table not found ${ENDCOLOR}" 
    fi
    read -p "Press Enter to continue"
}