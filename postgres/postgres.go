package postgres

import (
	gpg "gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Postgres struct {
	DB *gorm.DB
}

func New(dsn string) (*Postgres, error) {
	db, err := gorm.Open(gpg.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	return &Postgres{
		DB: db,
	}, nil
}

func (p *Postgres) Close() {
}
