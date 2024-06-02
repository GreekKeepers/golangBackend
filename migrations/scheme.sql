DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Coin CASCADE;
DROP TABLE IF EXISTS Amount CASCADE;
DROP TABLE IF EXISTS Game CASCADE;
DROP TABLE IF EXISTS UserSeed CASCADE;
DROP TABLE IF EXISTS ServerSeed CASCADE;
DROP TABLE IF EXISTS Bet CASCADE;
DROP TABLE IF EXISTS GameState CASCADE;
DROP TABLE IF EXISTS Achievement CASCADE;
DROP TYPE IF EXISTS oauth_provider;
DROP TABLE IF EXISTS Referal CASCADE;
DROP TABLE IF EXISTS Referals CASCADE;

CREATE TYPE oauth_provider AS ENUM ('local', 'google', 'facebook', 'twitter');

CREATE TABLE IF NOT EXISTS Users(
    id BIGSERIAL PRIMARY KEY,
    registration_time TIMESTAMP DEFAULT NOW(),

    login TEXT NOT NULL UNIQUE,
    username TEXT NOT NULL,
    password char(128) NOT NULL,
    provider oauth_provider DEFAULT 'local',
    user_level BIGINT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS Achievement(
    id BIGSERIAL PRIMARY KEY,

    achieving_time TIMESTAMP DEFAULT NOW(),
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,

    achievement_name TEXT NOT NULL,
    level_cost SMALLINT NOT NULL
);

CREATE TABLE IF NOT EXISTS RefreshToken (
    token TEXT PRIMARY KEY,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    creation_date TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Coin(
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    price NUMERIC(1000, 4) NOT NULL
);

CREATE TABLE IF NOT EXISTS Amount(
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    coin_id BIGSERIAL NOT NULL REFERENCES Coin(id) ON DELETE CASCADE,

    amount NUMERIC(1000, 4) DEFAULT 0
);

CREATE UNIQUE INDEX amount_unique_idx ON Amount(user_id, coin_id);

CREATE TABLE IF NOT EXISTS Game(
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,

    parameters TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS UserSeed(
    id BIGSERIAL PRIMARY KEY,
    --relative_id BIGINT NOT NULL,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,

    user_seed char(64) NOT NULL
);

CREATE UNIQUE INDEX user_seed_unique_idx ON UserSeed(user_id, user_seed);

CREATE TABLE IF NOT EXISTS ServerSeed(
    id BIGSERIAL PRIMARY KEY,
    --relative_id BIGINT NOT NULL,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,

    server_seed char(128) NOT NULL,
    revealed boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS Bet(
    id BIGSERIAL PRIMARY KEY,
    --relative_id BIGINT,
    timestamp TIMESTAMP DEFAULT NOW(),
    amount NUMERIC(1000, 4),
    profit NUMERIC(1000, 4),
    num_games INTEGER NOT NULL,
    outcomes TEXT NOT NULL,
    profits TEXT NOT NULL,

    bet_info TEXT NOT NULL,
    state TEXT,
    uuid TEXT NOT NULL,

    game_id BIGSERIAL NOT NULL REFERENCES Game(id) ON DELETE CASCADE,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    coin_id BIGSERIAL NOT NULL REFERENCES Coin(id) ON DELETE CASCADE,
    userseed_id BIGSERIAL NOT NULL REFERENCES UserSeed(id) ON DELETE CASCADE,
    serverseed_id BIGSERIAL NOT NULL REFERENCES ServerSeed(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Payout(
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT NOW(),
    amount NUMERIC(1000, 4),
    status INTEGER DEFAULT 0,
    additional_data TEXT NOT NULL,

    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS GameState(
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT NOW(),
    amount NUMERIC(1000, 4),

    bet_info TEXT NOT NULL,
    state TEXT NOT NULL,
    uuid TEXT NOT NULL,

    game_id BIGSERIAL NOT NULL REFERENCES Game(id) ON DELETE CASCADE,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    coin_id BIGSERIAL NOT NULL REFERENCES Coin(id) ON DELETE CASCADE,
    userseed_id BIGSERIAL NOT NULL REFERENCES UserSeed(id) ON DELETE CASCADE,
    serverseed_id BIGSERIAL NOT NULL REFERENCES ServerSeed(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX state_unique_idx ON GameState(game_id, user_id, coin_id, userseed_id, serverseed_id);


CREATE TABLE IF NOT EXISTS Invoice(
    id TEXT NOT NULL PRIMARY KEY,
    merchant_id TEXT NOT NULL,
    order_id TEXT NOT NULL UNIQUE,
    create_date TIMESTAMP DEFAULT NOW(),
    status INTEGER NOT NULL,
    pay_url TEXT NOT NULL,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    amount NUMERIC(1000, 4),
    currency TEXT NOT NULL
);

CREATE TYPE billine_status AS ENUM ('pending', 'success', 'failed' );

CREATE TABLE IF NOT EXISTS InvoiceBilline(
    id TEXT NOT NULL PRIMARY KEY,
    merchant_id TEXT NOT NULL,
    order_id TEXT NOT NULL UNIQUE,
    create_date TIMESTAMP DEFAULT NOW(),
    status billine_status DEFAULT 'pending',
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    amount NUMERIC(1000, 4),
    currency TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS TokensToTrack(
    id TEXT NOT NULL PRIMARY KEY,
    tokens TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Referal(
    id BIGSERIAL PRIMARY KEY,
    refer_to BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE UNIQUE,
    link_name VARCHAR(8) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Referals(
    id BIGSERIAL PRIMARY KEY,
    refer_to BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    refer_name BIGSERIAL NOT NULL REFERENCES Referal(id) ON DELETE CASCADE,
    referal BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    create_date TIMESTAMP DEFAULT NOW()
);
CREATE UNIQUE INDEX referals_unique_idx ON Referals(refer_to, referal);

-- Partner
CREATE TYPE PartnerProgram AS ENUM(
    'firstMonth',
    'novice',
    'beginner',
    'intermediate',
    'advanced',
    'pro',
    'god'
);

CREATE TABLE IF NOT EXISTS Partner(
    --id BIGSERIAL PRIMARY KEY,
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    country TEXT NOT NULL,
    traffic_source TEXT NOT NULL,
    users_amount_a_month BIGINT NOT NULL,
    program PartnerProgram NOT NULL,
    is_verified boolean NOT NULL,
    login varchar(25) UNIQUE,
    password char(128) NOT NULL,
    registration_time TIMESTAMP DEFAULT Now(),
    language TEXT
);

CREATE TABLE IF NOT EXISTS PartnerContact(
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    partner_id BIGSERIAL NOT NULL REFERENCES Partner(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS PartnerSite(
    internal_id BIGSERIAL PRIMARY KEY, 
    id BIGINT NOT NULL,
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    
    partner_id BIGSERIAL NOT NULL REFERENCES Partner(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX partnersite_id_unique_idx ON PartnerSite(id, partner_id);

CREATE TABLE IF NOT EXISTS SiteSubId(
    internal_id BIGSERIAL PRIMARY KEY, 
    id BIGINT NOT NULL,
    name TEXT NOT NULL,
    url TEXT,
    
    site_id BIGINT NOT NULL REFERENCES PartnerSite(internal_id) ON DELETE CASCADE,
    partner_id BIGSERIAL NOT NULL REFERENCES Partner(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX subid_unique_idx ON SiteSubId(id, site_id);

CREATE TABLE IF NOT EXISTS RefClick(
    id BIGSERIAL PRIMARY KEY,
    --clicks BIGINT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    
    --sub_id BIGINT NOT NULL,
    sub_id_internal BIGINT NOT NULL REFERENCES SiteSubId(internal_id) ON DELETE CASCADE,
    partner_id BIGSERIAL NOT NULL REFERENCES Partner(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ConnectedUsers(
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,

    --sub_id BIGINT NOT NULL,
    sub_id_internal BIGINT NOT NULL REFERENCES SiteSubId(internal_id) ON DELETE CASCADE,
    partner_id BIGSERIAL NOT NULL REFERENCES Partner(id) ON DELETE CASCADE,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Withdrawal(
    id BIGSERIAL PRIMARY KEY,
    start_time TIMESTAMP DEFAULT NOW(),

    token varchar(20) NOT NULL,
    network varchar(30) NOT NULL,
    wallet_address varchar(200) NOT NULL,
    status TEXT DEFAULT 'waiting', --waiting/accepted/rejected,
    amount TEXT NOT NULL,

    partner_id BIGSERIAL NOT NULL REFERENCES Partner(id) ON DELETE CASCADE
);

-- DATA


-- COINS
INSERT INTO Coin(
    name,
    price
) VALUES (
    'DraxBonus',
    1000
);
INSERT INTO Coin(
    name,
    price
) VALUES (
    'Drax',
    10
);


-- GAMES
INSERT INTO Game(
    name,
    parameters
) VALUES (
    'CoinFlip',
    '{"profit_coef":"1.98"}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Dice',
    '{"profit_coef":"1.94"}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Rocket',
    '{"profit_coef":"1.94"}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Crash',
    '{"profit_coef":"1.94"}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'RPS',
    '{"profit_coef":"1.98", "draw_coef":"0.99"}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Race',
    '{"profit_coef":"4.9", "cars_amount":5}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Thimbles',
    '{"profit_coef":"2.82", "cars_amount":3}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'CarRace',
    '{"profit_coef":"1.94", "cars_amount":2}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'StatefullTest',
    '{"multiplier":"1.98"}'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Wheel',
    '{"max_risk":2,
     "max_num_sectors":4,
     "multipliers": [
        [
            [
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0"
            ],
            [
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0"
            ],
            [   
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0"
            ],
            [
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0"
            ],
            [
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.5",
                "1.2",
                "1.2",
                "1.2",
                "0.0",
                "1.2",
                "1.2",
                "1.2",
                "1.2",
                "0.0"
            ]
        ],
        [
            [
                "0.0",
                "1.9",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0"
            ],
            [
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.8",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0"
            ],
            [
                "1.5",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0",
                "1.7",
                "0.0",
                "4.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0"
            ],
            [
                "2.0",
                "0.0",
                "3.0",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.5",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0",
                "1.6",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0"
            ],
            [
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.5",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "3.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0",
                "1.5",
                "0.0",
                "5.0",
                "0.0",
                "1.5",
                "0.0",
                "2.0",
                "0.0",
                "1.5",
                "0.0"
            ]
        ],
        [
            [
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "9.9"
            ],
            [
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "19.8"
            ],
            [
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "29.7"
            ],
            [
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "39.6"
            ],
            [
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "0.0",
                "49.5"
            ]
        ]
     ]
     }'
);




INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Mines',
    '{"max_reveal":[
        24, 21, 17, 14, 12, 10, 9, 8, 7, 6, 5, 5, 4, 4, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1 
    ],
    "multipliers":[["1.0312", "1.076", "1.125", "1.1785", "1.2375", "1.3026", "1.375", "1.4558", "1.5468", "1.65", "1.7678", "1.9038", "2.0625", "2.25", "2.475", "2.75", "3.0937", "3.5357", "4.125", "4.95", "6.1875", "8.25", "12.375", "24.75"], ["1.076", "1.1739", "1.2857", "1.4142", "1.5631", "1.7368", "1.9411", "2.1838", "2.475", "2.8285", "3.2637", "3.8076", "4.5", "5.4", "6.6", "8.25", "10.6071", "14.1428", "19.8", "29.7", "49.5", "99.0", "297.0"], ["1.125", "1.2857", "1.4785", "1.712", "1.9973", "2.3498", "2.7904", "3.3485", "4.066", "5.0043", "6.2554", "7.9615", "10.35", "13.8", "18.975", "27.1071", "40.6607", "65.0571", "113.85", "227.7", "569.2501", "2277.0031"], ["1.1785", "1.4142", "1.712", "2.0924", "2.5848", "3.231", "4.0926", "5.2619", "6.881", "9.1747", "12.5109", "17.5153", "25.3", "37.95", "59.6357", "99.3928", "178.9071", "357.8143", "834.9005", "2504.7058", "12523.5607"], ["1.2375", "1.5631", "1.9973", "2.5848", "3.3925", "4.5234", "6.1389", "8.5001", "12.0418", "17.5153", "26.273", "40.8692", "66.4125", "113.85", "208.725", "417.45", "939.2628", "2504.7058", "8766.4925", "52600.8182"], ["1.3026", "1.7368", "2.3498", "3.231", "4.5234", "6.462", "9.4445", "14.1668", "21.8942", "35.0307", "58.3846", "102.173", "189.75", "379.5", "834.9005", "2087.2513", "6261.7803", "25047.4383", "175345.3772"], ["1.375", "1.9411", "2.7904", "4.0926", "6.1389", "9.4445", "14.9539", "24.47", "41.599", "73.9538", "138.6634", "277.3269", "600.875", "1442.1017", "3965.79", "13219.3884", "59488.0423", "475961.5384"], ["1.4558", "2.1838", "3.3485", "5.2619", "8.5001", "14.1668", "24.47", "44.046", "83.198", "166.3961", "356.5632", "831.981", "2163.1542", "6489.4628", "23795.2169", "118976.0846", "1071428.5714"], ["1.5468", "2.475", "4.066", "6.881", "12.0418", "21.8942", "41.599", "83.198", "176.7959", "404.105", "1010.2628", "2828.7411", "9193.3956", "36774.2654", "202288.5165", "2024539.8773"], ["1.65", "2.8285", "5.0043", "9.1747", "17.5153", "35.0307", "73.9538", "166.3961", "404.105", "1077.6143", "3232.843", "11315.0616", "49031.7468", "294205.052", "3245901.6393"], ["1.7678", "3.2637", "6.2554", "12.5109", "26.273", "58.3846", "138.6634", "356.5632", "1010.2628", "3232.843", "12123.2901", "56577.8946", "367756.315", "4419642.8571"], ["1.9038", "3.8076", "7.9615", "17.5153", "40.8692", "102.173", "277.3269", "831.981", "2828.7411", "11315.0616", "56577.8946", "396158.4633", "5156250.0"], ["2.0625", "4.5", "10.35", "25.3", "66.4125", "189.75", "600.875", "2163.1542", "9193.3956", "49031.7468", "367756.315", "5156250.0"], ["2.25", "5.4", "13.8", "37.95", "113.85", "379.5", "1442.1017", "6489.4628", "36774.2654", "294205.052", "4419642.8571"], ["2.475", "6.6", "18.975", "59.6357", "208.725", "834.9005", "3965.79", "23795.2169", "202288.5165", "3245901.6393"], ["2.75", "8.25", "27.1071", "99.3928", "417.45", "2087.2513", "13219.3884", "118976.0846", "2024539.8773"], ["3.0937", "10.6071", "40.6607", "178.9071", "939.2628", "6261.7803", "59488.0423", "1071428.5714"], ["3.5357", "14.1428", "65.0571", "357.8143", "2504.7058", "25047.4383", "475961.5384"], ["4.125", "19.8", "113.85", "834.9005", "8766.4925", "175345.3772"], ["4.95", "29.7", "227.7", "2504.7058", "52600.8182"], ["6.1875", "49.5", "569.2501", "12523.5607"], ["8.25", "99.0", "2277.0031"], ["12.375", "297.0"], ["24.75"]] 
    }'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Poker',
    '{
        "initial_deck": [
   {
      "number":1,
      "suit":0
   },
   {
      "number":2,
      "suit":0
   },
   {
      "number":3,
      "suit":0
   },
   {
      "number":4,
      "suit":0
   },
   {
      "number":5,
      "suit":0
   },
   {
      "number":6,
      "suit":0
   },
   {
      "number":7,
      "suit":0
   },
   {
      "number":8,
      "suit":0
   },
   {
      "number":9,
      "suit":0
   },
   {
      "number":10,
      "suit":0
   },
   {
      "number":11,
      "suit":0
   },
   {
      "number":12,
      "suit":0
   },
   {
      "number":13,
      "suit":0
   },
   {
      "number":1,
      "suit":1
   },
   {
      "number":2,
      "suit":1
   },
   {
      "number":3,
      "suit":1
   },
   {
      "number":4,
      "suit":1
   },
   {
      "number":5,
      "suit":1
   },
   {
      "number":6,
      "suit":1
   },
   {
      "number":7,
      "suit":1
   },
   {
      "number":8,
      "suit":1
   },
   {
      "number":9,
      "suit":1
   },
   {
      "number":10,
      "suit":1
   },
   {
      "number":11,
      "suit":1
   },
   {
      "number":12,
      "suit":1
   },
   {
      "number":13,
      "suit":1
   },
   {
      "number":1,
      "suit":2
   },
   {
      "number":2,
      "suit":2
   },
   {
      "number":3,
      "suit":2
   },
   {
      "number":4,
      "suit":2
   },
   {
      "number":5,
      "suit":2
   },
   {
      "number":6,
      "suit":2
   },
   {
      "number":7,
      "suit":2
   },
   {
      "number":8,
      "suit":2
   },
   {
      "number":9,
      "suit":2
   },
   {
      "number":10,
      "suit":2
   },
   {
      "number":11,
      "suit":2
   },
   {
      "number":12,
      "suit":2
   },
   {
      "number":13,
      "suit":2
   },
   {
      "number":1,
      "suit":3
   },
   {
      "number":2,
      "suit":3
   },
   {
      "number":3,
      "suit":3
   },
   {
      "number":4,
      "suit":3
   },
   {
      "number":5,
      "suit":3
   },
   {
      "number":6,
      "suit":3
   },
   {
      "number":7,
      "suit":3
   },
   {
      "number":8,
      "suit":3
   },
   {
      "number":9,
      "suit":3
   },
   {
      "number":10,
      "suit":3
   },
   {
      "number":11,
      "suit":3
   },
   {
      "number":12,
      "suit":3
   },
   {
      "number":13,
      "suit":3
   }
],
    "multipliers": ["0.0","0.0","0.0","0.0","0.0","0.0","0.0","0.0","0.0","0.0"]
    }'
);


INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Plinko',
    '{"multipliers":[[["20.5", "4.0", "0.9", "0.6", "0.4", "0.6", "0.9", "4.0", "20.5"], ["45.0", "8.0", "0.9", "0.6", "0.4", "0.4", "0.6", "0.9", "8.0", "45.0"], ["47.0", "8.0", "2.0", "0.9", "0.6", "0.4", "0.6", "0.9", "2.0", "8.0", "47.0"], ["65.0", "17.0", "4.0", "0.9", "0.6", "0.4", "0.4", "0.6", "0.9", "4.0", "17.0", "65.0"], ["70.0", "16.0", "3.0", "2.0", "0.9", "0.6", "0.4", "0.6", "0.9", "2.0", "3.0", "16.0", "70.0"], ["80.0", "17.0", "6.0", "4.0", "0.9", "0.6", "0.4", "0.4", "0.6", "0.9", "4.0", "6.0", "17.0", "80.0"], ["100.0", "45.0", "9.0", "3.0", "1.1", "0.9", "0.6", "0.4", "0.6", "0.9", "1.1", "3.0", "9.0", "45.0", "100.0"], ["110.0", "45.0", "13.0", "9.0", "1.1", "0.9", "0.6", "0.4", "0.4", "0.6", "0.9", "1.1", "9.0", "13.0", "45.0", "110.0"], ["120.0", "28.0", "24.0", "8.0", "2.0", "0.9", "0.9", "0.6", "0.4", "0.6", "0.9", "0.9", "2.0", "8.0", "24.0", "28.0", "120.0"]], [["50.0", "4.0", "0.5", "0.4", "0.2", "0.4", "0.5", "4.0", "50.0"], ["66.0", "12.0", "0.5", "0.4", "0.2", "0.2", "0.4", "0.5", "12.0", "66.0"], ["95.0", "10.0", "2.0", "0.9", "0.4", "0.2", "0.4", "0.9", "2.0", "10.0", "95.0"], ["150.0", "20.0", "5.0", "0.6", "0.5", "0.2", "0.2", "0.5", "0.6", "5.0", "20.0", "150.0"], ["175.0", "35.0", "4.0", "2.0", "0.6", "0.4", "0.2", "0.4", "0.6", "2.0", "4.0", "35.0", "175.0"], ["250.0", "44.0", "7.0", "4.0", "0.9", "0.4", "0.2", "0.2", "0.4", "0.9", "4.0", "7.0", "44.0", "250.0"], ["390.0", "55.0", "15.0", "4.0", "0.9", "0.8", "0.4", "0.2", "0.4", "0.8", "0.9", "4.0", "15.0", "55.0", "390.0"], ["500.0", "60.0", "22.0", "8.0", "2.0", "0.9", "0.4", "0.2", "0.2", "0.4", "0.9", "2.0", "8.0", "22.0", "60.0", "500.0"], ["520.0", "80.0", "15.0", "10.0", "3.0", "2.0", "0.5", "0.3", "0.2", "0.3", "0.5", "2.0", "3.0", "10.0", "15.0", "80.0", "520.0"]], [["100.0", "0.6", "0.2", "0.2", "0.1", "0.2", "0.2", "0.6", "100.0"], ["143.0", "5.0", "0.7", "0.3", "0.1", "0.1", "0.3", "0.7", "5.0", "143.0"], ["170.0", "15.0", "2.0", "0.3", "0.2", "0.1", "0.2", "0.3", "2.0", "15.0", "170.0"], ["290.0", "15.0", "2.0", "0.8", "0.5", "0.3", "0.3", "0.5", "0.8", "2.0", "15.0", "290.0"], ["380.0", "20.0", "4.0", "2.0", "0.8", "0.3", "0.1", "0.3", "0.8", "2.0", "4.0", "20.0", "380.0"], ["500.0", "68.0", "7.0", "2.0", "0.9", "0.4", "0.2", "0.2", "0.4", "0.9", "2.0", "7.0", "68.0", "500.0"], ["770.0", "65.0", "13.0", "3.0", "2.0", "0.5", "0.3", "0.1", "0.3", "0.5", "2.0", "3.0", "13.0", "65.0", "770.0"], ["800.0", "200.0", "50.0", "5.0", "0.8", "0.5", "0.3", "0.1", "0.1", "0.3", "0.5", "0.8", "5.0", "50.0", "200.0", "800.0"], ["1000.0", "280.0", "30.0", "15.0", "1.5", "0.6", "0.5", "0.4", "0.1", "0.4", "0.5", "0.6", "1.5", "15.0", "30.0", "280.0", "1000.0"]]]}'
);



INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Apples',
    '{
        "difficulties": [
          {
            "mines": 1,
            "total_spaces": 4
          },
          {
            "mines": 1,
            "total_spaces": 3
          },
          {
            "mines": 1,
            "total_spaces": 2
          },
          {
            "mines": 2,
            "total_spaces": 3
          },
          {
            "mines": 3,
            "total_spaces": 4
          }
        ],
        "multipliers":[
          [
            "1.32",
            "1.76",
            "2.34",
            "3.12",
            "4.17",
            "5.56",
            "7.41",
            "9.88",
            "13.18"
          ],
          [
            "1.48",
            "2.22",
            "3.34",
            "5.01",
            "7.51",
            "11.27",
            "16.91",
            "25.37",
            "38.05"
          ],
          [
            "1.98",
            "3.96",
            "7.92",
            "15.84",
            "31.68",
            "63.36",
            "126.72",
            "253.44",
            "506.88"
          ],
          [
            "2.97",
            "8.91",
            "26.73",
            "80.19",
            "240.57",
            "721.71",
            "2165.13",
            "6495.39",
            "19486.17"
          ],
          [
            "3.96",
            "15.84",
            "63.36",
            "253.44",
            "1013.76",
            "4055.04",
            "16220.16",
            "64880.64",
            "259522.56"
          ]
        ]
    }'
);



INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Slots',
    '{
        "num_outcomes": 343,
        "multipliers": ["5", "3", "3", "3", "3", "3", "3", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "10", "0", "0", "10", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "12", "0", "12", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "20", "20", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "45", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "100"] 
    }'
);


INSERT INTO Game(
    name,
    parameters
) VALUES (
    'Roulette',
    '{
        "zero_coef":"52",
        "num_coef":"34.8148",
        "num2_coef":"17.3752",
        "num4_coef":"8.6957",
        "num12_coef":"2.8986",
        "num18_coef":"1.9322"
    }'
);

INSERT INTO Game(
    name,
    parameters
) VALUES (
    'BigSlots',
    '
{
        "tiles": [
                {
                        "8": "0.25",
                        "9": "0.25",
                        "10": "0.75",
                        "11": "0.75",
                        "12": "2",
                        "13": "2",
                        "14": "2",
                        "15": "2",
                        "16": "2",
                        "17": "2",
                        "18": "2",
                        "19": "2",
                        "20": "2",
                        "21": "2",
                        "22": "2",
                        "23": "2",
                        "24": "2",
                        "25": "2",
                        "26": "2",
                        "27": "2",
                        "28": "2",
                        "29": "2",
                        "30": "2"
                },
                {
                        "8": "0.40",
                        "9": "0.40",
                        "10": "0.90",
                        "11": "0.90",
                        "12": "4",
                        "13": "4",
                        "14": "4",
                        "15": "4",
                        "16": "4",
                        "17": "4",
                        "18": "4",
                        "19": "4",
                        "20": "4",
                        "21": "4",
                        "22": "4",
                        "23": "4",
                        "24": "4",
                        "25": "4",
                        "26": "4",
                        "27": "4",
                        "28": "4",
                        "29": "4",
                        "30": "4"
                },
                {
                        "8": "0.50",
                        "9": "0.50",
                        "10": "1",
                        "11": "1",
                        "12": "5",
                        "13": "5",
                        "14": "5",
                        "15": "5",
                        "16": "5",
                        "17": "5",
                        "18": "5",
                        "19": "5",
                        "20": "5",
                        "21": "5",
                        "22": "5",
                        "23": "5",
                        "24": "5",
                        "25": "5",
                        "26": "5",
                        "27": "5",
                        "28": "5",
                        "29": "5",
                        "30": "5"
                },
                {
                        "8": "0.80",
                        "9": "0.80",
                        "10": "1.20",
                        "11": "1.20",
                        "12": "8",
                        "13": "8",
                        "14": "8",
                        "15": "8",
                        "16": "8",
                        "17": "8",
                        "18": "8",
                        "19": "8",
                        "20": "8",
                        "21": "8",
                        "22": "8",
                        "23": "8",
                        "24": "8",
                        "25": "8",
                        "26": "8",
                        "27": "8",
                        "28": "8",
                        "29": "8",
                        "30": "8"
                },
                {
                        "8": "1",
                        "9": "1",
                        "10": "1.50",
                        "11": "1.50",
                        "12": "10",
                        "13": "10",
                        "14": "10",
                        "15": "10",
                        "16": "10",
                        "17": "10",
                        "18": "10",
                        "19": "10",
                        "20": "10",
                        "21": "10",
                        "22": "10",
                        "23": "10",
                        "24": "10",
                        "25": "10",
                        "26": "10",
                        "27": "10",
                        "28": "10",
                        "29": "10",
                        "30": "10"
                },
                {
                        "8": "1.5",
                        "9": "1.5",
                        "10": "2",
                        "11": "2",
                        "12": "12",
                        "13": "12",
                        "14": "12",
                        "15": "12",
                        "16": "12",
                        "17": "12",
                        "18": "12",
                        "19": "12",
                        "20": "12",
                        "21": "12",
                        "22": "12",
                        "23": "12",
                        "24": "12",
                        "25": "12",
                        "26": "12",
                        "27": "12",
                        "28": "12",
                        "29": "12",
                        "30": "12"
                },
                {
                        "8": "2",
                        "9": "2",
                        "10": "5",
                        "11": "5",
                        "12": "15",
                        "13": "15",
                        "14": "15",
                        "15": "15",
                        "16": "15",
                        "17": "15",
                        "18": "15",
                        "19": "15",
                        "20": "15",
                        "21": "15",
                        "22": "15",
                        "23": "15",
                        "24": "15",
                        "25": "15",
                        "26": "15",
                        "27": "15",
                        "28": "15",
                        "29": "15",
                        "30": "15"
                },
                {
                        "8": "2.5",
                        "9": "2.5",
                        "10": "10",
                        "11": "10",
                        "12": "25",
                        "13": "25",
                        "14": "25",
                        "15": "25",
                        "16": "25",
                        "17": "25",
                        "18": "25",
                        "19": "25",
                        "20": "25",
                        "21": "25",
                        "22": "25",
                        "23": "25",
                        "24": "25",
                        "25": "25",
                        "26": "25",
                        "27": "25",
                        "28": "25",
                        "29": "25",
                        "30": "25"
                },
                {
                        "8": "10",
                        "9": "10",
                        "10": "25",
                        "11": "25",
                        "12": "50",
                        "13": "50",
                        "14": "50",
                        "15": "50",
                        "16": "50",
                        "17": "50",
                        "18": "50",
                        "19": "50",
                        "20": "50",
                        "21": "50",
                        "22": "50",
                        "23": "50",
                        "24": "50",
                        "25": "50",
                        "26": "50",
                        "27": "50",
                        "28": "50",
                        "29": "50",
                        "30": "50"
                },
                {
                        "4": "3",
                        "5": "5",
                        "6": "100",
                        "11": "100",
                        "12": "100",
                        "13": "100",
                        "14": "100",
                        "15": "100",
                        "16": "100",
                        "17": "100",
                        "18": "100",
                        "19": "100",
                        "20": "100",
                        "21": "100",
                        "22": "100",
                        "23": "100",
                        "24": "100",
                        "25": "100",
                        "26": "100",
                        "27": "100",
                        "28": "100",
                        "29": "100",
                        "30": "100"
                }
        ],
        "multipliers": [
                "2",
                "8",
                "15",
                "25",
                "100"
        ],
        "multiplier_chance": 10,
        "free_spins_prices": {
                "1": 200000,
                "2": 200
        },
        "free_spins_reward_amount": 15
}
    '
);
