# `9Xpost-install`
This script prevents race conditions between packer and the debian/ubuntu
installers. Combined with the following snippet from `packer.json`, packer
will wait until the installer has finished before running additional
provisioners.

```
  "provisioners": [
    {
      "type": "file",
      "source": "installer/9Xpost-install",
      "destination": "/usr/lib/finish-install.d/93post-install",
      "direction": "upload"
    },
    {
      "type": "shell",
      "inline": [
        "while [ ! -f /tmp/ready_for_post_install ]",
        "do",
        "  sleep 5",
        "done"
      ]
    },
```

Once the Debian installer has finished it passes control to packer to run
additional provisioners. After these are finished, the final provisioner
should signal back to the Debian installer that packer is finished by creating
an empty file `/tmp/ready_to_shutdown`.

```
    {
      "type": "shell",
      "inline": [
        "touch /tmp/ready_to_shutdown"
      ]
    }
```

# `chroot_sshd_config`
Ansible tooling is run over ssh chrooted inside of `/target` after the
operating system is installed.

# `local_br0`
Network interface configuration to bring up virtual internal network on
vmhost (the machine running qemu).

Manually installed via
`sudo cp installer/local_br0 /etc/network/interfaces.d/br0 && ifup br0`

# `local_macvtap0`
macvtap virtual external interface
See the [ip-link](man:ip-link(8)) manpage for more details.

NOTE: The example must be edited to replace `enp0s0` and `de:ad:be:ef:00:03`
with the correct values.
`enp0s0` should be mapped to the device the macvtap interface is assigned to
and multiple macvtap interfaces can be assigned to the same physical interface.
`de:ad:be:ef:00:03` must match a unique local MAC address assigned to the VM in the
`config/<hostname>.yaml`

```
  external:
    # echo /dev/tap$(</sys/class/net/macvtap0/ifindex)
    macvtap: True
    iface: macvtap0
    name: wan0
    mac: "de:ad:be:ef:00:03"
    ip: 192.168.0.3
    netmask: 255.255.255.0
    gateway: 192.168.0.3
```

The example interface can be installed via
`sudo cp installer/local_macvtap0 /etc/network/interfaces.d/macvtap0 && ifup macvtap0`

# `restart_sshd`
This script restarts the `sshd` that is started by the Debian installer
network-console module. It also logs out the current `ssh` session, forcing
packer to reconnect.
