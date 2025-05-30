#!/bin/zsh

createdb webmemo -O postgres;

psql -U postgres -d webmemo << EOF
    create table Memos(
        id SERIAL NOT NULL,
        name VARCHAR(128) NOT NULL,
        content TEXT,
        PRIMARY KEY (id));
EOF
exit $?
