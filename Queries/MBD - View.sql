create or replace view
    players_characters
as
    select
        players.name,
        characters.name,
        characters.description,
        claims.exp
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
        players.name,
        powers.name,
        powers.description
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
