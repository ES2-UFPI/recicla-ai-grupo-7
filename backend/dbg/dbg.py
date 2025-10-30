"""
    Me faça um sistema de debug em python que imprima no console
    logs coloridos de acordo com o tipo
    e.g.:
        - [SYSTEM] [INFO] Server started
        - [SYSTEM] [ERROR] Failed to start server
        - [SYSTEM] [WARN] Some warning message

    o nome SYSTEM é uma global que pode ser facilmente mudada

    def log_info(*args):
        [...]
    def log_error(*args):
        [...]
    def log_warn(*args):
        [...]
"""

import sys
import os

from colorama import Fore, Style, init

SYSTEM_NAME = "SYSTEM"

def _supportsColor() -> bool:
    
    if not sys.stdout.isatty():
        return False
    if os.environ.get('TERM') in ('xterm', 'xterm-256color', 'screen', 'screen-256color'):
        return True
    if os.environ.get('CLICOLOR_FORCE') == '1':
        return True
    if os.environ.get('NO_COLOR') is not None:
        return False

    if sys.platform == "win32":
        if os.environ.get('ANSICON') is not None:
            return True

    return False


def _systemNameTag() -> str:
    if _supportsColor():
        return f"{Fore.BLUE}[{SYSTEM_NAME}]{Style.RESET_ALL}"
    return f"[{SYSTEM_NAME}]"

def _okTag() -> str:
    if _supportsColor():
        return f"{Fore.GREEN}[OK]{Style.RESET_ALL}"
    return "[OK]"

def _infoTag() -> str:
    if _supportsColor():
        return f"{Fore.CYAN}[INFO]{Style.RESET_ALL}"
    return "[INFO]"

def _errorTag() -> str:
    if _supportsColor():
        return f"{Fore.RED}[ERROR]{Style.RESET_ALL}"
    return "[ERROR]"

def _warnTag() -> str:
    if _supportsColor():
        return f"{Fore.YELLOW}[WARN]{Style.RESET_ALL}"
    return "[WARN]"

def log_ok(*args):
    print(_systemNameTag(), _okTag(), *args)

def log_info(*args):
    print(_systemNameTag(), _infoTag(), *args)

def log_error(*args):
    print(_systemNameTag(), _errorTag(), *args)

def log_warn(*args):
    print(_systemNameTag(), _warnTag(), *args)