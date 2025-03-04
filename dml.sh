#!bin/bash
insert_data() {
    if [ -z "$table" ]; then
        echo -e "${RED}Table Cannot be empty${ENDCOLOR}"
        return 1
    fi

    if [ ! -f "$DB_DIR/$CURRENT_DB/$table" ]; then
        echo -e "${YELLOW}Table $table not found${ENDCOLOR}"
        return 1
    fi

    header=$(head -n 1 "$DB_DIR/$CURRENT_DB/$table")
    types=$(head -n 1 "$DB_DIR/$CURRENT_DB/type_$table")

    IFS=',' read -ra HEADER_COLS <<< "$header"
    IFS=',' read -ra TYPE_COLS <<< "$types"

    declare -A row_data
    declare -A column_types

    for ((i=0; i<${#HEADER_COLS[@]}; i++)); do
        column_types["${HEADER_COLS[i]}"]="${TYPE_COLS[i]}"
    done

    for col in "${HEADER_COLS[@]}"; do
        while true; do
            read -p "Enter $col (${column_types[$col]} type, or q to quit): " row_data["$col"] 
            case "${column_types[$col]}" in
                "int")
                    validate_int "${row_data[$col]}" $col
                    if ! [[ "$?" == 0 ]];
                    then
                        continue
                    fi
                    ;;
                "string")
                    validate_string "${row_data[$col]}" $col
                    if ! [[ "$?" == 0 ]];
                    then
                        continue
                    fi
                    ;;
                "float")
                    validate_float "${row_data[$col]}" $col
                    if ! [[ "$?" == 0 ]];
                    then
                        continue
                    fi
                    ;;
                *)
                    echo -e "${YELLOW}Warning: Unknown type ${column_types[$col]} for column $col${ENDCOLOR}"
                    ;;
            esac
                break
            done
        done

    row=""
    for col in "${HEADER_COLS[@]}"; do
        if [ -z "$row" ]; then
            row="${row_data[$col]}"
        else
            row="${row},${row_data[$col]}"
        fi
    done

    echo "$row" >> "$DB_DIR/$CURRENT_DB/$table"
    echo -e "${GREEN}Data inserted successfully.${ENDCOLOR}"
}

insert_rows() {
    header "Get Table Data"
    get_tables
    
    echo "Enter q to exit"
    read -p "Enter Table Name: " table

    while true; do
        if [[ "$table" == "q" ]]; then
            break
        fi
        insert_data

        read -p "Press Enter to continue or q to exit: " c
        case $c in
            "q")
                break
                ;;
        esac

    done

    read -p "Press Enter to continue"
}
update_data() {
    if [ -z "$table" ]; then
        echo -e "${RED}Table Cannot be empty${ENDCOLOR}"
        return 1
    fi

    if [ ! -f "$DB_DIR/$CURRENT_DB/$table" ]; then
        echo -e "${YELLOW}Table $table not found${ENDCOLOR}"
        return 1
    fi

    header=$(head -n 1 "$DB_DIR/$CURRENT_DB/$table")
    types=$(head -n 1 "$DB_DIR/$CURRENT_DB/type_$table")

    IFS=',' read -ra HEADER_COLS <<< "$header"
    IFS=',' read -ra TYPE_COLS <<< "$types"

    declare -A column_types
    declare -A row_data

    for ((i=0; i<${#HEADER_COLS[@]}; i++)); do
        column_types["${HEADER_COLS[i]}"]="${TYPE_COLS[i]}"
    done

    filename="$DB_DIR/$CURRENT_DB/$table"

    get_line_by_column_value "$filename"

    if [ -z "$data" ]; then
        echo -e "${YELLOW}No records found matching the search criteria.${ENDCOLOR}"
        return 1
    fi

    echo -e "${CYAN}Found Records:${ENDCOLOR}"
    echo "$data" | nl

    read -p "Enter the record number to update (or q to quit): " record_num
    
    if [[ "$record_num" == "q" ]]; then
        return
    fi

    if ! [[ "$record_num" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid record number${ENDCOLOR}"
        return 1
    fi

    record=$(echo "$data" | sed -n "${record_num}p")
    
    if [ -z "$record" ]; then
        echo -e "${RED}Record not found${ENDCOLOR}"
        return 1
    fi

    IFS=',' read -ra EXISTING_RECORD <<< "$record"

    for ((i=0; i<${#HEADER_COLS[@]}; i++)); do
        col="${HEADER_COLS[i]}"
        
        echo -e "${YELLOW}Current $col: ${EXISTING_RECORD[i]}${ENDCOLOR}"
        
        while true; do
            read -p "Enter new $col (${column_types[$col]} type, or skip to keep current): " new_value
            
            if [ -z "$new_value" ]; then
                row_data["$col"]="${EXISTING_RECORD[i]}"
                break
            fi

            case "${column_types[$col]}" in
                "int")
                    if validate_int "$new_value" "$col"; then
                        row_data["$col"]="$new_value"
                        break
                    fi
                    ;;
                "float")
                    if validate_float "$new_value" "$col"; then
                        row_data["$col"]="$new_value"
                        break
                    fi
                    ;;
                "string")
                    if [ -n "$new_value" ]; then
                        row_data["$col"]="$new_value"
                        break
                    else
                        echo -e "${RED}$col cannot be empty${ENDCOLOR}"
                    fi
                    ;;
                *)
                    echo -e "${YELLOW}Warning: Unknown type ${column_types[$col]} for column $col${ENDCOLOR}"
                    row_data["$col"]="$new_value"
                    break
                    ;;
            esac
        done
    done

    updated_row=""
    for col in "${HEADER_COLS[@]}"; do
        if [ -z "$updated_row" ]; then
            updated_row="${row_data[$col]}"
        else
            updated_row="${updated_row},${row_data[$col]}"
        fi
    done

    awk -F',' -v OFS=',' -v search_record="$record" -v replace_record="$updated_row" '
    $0 == search_record {$0 = replace_record}
    {print}
    ' "$filename" > "${filename}.tmp" && mv "${filename}.tmp" "$filename"

    echo -e "${GREEN}Record updated successfully.${ENDCOLOR}"
}

update_rows() {
    header "Update Table Data"
    get_tables
    
    echo "Enter q to exit"
    
    while true; do
        read -p "Enter Table Name: " table
        
        if [[ "$table" == "q" ]]; then
            break
        fi
        
        update_data
    done

    read -p "Press Enter to continue"
}