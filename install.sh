#!/usr/bin/env bash

. scripts/cmd/clashctl.sh
. scripts/preflight.sh

_parse_args "$@"
_install_7z
_valid

CLASH_INSTALL_DONE=false
_cleanup_batch_install() {
    [ "$CLASH_INSTALL_BATCH" = true ] || return 0
    [ "$CLASH_INSTALL_DONE" = true ] && return 0
    [ -d "$CLASH_BASE_DIR" ] && rm -rf "$CLASH_BASE_DIR"
}
trap _cleanup_batch_install EXIT

_prepare_zip
_detect_init

_okcat "安装内核：$KERNEL_NAME by ${INIT_TYPE}"
_okcat '📦' "安装路径：$CLASH_BASE_DIR"

/bin/cp -rf . "$CLASH_BASE_DIR"
touch "$CLASH_CONFIG_BASE"
_set_envs
_is_regular_sudo && chown -R "$SUDO_USER" "$CLASH_BASE_DIR"

_install_service
if [ "$CLASH_INSTALL_RC" = true ]; then
    _apply_rc
else
    . "$CLASH_CMD_DIR/clashctl.sh"
fi

_merge_config
_detect_proxy_port

if [ "$CLASH_INSTALL_BATCH" = true ]; then
    "$BIN_YQ" -i ".secret = \"$(_get_random_val)\"" "$CLASH_CONFIG_MIXIN"

    _valid_config "$CLASH_CONFIG_BASE" && CLASH_CONFIG_URL="file://$CLASH_CONFIG_BASE"
    [ -z "$CLASH_CONFIG_URL" ] && _error_quit "后台安装需要订阅链接或本地 YAML 文件，例如：bash install.sh --background mihomo ./config.yaml"

    _sub_add "$CLASH_CONFIG_URL"
    sub_id=$("$BIN_YQ" '.profiles // [] | (map(.id) | max) // 1' "$CLASH_PROFILES_META")
    _sub_use "$sub_id"

    if [ "$CLASH_INSTALL_START" = false ]; then
        clashoff >/dev/null
    elif [ "$CLASH_INSTALL_TUN" = true ]; then
        clashtun on
    else
        clashon
    fi

    _is_regular_sudo && chown -R "$SUDO_USER" "$CLASH_BASE_DIR"
    _okcat '🎉' '后台安装完成'
    CLASH_INSTALL_DONE=true
    exit 0
fi

clashui
clashsecret "$(_get_random_val)" >/dev/null
clashsecret

_okcat '🎉' 'enjoy 🎉'
clashctl

_valid_config "$CLASH_CONFIG_BASE" && CLASH_CONFIG_URL="file://$CLASH_CONFIG_BASE"
_quit "clashsub add $(printf '%q' "$CLASH_CONFIG_URL") && clashsub use 1"
