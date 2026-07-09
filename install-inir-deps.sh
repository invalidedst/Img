#!/usr/bin/env bash
# Установка зависимостей iNiR (Niri shell) на Gentoo
# Запуск: chmod +x install-inir-deps.sh && sudo ./install-inir-deps.sh

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Запусти через sudo: sudo ./install-inir-deps.sh"
  exit 1
fi

echo "==> Подключаю GURU overlay..."
emerge --sync
if ! eselect repository list | grep -q guru; then
  eselect repository enable guru
fi
emerge --sync guru

PACKAGES=(
  # core / niri
  niri wl-clipboard libnotify polkit networkmanager gnome-keyring
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome
  xdg-user-dirs xdg-utils rsync git curl wget jq ripgrep dev-lang/python
  kitty foot fish gnome-base/gvfs kde-apps/dolphin

  # Qt6 / Quickshell stack
  dev-qt/qtdeclarative dev-qt/qtbase dev-qt/qtsvg dev-qt/qtwayland
  dev-qt/qt5compat dev-qt/qtimageformats dev-qt/qtmultimedia
  dev-qt/qtpositioning dev-qt/qtsensors dev-qt/qttools
  quickshell kirigami kdialog qt6ct breeze-icons plasma-integration

  # audio / media
  media-video/pipewire media-video/wireplumber media-sound/playerctl
  media-sound/pavucontrol media-video/mpv media-sound/cava
  media-sound/easyeffects yt-dlp socat

  # screenshots / region tools
  media-gfx/grim gui-apps/slurp media-gfx/swappy app-text/tesseract
  media-gfx/imagemagick media-video/ffmpeg

  # input / hardware / idle
  sys-power/upower wtype ydotool dev-python/evdev dev-python/pillow
  sys-power/brightnessctl x11-misc/ddcutil sys-apps/geoclue
  gui-apps/swayidle gui-apps/swaylock net-wireless/blueman sys-auth/fprintd
  sci-libs/libqalculate

  # theming / fonts / launcher
  media-libs/fontconfig media-fonts/dejavu media-fonts/liberation-fonts
  gui-apps/fuzzel dev-libs/glib app-i18n/translate-shell kde-apps/kvantum
)

echo "==> Устанавливаю пакеты (${#PACKAGES[@]} шт.)..."
emerge -av "${PACKAGES[@]}"

echo "==> Ставлю Nerd Font (JetBrains Mono)..."
FONT_DIR="${SUDO_USER:+/home/$SUDO_USER}/.local/share/fonts"
FONT_DIR="${FONT_DIR:-/root/.local/share/fonts}"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -oq JetBrainsMono.zip -d JetBrainsMono
rm JetBrainsMono.zip
fc-cache -f

echo "==> Готово. Если что-то из списка не нашлось (emerge выдаст ошибку по конкретному пакету),"
echo "    проверь имя через: emerge -s <название> — часть пакетов может называться иначе в дереве/GURU."
echo "==> Дальше:"
echo "    git clone https://github.com/snowarch/iNiR.git"
echo "    cd iNiR && ./setup install"
