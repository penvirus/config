import re
import subprocess

re_subkey = re.compile(r"^sub.*:{6}(\w):{5}.*\n^fpr.*:(\w+):$\n^grp.*:(\w+):$", re.MULTILINE)

def parse():
    cmd = ["gpg", "-k", "--with-colons", "--with-keygrip"]
    output = subprocess.check_output(cmd, encoding="utf-8")

    for match in re_subkey.finditer(output):
        sub, key, grip = match.group(1), match.group(2), match.group(3)

        if sub == "e":
            print(f".mutt/muttrc.gpg: set pgp_default_key={key[-8:]}")
        elif sub == "s":
            print(f".mutt/muttrc.gpg: set pgp_sign_as={key[-8:]}")
        elif sub == "a":
            print(f".gnupg/sshcontrol: {grip}")

if __name__ == "__main__":
    parse()
