CREATE TABLE IF NOT EXISTS Users(
    id BIGSERIAL PRIMARY KEY,
    registration_time TIMESTAMP DEFAULT NOW(),

    login TEXT NOT NULL UNIQUE,
    username TEXT NOT NULL,
    password char(128) NOT NULL,
    -- provider oauth_provider DEFAULT 'local',
    user_level BIGINT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS UserSeed(
    id BIGSERIAL PRIMARY KEY,
    --relative_id BIGINT NOT NULL,
    user_id BIGSERIAL NOT NULL REFERENCES Users(id) ON DELETE CASCADE,

    user_seed char(64) NOT NULL
);

CREATE UNIQUE INDEX user_seed_unique_idx ON UserSeed(user_id, user_seed);

Insert into users(login, username, password, user_level) values('login', 'username', '3db4f54bdf7e2dc901d05b4a05c460f007aed5d7f362ea0873b2b5ab2daf5d2e5ef88dd16d41354cc6da40dc5e1a511f26849e585d9b5fb60e5f3a271af6739d', 1);
