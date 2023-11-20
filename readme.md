## Bash Scripts to track overall memory usage and usage of specific processes based on command string.

## Install
1. Clone the repo
2. Replace `custom_string_1` with whatever command string you want to track.
3. Add more custom strings by duplicating the line with `custom_string_1` and then duplicating this line in the `jsonObject` variable `{ "string": "OrbStack", "memory": "$(echo $customString1 | awk '{print $1}')", "cpu": "$(echo $customString1 | awk '{print $2}')" }` and replacing `customString1` `customString2` (if that's the count you're at).
4. Edit your crontab with `crontab -e` and add the lines in the crontab.cron file in the repo.

## Why?
I've been switching between different ways of running Docker on my Mac and wanted to a way to reliably track each ways memory usage.
