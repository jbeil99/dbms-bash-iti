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