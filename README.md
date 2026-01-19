# Unreal-Engine-Batch-Cleaner
It's batch. It Cleans. It's unreal.

Clears out those meddelsome `upipelinecache` files for unreal engine games. Useful for early release titles that go through frequent updates.

## Key Features:

* Safe by default - Moves files to a timestamped `DELETE_ME` folder in your TEMP directory instead of deleting
* `--delete` flag - Permanently deletes if you want that behavior
* `--log` flag - Creates ue_cache_cleaner.log in the same directory as the script with detailed timestamps
* Timestamped backups - Each run creates a new folder like `DELETE_ME\UE_PipelineCache_20260118_143022`
* Recovery - You can inspect or restore files from the `DELETE_ME` folder if something goes wrong

## For Task Scheduler setup:

* If you want logging on login, set the arguments field to: `--log`
* If you want permanent deletion on login: `--delete --log`
* For "safe mode" (default): leave arguments blank
  * Weakling

The log file will be created in the same folder as the `.bat` file, so you can review what was found and processed on each run. You can manually clean out old `DELETE_ME` folders whenever you're confident you don't need them.
