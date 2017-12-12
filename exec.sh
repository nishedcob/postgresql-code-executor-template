#! /bin/sh

DEBUG=false
NULL="/dev/null"
PRINT_NULL="> $NULL 2> $NULL"

if $DEBUG; then
	echo ""

	whoami
	echo "says hello world!"
	echo "from Docker!"

	echo ""

	lsb_release -a
	uname -a

	echo ""

	cat /etc/os-release

	echo ""
fi

os_id=$(grep "^\(ID\|id\)=" /etc/os-release | awk -F= '{print $2}')

if $DEBUG; then
	echo "Detected OS ID: $os_id"

	echo ""
fi

if $DEBUG; then
	echo "Starting PostgreSQL Cluster..."
fi

if [ "$os_id" = 'debian' ] ; then
	debian_pg_start="/usr/bin/pg_ctlcluster 9.6 main start"
	if $DEBUG; then
    		eval $debian_pg_start && echo "Started cluster!" || echo "Failed to start cluster!";
	else
		eval "$debian_pg_start $PRINT_NULL"
	fi
else
    if [ "$os_id" = 'alpine' ] ; then
	md="mkdir -vp"
	pg_r_dir="/run/postgresql"
	pg_vr_dir="/var/run/postgresql"
	pg_data="/var/lib/postgresql/data"
	pg_user="postgres"
	pg_cmd="postgres &"
	ch_own="chown -R $pg_user:$pg_user"
	ch_mod_rd="chmod -v 775 $pg_r_dir"
	ch_mod_vrd="chmod -v 2777 $pg_vr_dir"
	su_pg="su - $pg_user -c"
	exprt="export PGDATA=$pg_data"
	start_pg="$su_pg \"$exprt && $pg_cmd\""
	validation="echo \"Started cluster!\" || echo \"Failed to start cluster!\""
	if $DEBUG; then
		cmd="$md $pg_r_dir && $ch_own $pg_r_dir && $ch_mod_rd && $md $pg_vr_dir && $ch_own $pg_vr_dir && $ch_mod_vrd && $start_pg && $validation"
	else
		cmd="$md $pg_r_dir $PRINT_NULL && $ch_own $pg_r_dir $PRINT_NULL && $ch_mod_rd $PRINT_NULL && $md $pg_vr_dir $PRINT_NULL && $ch_own $pg_vr_dir $PRINT_NULL && $ch_mod_vrd $PRINT_NULL && $start_pg $PRINT_NULL"
	fi
        eval $cmd
        sleep 10s
    else
	if $DEBUG; then
	        echo "Unknown/Unsupported OS";
	fi
        exit 1;
    fi
fi

if $DEBUG; then
	echo ""
fi

init_db="su - user -c \"psql -U user userdb -f /code/init.sql\""
if $DEBUG; then
	eval $init_db
else
	eval "$init_db $PRINT_NULL"
fi
su - user -c "psql -U user userdb -f /code/main.sql"

