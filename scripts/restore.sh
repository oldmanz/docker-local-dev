#!/bin/bash

file_count=0

for file in /dump/*
do
  echo "Found file $file"
  ((file_count=file_count+1))
done

until pg_isready
do
    echo "."
    sleep 1
done
sleep 2

if [ $file_count -eq 0 ]
then
  echo "$file_count" 
  echo "No Backup file found."
elif [ $file_count -ge 2 ]
then
  echo "$file_count" 
  echo "Far too many backup files found."
else
  for file in /dump/*
  do
    echo "Starting restore for file $file"
	su - postgres -c "pg_restore -d spatialdb -cv $file"
  done
fi