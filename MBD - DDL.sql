drop database if exists gacha;
create database gacha;

use gacha;

-- explain select * from players where username = 'exampleUsername';
-- on delete cascade

-- harus dalam procedure
-- declare + set (local)
-- set @ (global)

create table admins (
    id varchar(255) primary key,
    name varchar(255) not null,
    username varchar(255) unique not null,
    password text not null,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

    index(name),
    index(username)
);

create table players (
    id varchar(255) primary key,
    name varchar(255) not null,
    username varchar(255) unique not null,
    password text not null,
    claim_limit tinyint default 1,
    total_pull int default 10,
    total_exp bigint default 0,
    total_money bigint default 0,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

    index(name),
    index(username)
);

create table characters (
    id varchar(255) primary key,
    name varchar(255) not null,
    description text not null,
    exp bigint default 10,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

    index(name)
);

create table powers (
    id varchar(255) primary key,
    name varchar(255) not null,
    description text not null,
    price bigint default 10,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

    index(name)
);

-- Pivot Table

create table claims (
    id varchar(255) primary key,
    id_player varchar(255) not null,
    id_character varchar(255) not null,
    exp bigint default 10,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,

    foreign key (id_player) references players(id) on delete cascade,
    foreign key (id_character) references characters(id) on delete cascade
);

create table player_powers (
    id varchar(255) primary key,
    id_player varchar(255) not null,
    id_power varchar(255) not null,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,

    foreign key (id_player) references players(id) on delete cascade,
    foreign key (id_power) references powers(id) on delete cascade
);
