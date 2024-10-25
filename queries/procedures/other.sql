use gacha;

create or replace procedure login(
    in _username varchar(255),
    in _password text
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

create or replace procedure claim_character(
    in player_id varchar(255),
    in character_id varchar(255)
)
begin
    declare claim_exp bigint;
    declare error_message text;

    declare exit handler for not found
    begin
        rollback;
        signal sqlstate '02000'
        set message_text = 'Ada data yang tidak dapat ditemukan';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Gagal claim karakter';

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
        set error_message = 'Player sudah mencapat limit claim';
        signal sqlstate '45000';
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
    declare error_message text;

    declare exit handler for not found
    begin
        rollback;
        signal sqlstate '02000'
        set message_text = 'Ada data yang tidak dapat ditemukan';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Gagal claim karakter';

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
    declare error_message text;

    declare exit handler for not found
    begin
        rollback;
        signal sqlstate '02000'
        set message_text = 'Ada data yang tidak dapat ditemukan';
    end;

    declare exit handler for sqlexception
    begin
        rollback;
        signal
            sqlstate '45000'
        set
            message_text = error_message;
    end;

    set error_message = 'Gagal claim karakter';

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
