use gacha;

create or replace procedure get_admins(
    in _with_deleted boolean,
    in _only_deleted boolean
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

    if _with_deleted = true then
        select
            admins.id,
            admins.name,
            admins.created_at,
            admins.updated_at,
            admins.deleted_at
        from
            admins;
    elseif _only_deleted = true then
        select
            admins.id,
            admins.name,
            admins.created_at,
            admins.updated_at,
            admins.deleted_at
        from
            admins
        where
            admins.deleted_at is not null;
    else
        select
            admins.id,
            admins.name,
            admins.created_at,
            admins.updated_at
        from
            admins
        where
            admins.deleted_at is null;
    end if;

    commit;
end;

create or replace procedure get_players(
    in _with_deleted boolean,
    in _only_deleted boolean
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

    if _with_deleted = true then
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
    elseif _only_deleted = true then
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

    commit;
end;

create or replace procedure get_characters(
    in _with_deleted boolean,
    in _only_deleted boolean
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

    if _with_deleted = true then
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
    elseif _only_deleted = true then
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

    commit;
end;

create or replace procedure get_powers(
    in _with_deleted boolean,
    in _only_deleted boolean
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

    if _with_deleted = true then
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
    elseif _only_deleted = true then
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

    commit;
end;

create or replace procedure get_player_characters(
    in _player_username varchar(255)
)
begin
    declare player_id int;
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

    if validate_existing_user(
        'player',
        null,
        _player_username,
        null,
        error_message
    ) then
        select
            players.id
        into
            player_id
        from
            players
        where
            players.username = _player_username;

        select
            characters.id,
            characters.name,
            characters.description,
            characters.exp
        from
            claims
        join
            characters
        on
            characters.id = claims.id_character
        where
            claims.id_player = player_id;
    end if;

    commit;
end;


create or replace procedure get_player_powers(
    in _player_username varchar(255)
)
begin
    declare player_id int;
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

    if validate_existing_user(
        'player',
        null,
        _player_username,
        null,
        error_message
    ) then
        select
            players.id
        into
            player_id
        from
            players
        where
            players.username = _player_username;

        select
            powers.id,
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
    end if;

    commit;
end;

create or replace procedure get_player_exp_rank(
    in _with_deleted boolean,
    in _only_deleted boolean
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

    if _with_deleted = true then
        select
            players.id,
            players.name,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at,
            players.deleted_at
        from
            players
        order by
            players.total_exp;
    elseif _only_deleted = true then
        select
            players.id,
            players.name,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at,
            players.deleted_at
        from
            players
        where
            players.deleted_at is not null
        order by
            players.total_exp;
    else
        select
            players.id,
            players.name,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at
        from
            players
        where
            players.deleted_at is null
        order by
            players.total_exp;
    end if;

    commit;
end;

create or replace procedure get_player_money_rank(
    in _with_deleted boolean,
    in _only_deleted boolean
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

    if _with_deleted = true then
        select
            players.id,
            players.name,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at,
            players.deleted_at
        from
            players
        order by
            players.total_money;
    elseif _only_deleted = true then
        select
            players.id,
            players.name,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at,
            players.deleted_at
        from
            players
        where
            players.deleted_at is not null
        order by
            players.total_money;
    else
        select
            players.id,
            players.name,
            players.total_exp,
            players.total_money,
            players.created_at,
            players.updated_at
        from
            players
        where
            players.deleted_at is null
        order by
            players.total_money;
    end if;

    commit;
end;