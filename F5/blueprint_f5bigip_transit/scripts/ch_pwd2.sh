#!/usr/bin/expect

#edited by JC
#j.kwon@f5.com
log_user 0

set HOME "$env(HOME)"
set name [exec cat $HOME/.ssh/.user]
set password [exec cat $HOME/.ssh/.password]
set host [lindex $argv 0]

spawn ssh -o StrictHostKeyChecking=no $name@$host -p 222

expect ".*#"
send "modify auth password $name\n"
expect ".*"
send "$password\r"
expect ".*"
send "$password\r"
expect ".*#"
send "modify sys global-settings hostname bigip2.f5.com\n"
expect ".*#"
send "mv cm device bigip1 bigip2\n"
expect ".*#"
send "modify sys ntp servers add { time.google.com }\n"
expect ".*#"
send "modify sys ntp timezone Asia/Singapore\n"
expect ".*#"
send "modify sys dns name-servers add { 8.8.4.4 }\n"
expect ".*#"
send "save sys config\n"
expect ".*#"
send "quit\n"
