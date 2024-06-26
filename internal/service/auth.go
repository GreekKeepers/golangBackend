package service

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

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
	tokenParts := strings.Split(tokenString, ".")
	if len(tokenParts) != 3 {
		return fmt.Errorf("invalid token parts")
	}
	payloadBase64 := tokenParts[1]
	payloadBytes, err := base64.RawURLEncoding.DecodeString(payloadBase64)
	if err != nil {
		return fmt.Errorf("failed to decode payload: %w", err)
	}

	var payload map[string]interface{}
	err = json.Unmarshal(payloadBytes, &payload)
	if err != nil {
		return fmt.Errorf("failed to unmarshal payload: %w", err)
	}

	iat, ok := payload["iat"].(float64)
	if !ok {
		return fmt.Errorf("missing or invalid iat")
	}

	userID, ok := payload["sub"].(float64)
	if !ok {
		return fmt.Errorf("missing or invalid sub (userID)")
	}

	hashedPassword, err := s.r.GetHashedPassword(int64(userID))
	if err != nil {
		return fmt.Errorf("failed to get hashed password: %w", err)
	}

	salt, err := s.r.GetSeed(int64(userID))
	if err != nil {
		return fmt.Errorf("failed to get salt: %w", err)
	}

	key := fmt.Sprintf("%s%s%d", salt, hashedPassword, int64(iat))
	hash := hmac.New(sha256.New, []byte(key))
	key = hex.EncodeToString(hash.Sum(nil))

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return key, nil
	})
	if err != nil {
		return err
	}

	_, ok = token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return errors.New("invalid token")
	}

	return nil
}
