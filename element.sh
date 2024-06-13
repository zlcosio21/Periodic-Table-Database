#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ELEMENT="$1"
SYMBOL_ELEMENT=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$ELEMENT';")
NAME_ELEMENT=$($PSQL "SELECT name FROM elements WHERE name = '$ELEMENT';")

complete_message() {

  if [[ "$ELEMENT" == "$ATOMIC_NUMBER" || $ELEMENT =~ ^[0-9]+$ ]]; then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $ELEMENT;")
  elif [[ "$ELEMENT" == "$SYMBOL_ELEMENT" ]]; then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL_ELEMENT';")
  elif [[ "$ELEMENT" == "$NAME_ELEMENT" ]]; then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME_ELEMENT';")
  else
    echo "I could not find that element in the database."
    exit 0
  fi

  NAME_COMPLETE=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
  NAME_AND_SYMBOL=$($PSQL "SELECT name || ' (' || symbol || ')' FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
  TYPE=$($PSQL "SELECT types.type FROM properties INNER JOIN types ON types.type_id = properties.type_id WHERE atomic_number = $ATOMIC_NUMBER;")

  MESSAGE_PART_ONE=$($PSQL "SELECT 'The element with atomic number ' || atomic_number || ' is $NAME_AND_SYMBOL' FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
  MESSAGE_PART_TWO=$($PSQL "SELECT '$TYPE, with a mass of ' || atomic_mass || ' amu. $NAME_COMPLETE has a melting point of ' || melting_point_celsius || ' celsius and a boiling point of ' || boiling_point_celsius || ' celsius.' FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")

  echo "$MESSAGE_PART_ONE. It's a $MESSAGE_PART_TWO"

}

complete_message