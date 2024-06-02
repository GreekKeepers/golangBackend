package app

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/GreekKeepers/golangBackend/config"
	"github.com/GreekKeepers/golangBackend/httpserver"
	"github.com/GreekKeepers/golangBackend/internal/controller"
	"github.com/GreekKeepers/golangBackend/internal/repo"
	"github.com/GreekKeepers/golangBackend/internal/service"
	"github.com/GreekKeepers/golangBackend/logger"
	"github.com/GreekKeepers/golangBackend/postgres"
	"github.com/gin-gonic/gin"
)

func Run(cfg *config.Config) {
	l := logger.NewZerolog(cfg.Log.Level)

	pg, err := postgres.New(cfg.PG.URL)
	if err != nil {
		l.Fatal("failed to connect to postgres", err)
	}
	defer pg.Close()

	repos := repo.New(pg)

	services := service.New(repos)

	handler := gin.New()
	controller.New(handler, l, services)

	httpServer := httpserver.New(handler, httpserver.Port(cfg.HTTP.Port))

	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM)

	select {
	case s := <-interrupt:
		l.Info("app - Run - received signal: " + s.String())
	case err = <-httpServer.Notify():
		l.Error(fmt.Errorf("app - Run - httpServer.Notify: %w", err))
	}

	err = httpServer.Shutdown()
	if err != nil {
		l.Error(fmt.Errorf("app - Run - httpServer.Shutdown: %w", err))
	}
}
