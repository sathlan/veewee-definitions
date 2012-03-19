# Many thanks to @draco2002
# http://dracosplace.com/veewee_and_freebsd

#Based on https://gist.github.com/911058

Veewee::Session.declare( {
  :cpu_count => '1', :memory_size=> '512',
  :disk_size => '80140', :disk_format => 'VDI',:hostiocache => 'off', :hwvirtext => 'on',
  :os_type_id => 'FreeBSD_64',
  :iso_file => "FreeBSD-9.0-RELEASE-amd64-bootonly.iso",
  :iso_src => "ftp://ftp.fr.freebsd.org/pub/FreeBSD/releases/ISO-IMAGES/9.0/",
  :iso_md5 => "477019a305797186a8b3e4147f44edec",
  :iso_download_timeout => "1000",
  :boot_wait => "40",:boot_cmd_sequence => [
        'L<Backspace><Backspace><Backspace>root<Enter>',
        'echo "Make some directories writable";',
        'foreach i ("etc" "var" "usr" "root" "mnt" "boot")<Enter>mkdir -p /tmp/$i<Enter>mount_unionfs -o below,rw /tmp/$i /$i;<Enter>find /$i;<Enter>end<Enter>',
        # bug ?  To path the /usr/share/pc-sysinstall we need to
        # "create" the dir structure in /tmp
        'find /usr/share/pc-sysinstall/backend/ -type f | xargs touch ;<Enter>',
        'dhclient em0<Enter>',
        'echo "waiting for 10 seconds for the webserver to start";',
        'sleep 10;echo "Lets Get the Files";cd /tmp;fetch -v "http://%IP%:%PORT%/pcinstall.fbg.cfg";',
        'fetch -v "http://%IP%:%PORT%/functions-extractimage.sh.patch";',
        'fetch -v "http://%IP%:%PORT%/parseconfig.sh.patch";',
        'sleep 2;',
        'patch /usr/share/pc-sysinstall/backend/functions-extractimage.sh /tmp/functions-extractimage.sh.patch;',
        'patch /usr/share/pc-sysinstall/backend/parseconfig.sh /tmp/parseconfig.sh.patch;',
        'echo \'echo sshd_enable=\"YES\" >> $FSMNT/etc/rc.conf\' > /tmp/activate-ssh.sh ; cat /tmp/activate-ssh.sh;',
        'chmod +x /tmp/activate-ssh.sh;',
        'echo "Hope i got the file";',
        '/usr/sbin/pc-sysinstall -c /tmp/pcinstall.fbg.cfg;',
        'reboot<Enter>'
    ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",:kickstart_file => [ "pcinstall.fbg.cfg", "functions-extractimage.sh.patch", "parseconfig.sh.patch" ],
  :ssh_login_timeout => "10000",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => "10000"
   }
)
