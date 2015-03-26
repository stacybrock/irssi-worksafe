use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '0.03';
%IRSSI = (
	authors	=> 'Stacy Brock',
	contact => 'kalrnux@yahoo.com',
	name => 'Worksafe',
	description => 'Automatically switches away from an unsafe window after a set period of inactivity.',
	license => 'GPLv2 (http://www.gnu.org/copyleft/gpl.html)',
	url => 'https://github.com/stacybrock/irssi-worksafe',
	);

my @warning_messages = (
	"WATCH WHERE YOU'RE TYPING!",
	"DO YOU KNOW WHAT WINDOW YOU'RE IN?",
	"THIS ISN'T THE CHANNEL YOU'RE LOOKING FOR",
	);
my $timeout_tag, my $worksafe_status = 'stopped';

sub check_window {
# 	Irssi::print("check_window: $timeout_tag");
	
	my $win = Irssi::active_win();
	my $witem = $win->{active};
	my $status = $witem->{status};
	
	my $unsafe = Irssi::settings_get_str('worksafe_unsafe_window');
	if($win->get_active_name() eq $unsafe) {
		my $target_win = Irssi::window_find_item(Irssi::settings_get_str('worksafe_switch_to_window'));
		$target_win->set_active();
# 		Irssi::print("DEBUG: switched window away from unsafe");
		if(Irssi::settings_get_bool('worksafe_warn_after_switch')) {
			$target_win->print(get_warning_message(), MSGLEVEL_CLIENTNOTICE);
		}
	}
}

sub cmd_worksafe {
	my($data, $server, $witem) = @_;

	if(!$data) {
		Irssi::print("worksafe is $worksafe_status");
		Irssi::print("worksafe usage:");
		Irssi::print("/worksafe [start | stop]");
	} else {
		my @data = split(' ', $data);
		if($data[0] eq 'start') {
			if($worksafe_status eq 'running') {
				Irssi::print('worksafe already running');
			} else {
				Irssi::signal_add_last("window changed", "sig_window_changed");
				$worksafe_status = 'running';
				Irssi::print('worksafe started...');
			}
		} elsif($data[0] eq 'stop') {
			if($worksafe_status eq 'running') {
				Irssi::signal_remove("window changed", "sig_window_changed");
				Irssi::signal_remove("message own_public", "reset_idle_timer");
				Irssi::signal_remove("message own_private", "reset_idle_timer");
				Irssi::timeout_remove($timeout_tag);
			}
			$worksafe_status = 'stopped';
			Irssi::print('worksafe stopped');
		} else {
			Irssi::print("worksafe usage:");
			Irssi::print("/worksafe [start | stop]");
		}
	}
}

sub sig_window_changed {
	my($new_win, $old_win) = @_;

# 	Irssi::print("sig_window_changed: ".$new_win->get_active_name()." ".$old_win->get_active_name());
	if($new_win->get_active_name() eq Irssi::settings_get_str('worksafe_unsafe_window')) {
		Irssi::signal_add_last("message own_public", "reset_idle_timer");
		Irssi::signal_add_last("message own_private", "reset_idle_timer");
		$timeout_tag = Irssi::timeout_add(Irssi::settings_get_time('worksafe_check_interval'), 'check_window', '');
	} else {
		Irssi::signal_remove("message own_public", "reset_idle_timer");
		Irssi::signal_remove("message own_private", "reset_idle_timer");
		Irssi::timeout_remove($timeout_tag);
	}
}

sub reset_idle_timer {
	my($server, $msg, $target) = @_;

	if($target eq Irssi::settings_get_str('worksafe_unsafe_window')) {
		if($timeout_tag) {
			Irssi::timeout_remove($timeout_tag);
		}
		$timeout_tag = Irssi::timeout_add(Irssi::settings_get_time('worksafe_check_interval'), 'check_window', '');
	}
}

sub get_warning_message {
	return $warning_messages[rand(@warning_messages)];
}

Irssi::command_bind('worksafe', 'cmd_worksafe');
Irssi::settings_add_str('worksafe', 'worksafe_unsafe_window', 'CHANGEME');
Irssi::settings_add_str('worksafe', 'worksafe_switch_to_window', 'CHANGEMETOO');
Irssi::settings_add_time('worksafe', 'worksafe_check_interval', '5min');
Irssi::settings_add_bool('worksafe', 'worksafe_warn_after_switch', 1);
