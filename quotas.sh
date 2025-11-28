#!/bin/bash

# Création des fichiers quota pour /home
touch /home/aquota.user
touch /home/aquota.group
chmod 600 /home/aquota.*

# Création des fichiers quota pour /data
mkdir data
touch /data/aquota.user
touch /data/aquota.group
chmod 600 data/aquota.*

# Modification du fichiers /etc/fstab
echo "Veuillez ajouter ceti : ,usrquota,grpquota aprés errors=remount-ro dans cette ligne"
echo "UUID=6fc9fcca-5dd7-4045-ba9d-c658154b36fb /               ext4    errors=remount-ro 0       1"
echo "Dans fichier /etc/fstab"
echo "S'il est dejà la ,n ajoute rien"
sleep 2
nano /etc/fstab

# Creation  fichier de configuration
quotacheck -avugm 

# Recharger les points de montage
systemctl daemon-reload
cd /home
mount -o remount /
cd
cd data
mount -o remount /
cd

# Activer les quotas
quotaon -avug

# Modification soft et hard pour le quota /home
cd /home
user=$(who | awk '{print $1}' | sort -u)
for i in $user;
do
  setquota -u $i 500M 700M 0 0 /
  setquota -g $i 500M 700M 0 0 /
done
# Modification soft et hard pour le quota /data
cd
cd /data
adduser user
passwd user
setquota -g user 0 0 1000 1200 /

# Periode de 7 jours
setquota -u -t 604800 604800 /

# Verifiction du soft et hard
EMAIL=$(logname)
Message="Hard atteint"

a=$(repquota -ug / | grep user | awk '$3 > 710000 {echo "1"}') 
if [[ "$a" -eq 1 ]]
then
  mail -s "Rapport utilisateur" "$EMAIL" < "$Message"
fi 

echo "0 18 * * * /root/quota.sh" >> crontab
