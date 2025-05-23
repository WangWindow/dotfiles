#!/bin/bash

#创建/etc/rc.local文件
if [ -f /etc/rc.local ];
then
    sudo chmod 777 /etc/rc.local
    echo 'Error: find /etc/rc.local'
    echo 'please append sentences below by yourselves:

#!/bin/bash
/bin/backlight_load.sh &
exit 0

'
else
    sudo touch /etc/rc.local
    sudo chmod 777 /etc/rc.local
    sudo echo '''#!/bin/bash
/bin/backlight_load.sh &
exit 0''' > /etc/rc.local
fi


sudo echo '''
[Unit]
Description=/etc/rc.local Compatibility
Documentation=man:systemd-rc-local-generator(8)
ConditionFileIsExecutable=/etc/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no

[Install]
WantedBy=multi-user.target
Alias=rc-local.service
'''>> /etc/systemd/system/rc-local.service
sudo systemctl enable rc-local.service
sudo systemctl start rc-local.service
sudo systemctl status rc-local.service

