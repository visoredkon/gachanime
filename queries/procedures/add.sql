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

    set error_message = 'Gagal melakukan register';

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

    set error_message = 'Gagal melakukan transaksi';

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

    set error_message = 'Gagal melakukan transaksi';

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

    set error_message = 'Gagal melakukan transaksi';

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
