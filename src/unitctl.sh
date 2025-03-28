#!/command/with-contenv bash
# shellcheck shell=bash

set +e

main() {
    local unit_socket="${UNIT_SOCKET:-/run/control.unit.sock}"

    # Make sure unitd is available
    if ! socat -u OPEN:/dev/null "UNIX-CONNECT:${unit_socket}" 2>/dev/null; then
        echo "Error: Unit socket is not available"
        return 1
    fi

    local json_payload="${1:-}"
    local endpoint="${2:-config}"
    local request_method="${2:-PUT}"

    # Prepare curl arguments
    local curl_args=("--fail" "--unix-socket" "${unit_socket}" "-H" "Content-Type: application/json")

    # Check if the payload is a file or a string
    if [ -f "${json_payload}" ]; then
        curl_args+=("--data-binary" "@${json_payload}")
    else
        curl_args+=("--data" "${json_payload}")
    fi

    set -x
    curl -X "${request_method}" "${curl_args[@]}" "http://localhost/${endpoint}"
}

main "${@}"
