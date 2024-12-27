#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services
DISPLAY_SERVICES() {
  echo -e "\n~~~~~ AVAILABLE SERVICES ~~~~~"
  # Get the list of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Function to schedule an appointment
SCHEDULE_APPOINTMENT() {
  # Prompt for service selection
  echo -e "\nPlease select a service by entering the service number:"
  read SERVICE_ID_SELECTED

  # Validate the service ID
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nInvalid service number. Please try again."
    DISPLAY_SERVICES
    SCHEDULE_APPOINTMENT
    return
  fi

  # Prompt for customer phone number
  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE

  # Check if the customer exists
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    # Prompt for customer name if they don't exist
    echo -e "\nIt seems you are a new customer. Please enter your name:"
    read CUSTOMER_NAME

    # Insert the new customer into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  fi

  # Prompt for appointment time
  echo -e "\nEnter the time for your appointment:"
  read SERVICE_TIME

  # Insert the appointment into the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *| *$//g') # Trim whitespace
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g') # Trim whitespace
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nAn error occurred while scheduling your appointment. Please try again."
  fi
}

# Main script
echo -e "\n~~~~~ MY SALON ~~~~~\n"
DISPLAY_SERVICES
SCHEDULE_APPOINTMENT