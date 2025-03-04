#!/bin/bash

validate_int() {
    if ! [[ $1 =~ ^[+-]?[0-9]+$ ]]; 
    then 
        echo -e "${RED} $2  must be a integer ${ENDCOLOR}" 
        return 1
    else
        return 0
    fi
}

validate_float() {
    if ! [[ $1 =~ ^[+-]?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; 
    then 
        echo -e "${RED} $2 must be a Float${ENDCOLOR}" 
        return 1
    else
        return 0
    fi
}

validate_string() {
  if ! [[ $1 =~ ^[a-zA-Z]+$ ]]; 
  then
    echo -e "${RED} $2 must be a string (no numbers allowed) ${ENDCOLOR}"
    return 1  
  else
    return 0  
  fi
}

validate_type() {
    local types=("int" "string" "float")
    
    valid=false
    for type in "${types[@]}"; do
        if [[ "$type" == "$1" ]]; 
        then
            valid=true
            break
        fi
    done
    
    if ! $valid; 
    then
        echo -e "${RED} $2 must be one of: ${types[@]} ${ENDCOLOR}"
        return 1
    fi
}
