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
        echo -e "${BOLD}${GREEN} All Tables: ${ENDCOLOR}"
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


print_table() {
    local header="$1"
    local data="$2"
    
    if [ ${#data} -eq 0 ];
    then
        data="NO DATA FOUND"
    fi

    max_length=$(echo "$header" "$data" | awk -F',' '{if(length($0) > max) max=length($0)} END {print max}')
    separator=$(printf "%-${max_length}s" "=" | tr ' ' '=')
 
    echo "$header" | awk -F',' -v color="$RED" -v reset="$RESET" -v bold="$BOLD" \
    '{printf color bold "%-5s" reset, $1; printf color bold "%-12s" reset, $2; printf color bold "%-5s" reset, $3; printf color bold "%-15s\n", $4}'

    echo -e "${CYAN}$separator${ENDCOLOR}"   
    echo "$data" | awk -F',' '{printf "%-5s %-12s %-5s %-15s\n", $1, $2, $3, $4}'
}


get_table_data () {
    header "Get Table Data"
    get_tables
    read -p "Enter Table Name: " table
    if [ -z $table ];
    then
        echo -e "${RED} Table Cant be empty ${ENDCOLOR}"
    elif [ -f "$DB_DIR/$CURRENT_DB/$table" ];
    then
        header=$(head -n 1 $DB_DIR/$CURRENT_DB/$table)
        query_table_menu
        print_table $header $data
    else
        echo -e "${YELLOW} Table $table not found ${ENDCOLOR}" 
    fi
    read -p "Press Enter to continue"
}

query_table_menu () {
    while true; 
    do
        echo -e "${BLUE}${BOLD}1.${ENDCOLOR} Get all rows"
        echo -e "${BLUE}${BOLD}2.${ENDCOLOR} get rows by column"
        read -p "Enter a choice: " c
        case $c in 
            0)
                echo -e "${RED}Nah dont leave meeeeeeeeeeeee${ENDCOLOR}"
                break
                ;;
            1)
                data=$(awk 'NR > 1 {print $0}' "$DB_DIR/$CURRENT_DB/$table")
                break
                ;;
            2)
                get_line_by_column_value "$DB_DIR/$CURRENT_DB/$table"
                break
                ;;
    esac
    done
}


get_line_by_column_value() {
    local filename="$1"
    read -p "Enter the column name: " column_name
    read -p "Enter the value to search for: " value

    column_number=$(awk -F',' -v column="$column_name" 'NR==1 {
        for (i=1; i<=NF; i++) {
            if ($i == column) {
                print i;
                exit;
            }
        }
    }' "$filename")
    echo $filename
    if [ -z "$column_number" ]; then
        echo "Column not found!"
        return
    fi


    data=""
    data=$(awk -F',' -v col="$column_number" -v val="$value" '
    NR > 1 {
        if ($col == val) {
            print $0;  
        }
    }' "$filename")

}
