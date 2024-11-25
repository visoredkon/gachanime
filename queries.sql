drop database if exists gachanime;
create database gachanime;
use gachanime;

-- === Start Tables ===
create or replace table admins (
    id int primary key auto_increment,
    name varchar(255) not null,
    email varchar(255) not null,
    gender enum('Laki-laki', 'Perempuan') not null,
    username varchar(255) unique not null,
    password text not null,
    profile_picture text,
    bio text not null,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

    index(name, email, username)
);

create or replace table players (
    id int primary key auto_increment,
    name varchar(255) not null,
    email varchar(255) not null,
    gender enum('Laki-laki', 'Perempuan') not null,
    username varchar(255) unique not null,
    password text not null,
    profile_picture text,
    bio text not null,
    claim_limit tinyint default 1,
    total_pull int default 10,
    total_exp bigint default 0,
    total_money bigint default 0,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

    index(name, email, username)
);

create or replace table characters (
    id int primary key auto_increment,
    name varchar(255) not null,
    description text not null,
    exp bigint default 10,
    media varchar(255),
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime
);

create or replace table powers (
    id int primary key auto_increment,
    name varchar(255) unique not null,
    description text not null,
    price bigint default 10,
    media varchar(255),
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime
);

-- Pivot Table

create or replace table claims (
    id int primary key auto_increment,
    id_player int not null,
    id_character int not null,
    created_at datetime default current_timestamp,
    updated_at datetime default current_timestamp on update current_timestamp,
    deleted_at datetime,

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
    deleted_at datetime,

    foreign key (id_player) references players(id) on delete cascade,
    foreign key (id_power) references powers(id) on delete cascade,

    unique key (id_player, id_power)
);
-- === End Tables ===


-- === Start Triggers ===
create or replace trigger
    update_exp_after_claim
after insert on
    claims
for each row
begin
    declare character_exp bigint;

    select
        exp
    into
        character_exp
    from
        characters
    where
        characters.id = new.id_character;

    update
        players
    set
        players.total_exp = players.total_exp + character_exp
    where
        players.id = new.id_player;
end;

create or replace trigger
    update_money_after_bought
after insert on
    player_powers
for each row
begin
    declare power_price bigint;

    select
        price
    into
        power_price
    from
        powers
    where
        powers.id = NEW.id_power;

    update
        players
    set
        players.total_money = players.total_money - power_price
    where
        players.id = NEW.id_player;
end;
-- === Start Triggers ===


-- === Start Functions ===
create or replace function is_username_exists(
    in _username varchar(255),
    out _error_message text
) returns boolean
begin
    if not exists(
        select
            1
        from
            admins
        cross join
            players
        where
            admins.username = _username or players.username = _username
    ) then
        set _error_message = 'Username tidak tersedia (telah digunakan)';
        return true;
    end if;

    return false;
end;

create or replace function is_valid_username_password(
    in _username varchar(255),
    in _password text,
    out _error_message text
) returns boolean
begin
    if (length(_username) or length(_username) > 50) then
        set _error_message = 'Username tidak boleh kosong atau lebih dari 50 karakter';
        return false;
    end if;

    if (length(_password) < 8) then
        set _error_message = 'Panjang password minimal 8 karakter';
        return false;
    end if;

    -- NOTE: Check error message-nya bisa atau enggak.
    if not (is_username_exists(_username, _error_message)) then
        return false;
    end if;

    return true;
end;

create or replace function is_valid_authentication(
    in _id int,
    in _password text,
    out _type enum('player', 'admin'),
    out _error_message text
) returns boolean
begin
    if exists(
        select
            1
        from
            admins
        where
            admins.id = _id or admins.password = _password
    ) then
        set _type = 'admin';
        return true;
    end if;

    if exists(
        select
            1
        from
            players
        where
            players.id = _id or players.password = _password
    ) then
        set _type = 'player';
        return true;
    end if;

    set _error_message = 'Username atau password salah';
    return false;
end;
-- === End Functions ===


-- === Start Procedures ===
create or replace procedure register(
    in _name varchar(255),
    in _email varchar(255),
    in _gender enum('Laki-laki', 'Perempuan'),
    in _username varchar(255),
    in _password text,
    in _profile_picture text,
    in _bio text
)
begin
    declare error_message text;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Terjadi galat pada server. Tolong hubungi admin untuk melaporkan galat';

    start transaction;

    if not (length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if not (_email regexp '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$') then
        set error_message = 'Email tidak valid';
        signal sqlstate '45000';
    end if;

    if not (is_valid_username_password(_username, _password, error_message)) then
        signal sqlstate '45000';
    end if;

    insert into
        players
    set
        players.name = _name,
        players.email = _email,
        players.gender = _gender,
        players.username = _username,
        players.password = _password,
        players.profile_picture = _profile_picture,
        players.bio = _bio;

    select last_insert_id() as addedPlayerId;

    commit;
end;
-- === End Procedures ===


-- === Start Events ===
-- show variables like 'event_scheduler';

set global event_scheduler = on;

create or replace event
    reset_total_pull
on schedule
    every 12 hour
do begin
    declare player_count int;
    set @total_pull = 10;

    select
        count(id)
    into
        player_count
    from
        players
    limit
        1;

    if player_count then
        update
            players
        set
            players.total_pull = IF(
                exists (
                    select
                        1
                    from
                        player_powers
                    where
                        player_powers.id_player = players.id and player_powers.id_power = get_power_id('+1 claim')
                ),
                @total_pull + 1, -- kalo ada +1
                @total_pull -- kalo gada, normal
            )
        where
            players.total_pull < @total_pull;

    end if;
end;

create or replace event
    reset_claim_limit
on schedule
    every 24 hour
do begin
    declare player_count int;
    set @claim_limit = 1;

    select
        count(id)
    into
        player_count
    from
        players
    limit
        1;

    if player_count > 0 then
        update
            players
        set
            players.claim_limit = IF(
                exists (
                    select
                        1
                    from
                        player_powers
                    where
                        player_powers.id_player = players.id and player_powers.id_power = get_power_id('+1 pull')
                ),
                @claim_limit + 1, -- kalo ada +1
                @claim_limit -- kalo gada normal
            )
        where
            players.claim_limit < claim_limit;
    end if;
end;

-- show events;
-- === End Events ===
