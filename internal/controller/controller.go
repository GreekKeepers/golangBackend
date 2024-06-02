package controller

import (
	"github.com/GreekKeepers/golangBackend/internal/service"
	"github.com/GreekKeepers/golangBackend/logger"
	"github.com/gin-gonic/gin"
)

func New(handler *gin.Engine, l logger.Logger, services *service.Service) {
	handler.Use(gin.Logger())
	handler.Use(gin.Recovery())

	h := handler.Group("/")
	h.Use(authMiddleware(l, services.Auth))
	{
		h.GET("/", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "Hello World",
			})
		})
	}
}
