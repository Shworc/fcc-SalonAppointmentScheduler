#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU(){
  #if [[ $1 ]]
  #then
  #  echo -e "\n$1"
  #fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # get available services
  #echo -e "1) cut \n2) color \n3) perm \n4) style \n5) trim"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$($PSQL "SELECT name FROM services INNER JOIN appointments ON services.service_id = appointments.service_id WHERE services.service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICES ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_PHONE_READ=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
    SERVICE_NAME=$($PSQL "SELECT name FROM services INNER JOIN appointments ON services.service_id = appointments.service_id WHERE services.service_id = $SERVICE_ID_SELECTED")
    CUSTOMER_NAME_READ=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # get phone number for services
    if [[ -z $CUSTOMER_PHONE_READ ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME_READ=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      #echo $INSERT_CUSTOMER
      #
      echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME_READ?"
      read SERVICE_TIME
      APPOINTMENT
    else
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE_NAME=$($PSQL "SELECT name FROM services INNER JOIN appointments ON services.service_id = appointments.service_id WHERE services.service_id = $SERVICE_ID_SELECTED")
      SERV_NAME=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
      CUSTOMER_NAME_READ=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUST_NAME=$(echo $CUSTOMER_NAME_READ | sed 's/\s//g' -E)
      echo "What time would you like your $SERV_NAME, $CUST_NAME?"
      read SERVICE_TIME
      APPOINTMENT
    fi
    
  fi
}
APPOINTMENT(){
  SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #SERVICE_NAME=$($PSQL "SELECT name FROM services INNER JOIN appointments ON services.service_id = appointments.service_id WHERE services.service_id = $SERVICE_ID_SELECTED")
  SERV_NAME=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME_READ=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  CUST_NAME=$(echo $CUSTOMER_NAME_READ | sed 's/\s//g' -E)
  APPOINTMENT_RESERVE=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  echo $APPOINTMENT_RESERVE
  SERVICE_NAME=$($PSQL "SELECT name FROM services INNER JOIN appointments ON services.service_id=appointments.service_id WHERE services.service_id=$SERVICE_ID_SELECTED")
  echo "I have put you down for a $SERV_NAME at $SERVICE_TIME, $CUST_NAME."
  # send to main menu
}

MAIN_MENU
