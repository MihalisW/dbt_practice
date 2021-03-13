#!/usr/bin/env bash 
dbt run --models extracts
dbt test
dbt snapshot 
dbt run --models facts