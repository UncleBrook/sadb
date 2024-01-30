_sadb_completion()
{
  local cur prev opts cmds c subcommand device_selected adb alias_cmds
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-d -e -s -p"
  cmds="backup bugreport connect devices disable-verity disconnect emu \
        enable-verity features forward get-devpath get-serialno get-state \
        help host-features install install-multiple jdwp keygen \
        kill-server logcat longcat ls ppp pull push reboot \
        reboot-bootloader reconnect remount restore reverse root shell \
        sideload start-server sync tcpip track-devices track-jdwp \
        uninstall unroot usb version wait-for-bootloader wait-for-device \
        wait-for-recovery wait-for-sideload alias"
  cmds_not_need_device="connect devices disconnect help keygen kill-server \
                        start-server version alias"
  subcommand=""
  device_selected=""

  # Find the real adb.
  adb=$(which adb)
  adb_paths=$(which -a adb)

  alias_cmds=$(awk -F '=' '{ print $1}' "${HOME}/.config/sadb/.alias" | tr '\n' ' ')

  read -r line1 <<< "$adb_paths"
  if [[ "$line1" == *"adb: aliased to"* ]]; then
    adb=$(awk 'NR==2 {print; exit}' <<< "$adb_paths")
  fi

  # Look for the subcommand.
  c=1
  while [ $c -lt $COMP_CWORD ]; do
    word="${COMP_WORDS[c]}"
    if [ "$word" = "-d" -o "$word" = "-e" -o "$word" = "-s" ]; then
      device_selected=true
      opts="-p"
    fi
    for cmd in $cmds; do
      if [ "$cmd" = "$word" ]; then
        subcommand="$word"
      fi
    done
    c=$((++c))
  done

  case "${subcommand}" in
    '')
      case "${prev}" in
        -p)
          return 0;
          ;;
        -s)
          # Use 'adb devices' to list serial numbers.
          COMPREPLY=( $(compgen -W "$($adb devices |
                awk '/(device|recovery|sideload)$/{print $1}')" -- ${cur} ) )
          return 0
          ;;
      esac
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
          return 0
          ;;
      esac
      if [ -z "$device_selected" ]; then
        local num_devices=$(( $($adb devices 2>/dev/null|wc -l) - 2 ))
        if [ "$num_devices" -gt "1" ]; then
          # With multiple devices, you must choose a device first.
          COMPREPLY=( $(compgen -W "${opts} ${cmds_not_need_device}" -- ${cur}) )
          return 0
        fi
      fi

      if [[ $alias_cmds ]]; then
        cmds="$alias_cmds \ 
              $cmds"
      fi

      COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
      return 0
      ;;
    disconnect)
      # Use 'adb devices' to list serial numbers.
      COMPREPLY=( $(compgen -W "$($adb devices |
            awk '/(device|recovery|sideload|offline|unauthorized)$/{print $1}')" -- ${cur} ) )
      return 0
      ;;
    install)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-l -r -s" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    forward)
      # Filename or installation option.
      COMPREPLY=( $(compgen -W "tcp: localabstract: localreserved: localfilesystem: dev: jdwp:" -- ${cur}) )
      return 0
      ;;
    uninstall)
      local apks=$($adb shell pm list packages 2>/dev/null | cut -b9-999 | tr '\n\r' ' ')
      if [[ $prev != "-k" && $cur == "-" ]]; then
          COMPREPLY=( $(compgen -W "-k $apks" -- ${cur}) )
      else
          COMPREPLY=( $(compgen -W "$apks" -- ${cur}) )
      fi
      return 0
      ;;
    logcat)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-v -b -c -d -f -g -n -r -s" -- ${cur}) )
          return 0
          ;;
      esac
      case "${prev}" in
        -v)
          COMPREPLY=( $(compgen -W "brief process tag thread raw time long" -- ${cur}) )
          return 0
          ;;
        -b)
          COMPREPLY=( $(compgen -W "radio events main all" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    backup)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-f -apk -noapk -obb -noobb -shared -noshared -all -system -nosystem" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    pull)
      if [ ${prev} == "pull" ]; then
          local IFS=$'\n'
          if [ -z ${cur} ]; then
              local files=$($adb shell "ls -a -d /*" 2>/dev/null | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          else
              local stripped_cur=$(echo ${cur} | sed 's,^",,')
              local files=$($adb shell "ls -a -d '${stripped_cur}'*" 2>/dev/null | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          fi
          return 0
      fi
      ;;
    push)
      if [ "${COMP_WORDS[COMP_CWORD-2]}" == "push" ]; then
          local IFS=$'\n'
          if [ -z "${cur}" ]; then
              local files=$($adb shell "ls -a -d /*" 2>/dev/null | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          else
              local stripped_cur=$(echo ${cur} | sed 's,^",,')
              local files=$($adb shell "ls -a -d '${stripped_cur}'*" 2>/dev/null | tr -d '\r')
              COMPREPLY=( $(compgen -W "$files" -o filenames -- ${cur}) )
          fi
          return 0
      fi
      ;;
    alias)
      if [ ${prev} == "alias" ]; then
        COMPREPLY=( $(compgen -W "-l --list -r --remove -h --help" -o filenames -- ${cur}) )
      fi
      ;;
  esac
}
complete -o default -F _sadb_completion sadb
