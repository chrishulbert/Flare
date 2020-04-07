# Flare

Simple 2-way sync to Backblaze B2

* Hidden files are deliberately not synced. Things would quickly get out of hand (eg collisions/conflicts) if we synced eg git metadata, so I simply don't do that. This also has the upside of ignoring .DS_Store nonsense.
* macOS touches folder's last modified dates whenever it changes a .DS_Store, which makes for extra work unfortunately.

## License

License is MIT, which means no liability is accepted. This is just a hobby project for me. You must treat this as experimental and don't use it for important files.

## Folder modification date issues

* macOS files change last modified as you'd expect: when changing contents.
* macOS changes a folder's 'last modified' date when you add or remove or rename a file, but not when you change a file's contents.
* Worse: If you add/remove/rename a file in a folder, it doesn't affect that folder's parent folder last modified date at all.
* Windows is much the same apparently: parent-parent folders don't update dates.
* Summary: Folder last modified dates are useless.
* There used to be plenty of code in here for using folder dates to skip entire hierarchies efficiently, but that unfortunately has to be removed. 

## Folder syncing limitations

Folder syncing is very rudimentary. It should work until you try to delete a folder, at which point it'll lose metadata for that folder and assume it needs to be re-synced down.
Flare keeps track of folders that existed at the last sync, so it can guess that a folder was deleted since last sync. However, since folder modification dates are largely unhelpful, it's rudimentary.
And since the BZ api doesn't give us information about folder deletions, even if you did send a deletion 'up', another client wouldn't know to pull that deletion 'down'.
Perhaps something could be done with empty folders: If it detects that some files were deleted in a folder, and thus emptied a folder, it would presume that the folder was deleted and is to be removed locally.
However, I'm still uncomfortable with the heuristics for folder deletions because the dates are meaningless, so I'm not going to implement this.
Having said all that, if you have folders with contents, Flare will work just fine - just don't try deleting those folders. 

## File deletions

For safety, if the sync heuristics determine that a file was deleted elsewhere and needs to be deleted on your machine, it moves it into a temporary folder.
The temporary folder is: `.flare/Deleted`.
The date that the file was deleted is prefixed to its filename in the format YYYYMMDD.
After a month, it is deleted from that folder.
So if you ever lose a file, look there first!
