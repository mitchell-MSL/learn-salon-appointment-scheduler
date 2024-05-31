#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#$PSQL "TRUNCATE TABLE customers CASCADE;"
#$PSQL "TRUNCATE TABLE appointments;"

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #display service list
  SERVICE_LIST
  #if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Sorry, that's not a service."
    
  else
    FIND_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  fi

  # if not available
  if [[ -z $FIND_SERVICE ]]
  then
    MAIN_MENU "Sorry, that's not a service."

  else
    # get customer info
    echo -e "\nGreat, what's the best number to reach you at?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    echo -e "\nAnd what time would you like your appointment?"
    read SERVICE_TIME
    # insert appointment
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    NEW_ROW=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $FIND_SERVICE, '$SERVICE_TIME');")


    # get appointment info
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$FIND_SERVICE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' ")
    # send to main menu
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
    exit 0
  fi
}


SERVICE_LIST(){
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "Here are the services we have available:"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
}

MAIN_MENU
