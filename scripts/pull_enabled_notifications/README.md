# Chrome Preference File Parser

## Overview

Takes either a file path with `-path` or a list of hosts with `-hosts`.

- If a filepath is provided it will parse out the sites listed under notifications.
- If hosts are provided the script will go to each host and run the following code:
  - enumerate each directory under C:\Users
  - attempt to locate `AppData\Local\Google\Chrome\User Data\` under the users directory
  - if the folder is found it will enumerate every folder that contains `Default` or `Profile`
    - By default the users profile will be under `Default`, however, if the users has created multiple chrome profiles there will be `Profile 1`, `Profile 2` and so on
  - it will then attempt to find a `Preferences` file in each location and parse out the sites listed under notifications

Relevant Case: #18422
