# Chrome History Grabber

## Overview

Takes a list of hosts with `-hosts`.

- If hosts are provided the script will go to each host and run the following code:
  - enumerate each directory under `C:\Users`
  - attempt to locate `AppData\Local\Google\Chrome\User Data\` under the users directory
  - if the folder is found it will enumerate every folder that contains `Default` or `Profile`
    - By default the users profile will be under `Default`, however, if the users has created multiple chrome profiles there will be `Profile 1`, `Profile 2` and so on
  - it will then attempt to find a `History` file in each location 
  - After grabbing all the paths it will then copy these files to the bastion under `C:\[Current User Profile]\Documents\[hostname]_[username]_[profile_name].sqlite"


