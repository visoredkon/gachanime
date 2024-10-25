use gacha;

create or replace procedure edit_admin(
    in _new_admin_name varchar(255),
    in _old_admin_username varchar(255),
    in _new_admin_username varchar(255),
    in _new_admin_password text
)
begin
    declare error_message text;

    declare exit handler for not found
    begin
        rollback;
        signal sqlstate '02000'
        set message_text = 'Data tidak ditemukan';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Gagal melakukan transaksi';

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
        signal sqlstate '02000';
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

    declare exit handler for not found
    begin
        rollback;
        signal sqlstate '02000'
        set message_text = 'Data tidak ditemukan';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Gagal melakukan transaksi';

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
        signal sqlstate '02000';
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

    declare exit handler for not found
    begin
        rollback;
        signal sqlstate '02000'
        set message_text = 'Data tidak ditemukan';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Gagal melakukan transaksi';

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
        signal sqlstate '02000';
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

create or replace procedure edit_power(
    in _power_id int,
    in _new_power_name varchar(255),
    in _new_power_description text,
    in _new_power_price bigint
)
begin
    declare error_message text;

    declare exit handler for not found
    begin
        rollback;
        signal sqlstate '02000'
        set message_text = 'Data tidak ditemukan';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Gagal melakukan transaksi';
    
    start transaction;

    if not exists(
        select
            1
        from
            powers
        where
            powers.id = _power_id
    ) then
        set error_message = 'Power tidak ditemukan';
        signal sqlstate '02000';
    end if;

    update
        powers
    set
        powers.name = _new_power_name,
        powers.description = _new_power_description,
        powers.price = _new_power_price
    where
        powers.id = _power_id;

    commit;
end;
