#!/usr/bin/env bash

# Creating Database
mongo $1 --eval "db.test.insert({name:'db creation'})" 2>/dev/null
