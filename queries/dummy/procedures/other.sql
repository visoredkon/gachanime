use gacha;

call gacha.login('player1', '12345678');

set @rand_char = gacha.get_random_character('kazuma');

call gacha.claim_character(
    'kazuma',
     @rand_char
);

call gacha.buy_power(
    'player1',
    'power1'
);

call gacha.buy_power(
    'player1',
    'power1'
);

call gacha.sell_character(
    'player1',
    'chara2'
);

-- SHOW VARIABLES LIKE 'event_scheduler';
