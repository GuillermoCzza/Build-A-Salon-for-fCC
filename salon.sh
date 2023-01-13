#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ My Salon ~~~~~\n"
MAIN_MENU(){
  if [[ ! -z $1 ]]
  then
    echo $1
  fi
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | sed -r "s/^ *//g; s/ *$//g; s/ \|/)/g"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please input only numbers."
  else

    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "Please input only numbers from the list."
    else

      echo "Please input your phone number"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo "Hello new customer, please input your name."
        read CUSTOMER_NAME
        CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      fi

      echo "At what time do you want to schedule your appointment?"
      read SERVICE_TIME
      APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID'")
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed -r "s/( )+/ /g"
    fi
  fi

}

MAIN_MENU "Welcome, how can I help you?"