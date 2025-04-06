# Backup Postgres database

```sh
PGPASSWORD=<your_password_here> pg_dump -h <your_host_here> -U <your_user_here> -p <your_port_here> -d <your_database_name_here> > data/backup-$(date +%Y-%m-%d).sql
BORG_PASSPHRASE=<your_borg_passphrase_here> borg create --stats --progress /path/to/backup/./api_backup::'{now:%Y%m%d}' ./data
borg prune --list --keep-daily=7 --keep-weekly=4 --keep-monthly=6 /path/to/backup
```

# Restore Postgres database

```sh
PGPASSWORD=<your_password_here> psql -h <your_host_here> -U <your_user_here> -p <your_port_here> -d <your_database_name_here> < data/backup-<date>.sql
BORG_PASSPHRASE=<your_borg_passphrase_here> borg extract --list --dry-run /path/to/backup/./api_backup::'{now:%Y%m%d}'
BORG_PASSPHRASE=<your_borg_passphrase_here> borg extract /path/to/backup/./api_backup::'{now:%Y%m%d}'
```