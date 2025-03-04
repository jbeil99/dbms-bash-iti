#!/bin/bash

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
    header List Database
    get_dbs
    read -p "Press Enter to continue"
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

print_table() {
    if [ ${#data} -eq 0 ]; then
        data="NO DATA FOUND"
    fi

    IFS=',' read -ra HEADER_COLS <<< "$header"
    num_cols=${#HEADER_COLS[@]}

    column_widths=()
    for ((i=0; i<num_cols; i++)); do
        max_width=$(echo "$header" "$data" | 
            awk -F',' -v col=$i '{width=length($((col+1))); if(width > max[col]) max[col]=width} 
            END {print max[col]}')
        column_widths+=("$max_width")
    done

    header_format_string=""
    for width in "${column_widths[@]}"; do
       header_format_string+="${PURPLE}${BOLD}%-${width}s${ENDCOLOR} "
    done
    header_format_string+="\n"
    
    data_format_string=""
    for width in "${column_widths[@]}"; do
        data_format_string+="${BOLD}%-${width}s${ENDCOLOR} "
    done
    data_format_string+="\n"


    printf "$header_format_string" "${HEADER_COLS[@]}"

    separator=$(printf '=%.0s' $(seq 1 $(($(echo "${column_widths[@]}" | tr ' ' '+' | bc) + num_cols))))
    echo -e "${CYAN}$separator${ENDCOLOR}"

    if [ "$data" != "NO DATA FOUND" ]; 
    then
        echo "$data" | while IFS=',' read -ra ROWS; do
            printf "$data_format_string" "${ROWS[@]}"
        done
    else
        echo "NO DATA FOUND"
    fi
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
        print_table 
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
                main_menu
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