import sys

def warn(*args):
    print("\033[1;33mwarning:\033[m", *args, file=sys.stderr)

def err(*args):
    print("\033[1;31merror:\033[m", *args, file=sys.stderr)

def die(*args):
    err(*args)
    sys.exit(1)
