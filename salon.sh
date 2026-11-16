#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e '\n~~~~~ MY SALON ~~~~~\n'
echo -e 'Welcome to My Salon, how can I help you?\n'

SERVICE_MENU(){
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL 'SELECT * FROM services')
  echo "$SERVICES" | while IFS='|' read -r ID SERVICE
  do
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  PROCESS_SERVICE $SERVICE_ID_SELECTED
}

PROCESS_SERVICE(){
  FIND_SERVICE=$($PSQL 'SELECT service_id,name FROM services WHERE service_id = '$1'');
  IFS='|' read -r SERVICE_ID SERVICE_NAME <<< "$FIND_SERVICE"
  if [[ -z $FIND_SERVICE ]]
  then
  SERVICE_MENU "I could not find that service. What would you like today?"
  else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  FIND_NUMBER=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $FIND_NUMBER ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      SET_SCHEDULE
    else
      SET_SCHEDULE
    fi
  fi
}

SET_SCHEDULE(){
  CUSTOMER_INFO=$($PSQL "SELECT customer_id,name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  IFS='|' read -r CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER_INFO"

  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID','$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}
SERVICE_MENU


