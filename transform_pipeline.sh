#!/usr/bin/env bash 
dbt run --models extracts #--full-refresh
dbt test
dbt snapshot 
dbt run --models facts #--full-refresh