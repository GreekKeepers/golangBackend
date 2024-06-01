package repo

import "github.com/GreekKeepers/golangBackend/postgres"

type Repo struct {
	Auth
}

func New(pg *postgres.Postgres) *Repo {
	return &Repo{}
}

// repo interfaces
type (
	Auth interface {
		GetHashedPassword(id int64) (string, error)
		GetSeed(id int64) (string, error)
	}
)
