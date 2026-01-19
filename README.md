# Unreal-Engine-Batch-Cleaner
It's batch. It Cleans. It's unreal.

Clears out those meddelsome `upipelinecache` files for unreal engine games. Useful for early release titles that go through frequent updates.

## Key Features:

* Safe by default - Moves files to a timestamped `DELETE_ME` folder in your TEMP directory instead of deleting
* `--delete` flag - Permanently deletes if you want that behavior
* `--log` flag - Creates ue_cache_cleaner.log in the same directory as the script with detailed timestamps
* Timestamped backups - Each run creates a new folder like `DELETE_ME\UE_PipelineCache_20260118_143022`
* Recovery - You can inspect or restore files from the `DELETE_ME` folder if something goes wrong

# Setup Instructions:

## Save the script:

Copy the script to a `.bat` file (e.g., `CleanUECache.bat`)
Save it somewhere permanent like `C:\Users\ME\Scripts\` or your Documents folder
Star the repo. Copy the file manually. Use `git clone`. You don't have to learn or install `git` for this.

## Set to run at login via Task Scheduler:

* Press Win + R, type taskschd.msc, press Enter
* Click "Create Basic Task" in the right panel
* Name it something like "Clean UE Pipeline Cache"
* Trigger: "When I log on"
* Action: "Start a program"
* Browse to your `.bat` file
* Check "Open Properties dialog" on the final screen
* In Properties, go to the "General" tab and check "Run with highest privileges"
* Click OK

## Alternative - Quick Test:
Just double-click the .bat file anytime to run it manually and see what it finds/deletes.

# What it does:

* Searches your entire `%LocalAppData%` folder for any file named `upipelinecache`
* Moves or deletes all instances it finds
* Shows you what it moved/deleted

# For Task Scheduler setup:

* If you want logging on login, set the arguments field to: `--log`
* Completely silent, add the `--silent` argument
* If you want permanent deletion on login: `--delete --log`
* For "safe mode" (default): leave arguments blank
  * Weakling

The log file will be created in the same folder as the `.bat` file, so you can review what was found and processed on each run. You can manually clean out old `DELETE_ME` folders whenever you're confident you don't need them.
