#!/bin/zsh

createdb webmemo -O postgres;

psql -U postgres -d webmemo << EOF
    create sequence memos_seq;
    create table Memos(
        id INTEGER NOT NULL,
        name VARCHAR(128) NOT NULL,
        content TEXT,
        PRIMARY KEY (id));
EOF
exit $?
