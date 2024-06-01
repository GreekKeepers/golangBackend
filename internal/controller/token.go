package controller

import (
	"strings"

	"github.com/gin-gonic/gin"
)

func extractTokenFromRequest(r *gin.Context) string {
	authHeader := r.GetHeader("Authorization")
	if authHeader == "" {
		return ""
	}

	return strings.Split(authHeader, " ")[1]
}
