#!/usr/bin/env bash
desktop_id() {
    local exe=${1##*/} dir file id fallback=
    local pattern=${exe//./\\.}
    pattern=${pattern//+/\\+}
    local IFS=:
    for dir in ${XDG_DATA_HOME:-$HOME/.local/share} ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do
        [[ -d $dir/applications ]] || continue
        while IFS= read -r file; do
            id=${file#"$dir/applications/"}
            id=${id//\//-}
            id=${id%.desktop}
            if [[ $id == "$exe" || $id == *."$exe" ]]; then
                printf '%s' "$id"
                return
            fi
            [[ -z $fallback ]] && ! grep -q '^NoDisplay=true' "$file" && fallback=$id
        done < <(grep -rlE "^(Exec|TryExec)=([^ ]*/)?$pattern( |$)" "$dir/applications" --include='*.desktop')
    done
    printf '%s' "$fallback"
}

read_configured_terminal() {
    local file=${XDG_CONFIG_HOME:-$HOME/.config}/proscenio/config.toml
    local basic_pattern='^terminal[[:space:]]*=[[:space:]]*"(([^"\\]|\\.)*)"'
    local literal_pattern="^terminal[[:space:]]*=[[:space:]]*'([^']*)'"
    local section= line value
    [[ -r $file ]] || return
    while IFS= read -r line; do
        line=${line#"${line%%[![:space:]]*}"}
        if [[ $line == \[* ]]; then
            section=${line%%#*}
            section=${section//[[:space:]\[\]]/}
        elif [[ $section == apps && $line =~ $basic_pattern ]]; then
            value=${BASH_REMATCH[1]//\\\\/$'\001'}
            value=${value//\\\"/\"}
            printf '%s' "${value//$'\001'/\\}"
            return
        elif [[ $section == apps && $line =~ $literal_pattern ]]; then
            printf '%s' "${BASH_REMATCH[1]}"
            return
        fi
    done <"$file"
}

find_default_desktop_file() {
    local line id dir
    local IFS=:
    line=$(LC_ALL=C gio mime "$1" 2>/dev/null | head -n 1)
    [[ $line == "Default application for "* ]] || return
    id=${line##*: }
    for dir in ${XDG_DATA_HOME:-$HOME/.local/share} ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do
        if [[ -f $dir/applications/$id ]]; then
            printf '%s' "$dir/applications/$id"
            return
        fi
    done
}

make_unit_option() {
    local uuid
    [[ -n $1 ]] || return
    uuid=$(</proc/sys/kernel/random/uuid)
    printf '%s' "--unit=app-$(systemd-escape "$1")-${uuid//-/}"
}

case ${1-} in
    --terminal)
        shift
        terminal=$(read_configured_terminal)
        [[ -n $terminal ]] && set -- "$terminal" "$@"
        ;;
    --mime)
        file=$(find_default_desktop_file "${2-}")
        shift 2
        if [[ -n $file ]]; then
            id=${file##*/}
            unit_option=$(make_unit_option "${id%.desktop}")
            systemd-run --user --scope --quiet --collect ${unit_option:+"$unit_option"} -- gio launch "$file" && exit
        fi
        ;;
esac

for cmd in "$@"; do
    [[ -z "$cmd" ]] && continue
    eval "command -v ${cmd%% *}" >/dev/null 2>&1 || continue
    unit_option=$(make_unit_option "$(desktop_id "${cmd%% *}")")
    systemd-run --user --scope --quiet --collect ${unit_option:+"$unit_option"} -- bash -c "$cmd" &
    exit
done
