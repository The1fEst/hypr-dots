#!/usr/bin/env bash
set -euo pipefail

REPO=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
STATE=$HOME/.local/state/hypr-dots
BACKUP=$STATE/backup/$(date +%Y%m%d-%H%M%S)
SHELL_PKGBUILD=https://raw.githubusercontent.com/The1fEst/proscenio/main/packaging/PKGBUILD
SHELL_PACKAGE=$HOME/.cache/proscenio/package

MANAGED=(
  .config/code-flags.conf
  .config/fish/config.fish
  .config/fuzzel/fuzzel.ini
  .config/hypr/hypridle.conf
  .config/hypr/hyprland
  .config/hypr/hyprland.lua
  .config/hypr/hyprlock
  .config/hypr/hyprlock.conf
  .config/kitty
  .config/matugen
  .config/starship.toml
  .config/systemd/user/cliphist-image.service
  .config/systemd/user/cliphist-text.service
  .config/systemd/user/hypr-dots-check.service
  .config/systemd/user/hypr-dots-check.timer
  .config/systemd/user/hypridle.service
  .config/systemd/user/hyprland-session.target
  .config/systemd/user/proscenio.service
  .config/systemd/user/wl-clip-persist.service
  .config/wlogout
  .config/xdg-desktop-portal/hyprland-portals.conf
  .local/bin/hypr-dots-check
)

GENERATED=(
  .config/hypr/hyprland/colors.lua
  .config/hypr/hyprlock/colors.conf
)

SEEDED=(
  .config/btop/btop.conf
  .config/darklyrc
  .config/dolphinrc
  .config/fontconfig/fonts.conf
  .config/hypr/custom
  .config/kdeglobals
  .local/state/dolphinstaterc
)

UNITS=(
  cliphist-image.service
  cliphist-text.service
  hypr-dots-check.timer
  hypridle.service
  proscenio.service
  wl-clip-persist.service
)

usage() {
  echo "usage: $0 [all|packages|configs|system|diff]"
  echo "  packages  paru, the proscenio package and the hypr-dots meta package"
  echo "  configs   copies the configs in home/ into \$HOME, enables the session units and"
  echo "            records the commit installed, for hypr-dots-check"
  echo "  system    groups, services, default apps, GTK and Qt settings, fonts"
  echo "  diff      shows how the configs in \$HOME differ from home/"
}

install_paru() {
  command -v paru >/dev/null && return
  sudo pacman -S --needed --noconfirm base-devel git
  local build
  build=$(mktemp -d)
  git clone https://aur.archlinux.org/paru.git "$build"
  (cd "$build" && makepkg -si --noconfirm)
  rm -rf "$build"
}

install_depends() {
  local depends provides name
  local assumed=()
  mapfile -t depends < <(source "$1/PKGBUILD" && printf '%s\n' "${depends[@]}")
  mapfile -t provides < <(source "$1/PKGBUILD" && printf '%s\n' "${provides[@]}")
  for name in "${provides[@]}"; do
    if [[ -n $name ]]; then
      assumed+=(--assume-installed "$name")
    fi
  done
  paru -S --needed --noconfirm --asdeps "${assumed[@]}" "${depends[@]}"
}

build_pkgbuild() {
  (cd "$1" && makepkg -Acfsi --noconfirm)
}

fetch_shell_pkgbuild() {
  mkdir -p "$SHELL_PACKAGE"
  curl -fsSL -o "$SHELL_PACKAGE/PKGBUILD" "$SHELL_PKGBUILD"
}

remove_fork_packages() {
  local old
  mapfile -t old < <(pacman -Qq | grep '^illogical-impulse-' || true)
  if ((${#old[@]})); then
    sudo pacman -Rdd --noconfirm "${old[@]}"
  fi
}

packages() {
  install_paru
  fetch_shell_pkgbuild
  install_depends "$SHELL_PACKAGE"
  build_pkgbuild "$SHELL_PACKAGE"
  install_depends "$REPO/pkg/hypr-dots"
  remove_fork_packages
  build_pkgbuild "$REPO/pkg/hypr-dots"
}

generated_names() {
  local path=$1
  local entry
  for entry in "${GENERATED[@]}"; do
    if [[ $(dirname "$entry") == "$path" ]]; then
      basename "$entry"
    fi
  done
}

differs() {
  local path=$1
  local name
  local exclude=()
  while read -r name; do
    exclude+=(--exclude="$name")
  done < <(generated_names "$path")
  ! diff -rq "${exclude[@]}" "$REPO/home/$path" "$HOME/$path" >/dev/null 2>&1
}

unlink_into_copy() {
  local target=$1
  local resolved
  resolved=$(readlink -f "$target")
  rm "$target"
  if [[ -e $resolved ]]; then
    cp -a "$resolved" "$target"
  fi
}

back_up() {
  local path=$1
  mkdir -p "$(dirname "$BACKUP/$path")"
  cp -a "$HOME/$path" "$BACKUP/$path"
  echo "backed up ~/$path to $BACKUP/$path"
}

copy() {
  local path=$1
  local source=$REPO/home/$path
  local target=$HOME/$path
  mkdir -p "$(dirname "$target")"
  if [[ -L $target ]]; then
    unlink_into_copy "$target"
  fi
  if [[ -e $target ]]; then
    differs "$path" || return 0
    back_up "$path"
  fi
  if [[ -d $source ]]; then
    local name
    local exclude=()
    while read -r name; do
      exclude+=(--exclude="/$name")
    done < <(generated_names "$path")
    rsync -a --delete "${exclude[@]}" "$source/" "$target/"
  else
    cp "$source" "$target"
  fi
  echo "copied ~/$path"
}

seed() {
  local path=$1
  local target=$HOME/$path
  if [[ -e $target ]]; then
    return
  fi
  mkdir -p "$(dirname "$target")"
  cp -r "$REPO/home/$path" "$target"
  echo "created ~/$path"
}

enable_units() {
  local unit wanted
  for unit in "${UNITS[@]}"; do
    for wanted in "$HOME"/.config/systemd/user/*.wants/"$unit"; do
      if [[ -L $wanted ]]; then
        rm "$wanted"
      fi
    done
  done
  systemctl --user daemon-reload
  systemctl --user enable "${UNITS[@]}"
}

configs() {
  local path
  for path in "${MANAGED[@]}"; do
    copy "$path"
  done
  for path in "${SEEDED[@]}"; do
    seed "$path"
  done
  enable_units
  record_installed
  if pgrep -x Hyprland >/dev/null; then
    hyprctl reload >/dev/null || true
  fi
}

record_installed() {
  local commit
  commit=$(git -C "$REPO" rev-parse HEAD 2>/dev/null) || return 0
  mkdir -p "$STATE"
  printf 'repo=%q\ncommit=%q\n' "$REPO" "$commit" >"$STATE/installed"
}

show_diff() {
  local path name
  for path in "${MANAGED[@]}"; do
    local exclude=()
    while read -r name; do
      exclude+=(--exclude="$name")
    done < <(generated_names "$path")
    diff -ru "${exclude[@]}" "$REPO/home/$path" "$HOME/$path" || true
  done
}

network_managed_elsewhere() {
  local service
  for service in systemd-networkd iwd connman netctl dhcpcd; do
    systemctl is-enabled --quiet "$service" 2>/dev/null && return 0
  done
  return 1
}

set_default_apps() {
  local mime
  gio mime inode/directory org.kde.dolphin.desktop
  for mime in x-scheme-handler/http x-scheme-handler/https text/html; do
    gio mime "$mime" brave-origin.desktop
  done
  gio mime x-scheme-handler/mailto org.mozilla.Thunderbird.desktop
  gio mime text/calendar org.gnome.Calendar.desktop
  gio mime text/plain com.microsoft.VSCode.desktop
  for mime in image/jpeg image/png image/gif image/webp image/tiff image/bmp; do
    gio mime "$mime" satty.desktop
  done
  for mime in video/mp4 video/x-matroska video/webm video/quicktime audio/mpeg audio/flac; do
    gio mime "$mime" vlc.desktop
  done
}

font_installed() {
  fc-list : family | tr ',' '\n' | grep -qx "$1"
}

install_google_sans() {
  font_installed "Google Sans" && return
  local url=https://raw.githubusercontent.com/google/fonts/main/ofl/googlesans
  local target=$HOME/.local/share/fonts/hypr-dots-google-sans
  local file
  mkdir -p "$target"
  for file in 'GoogleSans[GRAD,opsz,wght].ttf' 'GoogleSans-Italic[GRAD,opsz,wght].ttf' 'OFL.txt'; do
    curl -fgLo "$target/$file" "$url/$file"
  done
  fc-cache -f
}

install_google_sans_flex() {
  font_installed "Google Sans Flex" && return
  local target=$HOME/.local/share/fonts/hypr-dots-google-sans-flex
  git clone --depth 1 --recurse-submodules https://github.com/end-4/google-sans-flex "$target"
  rm -rf "$target/.git"
  fc-cache -f
}

system() {
  if ! getent group i2c >/dev/null; then
    sudo groupadd i2c
  fi
  sudo usermod -aG video,i2c,input "$(whoami)"
  echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
  systemctl --user enable --now ydotool
  sudo systemctl enable --now bluetooth
  if network_managed_elsewhere; then
    echo "another network manager is enabled, leaving NetworkManager alone"
  else
    sudo systemctl enable --now NetworkManager
  fi
  set_default_apps
  gsettings set org.gnome.desktop.interface font-name 'Google Sans Medium 11 @opsz=11,wght=500'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly
  install_google_sans
  install_google_sans_flex
}

case ${1:-all} in
  all)
    packages
    configs
    system
    ;;
  packages | configs | system)
    "$1"
    ;;
  diff)
    show_diff
    ;;
  *)
    usage
    exit 1
    ;;
esac
