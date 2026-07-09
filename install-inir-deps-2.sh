#!/usr/bin/env bash
# Установка зависимостей iNiR (Niri shell) на Gentoo
# Запуск: chmod +x install-inir-deps-2.sh && sudo ./install-inir-deps-2.sh

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Запусти через sudo: sudo ./install-inir-deps-2.sh"
  exit 1
fi

echo "==> Подключаю GURU overlay..."
emerge --sync
if ! eselect repository list | grep -q guru; then
  eselect repository enable guru
fi
emerge --sync guru

# Пакеты с точной, проверенной категорией
PACKAGES_KNOWN=(
  gnome-base/gvfs
  dev-qt/qtdeclarative dev-qt/qtbase dev-qt/qtsvg dev-qt/qtwayland
  dev-qt/qt5compat dev-qt/qtimageformats dev-qt/qtmultimedia
  dev-qt/qtpositioning dev-qt/qtsensors dev-qt/qttools
  gui-apps/quickshell
  media-video/pipewire media-video/wireplumber media-sound/playerctl
  media-sound/pavucontrol media-video/mpv media-sound/cava
  media-sound/easyeffects
  gui-apps/grim gui-apps/slurp gui-apps/swappy app-text/tesseract
  media-gfx/imagemagick media-video/ffmpeg
  sys-power/upower dev-python/evdev dev-python/pillow
  sys-power/brightnessctl x11-misc/ddcutil
  net-wireless/blueman sys-auth/fprintd sci-libs/libqalculate
  media-libs/fontconfig media-fonts/dejavu media-fonts/liberation-fonts
  gui-apps/fuzzel dev-libs/glib app-i18n/translate-shell
  app-misc/jq sys-apps/xdg-desktop-portal sys-apps/xdg-desktop-portal-gnome
)

# Пакеты без категории — portage сам найдёт единственный подходящий пакет.
# Если название окажется неоднозначным, emerge покажет список вариантов —
# тогда допиши нужный полным путём (category/name) и перезапусти скрипт.
PACKAGES_AUTO=(
  niri wl-clipboard libnotify polkit networkmanager gnome-keyring
  xdg-desktop-portal-gtk xdg-user-dirs xdg-utils rsync curl wget ripgrep
  kitty foot fish dolphin
  kirigami kdialog qt6ct breeze-icons plasma-integration
  yt-dlp socat wtype ydotool geoclue swayidle swaylock kvantum
)

# Многие пакеты из GURU (fuzzel, quickshell, niri и т.п.) держат только
# ~amd64 keyword (testing-ветка), поэтому голый emerge на стабильной
# системе их не поставит — упадёт с "have been masked". Ставим в два
# прохода: 1) --autounmask-write сам дописывает нужные разрешения в
# /etc/portage/package.accept_keywords (и package.use, если понадобится),
# 2) если после этого остаётся что доустановить — повторный emerge уже
# ставит пакеты по-настоящему. Если маскировать было нечего, всё
# происходит за один проход.
install_pkgs() {
  local pkgs=("$@")
  if emerge -av --autounmask-write "${pkgs[@]}"; then
    return 0
  fi
  echo "==> Portage дописал недостающие разрешения (keywords/USE), повторяю установку..."
  emerge -av "${pkgs[@]}"
}

echo "==> Устанавливаю проверенные пакеты (${#PACKAGES_KNOWN[@]} шт.)..."
install_pkgs "${PACKAGES_KNOWN[@]}"

echo "==> Устанавливаю остальное с автоопределением категории (${#PACKAGES_AUTO[@]} шт.)..."
install_pkgs "${PACKAGES_AUTO[@]}"

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
echo "==> Что именно разрешил autounmask, можно посмотреть тут:"
echo "    cat /etc/portage/package.accept_keywords/zz-autounmask* 2>/dev/null"
echo "==> Дальше:"
echo "    git clone https://github.com/snowarch/iNiR.git"
echo "    cd iNiR && ./setup install"
