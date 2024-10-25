use gacha;

call gacha.add_new_admin(
    'Kami',
    'kami',
    '12345678'
);

call gacha.edit_admin(
    'Kami sama',
     'kami',
     'kaminew',
     '12345678'
);

call gacha.register(
    'Pahril',
    'player1',
    '12345678'
);

call gacha.login('player1', '12345678');

call gacha.get_players(true, null);

call gacha.add_new_character(
    'Kaguya Shinomiya',
    'Cakep parah',
    100
);

call gacha.add_new_character(
    'Frieren',
    'Hanya milik Himmel sang Pahlawan',
    100
);

call gacha.add_new_character(
    'Ram',
    'Agak freak, tapi okelah.',
    100
);

call gacha.add_new_character(
    'Rem',
    'Rem? Siapa ya? Wait, kenapa aku buat karakter yang namanya Rem? Rem te.. dare no koto?',
    100
);

call gacha.add_new_character(
    'Megumin',
    'Explosionnnnnnn!',
    100
);

call gacha.add_new_power(
    '+1 pull',
    'Memberikan +1 pull',
    50
);

call gacha.add_new_power(
    '+1 claim',
    'Memberikan +1 claim',
    100
);

set @rand_char = gacha.get_random_character('player1');

call gacha.claim_character(
    'player1',
     @rand_char
);

select gacha.get_random_character('player1');

select gacha.count_player_characters('player1');

select gacha.count_player_powers('player1');

call gacha.get_player_characters('player1');

call gacha.get_player_powers('player1');

select * from gacha.players;

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
