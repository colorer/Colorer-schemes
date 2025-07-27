"""\
Automatic HRC changes tests runner.
Validates parsing result for a set of source files against
previously collected data.

Advantage over Perl version:
- doesn't require diff utility
- works out of the box on Windows with Python installed

placed in public domain by techtonik // rainforce.org
"""

import sys

if sys.version_info < (3, 0):
    sys.stdout.write("Sorry, requires Python 3.x, not Python 2.x\n")
    sys.exit(1)

import os
import copy
import difflib
import optparse
import subprocess
import fnmatch
import multiprocessing.pool
from datetime import datetime
from os.path import dirname, join, normpath
import threading
import shutil

# -- global variable --
script_path = None
working_path = None
out_dir = None
valid_dir = None
css = None
colorer = None
colorer_opts = None
lock = None
options = None
args = []
testfile_list = None
no = 0


def main():
    parse_args()
    init()
    find_files()
    results = run_tests()
    changed = report(results)

    if changed==0:
        sys.exit(0)
    else:
        sys.exit(1)


def parse_args():
    usage = "%prog [--quick] [GLOB...]"
    opt = optparse.OptionParser(usage=usage, add_help_option=False)
    opt.add_option("--quick", action="store_true",
                   help="exclude /full/ dirs from testing")
    opt.add_option("--help", action="store_true")

    global options, args
    (options, args) = opt.parse_args()

    if options.help:
        print(__doc__)
        opt.print_help()
        sys.exit(0)


def init():
    global script_path
    global working_path
    global out_dir
    global out_result_dir
    global valid_dir
    global colorer
    global colorer_opts
    global css_path

    # -- path setup --
    working_path = os.getcwd()
    script_path = normpath(join(working_path, dirname(__file__)))
    project_path = join(script_path, "..", "..")

    colorer_path = normpath(join(project_path, "bin"))
    catalog_path = normpath(join(project_path, "_build/base/catalog.xml"))
    hrd_path = normpath(join(project_path, "_build", "base", "hrd"))
    hrd = os.getenv('COLORER5HRD', 'white')
    css_path = "css/%s.css" % (hrd)
    css_origin_path = normpath("%s/css/%s.css" % (hrd_path, hrd))
    print(css_origin_path)
    if not os.path.isfile(css_origin_path):
        print("Warning: Stylesheet %s does not exist" % hrd)

    colorer_exe = "colorer"
    colorer = join(colorer_path, colorer_exe)
    if not os.path.isfile(colorer):
        sys.exit("Error: No %s in %s" % (colorer_exe, colorer_path))

    valid_dir = normpath(join(script_path, "_valid"))
    if not os.path.exists("_test"): 
        os.mkdir("_test")
    out_dir = "_test/test_" + datetime.today().strftime("%Y-%m-%d_%H-%M-%S")
    if os.path.exists(out_dir):
        sys.exit("Exiting: Test dir already exists - %s" % out_dir)
    out_result_dir = join(out_dir,"result");
    os.mkdir(out_dir)
    os.mkdir(out_result_dir)
    os.mkdir(out_dir + "/css")
    shutil.copy(css_origin_path, join(out_dir,css_path))

    colorer_opts = ["-c", catalog_path, "-el", "info", "-ed", out_dir]


def find_files():
    global testfile_list
    testfile_list = []
    # look for files for highlight tests
    # skip dirs: current ".", "_valid" and "__*" results
    for root, dirs, files in os.walk(script_path):
        for d in copy.copy(dirs):
            if d[0] in (".", "_"):
                dirs.remove(d)
        if options.quick:
            if "full" in dirs:
                dirs.remove("full")
        if root == script_path:
            continue
        for name in files:
            path = normpath(join(root, name))
            if len(args):
                for glob in args:
                    if fnmatch.fnmatch(path, glob):
                        break
                else:
                    continue  # next file
            testfile_list.append(path)


def run_tests():
    print("Running tests")

    global testfile_list
    global lock

    lock = threading.Lock()
    pool = multiprocessing.pool.ThreadPool()
    results = pool.map(run_one_test, testfile_list)
    return results


def run_one_test(test):
    global no
    global lock

    with lock:
        no += 1
        print("Processing (%s/%s) %s" % (no, len(testfile_list), test))

    filename = "%s.html" % test
    origname = filename.replace(script_path, valid_dir, 1)
    outname = filename.replace(script_path, join(working_path, out_result_dir), 1)
    outdir = dirname(outname)

    if not os.path.exists(outdir):
        os.makedirs(outdir, exist_ok=True)

    colorer_args = ["-ht", test, "-dc", "-dh", "-ln", "-o", outname]
    cmd = [colorer] + colorer_opts + colorer_args
    ret = subprocess.call(cmd)
    return test, ret, origname, outname


def filediff(oldpath, newpath):
    """return diff output or empty string"""
    with open(oldpath, "r", errors="surrogateescape") as of:
        ol = of.readlines()
    with open(newpath, "r", errors="surrogateescape") as nf:
        nl = nf.readlines()
    local_diff = difflib.unified_diff(ol, nl, oldpath, newpath, n=1)
    return list(local_diff)


def report(results):
    failed = 0
    changed = 0
    if len(testfile_list) == 0:
        print("Files for test didn`t found")
        return

    print("Generating report...")
    fail_log = open(join(out_dir, "fails.html"), "w")
    fail_log.write(
        """
        <html>
        <head>
            <meta http-equiv="content-type" content="text/html; charset=utf-8">
            <title>%s Colorer Test Results</title>
            <link href="%s" rel="stylesheet" type="text/css"/>
        </head>
        <body>
        """ % (out_dir, css_path)
    )

    for test, ret, origname, outname in results:
        fail_log.write('<div><pre class="testname">%s</pre><pre>' % test)

        if ret != 0:
            failed += 1
            print("Failed: colorer returned %s" % ret)
            fail_log.write("Failed: colorer returned %s" % ret)
            # BUG: colorer doesn't return any error codes in some error cases
            #      like absent hrd catalogs or
            fail_log.write('</pre></div>')
            continue

        if os.path.isfile(origname):
            diff = filediff(origname, outname)
            if len(diff):
                changed += 1
            for line in diff:
                fail_log.write(line)
        else:
            fail_log.write(origname + "does not exist!")
            changed += 1

        fail_log.write('</pre></div>\n')

    fail_log.write('</body></html>')
    fail_log.close()
    print("Executed: %s, Failed: %s (%1.2f%%), Changed: %s (%1.2f%%)" %
          (len(testfile_list), failed, (float(failed) / len(testfile_list) * 100),
           changed, (float(changed) / len(testfile_list) * 100))
          )
    
    return failed+changed


if __name__ == "__main__":
    main()
