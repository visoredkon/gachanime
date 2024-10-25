use gacha;

create or replace function validate_username_password(
    in _username varchar(255),
    in _password text,
    out _error_message text
)
returns boolean
begin
    set _error_message = '';

    if length(_username) < 3 or length(_username) > 11 then
        set _error_message = 'Panjang username tidak boleh kurang dari 3 huruf atau lebih dari 10 huruf';
        return false;
    end if;

    if length(_password) < 8 then
        set _error_message = 'Panjang password tidak boleh kurang dari 8 karakter';
        return false;
    end if;

    return true;
end;

create or replace function validate_username_unique(
    in _username varchar(255),
    out _error_message text
)
returns boolean
begin
    set _error_message = '';

    if exists(
            select
                1
            from
                admins
            where
                admins.username = _username
    ) or exists(
            select
                1
            from
                players
            where
                players.username = _username
    ) then
        set _error_message = 'Username tidak tersedia';
        return false;
    end if;

    return true;
end;

create or replace function validate_name_description(
    in _type varchar(255),
    in _name varchar(255),
    in _description varchar(255),
    out _error_message text
)
returns boolean
begin
    set _error_message = '';

    if (_type <> 'character') and (_type <> 'power') then
        set _error_message = 'Tipe tidak valid';
        return false;
    end if;

    if length(_name) < 3 then
        set _error_message = concat('Nama ', _type, 'minimal 3 karakter');
        return false;
    end if;

    if length(_description) < 10 then
        set _error_message = concat('Deskripsi ', _type, 'harus lebih dari 10 karakter');
        return false;
    end if;

    return true;
end;

create or replace function validate_existing_user(
    in _type varchar(255),
    in _is_auth boolean,
    in _username varchar(255),
    in _password text,
    out _error_message text
)
returns boolean
begin
    set _error_message = '';

    if (_type <> 'admin') and (_type <> 'player') then
        set _error_message = 'Tipe tidak valid';
        return false;
    end if;

    if (_type = 'admin') then
        if _is_auth then
            if exists(
                select
                    1
                from
                    admins
                where
                    admins.username = _username and admins.deleted_at is null and admins.password = password(_password)
            ) then
                return true;
            end if;

            set _error_message = 'Username tidak ditemukan';
            return false;
        end if;

        if exists(
            select
                1
            from
                admins
            where
                admins.username = _username and admins.deleted_at is null
        ) then
            return true;
        end if;

        set _error_message = 'Username tidak ditemukan';
        return false;
    end if;

    if (_type = 'player') then
        if _is_auth then
            if exists(
                select
                    1
                from
                    players
                where
                    players.username = _username and players.deleted_at is null and players.password = password(_password)
            ) then
                return true;
            end if;

            set _error_message = 'Username tidak ditemukan';
            return false;
        end if;

        if exists(
            select
                1
            from
                players
            where
                players.username = _username and players.deleted_at is null
        ) then
            return true;
        end if;

        set _error_message = 'Username tidak ditemukan';
        return false;
    end if;
end;

create or replace function get_random_character(
    in _player_id varchar(255)
)
returns varchar(255)
begin
    declare character_id varchar(255);

    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Tidak dapat menemukan player!';
    end;

    if (select total_pull from players where players.id = _player_id) = 0 then
        signal
            sqlstate '45000'
        set
            message_text = 'Player telah mencapai limit pull!';
    end if;

    update
        players
    set
        players.total_pull = players.total_pull - 1
    where
        players.id = _player_id;

    select
        id
    into
        character_id
    from
        characters
    order by
        rand()
    limit 1;

    return character_id;
end;

create or replace function get_power_id(
    in _power_name varchar(255)
)
returns int
begin
    declare power_id int;

    select
        id
    into
        power_id
    from
        powers
    where
        powers.name = _power_name;

    return power_id;
end;

create or replace function count_player_characters(
    in _player_id varchar(255)
)
returns int
begin
    declare total_characters int;

    select
        count(id_player)
    into
        total_characters
    from
        claims
    where
        claims.id_player = _player_id;

    return total_characters;
end;

create or replace function count_player_powers(
    in _player_id varchar(255)
)
returns int
begin
    declare total_powers int;

    select
        count(id_player)
    into
        total_powers
    from
        player_powers
    where
        player_powers.id_player = _player_id;

    return total_powers;
end;
