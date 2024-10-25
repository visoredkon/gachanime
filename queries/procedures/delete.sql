use gacha;

create or replace procedure delete_admin(
    in _admin_username varchar(255),
    in _soft boolean
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
            admins.username = _admin_username
    ) then
        set error_message = 'Username tidak ditemukan';
        signal sqlstate '02000';
    end if;

    if _soft then
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
    in _soft boolean
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
            players.username = _player_username
    ) then
        set error_message = 'Username tidak ditemukan';
        signal sqlstate '02000';
    end if;

    if _soft then
        update
            players
        set
            players.deleted_at = now()
        where
            players.username = _player_username;
    else
        delete from
            players
        where
            players.username = _player_username;
    end if;

    commit;
end;

create or replace procedure delete_character(
    in _character_id varchar(255),
    in _soft boolean
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

    if _soft then
        update
            characters
        set
            characters.deleted_at = now()
        where
            characters.id = _character_id;
    else
        delete from
            characters
        where
            characters.id = _character_id;
    end if;

    commit;
end;

create or replace procedure delete_power(
    in _power_id varchar(255),
    in _soft boolean
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

    if _soft then
        update
            powers
        set
            powers.deleted_at = now()
        where
            powers.id = _power_id;
    else
        delete from
            powers
        where
            powers.id = _power_id;
    end if;

    commit;
end;
