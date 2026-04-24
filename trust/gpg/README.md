# Trust Database

These are the GPG public keys of key people involved in Haiku.

> Never give your secret keys (gpg --export-secret-key) to anyone!

## git commit signing

It's recommended to sign all of your git commits. This can be done
by ensuring your ~/.gitconfig looks like the following:

```
[user]
        name = Cool User
        email = user@cooluser.com
        signingkey = 1234DEADBEEFCAFE5678BEEFDEADCAFE
```

Of note, the signingkey is the public key you wish to sign
your commits with. It needs to exist within your local gpg
client. ```gpg --list-secret-keys --with-keygrip```

## GPG SSH Authentication

Optional, but neat.

**Enable SSH support**
```
echo enable-ssh-support >> $HOME/.gnupg/gpg-agent.conf
```

**Tell your sessions to use the gpg-agent**

Add the following to your bashrc or profile
```
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
```

**Find your GPG keygrip**
```
$ gpg --list-secret-keys --with-keygrip
.
      Keygrip = 23453534564526245DEA23452353415662453624 
.
```

**Add your keygrip to your sshcontrol**
```
$ echo 23453534564526245DEA23452353415662453624 >> ~/.gnupg/sshcontrol
```

**Check for your identity**
```
$ ssh-add -l
256 SHA256:RandomStringOfCoolStuffThatDoesntMatter keyname (ED25519)
```

**Export your ssh key**
```
gpg --export-ssh-key (gpgid)
```
