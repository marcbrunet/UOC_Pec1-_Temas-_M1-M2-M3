#!/bin/bash


# filter arguments
USERS=""
USERSFLAG=false
NEXT=false
LISTADO=false
INFORMA=false


for var in "$@"; do
  case $var in
    -e)
        INFORMA=true
        NEXT=false
        ;;
    -a)
        LISTADO=true
        NEXT=false
        ;;
    -uu)
        NEXT=true
        USERSFLAG=true
        ;;
    * )
        ;;
  esac
  if $NEXT; then
    if [[ $var != "-uu" ]]; then
      USERS=$USERS" "$var
    fi
  fi

done

if $LISTADO; then
  if $USERSFLAG; then
    for user in $USERS; do
      #statements
      if id -u "$user" >/dev/null 2>&1; then
        :
      else
        echo "el ususario $user no existe" || exit 1
      fi
    done
  else
    USERS=$(sudo cat /etc/passwd | awk -F':' '{ print $1 }')
  fi
  for user in $USERS; do
    #statements
    archivos=$(find / -user $user -mtime -1 2>/dev/null)
    if [ "${#archivos}" != "0" ]; then
          echo "##################################################################"
          echo "archovos del ususario $user"
          for file in $archivos; do
            echo  $file
          done
          datatime=$(date '+ %d_%m_%Y_%X')
          filename=$("$user"-"$datatime" | tr -d ' ')
          echo $archivos > /root/informes/"$filename"
    fi
  done
fi

exit 0
