Live Concert Tracker
====================

This is a Pyramid application that allows you to set up a live concert database.
The purpose of this application is to allow a user to host media recordings and files associated with live concerts.
I use this for my live-rage site (temporarily offline) and it has worked extremely well.

Usage
-----

In order to use this, the Pyramid base framework must be installed, as well as the MongoDB scaffold.
Database settings must be included in your development.ini or production.ini .
Feel free to drop in your own bootstrap theme as well.
Additionally, the directory that is written to for file uploads needs to be specified in the production / development.ini as:

  BASE_DIR = "/path/to/directory"


Notes
-----

There is still a lot of work to be done.
Some of the models need to be merged, and there is some redundant information.
At the moment, no scripts are included to facilitate file syncing / sharing / sharding / etc between servers.
If you use it as is, it will write to a directory on the server itself, although I have some changes coming that make it more "extensible", ie host on multiple servers.

JS Notes
--------

Yes, I know it's really bad (global namespace? what?), this is what I'm fixing next.
