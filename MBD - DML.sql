use gacha;

call gacha.add_new_admin(
    'admin1',
    'Kami',
    'kami',
    '12345678'
);

call gacha.add_new_player(
    'player1',
    'Pahril',
    'pahril',
    '12345678'
);

call gacha.add_new_character(
    'chara1',
    'Kaguya Shinomiya',
    'Cakep parah',
    100
);

call gacha.add_new_character(
    'chara2',
    'Frieren',
    'Hanya milik Himmel sang Pahlawan',
    100
);

call gacha.add_new_character(
    'chara3',
    'Ram',
    'Agak freak, tapi okelah.',
    100
);

call gacha.add_new_character(
    'chara4',
    'Rem',
    'Rem? Siapa ya? Wait, kenapa aku buat karakter yang namanya Rem? Rem te.. dare no koto?',
    100
);

call gacha.add_new_character(
    'chara5',
    'Megumin',
    'Explosionnnnnnn!',
    100
);

call gacha.add_new_power(
    'power1',
    '+1 pull',
    'Memberikan +1 pull',
    50
);

call gacha.add_new_power(
    'power2',
    '+1 claim',
    'Memberikan +1 claim',
    100
);

set @rand_char = gacha.get_random_character('player1');

call gacha.claim_character(
    'claim2',
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
    'playerpower1',
    'player1',
    'power1'
);

call gacha.buy_power(
    'playerpower2',
    'player1',
    'power1'
);

call gacha.sell_character(
    'player1',
    'chara2'
);

SHOW VARIABLES LIKE 'event_scheduler';
