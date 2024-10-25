drop database if exists gacha;
create database gacha;

use gacha;

create or replace table admins (
    id int primary key auto_increment,
    name varchar(255) not null,
    username varchar(255) unique not null,
    password text not null,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

    index(username)
);

create or replace table players (
    id int primary key auto_increment,
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

    index(username)
);

create or replace table characters (
    id int primary key auto_increment,
    name varchar(255) not null,
    description text not null,
    exp bigint default 10,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime
);

create or replace table powers (
    id int primary key auto_increment,
    name varchar(255) unique not null,
    description text not null,
    price bigint default 10,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime
);

-- Pivot Table

create or replace table claims (
    id int primary key auto_increment,
    id_player int not null,
    id_character int not null,
    exp bigint default 10,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,

    foreign key (id_player) references players(id) on delete cascade,
    foreign key (id_character) references characters(id) on delete cascade,

    unique key (id_player, id_character)
);

create or replace table player_powers (
    id int primary key auto_increment,
    id_player int not null,
    id_power int not null,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,

    foreign key (id_player) references players(id) on delete cascade,
    foreign key (id_power) references powers(id) on delete cascade,

    unique key (id_player, id_power)
);
