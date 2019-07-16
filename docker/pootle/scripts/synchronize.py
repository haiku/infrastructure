import datetime
import os
import smtplib
import subprocess
import sys

import jinja2

SYNC_STATUS_TEMPLATE_DIR = "/app"
SYNC_STATUS_OUTPUT_FILE = "/var/pootle/sync/sync-status.html"
SYNC_EMAIL_SENDER_EMAIL = "noreply@haiku-os.org"
SYNC_EMAIL_SENDER_LINE = "Haiku Pootle Sync <noreply@haiku-os.org>"
SYNC_EMAIL_RECEIVER_EMAIL = ["haiku-i18n@freelists.org", "haiku-sysadmin@freelists.org"]
SYNC_EMAIL_RECEIVER_LINE = "haiku-i18n@freelists.org, haiku-sysadmin@freelists.org"
SYNC_EMAIL_SERVER = "smtp"

REPOSITORY_DIR = "/var/pootle/repository"
TEMPLATES_DIR = os.path.join(REPOSITORY_DIR, "generated/objects/catalogs")
POOTLE_CATALOGS_DIR = "/var/pootle/catalogs/haiku"
REPOSITORY_CATALOGS_DIR = os.path.join(REPOSITORY_DIR, "data/catalogs")

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
            self.output = subprocess.check_output(self.command, stderr=subprocess.STDOUT, cwd=self.work_dir).decode("utf-8")
            self.return_code = 0
        except subprocess.CalledProcessError as e:
            self.output = e.output
            self.return_code = e.returncode
            raise e

    @property
    def pretty_status(self):
        if self.return_code == 0:
            return "success"
        elif self.return_code is None:
            return "skipped/not executed"
        else:
            return "failure"


# Steps
step_list = [
    Step("clear_backup", "Clear old backup", ["rm", "-rf", POOTLE_CATALOGS_DIR + "-bak"]),
    Step("make_backup", "Make a backup of the current catalogs",
         ["cp", "-r", POOTLE_CATALOGS_DIR, POOTLE_CATALOGS_DIR + "-bak"]),
    Step("sync_stores", "Save translations in database to disk",
         ["pootle", "sync_stores", "--overwrite", "--force"]),
    Step("repository_pull", "Pull latest changes from repository", ["git", "pull"], work_dir=REPOSITORY_DIR),
    Step("build_catkeys", "Build Catkeys", ["jam", "-q", "catkeys"], work_dir=REPOSITORY_DIR),
    Step("import_templates", "Import templates from build",
            ["python", "/app/import_templates_from_repository.py", TEMPLATES_DIR, POOTLE_CATALOGS_DIR]),
    Step("update_stores", "Import updated translations in the database", ["pootle", "update_stores"]),
    Step("finish_output", "Post-process translations to be imported into the repository",
         ["python", "/app/finish_output_catalogs.py", POOTLE_CATALOGS_DIR, REPOSITORY_CATALOGS_DIR]),
    Step("commit_add", "Prepare commit with new translations", ["git", "add", "-A"], work_dir=REPOSITORY_DIR),
    Step("commit_commit", "Perform commit for updated translations",
         ["git", "commit", "-m", "Update translations from Pootle", "--author", "Autocomitter <noreply@haiku-os.org>"],
         work_dir=REPOSITORY_DIR),
    Step("commit_rebase", "Rebase commit to any changes in the repository",
          ["git", "pull", "--rebase"], work_dir=REPOSITORY_DIR),
    Step("commit_push", "Push the changes to the Haiku Repository", ["git", "push"], work_dir=REPOSITORY_DIR)
]

# Check if we are running in the repository dir. This goes way over my head, but jam seems to ignore any way we set the
# current working directory from python, including os.setcwd() and using the cwd-arguments for the subprocess functions.
if os.getcwd() != REPOSITORY_DIR:
    print("You can only run this script from the %s as current working dir" % REPOSITORY_DIR)
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
template_loader = jinja2.FileSystemLoader(searchpath=SYNC_STATUS_TEMPLATE_DIR)
template_env = jinja2.Environment(loader=template_loader)
template = template_env.get_template("synchronize-template.html")
with open(SYNC_STATUS_OUTPUT_FILE, "w" ) as f:
    f.write(template.render(lastrun_date=datetime.datetime.now(), steps=step_list).encode("utf-8"))

# Log through e-mail
template = template_env.get_template("synchronize-email-template.txt")
email_message = template.render(sender=SYNC_EMAIL_SENDER_EMAIL, receiver=SYNC_EMAIL_RECEIVER_LINE, lastrun_date=datetime.datetime.now(), steps=step_list)
try:
   smtp = smtplib.SMTP(SYNC_EMAIL_SERVER)
   smtp.sendmail(SYNC_EMAIL_SENDER_EMAIL, SYNC_EMAIL_RECEIVER_EMAIL, email_message)
   print "Successfully sent email"
except smtplib.SMTPException:
   print "Error: unable to send email"
