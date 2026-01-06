function wps_cloud
    if test (count $argv) -ne 1
        echo "Usage: wps_cloud [on|off]" >&2
        return 1
    end

    set mode ""
    switch $argv
        case "off"
            set mode "-x"
        case "on"
            set mode "+x"
        case '*'
            echo "Error: action must be 'on' or 'off'" >&2
            return 1
    end

    sudo fd '^wpscloudsvr$' / --type f --regex --exec chmod $mode {}
    if test $status -eq 0
        echo "chmod $mode OK"
    else
        echo "Error: failed to execute fd or chmod" >&2
        return 1
    end
end
