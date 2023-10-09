#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNTER=0

if [[ $# -eq 0 ]]
then
  echo -e "Enter your username:"
  read USER_NAME
  if [[ -z $USER_NAME ]]
  then
    echo "Enter a valid username."
    exit
  else
  # does username exist
  FIND_USER=$($PSQL "SELECT username FROM users WHERE username ILIKE '$USER_NAME'")

  # insert since doesn't exist
  if [[ -z $FIND_USER ]]
  then
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME')")
    GET_NEW_USER=$($PSQL "SELECT username FROM users WHERE username ILIKE '$USER_NAME'")
    echo -e "Welcome, $(echo $USER_NAME | sed -r 's/^ *| *$//g')! It looks like this is your first time here."
    echo -e "Guess the secret number between 1 and 1000:"
    while true
    do
      read USER_GUESS
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    # elif [[ $USER_GUESS -lt 1 || $USER_GUESS -gt 1000 ]]
    # then
    #   echo "Not in range, guess again:"
    else
      ((GUESS_COUNTER++))   

      if [[ $RANDOM_NUMBER -eq $USER_GUESS ]]
      then
        INSERT_NEW_GAME=$($PSQL "UPDATE users SET games_played = 1, best_game = $GUESS_COUNTER WHERE username ILIKE '$USER_NAME'")
        echo -e "You guessed it in $(echo $GUESS_COUNTER | sed -r 's/^ *| *$//g') tries. The secret number was $(echo $RANDOM_NUMBER | sed -r 's/^ *| *$//g'). Nice job!"
        exit
      elif [[ $RANDOM_NUMBER -lt $USER_GUESS ]]
      then
        echo -e "It's lower than that, guess again:"
      else
        echo -e "It's higher than that, guess again:"
      fi
    fi
    done
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username ILIKE '$USER_NAME'")
    BEST_GUESS=$($PSQL "SELECT best_game FROM users WHERE username ILIKE '$USER_NAME'")
    USERNAME=$($PSQL "SELECT username FROM users WHERE username ILIKE '$USER_NAME'")
    echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."

    echo -e "Guess the secret number between 1 and 1000:"
    while true
    do
      read USER_GUESS
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "That is not an integer, guess again:"
    # elif [[ $USER_GUESS -lt 1 || $USER_GUESS -gt 1000 ]]
    # then
    #   echo -e "Not in range, guess again:"
    else
      ((GUESS_COUNTER++))   

      if [[ $RANDOM_NUMBER -eq $USER_GUESS ]]
      then
        echo -e "You guessed it in $(echo $GUESS_COUNTER | sed -r 's/^ *| *$//g') tries. The secret number was $(echo $RANDOM_NUMBER | sed -r 's/^ *| *$//g'). Nice job!"
        BEST_GUESS_QUERY=$($PSQL "SELECT best_game FROM users WHERE username ILIKE '$USER_NAME'")
        if [[ $BEST_GUESS_QUERY -lt $GUESS_COUNTER ]]
        then
          NEW_SCORE=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username ILIKE '$USER_NAME'")
          exit
        else
          NEW_SCORE=$($PSQL "UPDATE users SET best_game = $GUESS_COUNTER, games_played = games_played + 1 WHERE username ILIKE '$USER_NAME'")
          exit
        fi
      elif [[ $RANDOM_NUMBER -lt $USER_GUESS ]]
      then
        echo -e "It's lower than that, guess again:"
      else
        echo -e "It's higher than that, guess again:"
      fi
    fi
    done
  fi
  fi
else
  echo "Proper usage: ./number_guess.sh"
  exit
fi

