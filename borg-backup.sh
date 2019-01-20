#!/bin/sh

# based on borgbackup.readthedocs.io 
# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup to $BORG_REPO"

# Backup the backup folder to an archive named by the date
now=$(date +'%Y_%m_%d')

info "Starting backup to $BORG_REPO $now"

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --remote-path=borg1             \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    ${BORG_REPO}::${now}            \
    /backup                         \

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 3 monthly

borg prune                          \
    --list                          \
    --remote-path=borg1             \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  3               \
    ${BORG_REPO}            \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
fi

exit ${global_exit}
