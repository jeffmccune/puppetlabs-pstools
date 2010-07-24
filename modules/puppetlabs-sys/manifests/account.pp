# Class: puppetlabs-sys::account
#
#   This defined resource type manages user accounts.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
define puppetlabs-sys::account(
  $homedir=false,
  $uid,
  $gid,
  $groups=["0"],
  $email=false,
  $comment="",)
{
  $module = "puppetlabs-sys"
  $source = "puppet:///modules/${module}"
  $name_real = $name
  $email_real = $email ? {
    false => "${name_real}@puppetlabs.com",
    default => $email,
  }
  $homedir_real = $homedir ? {
    false => "/home/${name_real}",
    default => $homedir,
  }
  $uid_real => $uid ? { false => undef, default => $uid }
  $gid_real => $gid ? { false => undef, default => $gid }
####
  File {
    owner => $uid_real,
    group => $gid_real,
    mode => "0644",
    replace => false,
  }
####
  group { "${name_real}":
    ensure => present,
    gid => $gid_real,
  }
  user { "${name_real}":
    ensure => "present",
    homedir => $homedir_real,
    uid => $uid_real,
    gid => $gid_real,
  }
  file {
    "$homedir_real":
      ensure => directory,
      require => [ User["$name_real"], Group["$name_real"] ];
    "${homedir_real}/.bash_profile":
      mode => "0755",
      source => "${source}/bash_profile",
    "${homedir_real}/.ssh":
      ensure => directory,
      mode => "0700";
    "${homedir_real}/.ssh/authorized_keys":
      source => "${source}/authorized_keys";
    "${homedir_real}/.vim":
      ensure => directory,
      source => "${source}/vim",
      recurse => true;
    "${homedir_real}/.vimrc":
      source => "${source}/vimrc";
  }
}
#
