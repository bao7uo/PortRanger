#!/bin/bash

# -----------------------------------------------
# PortRanger.sh
# -----------------------------------------------
# Copyright (c) 2018 Paul Taylor @bao7uo
# See README on github for detailed information.
# github.com/bao7uo/PortRanger
# -----------------------------------------------
# Accepts an unordered list of ports for example,
# from a grepable nmap (gnmap) file, and
# condenses it into a comma-separated port-range
# list that is useful for input into other tools.
# -----------------------------------------------

if test -t 0; then
    echo PortRanger requires a port list on stdin.
    echo 'e.g. grep -oP "[0-9]+(?=/open)"'\
            'my_results.gnmap | ./PortRanger.sh'
    exit
fi

[[ -n $1 ]] && RANGE_SPAN=$1 || RANGE_SPAN=1

paste -sd, < <(

    while read PORT; do

        function get_result {
            [[ $RANGE_START -eq $RANGE_END ]] && 
                echo $RANGE_START || 
                echo $RANGE_START-$RANGE_END
        }

        [[ -z $RANGE_START ]] && 
                RANGE_START=$PORT RANGE_END=$PORT || {

            if ((PORT <= RANGE_END + RANGE_SPAN)); then
                RANGE_END=$PORT
            else
                echo $(get_result $RANGE_START $RANGE_END)
                RANGE_START=$PORT RANGE_END=$PORT
            fi

        }   

    done < <(cat | sort -un)

    echo $(get_result $RANGE_START $RANGE_END)

)
