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

# Private
_pop_sig_handler()
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
_exec_sig_handlers()
{
    local pid nb_handlers
    eval "nb_handlers=\${_NB_${1}_HANDLERS_${2}:-0}"
    while [ "${nb_handlers}" -gt 0 -a "${nb_handlers}" -gt "${3}" ]; do
        _pop_sig_handler "${1}" "${2}" 1
        nb_handlers=$((nb_handlers-1))
    done
}

# Private
_get_shell_pid()
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
push_sig_handler()
{
    local pid nb_handlers
    _get_shell_pid pid
    trap "_exec_sig_handlers ${1} ${pid} 0" "${1}" || return 1
    eval "nb_handlers=\${_NB_${1}_HANDLERS_${pid}:-0}"
    eval "_${1}_HANDLERS_${pid}_${nb_handlers}=\${2}"
    eval "_NB_${1}_HANDLERS_${pid}=$((nb_handlers+1))"
    [ -n "${3}" ] && eval "${3}=$((nb_handlers+1))" || true
}

# Pop the last signal handler from the handlers stack.
# $1: signal (e.g INT, TERM, EXIT, ERR, ...)
# $2: 0 or 1 (if set to 1 the handler will be popped and executed)
# Return: handler exit code
pop_sig_handler()
{
    local pid
    _get_shell_pid pid
    _pop_sig_handler "${1}" "${pid}" "${2}"
    return "${?}"
}

# Cancel a handler. Execute all the handlers that have been pushed
# after the cancelled handler.
# $1: signal (e.g INT, TERM, EXIT, ERR, ...)
# $2: handler ID
# Return: handler exit code
cancel_sig_handler()
{
    local pid
    _get_shell_pid pid
    _exec_sig_handlers "${1}" "${pid}" "${2}"
    _pop_sig_handler "${1}" "${pid}" 0
    return "${?}"
}
