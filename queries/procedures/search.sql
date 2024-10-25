use gacha;

create or replace procedure search_admins(
    in _admin_name varchar(255)
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

    select
        id, name
    from
        admins
    where
        admins.name like concat('%', _admin_name, '%');

    commit;
end;

create or replace procedure search_admins_by_id(
    in _admin_id int
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

    select
        id, name
    from
        admins
    where
        admins.id = _admin_id;

    commit;
end;

create or replace procedure search_players(
    in _player_name varchar(255)
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

    select
        id, name
    from
        players
    where
        players.name like concat('%', _player_name, '%');

    commit;
end;

create or replace procedure search_players_by_id(
    in _player_id int
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

    select
        id, name
    from
        players
    where
        players.id = _player_id;

    commit;
end;

create or replace procedure search_characters(
    in _character_name varchar(255)
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

    select
        id, name
    from
        characters
    where
        characters.name like concat('%', _character_name, '%');

    commit;
end;

create or replace procedure search_characters_by_id(
    in _character_id int
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

    select
        id, name
    from
        characters
    where
        characters.id = _character_id;

    commit;
end;

create or replace procedure search_powers(
    in _power_name varchar(255)
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

    select
        id, name
    from
        powers
    where
        powers.name like concat('%', _power_name, '%');

    commit;
end;

create or replace procedure search_powers_by_id(
    in _power_id int
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

    select
        id, name
    from
        powers
    where
        powers.id = _power_id;

    commit;
end;
