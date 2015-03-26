# irssi-worksafe

This irssi script automatically switches away from an unsafe window after a period of inactivity.

For example, let's say your unsafe window is `#smacktalk` and you currently have it active. If you go inactive (for a configurable time period), the script will automatically switch the active window to something safer, like `#ruby`.

## Configuration

This script adds a few settings to `config`:

* `worksafe_unsafe_window = #changeme`  
This is the unsafe window that the script will be keeping an eye out for.

* `worksafe_switch_to_window = #changemetoo`  
This is the safe window to switch to.

* `worksafe_check_interval = 5min`  
Interval to check for inactivity in the unsafe window. Once the inactivity timeout is hit, the active window will be switched to the safe window. Acceptable values are a number in milliseconds, or a string like "5min", "1hour", etc. See also [irssi's time parsing code](https://github.com/irssi/irssi/blob/9abdeb8611977e0ab56ce3e30ee9561a7e8cb204/src/core/misc.c#L816).

* `worksafe_warn_after_switch = 1`  
Display a warning message after the active window has been switched to the safe window. You *really* don't want to change this to 0, but you can if you want.

These values can be changed from within irssi by running `/set setting_name value`

## Installation and Usage

To install, place a copy of this script in `.irssi/scripts`

To run, start irssi and run `/worksafe start`

To stop, `/worksafe stop`

To autorun whenever irssi is started, create a symlink in `.irssi/scripts/autorun` that points to `worksafe.pl`
