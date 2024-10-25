use gacha;

create or replace procedure register(
    in _player_name varchar(255),
    in _player_username varchar(255),
    in _player_password text
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

    start transaction;

    if not validate_username_password(_player_username, _player_password, error_message) then
        signal sqlstate '45000';
    end if;

    if not validate_username_unique(_player_username, error_message) then
        signal sqlstate '45000';
    end if;

    insert into
        players
    set
        players.name = _player_name,
        players.username = _player_username,
        players.password = password(_player_password);

    select last_insert_id();

    commit;
end;

create or replace procedure login(
    in _username varchar(255),
    in _password text
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

    start transaction;

    if validate_existing_user(
        'admin',
        true,
        _username,
        _password,
        error_message
    ) then
        select
            admins.id,
            admins.username,
            admins.name
        from
            admins
        where
            admins.username = _username;
    else
        signal
            sqlstate '45000'
        set
            message_text = 'Username atau password salah';
    end if;

    if validate_existing_user(
        'player',
        true,
        _username,
        _password,
        error_message
    ) then
        select
            players.id,
            players.username,
            players.name
        from
            players
        where players.username = _username;
    else
        signal
            sqlstate '45000'
        set
            message_text = 'Username atau password salah';
    end if;

    commit;
end;

create or replace procedure add_new_admin(
    in _admin_name varchar(255),
    in _admin_username varchar(255),
    in _admin_password text
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

    start transaction;

    if not validate_username_password(_admin_username, _admin_password, error_message) then
        signal sqlstate '45000';
    end if;
    
    if not validate_username_unique(_admin_username, error_message) then
        signal sqlstate '45000';
    end if;

    insert into
        admins(name, username, password)
    values
        (_admin_name, _admin_username, password(_admin_password));

    select last_insert_id();

    commit;
end;

create or replace procedure add_new_character(
    in _character_name varchar(255),
    in _character_description text,
    in _character_exp bigint
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

    start transaction;

    if not validate_name_description(
            'character',
            _character_name,
            _character_description,
            error_message)
    then
        signal sqlstate '45000';
    end if;

    if _character_exp < 10 then
        signal sqlstate
            '45000'
        set
            message_text = 'Jumlah EXP minimal 10!';
    else
        insert into
            characters
        set
            characters.name = _character_name,
            characters.description = _character_description,
            characters.exp = _character_exp;
    end if;

    select last_insert_id();

    commit;
end;

create or replace procedure add_new_power(
    in _power_name varchar(255),
    in _power_description text,
    in _power_price bigint
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

    start transaction;

    if not validate_name_description(
            'power',
            _power_name,
            _power_description,
            error_message)
    then
        signal sqlstate '45000';
    end if;

    if _power_price < 10 then
        set error_message = 'Harga minimal 10!';
        signal sqlstate '45000';
    end if;

    insert into
        powers
    set
        powers.name = _power_name,
        powers.description = _power_description,
        powers.price = _power_price;

    select last_insert_id();

    commit;
end;

create or replace procedure edit_admin(
    in _new_admin_name varchar(255),
    in _old_admin_username varchar(255),
    in _new_admin_username varchar(255),
    in _new_admin_password text
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

    start transaction;

    if not exists(
        select
            1
        from
            admins
        where
            admins.username = _old_admin_username
    ) then
        set error_message = 'Username tidak ditemukan';
        signal sqlstate '45000';
    end if;

    if not validate_username_password(_new_admin_username, _new_admin_password, error_message) then
        signal sqlstate '45000';
    end if;

    if not validate_username_unique(_new_admin_username, error_message) then
        signal sqlstate '45000';
    end if;

    update
        admins
    set
        admins.name = _new_admin_name,
        admins.username = _new_admin_username,
        admins.password = password(_new_admin_password)
    where
        admins.username = _old_admin_username;

    commit;
end;

create or replace procedure edit_player(
    in _new_player_name varchar(255),
    in _old_player_username varchar(255),
    in _new_player_username varchar(255),
    in _new_player_password text
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

    start transaction;

    if not exists(
        select
            1
        from
            players
        where
            players.username = _old_player_username
    ) then
        set error_message = 'Username tidak ditemukan';
        signal sqlstate '45000';
    end if;

    if not validate_username_password(_new_player_username, _new_player_password, error_message) then
        signal sqlstate '45000';
    end if;

    if not validate_username_unique(_new_player_username, error_message) then
        signal sqlstate '45000';
    end if;

    update
        players
    set
        players.name = _new_player_name,
        players.username = _new_player_username,
        players.password = password(_new_player_password)
    where
        players.username = _old_player_username;

    commit;
end;

create or replace procedure edit_character(
    in _character_id int,
    in _new_character_name varchar(255),
    in _new_character_description text,
    in _new_character_exp bigint
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

    start transaction;

    if not exists(
        select
            1
        from
            characters
        where
            characters.id = _character_id
    ) then
        set error_message = 'Karakter tidak ditemukan';
        signal sqlstate '45000';
    end if;

    update
        characters
    set
        characters.name = _new_character_name,
        characters.description = _new_character_description,
        characters.exp = _new_character_exp
    where
        characters.id = _character_id;

    commit;
end;

create or replace procedure delete_admin(
    in _admin_username varchar(255),
    in _hard boolean
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

    start transaction;

    if not exists(
        select
            1
        from
            admins
        where
            admins.username = _admin_username
    ) then
        set error_message = 'Username tidak ditemukan';
        signal sqlstate '45000';
    end if;

    if _hard = true then
        update
            admins
        set
            admins.deleted_at = now()
        where
            admins.username = _admin_username;
    else
        delete from
            admins
        where
            admins.username = _admin_username;
    end if;

    commit;
end;

create or replace procedure delete_player(
    in _player_username varchar(255),
    in _hard boolean
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

    start transaction;

    if not exists(
        select
            1
        from
            players
        where
            players.username = _player_username
    ) then
        set error_message = 'Username tidak ditemukan';
        signal sqlstate '45000';
    end if;

    update
        players
    set
        players.deleted_at = now()
    where
        players.username = _player_username;

    commit;
end;

create or replace procedure search_admins(
    in _admin_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal
            sqlstate '45000'
        set
            message_text = 'Tidak dapat menemukan admin yang dicari';
    end;

    select
        id, name
    from
        admins
    where
        admins.name like concat('%', _admin_name, '%');
end;

create or replace procedure search_players(
    in _player_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal
            sqlstate '45000'
        set
            message_text = 'Tidak dapat menemukan player yang dicari';
    end;

    select
        id, name
    from
        players
    where
        players.name like concat('%', _player_name, '%');
end;

create or replace procedure search_characters(
    in _character_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Tidak dapat menemukan character yang dicari';
    end;

    select
        id, name
    from
        characters
    where
        characters.name like concat('%', _character_name, '%');
end;

create or replace procedure search_powers(
    in _power_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal
            sqlstate '45000'
        set
            message_text = 'Tidak dapat menemukan power yang dicari';
    end;

    select
        id, name
    from
        powers
    where
        powers.name like concat('%', _power_name, '%');
end;

create or replace procedure get_players(
    in with_deleted boolean,
    in only_deleted boolean
)
begin
    if with_deleted = true then
        select
            players.id,
            players.name,
            players.total_pull,
            players.claim_limit,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at,
            players.deleted_at
        from
            players;
    elseif only_deleted = true then
        select
            players.id,
            players.name,
            players.total_pull,
            players.claim_limit,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at,
            players.deleted_at
        from
            players
        where
            players.deleted_at is not null;
    else
        select
            players.id,
            players.name,
            players.total_pull,
            players.claim_limit,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at
        from
            players
        where
            players.deleted_at is null;
    end if;
end;

create or replace procedure get_characters(
    in with_deleted boolean,
    in only_deleted boolean
)
begin
    if with_deleted = true then
        select
            characters.id,
            characters.name,
            characters.description,
            characters.exp,
            characters.created_at,
            characters.updated_at,
            characters.deleted_at
        from
            characters;
    elseif only_deleted = true then
        select
            characters.id,
            characters.name,
            characters.description,
            characters.exp,
            characters.created_at,
            characters.updated_at,
            characters.deleted_at
        from
            characters
        where
            characters.deleted_at is not null;
    else
        select
            characters.id,
            characters.name,
            characters.description,
            characters.exp,
            characters.created_at,
            characters.updated_at
        from
            characters
        where
            characters.deleted_at is null;
    end if;
end;

create or replace procedure get_powers(
    in with_deleted boolean,
    in only_deleted boolean
)
begin
    if with_deleted = true then
        select
            powers.id,
            powers.name,
            powers.description,
            powers.price,
            powers.created_at,
            powers.updated_at,
            powers.deleted_at
        from
            powers;
    elseif only_deleted = true then
        select
            powers.id,
            powers.name,
            powers.description,
            powers.price,
            powers.created_at,
            powers.updated_at,
            powers.deleted_at
        from
            powers
        where
            powers.deleted_at is not null;
    else
        select
            powers.id,
            powers.name,
            powers.description,
            powers.price,
            powers.created_at,
            powers.updated_at
        from
            powers
        where
            powers.deleted_at is null;
    end if;
end;

create or replace procedure claim_character(
    in player_id varchar(255),
    in character_id varchar(255)
)
begin
    declare claim_exp bigint;

    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Ada data yang tidak dapat ditemukan!';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal sqlstate
            '45000'
        set
            message_text = 'Gagal claim character!';
    end;

    start transaction;

    select
        exp
    into
        claim_exp
    from
        characters
    where
        id = character_id;

    if (select claim_limit from players where players.id = player_id) = 0 then
        signal sqlstate
            '45000'
        set
            message_text = 'Player telah mencapai limit claim!';
    end if;

    if exists (
        select
            1
        from
            claims
        where
            claims.id_player = player_id and claims.id_character = character_id
    ) then
        update
            players
        set
            players.total_money = players.total_money + claim_exp,
            players.claim_limit = players.claim_limit - 1
        where
            players.id = player_id;

        commit;
    else
        insert into
            claims
        set
            claims.id_player = player_id,
            claims.id_character = character_id,
            claims.exp = claim_exp;

        update
            players
        set
            players.claim_limit = players.claim_limit - 1
        where
            players.id = player_id;

        commit;
    end if;
end;

create or replace procedure buy_power(
    player_id varchar(255),
    power_id varchar(255)
)
begin
    declare player_money bigint;
    declare power_price bigint;

    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Ada data yang tidak dapat ditemukan!';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal sqlstate
            '45000'
        set
            message_text = 'Transaksi gagal!';
    end;

    start transaction;

    if exists (
        select
            1
        from
            player_powers
        where
            player_powers.id_player = player_id and player_powers.id_power = power_id
    ) then
        signal sqlstate
            '45000'
        set
            message_text = 'Player telah memiliki power ini!';
    end if;

    select
        total_money, price
    into
        player_money, power_price
    from
        players
    join
        powers
    on
        powers.id = power_id
    where
        players.id = player_id;

    if player_money < power_price then
        signal sqlstate
            '45000'
        set
            message_text = 'Uang yang dimiliki player tidak cukup!';
    end if;

    insert into
        player_powers
    set
        player_powers.id_player = player_id,
        player_powers.id_power = power_id;

    commit;
end;

create or replace procedure sell_character(
    player_id varchar(255),
    character_id varchar(255)
)
begin
    declare chara_exp bigint;

    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Transaksi gagal!';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    select
        exp
    into
        chara_exp
    from
        claims
    where
        claims.id_player = player_id and claims.id_character = character_id;

    delete from
        claims
    where
        claims.id_player = player_id and claims.id_character = character_id;

    update
        players
    set
        players.total_exp = players.total_exp -  chara_exp,
        players.total_money = players.total_money + chara_exp
    where
        players.id = player_id;

    commit;
end;

create or replace procedure get_player_powers(
    in player_id varchar(255)
)
begin
    select
        powers.name,
        powers.description,
        powers.price
    from
        player_powers
    join
        powers
    on
        powers.id = player_powers.id_power
    where
        player_powers.id_player = player_id;
end;