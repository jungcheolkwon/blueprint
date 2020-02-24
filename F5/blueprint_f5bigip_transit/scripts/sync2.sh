#!/usr/bin/expect

#edited by JC
#j.kwon@f5.com
log_user 0

set HOME "$env(HOME)"
set name [exec cat $HOME/.ssh/.user]
set password [exec cat $HOME/.ssh/.password]
set host [lindex $argv 0]
sleep 3

spawn ssh -o StrictHostKeyChecking=no $name@$host -p 222

expect ".*#"
send "modify sys db provision.1nicautoconfig value disable\n"
expect ".*#"
send "modify cm device bigip2 configsync-ip 172.16.1.11\n"
expect ".*#"
send "modify cm trust-domain add-device { ca-device true device-ip 172.16.1.10 device-name bigip1 username $name password $password }\n"
expect ".*#"
send "create cm device-group sync-group devices add { bigip1 bigip2 } type sync-failover auto-sync enabled network-failover disabled\n"
expect ".*#"
send "run cm config-sync to-group sync-group\n"
expect ".*#"
send "save sys config\n"
expect ".*#"
send "quit\n"
