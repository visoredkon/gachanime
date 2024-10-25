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
    in _player_username varchar(255),
    in _character_id varchar(255)
)
begin
    declare player_id int;
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

    if not validate_existing_user(
        'player',
        null,
        _player_username,
        null,
        error_message
    ) then
        signal
            sqlstate '02000'
        set
            message_text = error_message;
    end if;

    select
        players.id
    into
        player_id
    from
        players
    where
        players.username = _player_username;

    select
        exp
    into
        claim_exp
    from
        characters
    where
        id = _character_id;

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
            claims.id_player = player_id and claims.id_character = _character_id
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
            claims.id_character = _character_id,
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
    _player_username varchar(255),
    _power_id varchar(255)
)
begin
    declare player_id int;
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

    if not validate_existing_user(
        'player',
        null,
        _player_username,
        null,
        error_message
    ) then
        signal
            sqlstate '02000'
        set
            message_text = error_message;
    end if;

    select
        players.id
    into
        player_id
    from
        players
    where
        players.username = _player_username;

    if exists (
        select
            1
        from
            player_powers
        where
            player_powers.id_player = player_id and player_powers.id_power = _power_id
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
        powers.id = _power_id
    where
        players.id = player_id;

    if player_money < power_price then
        set error_message = 'Uang yang dimiliki player tidak cukup!';
        signal sqlstate '45000';
    end if;

    insert into
        player_powers
    set
        player_powers.id_player = player_id,
        player_powers.id_power = _power_id;

    commit;
end;

create or replace procedure sell_character(
    _player_username varchar(255),
    _character_id varchar(255)
)
begin
    declare player_id int;
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

    if not validate_existing_user(
        'player',
        null,
        _player_username,
        null,
        error_message
    ) then
        signal
            sqlstate '02000'
        set
            message_text = error_message;
    end if;

    select
        players.id
    into
        player_id
    from
        players
    where
        players.username = _player_username;

    select
        exp
    into
        chara_exp
    from
        claims
    where
        claims.id_player = player_id and claims.id_character = _character_id;

    delete from
        claims
    where
        claims.id_player = player_id and claims.id_character = _character_id;

    update
        players
    set
        players.total_exp = players.total_exp -  chara_exp,
        players.total_money = players.total_money + chara_exp
    where
        players.id = player_id;

    commit;
end;
