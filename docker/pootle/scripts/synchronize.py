import datetime
import os
import smtplib
import subprocess
import sys

import jinja2
import toml as toml


class Step:
    def __init__(self, name, label, command, work_dir=None):
        self.name = name
        self.label = label
        self.command = command
        if work_dir is None:
            self.work_dir = os.getcwd()
        else:
            self.work_dir = work_dir
        self.output = None
        self.return_code = None

    def execute(self):
        try:
            print("Executing step %s" % self.name)
            self.output = subprocess.check_output(self.command, stderr=subprocess.STDOUT, cwd=self.work_dir) \
                .decode("utf-8")
            self.return_code = 0
        except subprocess.CalledProcessError as error:
            self.output = error.output
            self.return_code = error.returncode
            raise error

    @property
    def pretty_status(self):
        if self.return_code == 0:
            return "success"
        elif self.return_code is None:
            return "skipped/not executed"
        else:
            return "failure"


# Get the settings file
try:
    settings_path = os.environ["SYNC_CONFIG"]
except KeyError:
    print("SYNC_CONFIG environment is not set: it should point to the configuration")
    sys.exit(-1)

if not os.path.exists(settings_path):
    print("SYNC_CONFIG (set to %s) does not point to an existing configuration file" % settings_path)
    sys.exit(-1)

try:
    with open(settings_path, "r") as f:
        settings = toml.load(f)
except IOError as e:
    print("Error loading configuration file at %s: %s" % (settings_path, e.message))
    sys.exit(-1)

# Get the global variables
REPORT_TEMPLATE_DIR = settings["report"]["template_dir"]
REPORT_OUTPUT_FILE = settings["report"]["report_output_file"]
EMAIL_SENDER_ADDRESS = settings["email"]["sender_address"]
EMAIL_SENDER_LINE = settings["email"]["sender_line"]
EMAIL_RECEIVER_ADDRESSES = settings["email"]["receiver_addresses"]
EMAIL_RECEIVER_LINE = settings["email"]["receiver_line"]
EMAIL_SERVER = settings["email"]["server"]

# This should support multiple sync dicts in the future
SYNC_SETTINGS = settings["sync"]["haiku"]
for key in ["repository_dir", "templates_dir", "pootle_catalogs_dir", "repository_catalogs_dir", "languages"]:
    if key not in SYNC_SETTINGS.keys():
        print("Missing key %s in [sync.haiku], please fix the configuration" % key)
        sys.exit(-1)

# Steps
step_list = [
    Step("clear_backup", "Clear old backup", ["rm", "-rf", SYNC_SETTINGS["pootle_catalogs_dir"] + "-bak"]),
    Step("make_backup", "Make a backup of the current catalogs",
         ["cp", "-r", SYNC_SETTINGS["pootle_catalogs_dir"], SYNC_SETTINGS["pootle_catalogs_dir"] + "-bak"]),
    Step("sync_stores", "Save translations in database to disk",
         ["pootle", "sync_stores"]),
    Step("repository_pull", "Pull latest changes from repository", ["git", "pull"],
         work_dir=SYNC_SETTINGS["repository_dir"]),
    Step("build_catkeys", "Build Catkeys", ["jam", "-q", "catkeys"], work_dir=SYNC_SETTINGS["repository_dir"]),
    Step("import_templates", "Import templates from build",
            ["python", "/app/import_templates_from_repository.py", SYNC_SETTINGS["templates_dir"],
             SYNC_SETTINGS["pootle_catalogs_dir"]]),
    Step("update_stores", "Import updated translations in the database", ["pootle", "update_stores"]),
    Step("finish_output", "Post-process translations to be imported into the repository",
         ["python", "/app/finish_output_catalogs.py", SYNC_SETTINGS["pootle_catalogs_dir"],
          SYNC_SETTINGS["repository_catalogs_dir"]] + SYNC_SETTINGS["languages"]),
    Step("commit_add", "Prepare commit with new translations", ["git", "add", "-A"],
         work_dir=SYNC_SETTINGS["repository_dir"]),
    Step("commit_commit", "Perform commit for updated translations",
         ["git", "commit", "-m", "Update translations from Pootle", "--author", "Autocomitter <noreply@haiku-os.org>"],
         work_dir=SYNC_SETTINGS["repository_dir"]),
    Step("commit_rebase", "Rebase commit to any changes in the repository",
          ["git", "pull", "--rebase"], work_dir=SYNC_SETTINGS["repository_dir"]),
]
# Allow for the setting 'skip_push' to allow for a debugging mode where all the steps are executed, except for the push
if not settings.get("skip_push", False):
    step_list.append(Step("commit_push", "Push the changes to the Haiku Repository", ["git", "push"],
         work_dir=SYNC_SETTINGS["repository_dir"]))

# Check if we are running in the repository dir. This goes way over my head, but jam seems to ignore any way we set the
# current working directory from python, including os.setcwd() and using the cwd-arguments for the subprocess functions.
if os.getcwd() != SYNC_SETTINGS["repository_dir"]:
    print("You can only run this script from the %s as current working dir" % SYNC_SETTINGS["repository_dir"])
    sys.exit(-1)

# Execute
for step in step_list:
    try:
        step.execute()
    except subprocess.CalledProcessError:
        break

# Log to command line
for step in step_list:
    print ("Step %s: %s" % (step.name, step.pretty_status))
    if step.return_code != 0 and step.return_code is not None:
        print step.output

# Log to on-disk output
template_loader = jinja2.FileSystemLoader(searchpath=REPORT_TEMPLATE_DIR)
template_env = jinja2.Environment(loader=template_loader)
template = template_env.get_template("synchronize-template.html")
with open(REPORT_OUTPUT_FILE, "w" ) as f:
    f.write(template.render(lastrun_date=datetime.datetime.now(), steps=step_list).encode("utf-8"))

# Log through e-mail
template = template_env.get_template("synchronize-email-template.txt")
email_message = template.render(sender=EMAIL_SENDER_LINE, receiver=EMAIL_RECEIVER_ADDRESSES,
                                lastrun_date=datetime.datetime.now(), steps=step_list)
try:
    smtp = smtplib.SMTP(EMAIL_SERVER)
    smtp.sendmail(EMAIL_RECEIVER_LINE, EMAIL_RECEIVER_ADDRESSES, email_message)
    print "Successfully sent email"
except smtplib.SMTPException:
    print "Error: unable to send email"
