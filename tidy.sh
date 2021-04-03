# Copyright (c) 2020 montag451
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# shellcheck shell=dash

# Private
_tidy_pop()
{
    local ret=0 nb_handlers handler
    eval "nb_handlers=\${_NB_${1}_HANDLERS_${2}:-0}"
    if [ "${nb_handlers}" -eq 0 ]; then
        return 0
    fi
    eval "handler=\${_${1}_HANDLERS_${2}_$((nb_handlers-1))}"
    if [ "${3}" -eq 1 ]; then
        eval "${handler}" || ret="${?}"
    fi
    unset "_${1}_HANDLERS_${2}_$((nb_handlers-1))"
    eval "_NB_${1}_HANDLERS_${2}=$((nb_handlers-1))"
    return "${ret}"
}

# Private
_tidy_exec()
{
    local pid nb_handlers ret results
    eval "nb_handlers=\${_NB_${1}_HANDLERS_${2}:-0}"
    while [ "${nb_handlers}" -gt 0 ] && [ "${nb_handlers}" -gt "${3}" ]; do
        _tidy_pop "${1}" "${2}" 1 && ret="${?}" || ret="${?}"
        results="${results:+${results} }${ret}"
        nb_handlers=$((nb_handlers-1))
    done
    # shellcheck disable=SC2015
    [ -n "${4}" ] && eval "${4}=\${results}" || true
}

# Private
_tidy_get_shell_pid()
{
    # It's not possible to use $$ because subshell share this value with
    # their parent shell
    eval "${1}=$(sh -c 'echo ${PPID}')"
    return "${?}"
}

# Push a signal handler on the handlers stack.
# $1: signal (e.g INT, TERM, EXIT, ERR, ...)
# $2: handler
# $3: (optional) a variable name where the handler ID will be saved
tidy_push()
{
    local pid nb_handlers
    _tidy_get_shell_pid pid
    # shellcheck disable=SC2064
    trap -- "_tidy_exec ${1} ${pid} 0" "${1}" || return 1
    eval "nb_handlers=\${_NB_${1}_HANDLERS_${pid}:-0}"
    eval "_${1}_HANDLERS_${pid}_${nb_handlers}=\${2}"
    eval "_NB_${1}_HANDLERS_${pid}=$((nb_handlers+1))"
    # shellcheck disable=SC2015
    [ -n "${3}" ] && eval "${3}=$((nb_handlers+1))" || true
}

# Pop the last signal handler from the handlers stack.
# $1: signal (e.g INT, TERM, EXIT, ERR, ...)
# $2: (optional, default: 0) 0 or 1 (if 1 the handler is popped and executed)
# Return: handler exit code
tidy_pop()
{
    local pid
    _tidy_get_shell_pid pid
    _tidy_pop "${1}" "${pid}" "${2:-0}"
    return "${?}"
}

# Cancel a handler. Execute all the handlers that have been pushed
# after the cancelled handler.
# $1: signal (e.g INT, TERM, EXIT, ERR, ...)
# $2: handler ID
# $3: (optional) a variable name where the results of executed handlers will be saved
tidy_cancel()
{
    local pid
    _tidy_get_shell_pid pid
    _tidy_exec "${1}" "${pid}" "${2}" "${3}"
    _tidy_pop "${1}" "${pid}" 0
}
