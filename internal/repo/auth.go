package repo

import (
	"github.com/GreekKeepers/golangBackend/postgres"
	"gorm.io/gorm"
)

type AuthRepo struct {
	db *gorm.DB
}

func NewAuthRepo(pg *postgres.Postgres) *AuthRepo {
	return &AuthRepo{db: pg.DB}
}

func (r *AuthRepo) GetHashedPassword(id int64) (string, error) {
	var password string
	err := r.db.Table("Users").Select("password").Where("id = ?", id).Row().Scan(&password)
	return password, err
}

func (r *AuthRepo) GetSeed(id int64) (string, error) {
	var seed string
	err := r.db.Table("UserSeed").Select("user_seed").Where("id = ?", id).Row().Scan(&seed)
	return seed, err
}
