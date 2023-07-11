# Security Best Practices 

Describes basic security best practices that you should follow to ensure the highest level of system security. 

In the default Greenplum Database security configuration:

-   Only local connections are allowed.
-   Basic authentication is configured for the superuser \(`gpadmin`\).
-   The superuser is authorized to do anything.
-   Only database role passwords are encrypted.

## <a id="sysuser"></a>System User \(gpadmin\) 

Secure and limit access to the `gpadmin` system user.

Greenplum requires a UNIX user id to install and initialize the Greenplum Database system. This system user is referred to as `gpadmin` in the Greenplum documentation. The `gpadmin` user is the default database superuser in Greenplum Database, as well as the file system owner of the Greenplum installation and its underlying data files. The default administrator account is fundamental to the design of Greenplum Database. The system cannot run without it, and there is no way to limit the access of the `gpadmin` user id.

The `gpadmin` user can bypass all security features of Greenplum Database. Anyone who logs on to a Greenplum host with this user id can read, alter, or delete any data, including system catalog data and database access rights. Therefore, it is very important to secure the `gpadmin` user id and only allow essential system administrators access to it.

Administrators should only log in to Greenplum as `gpadmin` when performing certain system maintenance tasks \(such as upgrade or expansion\).

Database users should never log on as `gpadmin`, and ETL or production workloads should never run as `gpadmin`.

## <a id="susers"></a>Superusers 

Roles granted the `SUPERUSER` attribute are superusers. Superusers bypass all access privilege checks and resource queues. Only system administrators should be given superuser rights.

See "Altering Role Attributes" in the *Greenplum Database Administrator Guide*.

## <a id="loginusers"></a>Login Users 

Assign a distinct role to each user who logs in and set the `LOGIN` attribute.

For logging and auditing purposes, each user who is allowed to log in to Greenplum Database should be given their own database role. For applications or web services, consider creating a distinct role for each application or service. See "Creating New Roles \(Users\)" in the *Greenplum Database Administrator Guide*.

Each login role should be assigned to a single, non-default resource queue.

## <a id="groups"></a>Groups 

Use groups to manage access privileges.

Create a group for each logical grouping of object/access permissions.

Every login user should belong to one or more roles. Use the `GRANT` statement to add group access to a role. Use the `REVOKE` statement to remove group access from a role.

The `LOGIN` attribute should not be set for group roles.

See "Creating Groups \(Role Membership\)" in the *Greenplum Database Administrator Guide*.

## <a id="objpriv"></a>Object Privileges 

Only the owner and superusers have full permissions to new objects. Permission must be granted to allow other rules \(users or groups\) to access objects. Each type of database object has different privileges that may be granted. Use the `GRANT` statement to add a permission to a role and the `REVOKE` statement to remove the permission.

You can change the owner of an object using the `REASSIGN OWNED BY` statement. For example, to prepare to drop a role, change the owner of the objects that belong to the role. Use the `DROP OWNED BY` to drop objects, including dependent objects, that are owned by a role.

Schemas can be used to enforce an additional layer of object permissions checking, but schema permissions do not override object privileges set on objects contained within the schema.

## <a id="password-strength-recommendations"></a>Operating System Users and File System 

> **Note** Commands shown in this section should be run as the root user.

To protect the network from intrusion, system administrators should verify the passwords used within an organization are sufficiently strong. The following recommendations can strengthen a password:

-   Minimum password length recommendation: At least 9 characters. MD5 passwords should be 15 characters or longer.
-   Mix upper and lower case letters.
-   Mix letters and numbers.
-   Include non-alphanumeric characters.
-   Pick a password you can remember.

The following are recommendations for password cracker software that you can use to determine the strength of a password.

-   John The Ripper. A fast and flexible password cracking program. It allows the use of multiple word lists and is capable of brute-force password cracking. It is available online at [http://www.openwall.com/john/](http://www.openwall.com/john/).
-   Crack. Perhaps the most well-known password cracking software, Crack is also very fast, though not as easy to use as John The Ripper. It can be found online at [https://dropsafe.crypticide.com/alecm/software/crack/c50-faq.html](https://dropsafe.crypticide.com/alecm/software/crack/c50-faq.html). 

The security of the entire system depends on the strength of the root password. This password should be at least 12 characters long and include a mix of capitalized letters, lowercase letters, special characters, and numbers. It should not be based on any dictionary word.

Password expiration parameters should be configured. The following commands must be run as `root` or using `sudo`.

Ensure the following line exists within the file `/etc/libuser.conf` under the `[import]` section.

```
login_defs = /etc/login.defs

```

Ensure no lines in the `[userdefaults]` section begin with the following text, as these words override settings from `/etc/login.defs`:

-   `LU_SHADOWMAX`
-   `LU_SHADOWMIN`
-   `LU_SHADOWWARNING`

Ensure the following command produces no output. Any accounts listed by running this command should be locked.

```

grep "^+:" /etc/passwd /etc/shadow /etc/group

```

> **Caution** Change your passwords after initial setup.

```

cd /etc
chown root:root passwd shadow group gshadow
chmod 644 passwd group
chmod 400 shadow gshadow

```

Find all the files that are world-writable and that do not have their sticky bits set.

```

find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print

```

Set the sticky bit \(`# chmod +t {dir}`\) for all the directories that result from running the previous command.

Find all the files that are world-writable and fix each file listed.

```

find / -xdev -type f -perm -0002 -print

```

Set the right permissions \(`# chmod o-w {file}`\) for all the files generated by running the aforementioned command.

Find all the files that do not belong to a valid user or group and either assign an owner or remove the file, as appropriate.

```

find / -xdev \( -nouser -o -nogroup \) -print

```

Find all the directories that are world-writable and ensure they are owned by either root or a system account \(assuming only system accounts have a User ID lower than 500\). If the command generates any output, verify the assignment is correct or reassign it to root.

```

find / -xdev -type d -perm -0002 -uid +500 -print

```

Authentication settings such as password quality, password expiration policy, password reuse, password retry attempts, and more can be configured using the Pluggable Authentication Modules \(PAM\) framework. PAM looks in the directory `/etc/pam.d` for application-specific configuration information. Running `authconfig` or `system-config-authentication` will re-write the PAM configuration files, destroying any manually made changes and replacing them with system defaults.

The default `pam_cracklib` PAM module provides strength checking for passwords. To configure `pam_cracklib` to require at least one uppercase character, lowercase character, digit, and special character, as recommended by the U.S. Department of Defense guidelines, edit the file `/etc/pam.d/system-auth` to include the following parameters in the line corresponding to password requisite `pam_cracklib.so try_first_pass`.

```
retry=3:
dcredit=-1. Require at least one digit
ucredit=-1. Require at least one upper case character
ocredit=-1. Require at least one special character
lcredit=-1. Require at least one lower case character
minlen-14. Require a minimum password length of 14.
```

For example:

```

password required pam_cracklib.so try_first_pass retry=3\minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1

```

These parameters can be set to reflect your security policy requirements. Note that the password restrictions are not applicable to the root password.

The `pam_tally2` PAM module provides the capability to lock out user accounts after a specified number of failed login attempts. To enforce password lockout, edit the file `/etc/pam.d/system-auth` to include the following lines:

-   The first of the auth lines should include:

    ```
    auth required pam_tally2.so deny=5 onerr=fail unlock_time=900
    ```

-   The first of the account lines should include:

    ```
    account required pam_tally2.so
    ```


Here, the deny parameter is set to limit the number of retries to 5 and the `unlock_time` has been set to 900 seconds to keep the account locked for 900 seconds before it is unlocked. These parameters may be configured appropriately to reflect your security policy requirements. A locked account can be manually unlocked using the `pam_tally2` utility:

```

/sbin/pam_tally2 --user {username} --reset

```

You can use PAM to limit the reuse of recent passwords. The remember option for the `pam_ unix` module can be set to remember the recent passwords and prevent their reuse. To accomplish this, edit the appropriate line in `/etc/pam.d/system-auth` to include the remember option.

For example:

```

password sufficient pam_unix.so [ … existing_options …] 
remember=5

```

You can set the number of previous passwords to remember to appropriately reflect your security policy requirements.

```

cd /etc
chown root:root passwd shadow group gshadow
chmod 644 passwd group
chmod 400 shadow gshadow

```

**Parent topic:** [Greenplum Database Security Configuration Guide](../topics/preface.html)
