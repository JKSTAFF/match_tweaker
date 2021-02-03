#!/bin/bash
export ALL_proxy=$1
arrayRepo=(
    https://github.com/monokoo/luci-app-arpbind.git 
    https://github.com/mchome/luci-app-vlmcsd.git
    https://github.com/mchome/openwrt-vlmcsd.git 
    https://github.com/kuoruan/luci-app-v2ray.git
    https://github.com/kuoruan/openwrt-v2ray.git
)

if [ ! -f "feeds.conf.default" ];
    then read -r -p "Put this script in OpenWRT folder and try again" input0
         exit 1
    else echo '                __         .__          __                         __'
         echo '  _____ _____ _/  |_  ____ |  |__     _/  |___  _  __ ____ _____  |  | __ ___________'
         echo ' /     \\__  \\   __\/ ___\|  |  \    \   __\ \/ \/ // __ \\__  \ |  |/ // __ \_  __ \'
         echo '|  Y Y  \/ __ \|  | \  \___|   Y  \    |  |  \     /\  ___/ / __ \|    <\  ___/|  | \/'
         echo '|__|_|_ (_____ /__|  \____ >___|_ /____|__|   \/\_/  \____ >_____ /__|__\\____ >__|'
         echo '                                 /_____/         Powered by Vector Di-gi' 
fi

read -r -p "Update the stock repo and feeds? [Y/n]" input1
case $input1 in
    [yY])
        git pull && ./scripts/feeds update -a && ./scripts/feeds install -a
        echo "Update complete"
        ;;
    *)
		echo "Skip update..."
	    ;;
esac

read -r -p "Apply custom settings? [Y/n]" input2
case $input2 in
    [yY])
        if [ ! -f "feeds/luci/modules/luci-base/root/etc/config/luci" ];
            then ./scripts/feeds update -a && ./scripts/feeds install -a
        fi
		sed -i 's/auto/zh_cn/g' feeds/luci/modules/luci-base/root/etc/config/luci && sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate && sed -i '/CST-8/a\set system.@system[-1].zonename='"'"'Asia/Shanghai'"'"'' package/base-files/files/bin/config_generate
        echo "Change default locale to Greater China. You still need to install luci language pack manually"
        sed -i 's/192.168/10.0/g' package/base-files/files/bin/config_generate && sed -i 's/10.0.1/10.0.0/g' package/base-files/files/bin/config_generate
        echo "Set default gateway to '10.0.0.1'"
        sed -i 's/disabled=1/disabled=0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
        echo "Wireless will be activated everytime reset"
        sed -i 's*root::0:0:99999:7:::*root:\$1\$Z5PSAHJ9$1UReP9Mm94CqDFVEnROB//:17713:0:99999:7:::*g' package/base-files/files/etc/shadow
        echo "Set 'toor' as the default password for root user"
		echo "Customize applied"
        ;;
        
    *)
		echo "Skip customize..."
	    ;;
esac

read -r -p "Add 3rd-part packages? [Y/n]" input3
case $input3 in
    [yY])
        if [ ! -d "package/custom" ];
            then mkdir package/custom
        fi
        for repo in ${arrayRepo[@]}
        do
            if [ -f ".gitmodules" ] && [ ! -z "`grep "$repo" .gitmodules`" ];
                then echo "$repo  already exist" 
                else 
                    cd package/custom
                    git submodule add $repo 
                    cd ../../
            fi
        done
        cd package/custom/luci-app-v2ray &&  git  checkout luci2  && cd ../../
        git submodule update --remote --merge
        
        echo "Now you can find all 3rd-part package by tapping 'make menuconfig'"
        ;;
    *)
		echo "Do nothing..."
	    ;;
esac
read -r -p "Press any key to quit" input4
exit 1