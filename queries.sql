drop database if exists gachanime;
create database gachanime;
use gachanime;

set global time_zone = '+08:00';

-- === Start Tables ===
create or replace table admins (
    id int unsigned primary key auto_increment,
    name varchar(255) not null,
    email varchar(255) unique not null,
    gender enum('Laki-laki', 'Perempuan') not null,
    username varchar(255) unique not null,
    password varchar(255) not null,
    bio text not null,
    created_at datetime default now(),
    updated_at datetime default now() on update now(),
    deleted_at datetime,

    fulltext (name, username, email, bio)
);

create or replace table players (
    id int unsigned primary key auto_increment,
    name varchar(255) not null,
    email varchar(255) unique not null,
    gender enum('Laki-laki', 'Perempuan') not null,
    username varchar(255) unique not null,
    password varchar(255) not null,
    bio text not null,
    claim_limit tinyint unsigned default 1,
    pull_limit tinyint unsigned default 10,
    total_exp bigint unsigned default 0,
    total_money bigint unsigned default 0,
    last_gacha_character_id int,
    created_at datetime default now(),
    updated_at datetime default now() on update now(),
    deleted_at datetime,

    fulltext (name, username, email, bio)
);

create or replace table characters (
    id int unsigned primary key auto_increment,
    name varchar(255) not null,
    description text not null,
    exp bigint unsigned default 10,
    created_at datetime default now(),
    updated_at datetime default now() on update now(),
    deleted_at datetime,

    fulltext (name, description)
);

create or replace table powers (
    id int unsigned primary key auto_increment,
    name varchar(255) unique not null,
    description text not null,
    price bigint unsigned default 10,
    created_at datetime default now(),
    updated_at datetime default now() on update now(),
    deleted_at datetime,

    fulltext (name, description)
);

-- Pivot Table
create or replace table claims (
    id int primary key auto_increment,
    id_player int unsigned not null,
    id_character int unsigned not null,
    isDivorced boolean not null default false,
    created_at datetime default now(),
    updated_at datetime default now() on update now(),
    deleted_at datetime,

    foreign key (id_player) references players(id) on update cascade on delete cascade,
    foreign key (id_character) references characters(id) on update cascade on delete cascade
);

create or replace table player_powers (
    id int unsigned primary key auto_increment,
    id_player int unsigned not null,
    id_power int unsigned not null,
    created_at datetime default now(),
    updated_at datetime default now() on update now(),
    deleted_at datetime,

    foreign key (id_player) references players(id) on update cascade on delete cascade,
    foreign key (id_power) references powers(id) on update cascade on delete cascade,

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
    declare character_exp bigint unsigned;

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
    update_limit_amount_after_claim
after insert on
    claims
for each row
begin
    update
        players
    set
        players.claim_limit = players.claim_limit - 1
    where
        players.id = new.id_player;
end;

create or replace trigger
    update_money_after_bought
after insert on
    player_powers
for each row
begin
    declare power_price bigint unsigned;

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
create or replace function better_length(
    in _value text
) returns int
begin
    return length(ifnull(_value, ''));
end;

create or replace function hash(
    in _value text
) returns text
begin
    return sha2(_value, 512);
end;

create or replace function is_username_exists(
    in _username varchar(255),
    out _error_message text
) returns boolean
begin
    if exists(
        select
            1
        from
            ((select
                1
            from
                admins
            where
                admins.username = _username and admins.deleted_at is null
            limit
                1)
            union
            (select
                1
            from
                players
            where
                players.username = _username and players.deleted_at is null
            limit
                1))
            as
                users
    ) then
        set _error_message = 'Username tidak tersedia (telah digunakan)';
        return true;
    end if;

    return false;
end;

create or replace function is_email_exists(
    in _email varchar(255),
    out _error_message text
) returns boolean
begin
    if exists(
        select
            1
        from
            ((select
                1
            from
                admins
            where
                admins.email = _email and admins.deleted_at is null
            limit
                1)
            union
            (select
                1
            from
                players
            where
                players.email = _email and players.deleted_at is null
            limit
                1))
            as
                users
    ) then
        set _error_message = 'Email telah digunakan';
        return true;
    end if;

    return false;
end;

create or replace function is_valid_username_password(
    in _username varchar(255),
    in _password varchar(255),
    out _error_message text
) returns boolean
begin
    declare username_length int default 0;
    declare password_length int default 0;

    set username_length = better_length(_username);
    set password_length = better_length(_password);

    if (not username_length or (username_length < 3 or username_length > 50)) then
        set _error_message = 'Username tidak boleh kosong atau lebih dari 50 karakter';
        return false;
    end if;

    if (not password_length or password_length < 8) then
        set _error_message = 'Panjang password minimal 8 karakter';
        return false;
    end if;

    return true;
end;

create or replace function is_valid_authentication(
    in _username varchar(255),
    in _password text,
    out _role enum('player', 'admin'),
    out _error_message text
) returns boolean
begin
    if exists(
        select
            1
        from
            admins
        where
            admins.username = _username and admins.password = hash(_password)
    ) then
        set _role = 'admin';
        return true;
    end if;

    if exists(
        select
            1
        from
            players
        where
            players.username = _username and players.password = hash(_password)
    ) then
        set _role = 'player';
        return true;
    end if;

    set _error_message = 'Username atau password salah';
    return false;
end;

create or replace function get_random_character(
    out _error_message text
) returns int unsigned
begin
    declare character_id int unsigned;

    if not exists(
        select
            1
        from
            v_characters_active
    ) then
        set _error_message = 'Data characters kosong';
        return 0;
    end if;

    select
        id
    into
        character_id
    from
        v_characters_active
    order by
        rand()
    limit 1;

    return character_id;
end;

create or replace function is_player_exists(
    in _id int unsigned,
    out _error_message text
) returns boolean
begin
    if exists(
        select
            1
        from
            v_players_active
        where
            id = _id and deleted_at is null
    ) then
        set _error_message = 'Player tidak dapat ditemukan';
        return true;
    end if;

    return false;
end;

create or replace function is_character_exists(
    in _id int unsigned,
    out _error_message text
) returns boolean
begin
    if exists(
        select
            1
        from
            v_characters_active
        where
            id = _id and deleted_at is null
    ) then
        return true;
    end if;

    set _error_message = 'Character tidak dapat ditemukan';
    return false;
end;
-- === End Functions ===


-- === Start Procedures ===
create or replace procedure register(
    in _name varchar(255),
    in _email varchar(255),
    in _gender varchar(255),
    in _username varchar(255),
    in _password text,
    in _bio text,
    in _role enum('admin', 'player')
)
begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if (not better_length(_role) or (_role != 'admin' and _role != 'player')) then
        set error_message = concat('Jenis role tidak valid: ', _role);
        signal sqlstate '45000';
    end if;

    if not (better_length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if not (better_length(_email) and _email regexp '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$') then
        set error_message = 'Email tidak valid';
        signal sqlstate '45000';
    end if;

    if not (better_length(_gender) and (_gender = 'Laki-laki' or _gender = 'Perempuan')) then
        set error_message = 'Gender tidak valid';
        signal sqlstate '45000';
    end if;

    if not (is_valid_username_password(_username, _password, error_message)) then
        signal sqlstate '45000';
    end if;

    if (is_username_exists(_username, error_message)) then
        signal sqlstate '45000';
    end if;

    if (is_email_exists(_email, error_message)) then
        signal sqlstate '45000';
    end if;

    case _role
        when
          'admin'
        then
            insert into
                admins
            set
                admins.name = _name,
                admins.email = _email,
                admins.gender = _gender,
                admins.username = _username,
                admins.password = hash(_password),
                admins.bio = _bio;

        when
            'player'
        then
            insert into
                players
            set
                players.name = _name,
                players.email = _email,
                players.gender = _gender,
                players.username = _username,
                players.password = hash(_password),
                players.bio = _bio;
    end case;

    select last_insert_id() as addedPlayerId;

    commit;
end;

create or replace procedure login(
    in _username varchar(255),
    in _password varchar(255)
) begin
    declare error_message text;
    declare role enum('player', 'admin');

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (is_valid_username_password(_username, _password, error_message)) then
        set error_message = 'Username atau password salah';
        signal sqlstate '45000';
    end if;

    if not (is_valid_authentication(_username, _password, role, error_message)) then
        signal sqlstate '45000';
    end if;

    if not (better_length(role)) then
        set error_message = null;
        signal sqlstate '45000';
    end if;

    if (role = 'player') then
        select
            id,
            name,
            username,
            role
        from
            players
        where
            players.username = _username
        limit
            1;
    end if;

    if (role = 'admin') then
        select
            id,
            name,
            username,
            role
        from
            admins
        where
            admins.username = _username
        limit
            1;
    end if;

    commit;
end;

create or replace procedure get_users(
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    start transaction;

    if (_only_deleted) then
        (select
            id,
            name,
            username,
            'admin' as role
        from
            v_admins_deleted)
        union
        (select
            id,
            name,
            username,
            'player' as role
        from
            v_players_deleted);
    end if;

    if (_with_deleted) then
        (select
            id,
            name,
            username,
            'admin' as role
        from
            v_admins)
        union
        (select
            id,
            name,
            username,
            'player' as role
        from
            v_players);
    end if;

    (select
        id,
        name,
        username,
        'admin' as role
    from
        v_admins_active)
    union
    (select
        id,
        name,
        username,
        'player' as role
    from
        v_players_active);

    commit;
end;

create or replace procedure get_admins(
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    start transaction;

    if (_only_deleted) then
        select
            id,
            name,
            username
        from
            v_admins_deleted;
    end if;

    if (_with_deleted) then
        select
            id,
            name,
            username
        from
            v_admins;
    end if;

    select
        id,
        name,
        username
    from
        v_admins_active;

    commit;
end;

create or replace procedure get_players(
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    if (_only_deleted) then
        select
            id,
            name,
            username
        from
            v_players_deleted;
    end if;

    if (_with_deleted) then
        select
            id,
            name,
            username
        from
            v_players;
    end if;

    select
        id,
        name,
        username
    from
        v_players_active;

    commit;
end;

create or replace procedure find_users(
    in _keyword varchar(255),
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_keyword)) then
        set error_message = 'Panjang keyword minimal 1 karakter';
        signal sqlstate '45000';
    end if;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    if (_only_deleted) then
        (select
            id,
            name,
            username
        from
            v_admins_deleted
        where
            match (name, username, email, bio) against (_keyword in natural language mode))
        union
        (select
            id,
            name,
            username
        from
            v_players_deleted
        where
            match (name, username, email, bio) against (_keyword in natural language mode));
    end if;

    if (_with_deleted) then
        (select
            id,
            name,
            username
        from
            v_admins
        where
            match (name, username, email, bio) against (_keyword in natural language mode))
        union
        (select
            id,
            name,
            username
        from
            v_players
        where
            match (name, username, email, bio) against (_keyword in natural language mode));
    end if;

    (select
        id,
        name,
        username
    from
        v_admins_active
    where
        match (name, username, email, bio) against (_keyword in natural language mode))
    union
    (select
        id,
        name,
        username
    from
        v_players_active
    where
        match (name, username, email, bio) against (_keyword in natural language mode));

    commit;
end;

create or replace procedure find_admins(
    in _keyword varchar(255),
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_keyword)) then
        set error_message = 'Panjang keyword minimal 1 karakter';
        signal sqlstate '45000';
    end if;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    if (_only_deleted) then
        select
            id,
            name,
            username
        from
            v_admins_deleted
        where
            match (name, username, email, bio) against (_keyword in natural language mode);
    end if;

    if (_with_deleted) then
        select
            id,
            name,
            username
        from
            v_admins
        where
            match (name, username, email, bio) against (_keyword in natural language mode);
    end if;

    select
        id,
        name,
        username
    from
        v_admins_active
    where
        match (name, username, email, bio) against (_keyword in natural language mode);

    commit;
end;

create or replace procedure find_players(
    in _keyword varchar(255),
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_keyword)) then
        set error_message = 'Panjang keyword minimal 1 karakter';
        signal sqlstate '45000';
    end if;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    if (_only_deleted) then
        select
            id,
            name,
            username
        from
            v_players_deleted
        where
            match (name, username, email, bio) against (_keyword in natural language mode);
    end if;

    if (_with_deleted) then
        select
            id,
            name,
            username
        from
            v_players
        where
            match (name, username, email, bio) against (_keyword in natural language mode);
    end if;

    select
        id,
        name,
        username
    from
        v_players_active
    where
        match (name, username, email, bio) against (_keyword in natural language mode);

    commit;
end;

create or replace procedure get_admin_by_id(
    in _id int unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    select
        *
    from
        v_admins
    where
        id = _id;

    commit;
end;

create or replace procedure get_admin_by_username(
    in _username varchar(255)
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    select
        *
    from
        v_admins
    where
        username = _username;

    commit;
end;

create or replace procedure get_player_by_id(
    in _id int unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    select
        *
    from
        v_players
    where
        id = _id;

    commit;
end;

create or replace procedure get_player_by_username(
    in _username varchar(255)
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    select
        *
    from
        v_players
    where
        username = _username;

    commit;
end;

create or replace procedure update_admin_by_id(
    in _id int unsigned,
    in _name varchar(255),
    in _email varchar(255),
    in _gender varchar(255),
    in _username varchar(255),
    in _password text,
    in _bio text
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if not (better_length(_email) and _email regexp '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$') then
        set error_message = 'Email tidak valid';
        signal sqlstate '45000';
    end if;

    if not (better_length(_gender) and (_gender = 'Laki-laki' or _gender = 'Perempuan')) then
        set error_message = 'Gender tidak valid';
        signal sqlstate '45000';
    end if;

    if not (is_valid_username_password(_username, _password, error_message)) then
        signal sqlstate '45000';
    end if;

    if (is_username_exists(_username, error_message)) then
        signal sqlstate '45000';
    end if;

    if (is_email_exists(_email, error_message)) then
        signal sqlstate '45000';
    end if;

    update
        admins
    set
        admins.name = ifnull(_name, admins.name),
        admins.email = ifnull(_email, admins.email),
        admins.gender = ifnull(_gender, admins.gender),
        admins.username = ifnull(_username, admins.username),
        admins.password = ifnull(hash(_password), admins.password),
        admins.bio = ifnull(_bio, admins.bio)
    where
        admins.id = _id;

    select
        updated_at
    from
        v_admins
    where
        id = _id;

    commit;
end;

create or replace procedure update_player_by_id(
    in _id int unsigned,
    in _name varchar(255),
    in _email varchar(255),
    in _gender varchar(255),
    in _username varchar(255),
    in _password text,
    in _bio text
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if not (better_length(_email) and _email regexp '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$') then
        set error_message = 'Email tidak valid';
        signal sqlstate '45000';
    end if;

    if not (better_length(_gender) and (_gender = 'Laki-laki' or _gender = 'Perempuan')) then
        set error_message = 'Gender tidak valid';
        signal sqlstate '45000';
    end if;

    if not (is_valid_username_password(_username, _password, error_message)) then
        signal sqlstate '45000';
    end if;

    if (is_username_exists(_username, error_message)) then
        signal sqlstate '45000';
    end if;

    if (is_email_exists(_email, error_message)) then
        signal sqlstate '45000';
    end if;

    update
        players
    set
        players.name = ifnull(_name, players.name),
        players.email = ifnull(_email, players.email),
        players.gender = ifnull(_gender, players.gender),
        players.username = ifnull(_username, players.username),
        players.password = ifnull(hash(_password), players.password),
        players.bio = ifnull(_bio, players.bio)
    where
        players.id = _id;

    select
        updated_at
    from
        v_players
    where
        id = _id;

    commit;
end;

create or replace procedure delete_admin_by_id(
    in _id int unsigned,
    in _isHard boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_id)) then
        set error_message = 'ID tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (_isHard is null) then
        set _isHard = false;
        signal sqlstate '45000';
    end if;

    if (_isHard) then
        delete from
            admins
        where
            admins.id = _id;

        select _id as id, now() as deleted_at;
    else
        update
            admins
        set
            admins.deleted_at = now()
        where
            admins.id = _id;

        select
            id,
            deleted_at
        from
            v_admins
        where
            id = _id;
    end if;

    commit;
end;

create or replace procedure delete_player_by_id(
    in _id int unsigned,
    in _isHard boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_id)) then
        set error_message = 'ID tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (_isHard is null) then
        set _isHard = false;
        signal sqlstate '45000';
    end if;

    if (_isHard) then
        delete from
            players
        where
            players.id = _id;

        select _id as id, now() as deleted_at;
    else
        update
            players
        set
            players.deleted_at = now()
        where
            players.id = _id;

        select
            id,
            deleted_at
        from
            v_players
        where
            id = _id;
    end if;

    commit;
end;

create or replace procedure add_character(
    in _name varchar(255),
    in _description text,
    in _exp bigint unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (not better_length(_description) or better_length(_description) < 10) then
        set error_message = 'Panjang deksripsi minimal 10 karakter';
        signal sqlstate '45000';
    end if;

    if (ifnull(_exp, 0) < 10) then
        set error_message = 'Jumlah exp minimal 10';
        signal sqlstate '45000';
    end if;

    insert into
        characters
    set
        characters.name = _name,
        characters.description = _description,
        characters.exp = _exp;

    select last_insert_id() as addedCharacterId;

    commit;
end;

create or replace procedure get_characters(
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    start transaction;

    if (_only_deleted) then
        select
            id,
            name
        from
            v_characters_deleted;
    end if;

    if (_with_deleted) then
        select
            id,
            name
        from
            v_characters;
    end if;

    select
        id,
        name
    from
        v_characters_active;

    commit;
end;

create or replace procedure find_characters(
    in _keyword varchar(255),
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_keyword)) then
        set error_message = 'Panjang keyword minimal 1 karakter';
        signal sqlstate '45000';
    end if;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    if (_only_deleted) then
        select
            id,
            name
        from
            v_characters_deleted
        where
            match (name, description) against (_keyword in natural language mode);
    end if;

    if (_with_deleted) then
    select
        id,
        name
    from
        v_characters
        where
            match (name, description) against (_keyword in natural language mode);
    end if;

    select
        id,
        name
    from
        v_characters_active
    where
        match (name, description) against (_keyword in natural language mode);

    commit;
end;

create or replace procedure get_character_by_id(
    in _id int unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    select
        *
    from
        v_characters
    where
        id = _id;

    commit;
end;

create or replace procedure update_character_by_id(
    in _id int unsigned,
    in _name varchar(255),
    in _description text,
    in _exp bigint unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (not better_length(_description) or better_length(_description) < 10) then
        set error_message = 'Panjang deksripsi minimal 10 karakter';
        signal sqlstate '45000';
    end if;

    if (ifnull(_exp, 0) < 10) then
        set error_message = 'Jumlah exp minimal 10';
        signal sqlstate '45000';
    end if;

    update
        characters
    set
        characters.name = ifnull(_name, characters.name),
        characters.description = ifnull(_description, characters.description),
        characters.exp = ifnull(_exp, characters.exp)
    where
        characters.id = _id;

    select
        updated_at
    from
        v_characters
    where
        id = _id;

    commit;
end;

create or replace procedure delete_character_by_id(
    in _id int unsigned,
    in _isHard boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_id)) then
        set error_message = 'ID tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (_isHard is null) then
        set _isHard = false;
        signal sqlstate '45000';
    end if;

    if (_isHard) then
        delete from
            characters
        where
            characters.id = _id;

        select _id as id, now() as deleted_at;
    else
        update
            characters
        set
            characters.deleted_at = now()
        where
            characters.id = _id;

        select
            id,
            deleted_at
        from
            v_characters
        where
            id = _id;
    end if;

    commit;
end;

create or replace procedure add_power(
    in _name varchar(255),
    in _description text,
    in _price bigint unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (not better_length(_description) or better_length(_description) < 10) then
        set error_message = 'Panjang deksripsi minimal 10 karakter';
        signal sqlstate '45000';
    end if;

    if (ifnull(_price, 0) < 10) then
        set error_message = 'Price minimal 10';
        signal sqlstate '45000';
    end if;

    insert into
        powers
    set
        powers.name = _name,
        powers.description = _description,
        powers.price = _price;

    select last_insert_id() as addedCharacterId;

    commit;
end;

create or replace procedure get_powers(
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    start transaction;

    if (_only_deleted) then
        select
            id,
            name
        from
            v_powers_deleted;
    end if;

    if (_with_deleted) then
        select
            id,
            name
        from
            v_powers;
    end if;

    select
        id,
        name
    from
        v_powers_active;

    commit;
end;

create or replace procedure find_powers(
    in _keyword varchar(255),
    in _only_deleted boolean,
    in _with_deleted boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_keyword)) then
        set error_message = 'Panjang keyword minimal 1 karakter';
        signal sqlstate '45000';
    end if;

    if (_only_deleted is null) then
        set _only_deleted = false;
    end if;

    if (_with_deleted is null) then
        set _with_deleted = false;
    end if;

    if (_only_deleted) then
        select
            id,
            name
        from
            v_powers_deleted
        where
            match (name, description) against (_keyword in natural language mode);
    end if;

    if (_with_deleted) then
    select
        id,
        name
    from
        v_powers
        where
            match (name, description) against (_keyword in natural language mode);
    end if;

    select
        id,
        name
    from
        v_powers_active
    where
        match (name, description) against (_keyword in natural language mode);

    commit;
end;

create or replace procedure get_power_by_id(
    in _id int unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    select
        *
    from
        v_powers
    where
        id = _id;

    commit;
end;

create or replace procedure get_power_id_by_name(
    in _name varchar(255)
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    select
        id
    from
        v_powers
    where
        name = _name;

    commit;
end;

create or replace procedure update_power_by_id(
    in _id int unsigned,
    in _name varchar(255),
    in _description text,
    in _price bigint unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if (_id is null) then
        set error_message = 'ID tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if not (better_length(_name)) then
        set error_message = 'Nama tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (not better_length(_description) or better_length(_description) < 10) then
        set error_message = 'Panjang deksripsi minimal 10 karakter';
        signal sqlstate '45000';
    end if;

    if (ifnull(_price, 0) < 10) then
        set error_message = 'Price minimal 10';
        signal sqlstate '45000';
    end if;

    update
        powers
    set
        powers.name = ifnull(_name, powers.name),
        powers.description = ifnull(_description, powers.description),
        powers.price = ifnull(_price, powers.price)
    where
        powers.id = _id;

    select
        updated_at
    from
        v_powers
    where
        id = _id;

    commit;
end;

create or replace procedure delete_power_by_id(
    in _id int unsigned,
    in _isHard boolean
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (better_length(_id)) then
        set error_message = 'ID tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (_isHard is null) then
        set _isHard = false;
        signal sqlstate '45000';
    end if;

    if (_isHard) then
        delete from
            powers
        where
            powers.id = _id;

        select _id as id, now() as deleted_at;
    else
        update
            powers
        set
            powers.deleted_at = now()
        where
            powers.id = _id;

        select
            id,
            deleted_at
        from
            v_powers
        where
            id = _id;
    end if;

    commit;
end;

create or replace procedure buy_power(
    in _player_id int,
    in _power_id int
) begin
    declare error_message text;
    declare power_price bigint unsigned;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if (_player_id is null) then
        set error_message = 'ID player tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if (_power_id is null) then
        set error_message = 'ID power tidak boleh kosong';
        signal sqlstate '45000';
    end if;

    if not exists(
        select
            1
        from
            v_powers_active
        where
            id = _power_id
    ) then
        set error_message = 'Power tidak ditemukan';
        signal sqlstate '45000';
    end if;

    select
        price
    into
        power_price
    from
        v_powers_active
    where
        id = _power_id;

    if ((select total_money from v_players_active where id = _player_id) < power_price) then
        set error_message = 'Uang player tidak mencukupi untuk membeli power';
        signal sqlstate '45000';
    end if;

    insert into
        player_powers
    set
        player_powers.id_player = _player_id,
        player_powers.id_power = _power_id;

    select _power_id as power_id;

    commit;
end;

create or replace procedure gacha_character(
    in _player_id int
) begin
    declare error_message text;
    declare character_id int unsigned;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (is_player_exists(_player_id, error_message)) then
        signal sqlstate '45000';
    end if;

    if ((select pull_limit from v_players_active where id = _player_id) = 0) then
        set error_message = 'Player telah mencapai limit pull';
        signal sqlstate '45000';
    end if;

    set character_id = get_random_character(error_message);

    if not (character_id) then
        signal sqlstate '45000';
    end if;

    update
        players
    set
        players.pull_limit = players.pull_limit - 1,
        players.last_gacha_character_id = character_id
    where
        players.id = _player_id;

    select
        id,
        name,
        description,
        exp
    from
        v_characters_active
    where
        id = character_id;

    commit;
end;

create or replace procedure claim_character(
    in _player_id int
) begin
    declare error_message text;
    declare character_id int unsigned;
    declare claim_exp bigint unsigned;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (is_player_exists(_player_id, error_message)) then
        signal sqlstate '45000';
    end if;

    select
        last_gacha_character_id
    into
        character_id
    from
        players
    where
        players.id = _player_id;

    if (character_id is null) then
        set error_message = 'Lakukan gacha character terlebih dahulu';
        signal sqlstate '45000';
    end if;

    if not (is_character_exists(character_id, error_message)) then
        signal sqlstate '45000';
    end if;

    select
        exp
    into
        claim_exp
    from
        v_characters_active
    where
        id = character_id;

    if ((select claim_limit from v_players_active where id = _player_id) = 0) then
        set error_message = 'Player telah mencapai limit claim';
        signal sqlstate '45000';
    end if;

    if exists(
        select
            1
        from
            claims
        where
            claims.id_player = _player_id and claims.id_character = character_id
    ) then
        update
            players
        set
            players.total_money = players.total_money + claim_exp
        where
            players.id = _player_id;
    end if;

    insert into
        claims
    set
        claims.id_player = _player_id,
        claims.id_character = character_id;

    select
        id,
        name,
        description,
        exp
    from
        v_characters_active
    where
        id = character_id;

    commit;
end;

create or replace procedure sell_character(
    in _player_id int,
    in _character_id int
) begin
    declare error_message text;
    declare character_exp bigint unsigned;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if not (is_player_exists(_player_id, error_message)) then
        signal sqlstate '45000';
    end if;

    if not (is_character_exists(_character_id, error_message)) then
        signal sqlstate '45000';
    end if;

    if not exists(
        select
            1
        from
            claims
        where
            (claims.id_player = _player_id and claims.id_character = _character_id) and claims.isDivorced = false
    ) then
        set error_message = 'Character tidak dimiliki';
        signal sqlstate '45000';
    end if;

    select
        exp
    into
        character_exp
    from
        v_characters_active
    where
        id = _character_id;

    update
        claims
    set
        claims.isDivorced = true
    where
        (claims.id_player = _player_id and claims.id_character = _character_id) and claims.isDivorced = false;

    update
        players
    set
        players.total_money = players.total_money + character_exp
    where
        players.id = _player_id;

    select
        id,
        name,
        description,
        exp
    from
        v_characters_active
    where
        id = _character_id;

    commit;
end;

create or replace procedure get_players_rank(
    in _type enum('exp', 'money'),
    in _limit int unsigned
) begin
    declare error_message text;

    declare exit handler for sqlexception, not found
    begin
        rollback;

        if (not better_length(error_message)) then
            resignal;
        end if;

        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    start transaction;

    if (not better_length(_type) or (_type != 'exp' and _type != 'money')) then
        set error_message = concat('Jenis rank tidak valid: ', _type);
        signal sqlstate '45000';
    end if;

    if (_limit is not null or _limit != '') then
        if (_type = 'exp') then
            select
                *
            from
                v_exp_rank
            limit
                _limit;
        end if;

        if (_type = 'money') then
            select
                *
            from
                v_exp_rank
            limit
                _limit;
        end if;
    else
        if (_type = 'exp') then
            select
                *
            from
                v_exp_rank;
        end if;

        if (_type = 'money') then
            select
                *
            from
                v_exp_rank;
        end if;
    end if;
end;
-- === End Procedures ===

-- === Start Views ===
create or replace view v_admins
    as
select
    id, name, email, gender, username, bio, created_at, updated_at, deleted_at
from
    admins;

create or replace view v_admins_active
    as
select
    id, name, email, gender, username, bio, created_at, updated_at, deleted_at
from
    admins
where
    admins.deleted_at is null;

create or replace view v_admins_deleted
    as
select
    id, name, email, gender, username, bio, created_at, updated_at, deleted_at
from
    admins
where
    admins.deleted_at is not null;

create or replace view v_players
    as
select
    id, name, email, gender, username, bio, claim_limit, pull_limit, total_exp, total_money, created_at, updated_at, deleted_at
from
    players;

create or replace view v_players_active
    as
select
    id, name, email, gender, username, bio, claim_limit, pull_limit, total_exp, total_money, created_at, updated_at, deleted_at
from
    players
where
    players.deleted_at is null;

create or replace view v_players_deleted
    as
select
    id, name, email, gender, username, bio, claim_limit, pull_limit, total_exp, total_money, created_at, updated_at, deleted_at
from
    players
where
    players.deleted_at is not null;

create or replace view v_characters
    as
select
    id, name, description, exp, created_at, updated_at, deleted_at
from
    characters;

create or replace view v_characters_active
    as
select
    id, name, description, exp, created_at, updated_at, deleted_at
from
    characters
where
    characters.deleted_at is null;

create or replace view v_characters_deleted
    as
select
    id, name, description, exp, created_at, updated_at, deleted_at
from
    characters
where
    characters.deleted_at is not null;

create or replace view v_powers
    as
select
    id, name, description, price, created_at, updated_at, deleted_at
from
    powers;

create or replace view v_powers_active
    as
select
    id, name, description, price, created_at, updated_at, deleted_at
from
    powers
where
    powers.deleted_at is null;

create or replace view v_powers_deleted
    as
select
    id, name, description, price, created_at, updated_at, deleted_at
from
    powers
where
    powers.deleted_at is not null;

create or replace view v_exp_rank
    as
select
    id, name, username, total_exp
from
    players
where
    players.deleted_at is null
order by
    players.total_exp;

create or replace view v_money_rank
    as
select
    id, name, username, total_money
from
    players
where
    players.deleted_at is null
order by
    players.total_money;
-- === End Views ===

-- === Start Events ===
-- show variables like 'event_scheduler';
set global event_scheduler = on;

create or replace event
    reset_pull_limit
on schedule
    every 12 hour
do begin
    declare player_count int unsigned;
    set @pull_limit = 10;

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
            players.pull_limit = IF(
                exists (
                    select
                        1
                    from
                        player_powers
                    where
                        player_powers.id_player = players.id and player_powers.id_power = get_power_id_by_name('+1 pull')
                ),
                @pull_limit + 1, -- kalo ada +1
                @pull_limit -- kalo gada, normal
            )
        where
            players.pull_limit < @pull_limit;

    end if;
end;

create or replace event
    reset_claim_limit
on schedule
    every 24 hour
do begin
    declare player_count int unsigned;
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
                        player_powers.id_player = players.id and player_powers.id_power = get_power_id_by_name('+1 claim')
                ),
                @claim_limit + 1, -- kalo ada +1
                @claim_limit -- kalo gada normal
            )
        where
            players.claim_limit < claim_limit;
    end if;
end;

create or replace event
    reset_last_gacha_character
on schedule
    every 1 hour
do begin
    declare player_count int unsigned;

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
            players.last_gacha_character_id = null
        where
            players.last_gacha_character_id is not null;
    end if;
end;
-- show events;
-- === End Events ===
