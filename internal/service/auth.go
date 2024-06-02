package service

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"

	"github.com/GreekKeepers/golangBackend/internal/repo"
	"github.com/golang-jwt/jwt/v5"
)

type AuthService struct {
	r repo.Auth
}

func NewAuth(r repo.Auth) *AuthService {
	return &AuthService{r: r}
}

func (s *AuthService) ValidateToken(tokenString string) error {
	token, err := jwt.ParseWithClaims(tokenString, &jwt.MapClaims{}, func(token *jwt.Token) (interface{}, error) {
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			return nil, errors.New("invalid claims")
		}

		userID, ok := claims["sub"].(int64)
		if !ok {
			return nil, errors.New("invalid user id")
		}
		fmt.Println("userID", userID)

		iat, ok := claims["iat"].(float64)
		if !ok {
			return nil, errors.New("invalid iat")
		}
		fmt.Println("iat", iat)

		hashedPassword, err := s.r.GetHashedPassword(userID)
		if err != nil {
			return nil, err
		}
		fmt.Println("hashedPassword", hashedPassword)

		salt, err := s.r.GetSeed(userID)
		if err != nil {
			return nil, err
		}

		key := fmt.Sprintf("%s%s%d", salt, hashedPassword, int64(iat))
		hash := hmac.New(sha256.New, []byte(key))
		key = hex.EncodeToString(hash.Sum(nil))
		fmt.Println("key", key)

		return []byte(key), nil
	})

	if err != nil {
		return err
	}

	_, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return errors.New("invalid token")
	}

	return nil
}
