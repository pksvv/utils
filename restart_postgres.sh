#!/bin/bash

PGDATA="/opt/homebrew/var/postgresql@14"
LOGFILE="$PGDATA/logfile.log"

echo "Checking if PostgreSQL is running..."
if pg_isready > /dev/null 2>&1; then
    echo "PostgreSQL is already running."
    exit 0
fi

echo "Checking for running PostgreSQL processes..."
POSTGRES_PID=$(pgrep -u $(whoami) postgres)

if [[ -n "$POSTGRES_PID" ]]; then
    echo "Stopping running PostgreSQL process (PID: $POSTGRES_PID)..."
    brew services stop postgresql@14
fi

echo "Checking for stale postmaster.pid file..."
if [[ -f "$PGDATA/postmaster.pid" ]]; then
    echo "Removing stale postmaster.pid file..."
    rm "$PGDATA/postmaster.pid"
fi

echo "Restarting PostgreSQL..."
brew services restart postgresql@14

echo "Waiting for PostgreSQL to start..."
sleep 5

echo "Verifying PostgreSQL status..."
if pg_isready > /dev/null 2>&1; then
    echo "PostgreSQL is running successfully!"
else
    echo "PostgreSQL failed to start. Check logs: $LOGFILE"
    cat "$LOGFILE"
fi

