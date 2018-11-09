#!/bin/bash

# filter arguments
USERS=""
USERSFLAG=false
NEXT=false
LISTADO=false
INFORMA=false

#Echo de esta forma antes de leer los comentarios en el foro del error de -u a -uu
# obtencion de los paramentos
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

# obtencion de lo usuarios i compraviociones
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

#paramente de busqueda de fichers modificats
if $LISTADO; then
  for user in $USERS; do
    #statements
    archivos=$(find / -user $user -mtime -1 2>/dev/null)
    if [ "${#archivos}" != "0" ]; then
          echo "##################################################################"
          echo "archovos del ususario $user"
          for file in $archivos; do
            echo  $file
          done
          datatime=$(date '+ %d-%m-%Y-%X')
          filename=$(echo "$user-$datatime" | tr -d ' ')
          echo $archivos > /root/informes/"$filename"
    fi
  done
fi

if $INFORMA; then
  for user in $USERS; do
    lastloguins=$(sudo last --time-format iso $user  | tr '\t(' '\t ' | tr ')\t\n' '\n '|  awk '{if ($1!="wtmp") if($1!="reboot") print $1"-"$2"-"$7"_"$4}')
    array=(${lastloguins//&/ })
    EPOCH='jan 1 1970'
    sum=0
    for i in "${!array[@]}";do
      log=$(echo "${array[i]}")
      Loguindate=$(echo $log | awk -F '_' '{print $2}' | awk -F 'T' '{print $1}')
      limitdate=$(date --iso-8601 -d 'now - 8 days')
      if [[ "$Loguindate" > "$limitdate" ]]; then
          date=$(echo $log | awk -F '_' '{print $1}'| awk -F '-' '{if ($3!="in")print $3":00"}')
          sum="$(date -u -d "$EPOCH $date" +%s) + $sum"
      fi
    done
    if [[ ${#array[@]} > 0 ]]; then
      secons=$(echo $sum|bc)
      connecttime=$(date -u -d @$secons +"%T")
      echo $user '  ' $connecttime '  ' ${#array[@]}
    fi
  done
fi
exit 0
