# Practice data pipeline in dbt

This is a practice dbt project.

## Prerequisites

You will have to have installed dbt locally. Comprehensive instructions can be found [here](https://docs.getdbt.com/dbt-cli/installation).

This particular project has been written with postgres in mind. The [postgres.app](https://postgresapp.com/) 
makes it quite quick and easy to spin up a local instance of postgres.

## Setting up the project

First clone this repository like so:

```
git clone https://github.com/MihalisW/dbt_practice.git
cd dbt_practice
```

The `profiles.yml` file uses jinja strings to retrieve your preferred settings 
from your environment variables. There are other files in this project that use
these settings as well. Use these commands in the terminal in order 
to set them.

```
export DBT_DB=postgres
export DBT_HOST=replace_this_with_the_database_host
export DBT_USER=replace_this_with_the_db_user
export DBT_PASS=replace_this_with_the_db_password
export DBT_PORT=replace_this_with_the_port_number
export DBT_DBNAME=replace_this_with_the_dm_name
export DBT_SCHEMA=replace_this_with_the_target_dm_schema
export DBT_SOURCE=replace_this_with_the_source_dm_schema

```

Now you can use the following config by running `nano ~/.dbt/profiles.yml` and pasting the following in.

```
data_warehouse_pipeline:
  target: dev
  outputs:
    dev:
      type: "{{ env_var('DBT_DB') }}"
      host: "{{ env_var('DBT_HOST') }}"
      user: "{{ env_var('DBT_USER') }}"
      pass: "{{ env_var('DBT_PASS') }}"
      port: "{{ env_var('DBT_PORT')|int }}"
      dbname: "{{ env_var('DBT_DBNAME') }}"
      schema: "{{ env_var('DBT_SCHEMA') }}"
      threads: 1
      keepalives_idle: 0 # default 0, indicating the system default
      search_path: ""
      role: ""
      sslmode: ""
```

Next you need to install all dependencies. For this you can run:

```
dbt deps
```
## Running the project

You can run all the models and snapshots in this project in the desired order by running

```
./transform_pipeline.sh
```
### Troubleshooting

You might find that your terminal will not execute the above bash file.
These are some initial steps that should overcome most problems:

1. Run `chmod +x transform_pipeline.sh` in order to allow execution permissions on the file.
2. Run `which bash`. Paste the outputted path in line 1 of `transform_pipeline.sh` like so: `#!path/to/bash`. 

## Results 

The transform pipeline should create two source tables for illustrative purposes and then outputs 
two tables in the target: `current_pageview_facts` for facts using the 
current location of the user and `immutable_pageview_facts` for facts using the time-based location of the user.

## Testing incremental features
In order to observe the incremental features of the pipeline follow these steps:
1. Run the pipeline for the first time
2. Replace line 54 in `users_extract.sql` with the following: 
   `SELECT	50	 AS id,	'SE15 1EN'	 AS postcode`
3. Re-run pipeline  
4. Uncomment lines 1242-1243 in `pageviews_extract.sql`
5. Re-run pipeline 

## Scheduling this pipeline

Assuming that we require an hourly cadance then we this should be scheduled every hour, with a 10 minute grace period to allow the extract process to complete.
**Note** this project loads 'extract' tables simply to illustrate the overall pipeline conveniently. This would be removed in an actual scenario from the `transform_pipeline.sh` file. 
In order to be sure that we meet our 49 minute window before the next extraction process we could use a clustering key on all instances of the user id, a partition key on timestamps between joined tables in order to improve performance.