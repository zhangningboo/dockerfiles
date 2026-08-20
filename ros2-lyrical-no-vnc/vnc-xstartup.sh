#!/usr/bin/env bash
set -e

unset SESSION_MANAGER

export XDG_CURRENT_DESKTOP=LXQt
export XDG_SESSION_DESKTOP=LXQt
export DESKTOP_SESSION=LXQt
export XDG_SESSION_TYPE=x11
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
export QT_STYLE_OVERRIDE="${QT_STYLE_OVERRIDE:-kvantum}"

runtime_dir="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
mkdir -p "${runtime_dir}"
chmod 700 "${runtime_dir}"
export XDG_RUNTIME_DIR="${runtime_dir}"

if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    exec dbus-run-session -- "$0"
fi

mkdir -p "${HOME}/.config/lxqt" "${HOME}/.config/Kvantum" "${HOME}/.config/autostart"

if [[ ! -e "${HOME}/.config/lxqt/lxqt.conf" ]]; then
    cat > "${HOME}/.config/lxqt/lxqt.conf" <<'EOF'
[General]
__userfile__=true
icon_theme=Papirus-Dark
theme=dark
tool_button_style=ToolButtonTextBesideIcon
EOF
fi

if [[ ! -e "${HOME}/.config/lxqt/session.conf" ]]; then
    cat > "${HOME}/.config/lxqt/session.conf" <<'EOF'
[General]
__userfile__=true
window_manager=openbox
EOF
fi

# LXQt 会通过 XDG autostart 再启动一次 Picom，隐藏系统项以避免重复实例。
if [[ ! -e "${HOME}/.config/autostart/picom.desktop" ]]; then
    cat > "${HOME}/.config/autostart/picom.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Picom
Hidden=true
EOF
fi

if [[ ! -e "${HOME}/.config/Kvantum/kvantum.kvconfig" ]]; then
    cat > "${HOME}/.config/Kvantum/kvantum.kvconfig" <<'EOF'
[General]
theme=KvArcDark
EOF
fi

# XRender 合成器为窗口提供阴影/淡入；可用 ENABLE_COMPOSITOR=0 关闭以降低带宽。
case "${ENABLE_COMPOSITOR:-1}" in
    1|true|yes) picom --backend xrender --vsync --shadow --fading --daemon || true ;;
    0|false|no) ;;
    *) echo "[WARN] ENABLE_COMPOSITOR must be true/false or 1/0; compositor disabled." >&2 ;;
esac

exec startlxqt
