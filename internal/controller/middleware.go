package controller

import (
	"net/http"

	"github.com/GreekKeepers/golangBackend/internal/service"
	"github.com/GreekKeepers/golangBackend/logger"
	"github.com/gin-gonic/gin"
)

func authMiddleware(l logger.Logger, auth service.Auth) gin.HandlerFunc {
	l.Info("authMiddleware")
	return func(c *gin.Context) {
		tokenString := extractTokenFromRequest(c)
		if tokenString == "" {
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}

		err := auth.ValidateToken(tokenString)
		if err != nil {
			l.Error(err)
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}

		c.Next()
	}
}
