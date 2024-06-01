package service

import "github.com/GreekKeepers/golangBackend/internal/repo"

type Service struct {
	Auth
}

func New(r *repo.Repo) *Service {
	return &Service{
		Auth: NewAuth(r.Auth),
	}
}

type (
	Auth interface {
		ValidateToken(tokenString string) error
	}
)
