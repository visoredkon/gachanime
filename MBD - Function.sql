use gacha;

create function get_random_character(
    in player_id varchar(255)
)
returns varchar(255)
begin
    declare character_id varchar(255);

    declare exit handler for not found
    begin
        signal sqlstate '45000'
        set message_text = 'Tidak dapat menemukan player!';
    end;

    if (select total_pull from players where players.id = player_id) = 0 then
        signal sqlstate
            '45000'
        set
            message_text = 'Player telah mencapai limit pull!';
    end if;

    update
        players
    set
        players.total_pull = players.total_pull - 1
    where
        players.id = player_id;

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

create function count_player_characters(
    in player_id varchar(255)
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
        claims.id_player = player_id;

    return total_characters;
end;

create function count_player_powers(
    in player_id varchar(255)
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
        player_powers.id_player = player_id;

    return total_powers;
end;

create procedure get_player_characters(
    in player_id varchar(255)
)
begin
    select
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
end;