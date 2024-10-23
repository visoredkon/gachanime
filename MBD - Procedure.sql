use gacha;

create procedure add_new_admin(
    in admin_id varchar(255),
    in admin_name varchar(255),
    in admin_username varchar(255),
    in admin_password text
)
begin
    if length(admin_username) < 3 or length(admin_username) > 10 then
        signal sqlstate
            '45000'
        set
            message_text = 'username harus memiliki minimal 3 karakter dan maksimal 10 karakter.';
    elseif length(admin_password) < 8 then
        signal sqlstate
            '45000'
        set
            message_text = 'password harus lebih dari 8 karakter.';
    else
        if exists (
            select
                1
            from
                admins
            join
                players
            where
                admins.username = admin_username or players.username = admin_username
        ) then
            signal sqlstate '45000'
            set message_text = 'Username telah digunakan!.';
        else
            insert into
                admins(id, name, username, password)
            values
                (admin_id, admin_name, admin_username, admin_password);
        end if;
    end if;
end;

create procedure add_new_player(
    in player_id varchar(255),
    in player_name varchar(255),
    in player_username varchar(255),
    in player_password text
)
begin
    if length(player_username) < 3 or length(player_username) > 10 then
        signal sqlstate
            '45000'
        set
            message_text = 'Username harus memiliki minimal 3 karakter dan maksimal 10 karakter!';
    elseif length(player_password) < 8 then
        signal sqlstate
            '45000'
        set
            message_text = 'Panjang password harus lebih dari 8 karakter!';
    else
        if exists (
            select
                1
            from
                players
            join
                admins
            where
                players.username = player_username or admins.username = player_username
        ) then
            signal sqlstate '45000'
            set message_text = 'Username telah digunakan!.';
        else
            insert into
                players
            set
                players.id = player_id,
                players.name = player_name,
                players.username = player_username,
                players.password = player_password;
        end if;
    end if;
end;

create procedure add_new_character(
    in character_id varchar(255),
    in character_name varchar(255),
    in character_description text,
    in character_exp bigint
)
begin
    if length(character_name) < 3 then
        signal sqlstate
            '45000'
        set
            message_text = 'Nama karakter minimal 3 huruf!';
    elseif length(character_description) < 10 then
        signal sqlstate
            '45000'
        set
            message_text = 'Deskripsi karakter harus lebih dari 10 huruf!';
    elseif character_exp < 10 then
        signal sqlstate
            '45000'
        set
            message_text = 'Jumlah EXP minimal 10!';
    else
        insert into
            characters
        set
            characters.id = character_id,
            characters.name = character_name,
            characters.description = character_description,
            characters.exp = character_exp;
    end if;
end;

create procedure add_new_power(
    in power_id varchar(255),
    in power_name varchar(255),
    in power_description text,
    in power_price bigint
)
begin
    if length(power_name) < 3 then
        signal sqlstate
            '45000'
        set
            message_text = 'Nama power minimal 3 huruf!';
    elseif length(power_description) < 10 then
        signal sqlstate
            '45000'
        set
            message_text = 'Deskripsi power harus lebih dari 10 huruf!';
    elseif power_price < 10 then
        signal sqlstate
            '45000'
        set
            message_text = 'Harga minimal 10!';
    else
        insert into
            powers
        set
            powers.id = power_id,
            powers.name = power_name,
            powers.description = power_description,
            powers.price = power_price;
    end if;
end;

create procedure search_admins(
    in admin_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Tidak dapat menemukan admin!';
    end;

    select
        id, name
    from
        admins
    where
        admins.name like concat('%', admin_name, '%');
end;

create procedure search_players(
    in player_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Tidak dapat menemukan admin!';
    end;

    select
        id, name
    from
        players
    where
        players.name like concat('%', player_name, '%');
end;

create procedure search_characters(
    in character_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Tidak dapat menemukan character!';
    end;

    select
        id, name
    from
        characters
    where
        characters.name like concat('%', character_name, '%');
end;

create procedure search_powers(
    in power_name varchar(255)
)
begin
    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Tidak dapat menemukan admin!';
    end;

    select
        id, name
    from
        powers
    where
        powers.name like concat('%', power_name, '%');
end;

create procedure get_player_powers(
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

create procedure claim_character(
    in claim_id varchar(255),
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
            claims.id = claim_id,
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

create procedure buy_power(
    player_power_id varchar(255),
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
        player_powers.id = player_power_id,
        player_powers.id_player = player_id,
        player_powers.id_power = power_id;

    commit;
end;

create procedure sell_character(
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