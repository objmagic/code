import os
import sys

try:
    from wcwidth import wcwidth, wcswidth
except ImportError:
    wcwidth = lambda s: 1
    wcswidth = lambda s: len(s)

_stderr_tty = None
_stderr_width = None

def isatty():
    global _stderr_tty
    if _stderr_tty is None:
        _stderr_tty = sys.stderr.isatty()
    return _stderr_tty

def ttywidth():
    global _stderr_width
    if _stderr_width is None:
        with os.popen("stty size", "r") as fh:
            line = fh.read().strip()
        rows, cols = line.split()
        _stderr_width = int(cols)
    return _stderr_width

def wctruncate(text, width=80):
    for i, c in enumerate(text):
        w = wcwidth(c)
        if w > 0:
            width -= w
        if width < 0:
            return text[:i]
    return text

def fmt_status(msg):
    return "\033[33m" + msg + "\033[m"

def print_status(*args, fmt=fmt_status):
    if isatty() and not opts.verbose:
        msg = " ".join(args)
        msg = msg.replace("\n", " ")
        out = ""
        out += "\033[1G" # cursor to column 1
        out += "\033[0J" # erase below
        out += fmt_status(msg)
        lines = math.ceil(wcswidth(msg) / ttywidth())
        if lines > 1:
            out += "\033[%dA" % (lines-1) # cursor up 1
        sys.stderr.write(out)
        if not args:
            sys.stderr.flush()

def print_status_truncated(*args, fmt=fmt_status):
    if isatty() and not opts.verbose:
        msg = " ".join(args)
        msg = msg.replace("\n", " ")
        out = ""
        out += "\r\033[K"
        out += fmt_status(msg)
        sys.stderr.write(out)
        if not args:
            sys.stderr.flush()

def window_title(msg):
    if isatty():
        print("\033]2;%s\007" % msg, file=sys.stderr)
