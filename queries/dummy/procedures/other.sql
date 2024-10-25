use gacha;

call gacha.login('player1', '12345678');

set @rand_char = gacha.get_random_character('kazuma');

call gacha.claim_character(
    'kazuma',
    @rand_char
);

call gacha.buy_power(
    'kazuma',
    '1'
);

call gacha.buy_power(
    'kazuma',
    '2'
);

call gacha.get_player_characters(
    'kazuma'
);

call gacha.sell_character(
    'kazuma',
    '10'
);

call gacha.get_player_powers(
    'kazuma'
);

-- SHOW VARIABLES LIKE 'event_scheduler';
