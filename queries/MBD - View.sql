use gacha;

create or replace view
    players_characters
as
    select
        players.name as player_name,
        characters.name as character_name,
        characters.description as character_description,
        claims.exp as character_exp
    from
        claims
    join
        players
    on
         players.id = claims.id_player
    join
        characters
    on
        characters.id = claims.id_character;

create or replace view
    players_powers
as
    select
        players.name as player_name,
        powers.name as power_name,
        powers.description as power_description
    from
        player_powers
    join
        players
    on
         players.id = player_powers.id_player
    join
        powers
    on
        powers.id = player_powers.id_power;
