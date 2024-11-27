#!/bin/bash 

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [ -z "$1" ]; then 
    echo "Please provide an element as an argument." 
    exit 0 
fi 

# Check if the input is a number
if [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1;")
else
  ELEMENT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1';")
fi

if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database"
else
  # atomic_number, symbol, name, type... 
  ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                        FROM elements 
                        INNER JOIN properties USING(atomic_number) 
                        INNER JOIN types USING(type_id) 
                        WHERE atomic_number=$ELEMENT")
  echo "$ELEMENT_INFO" | while IFS='|' read atomic_number name symbol type atomic_mass melting_point_celsius boiling_point_celsius
  do
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
  done
fi
