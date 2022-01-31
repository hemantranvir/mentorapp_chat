import subprocess
from flask import Flask

app = Flask(__name__)


@app.route('/create_organization')
def create_organization():
    command_to_run = '/home/zulip/deployments/current/manage.py generate_realm_creation_link | grep https'
    output = subprocess.getoutput(command_to_run)
    print(output)
    return 'Hello, World!'