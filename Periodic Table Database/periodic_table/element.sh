#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# check if argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # check if argument is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # get element info    
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol FROM elements WHERE atomic_number=$1")
  else
    # query properties
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol FROM elements WHERE symbol='$1' OR name='$1'")
  fi

  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    while IFS="|" read ATOMIC_NUMBER NAME SYMBOL
    do
      PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
      while IFS="|" read MASS MELTING BOILING TYPE
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
      done <<< "$PROPERTIES"
    done <<< "$ELEMENT"
  fi
fi
