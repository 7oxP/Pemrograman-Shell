#!/bin/bash
set -eo pipefail

if [ $(id -u) -eq 0 ]; then

    read -p "Masukkan nama username baru: " user

    if id "$user"> /dev/null 2>&1; then
        echo "Pengguna dengan nama $user sudah ada."
    else
        echo "Pengguna dengan nama $user belum ada. Membuat pengguna..."
        echo ""
        #Membuat pengguna baru dengan nama tertentu
        adduser $user --gecos ",,," --disabled-password
        echo ""
        echo "Pengguna dengan nama $user berhasil dibuat."
    fi

    # Melakukan pengecekkan terhadap program Nginx
    if ! command -v nginx> /dev/null 2>&1; then
        echo ""
        echo "Nginx belum terpasang. Memulai proses pengunduhan..."
        echo ""

        apt-get install nginx -y
        echo ""
        echo "Nginx berhasil diunduh dan diinstal."
    else
        echo "Nginx sudah terpasang."
    fi

    echo "Melakukan konfigurasi Reverse proxy..."
    echo ""

    read -p "Masukkan alamat IP dan Port: " alamat
    echo ""
    
    unlink /etc/nginx/sites-enabled/default
    path="/etc/nginx/sites-available/flask-app"
    touch $path
    
    cat > $path << EOF
server {
    listen 80;
    location /$user {
    proxy_pass http://$alamat/;
    }
}
EOF
# test perubahan
    # Membuat symlink ke direktori sites-enabled
    ln -s $path /etc/nginx/sites-enabled/

    service nginx restart

    echo "Konfigurasi selesai!"
    echo "Hasil konfigurasi dapat dilihat pada localhost/$user pada browser"
    
else
    echo "Login sebagai root untuk menjalankan script ini"
fi
