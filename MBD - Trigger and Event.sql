use gacha;

create trigger
    update_exp_after_claim
after insert on
    claims
for each row
begin
    update
        players
    set
        players.total_exp = players.total_exp + new.exp
    where
        players.id = new.id_player;
end;

create trigger
    update_money_after_bought
after insert on
    player_powers
for each row
begin
    declare power_price bigint;

    select
        price
    into
        power_price
    from
        powers
    where
        powers.id = NEW.id_power;

    update
        players
    set
        players.total_money = players.total_money - power_price
    where
        players.id = NEW.id_player;
end;

-- show variables like 'event_scheduler';

set global event_scheduler = on;

create event
    reset_total_pull
on schedule
    every 1 day
do begin
    declare player_count int;

    select count(id) into player_count from players;

    if player_count > 0 then
        update
            players
        set
            players.total_pull = IF(
                exists (
                    select
                        1
                    from
                        player_powers
                    where
                        player_powers.id_player = players.id and player_powers.id_power = 'power1'
                ),
                11, -- kalo ada +1
                10 -- kalo gada normal
            );
    end if;
end;

create event
    reset_claim_limit
on schedule
    every 1 day
do begin
    declare player_count int;

    select count(id) into player_count from players;

    if player_count > 0 then
        update
            players
        set
            players.claim_limit = IF(
                exists (
                    select
                        1
                    from
                        player_powers
                    where
                        player_powers.id_player = players.id and player_powers.id_power = 'power2'
                ),
                2, -- kalo ada +1
                1 -- kalo gada normal
            );
    end if;
end;

-- show events;
